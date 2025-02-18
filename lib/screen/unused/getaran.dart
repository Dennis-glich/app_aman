//getaran.dart 
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_database/firebase_database.dart';
import 'bar.dart';

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
    _fetchVibrationTotalData(); // Menampilkan data `vib_total` di grafik.
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

void _updateSwitch(String switchType, bool isOn) {
  int value = isOn ? 1 : 0;

  // Tentukan path berdasarkan tipe switch
  String path;
  switch (switchType) {
    case 'switch buzzer':
      path = 'switch_buzzer';
      break;
    default:
      throw ArgumentError('Switch type tidak valid: $switchType');
  }

  // Update nilai di Firebase
  _database.child('deviceId/control/$path').set(value);
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

  Widget buildControlCard(String title, bool isOn, String switchType) {
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
                // Perbarui nilai switch di Firebase
              _updateSwitch(switchType, value);

              // Perbarui status switch lokal
              switch (switchType) {
                case 'switch buzzer':
                  isBuzzerOn = value; // Update untuk buzzer
                  break;
                default:
                  throw ArgumentError('Switch type tidak valid: $switchType');
              }
            });
          },
        ),
      ),
    );
  }
}