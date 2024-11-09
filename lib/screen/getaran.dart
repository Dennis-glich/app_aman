import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'widget/bar.dart'; // Assuming 'buildVibrationChart' is defined in 'widget/bar.dart'

class GetaranMonitoring extends StatefulWidget {
  @override
  _GetaranMonitoringState createState() => _GetaranMonitoringState();
}

class _GetaranMonitoringState extends State<GetaranMonitoring> {

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  List<ChartData> _chartData = [];
  bool _isLoading = true;
  bool isBuzzerOn = false; // Add state for the buzzer switch

  @override
  void initState() {
    super.initState();
    _fetchVibrationData(); // Fetch vibration data when the page is loaded
    _initializeData(); // Listen to buzzer state changes from Firebase
  }

    // Function to initialize data from Firebase (for control switches and gas level)
  void _initializeData() {
    _database.child('deviceId/control').once().then((DatabaseEvent event) {
      final data = event.snapshot.value as Map;
      setState(() {
        isBuzzerOn = data['switch buzzer'] == 1;
      });
    });
  }

void _fetchVibrationData() {
  List<String> sensorKeys = ['S1', 'S2', 'S3', 'S4'];
  List<ChartData> fetchedData = [];

  // Loop through each sensor path to get data individually
  Future.wait(sensorKeys.map((sensor) {
    return _database.child('deviceId/monitor/vib_value/$sensor').once().then((DatabaseEvent event) {
      final data = event.snapshot.value;
      
      // Check if data is int or double, otherwise set default to 0
      double value = (data is int) ? data.toDouble() : (data is double ? data : 0.0);
      
      fetchedData.add(ChartData(sensor, value));
    });
  })).then((_) {
    setState(() {
      _chartData = fetchedData;
      _isLoading = false;
    });
  }).catchError((error) {
    setState(() {
      _isLoading = false;
    });
    print('Error fetching vibration data: $error');
  });
}

  // Function to update switch status in Firebase
  void _updateSwitch(String switchName, bool isOn) {
    int value = isOn ? 1 : 0;
    _database.child('deviceId/control/$switchName').set(value);
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final dateRange = '${DateFormat.d().format(firstDayOfMonth)} ${DateFormat.MMMM().format(firstDayOfMonth)} - ${DateFormat.d().format(lastDayOfMonth)} ${DateFormat.MMMM().format(lastDayOfMonth)} ${now.year}';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Monitoring Getaran'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg gas.jpg'), // Set background image
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView( // Make the content scrollable
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: kToolbarHeight + 20),
              // Tanggal dengan border dan background
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red[300],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent, width: 1),
                ),
                child: Text(
                  dateRange,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              SizedBox(height: 30),

              // Container untuk Graph/Chart dengan border merah
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red[300]!, width: 2), // Border merah
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isLoading 
                  ? Center(child: CircularProgressIndicator()) 
                  : buildVibrationChart(_chartData), // Pass the chartData here
              ),
              SizedBox(height: 20),

              // Label untuk data masing-masing sensor
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, color: Colors.red[300]),
                  SizedBox(width: 5),
                  Text(
                    'Data Masing-Masing Sensor',
                    style: TextStyle(fontSize: 18, color: Colors.red[300]),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Vibration Cards untuk masing-masing sensor
              Row(
                children: [
                  Expanded(
                    child: _buildVibrationCard('Vibrasi 1', _chartData.isNotEmpty ? '${_chartData[0].value.toInt()} Kali' : 'N/A'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildVibrationCard('Vibrasi 2', _chartData.isNotEmpty ? '${_chartData[1].value.toInt()} Kali' : 'N/A'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildVibrationCard('Vibrasi 3', _chartData.isNotEmpty ? '${_chartData[2].value.toInt()} Kali' : 'N/A'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildVibrationCard('Vibrasi 4', _chartData.isNotEmpty ? '${_chartData[3].value.toInt()} Kali' : 'N/A'),
                  ),
                ],
              ),
              SizedBox(height: 20),

                // Switch Buzzer
                Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: buildControlCard('Buzzer', isBuzzerOn, 'switch buzzer'),
                  ),
                  SizedBox(width: 5),
                ],
              )
            ],
          ),
        ),
      ),
      // Bottom Navigation Bar
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.red[300],
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, color: Colors.white),
            label: '',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.white),
            label: '',
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: 1, // Dashboard tab selected by default
        onTap: (index) {
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/dashboard');
              break;
            case 2:
              Navigator.pushNamed(context, '/profil');
              break;
          }
        },
      ),
    );
  }

  // Fungsi pembantu untuk membuat kartu getaran
  Widget _buildVibrationCard(String title, String count) {
    return Card(
      color: Colors.red.shade100,
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }

Widget buildControlCard(String title, bool isOn, String switchName) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: ListTile(
        title: Text(title),
        subtitle: Text(isOn ? 'On' : 'Off'),
        trailing: Switch(
          value: isOn,
          onChanged: (value) {
            setState(() {
              _updateSwitch(switchName, value);
              if (switchName == 'switch buzzer') isBuzzerOn = value;
            });
          },
        ),
      ),
    );
  }

}
