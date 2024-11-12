import 'package:firebase_auth/firebase_auth.dart';
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

  // Function to log out the user
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Log out from Firebase and Google
    Navigator.pushReplacementNamed(context, '/home'); // Redirect to login page
  }

  @override
  void initState() {
    super.initState();
    _listenToVibrationData();   // Mendengarkan `vib_value` untuk menambah `vib_total`.
    _fetchVibrationTotalData(); // Menampilkan data `vib_total` di grafik.
    _resetIfNewMonth(); 
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

void _listenToVibrationData() {
  _database.child('deviceId/monitor/vib_value').onValue.listen((DatabaseEvent event) {
    final dataSnapshot = event.snapshot;
    if (dataSnapshot.value != null) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(dataSnapshot.value as Map);

      // Tambahkan jumlah getaran ke Firebase di `vib_total` jika `vib_value` adalah 1
      data.forEach((sensor, value) {
        if (value == 1) {
          _database.child('deviceId/monitor/vib_total/$sensor').once().then((DatabaseEvent totalEvent) {
            final currentTotal = (totalEvent.snapshot.value ?? 0) as int;
            _database.child('deviceId/monitor/vib_total/$sensor').set(currentTotal + 1);
          });
        }
      });
    }
  });
}

void _fetchVibrationTotalData() {
  _database.child('deviceId/monitor/vib_total').onValue.listen((DatabaseEvent event) {
    final dataSnapshot = event.snapshot;
    if (dataSnapshot.value != null) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(dataSnapshot.value as Map);

      setState(() {
        _chartData = data.entries.map((entry) => ChartData(entry.key, entry.value.toDouble())).toList();
        _isLoading = false;
      });
    } else {
      setState(() {
        _isLoading = false;
      });
    }
  });
}

void _resetIfNewMonth() {
  final currentMonth = DateTime.now().month;
  _database.child('deviceId/monitor/last_reset_month').once().then((DatabaseEvent event) {
    final lastMonth = event.snapshot.value ?? currentMonth;

    if (lastMonth != currentMonth) {
      // Reset total getaran untuk semua sensor
      _database.child('deviceId/monitor/vib_total').set({
        'S1': 0,
        'S2': 0,
        'S3': 0,
        'S4': 0,
      });

      // Simpan bulan reset terakhir di Firebase
      _database.child('deviceId/monitor/last_reset_month').set(currentMonth);
    }
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
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 357,
                    padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Color.fromRGBO(97, 15, 28, 1.0),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center( // Menambahkan widget Center agar teks berada di tengah
                      child: Text(
                        dateRange,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Container untuk Graph/Chart dengan border merah
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Color.fromRGBO(97, 15, 28, 1.0), width: 2), // Border merah
                  borderRadius: BorderRadius.circular(12),
                ),
                child: _isLoading 
                  ? Center(child: CircularProgressIndicator()) 
                  : buildVibrationChart(_chartData),
              ),
              SizedBox(height: 20),

              // Label untuk data masing-masing sensor
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart,
                   color: Color.fromRGBO(97, 15, 28, 1.0),
                   ),
                  SizedBox(width: 5),
                  Text(
                    'Data Masing-Masing Sensor',
                    style: TextStyle(fontSize: 18, color: Color.fromRGBO(97, 15, 28, 1.0)),
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
        backgroundColor: const Color.fromRGBO(97, 15, 28, 1.0),
        items: [
          BottomNavigationBarItem(
            icon: GestureDetector(
              onTap: () => _logout(context), // Call logout function
              child: Icon(Icons.logout, color: Colors.white),
            ),
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
        currentIndex: 2, // Profile tab selected by default
        onTap: (index) {
          switch (index) {
            case 0:
              _logout(context); // Logout if logout icon is tapped
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
