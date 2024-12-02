import 'package:app_aman/screen/widget/line.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class GetaranMonitoring extends StatefulWidget {
  @override
  _GetaranMonitoringState createState() => _GetaranMonitoringState();
}

class _GetaranMonitoringState extends State<GetaranMonitoring> {
  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final String spreadsheetId = '1k5xMMhA5_t75juJYjNpWNzxGE_lJrA8hL5Zn2De-nwc';
  final String range = 'History!A:E';
  final String apiKey = 'AIzaSyCsvyziDI4jFMmuQP5e3_6Yjf5h3s9hsBs';

  List<String> vibrationData = ['N/A', 'N/A', 'N/A', 'N/A'];
  bool isBuzzerOn = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    fetchDataFromGoogleSheets();
  }

    Future<void> fetchDataFromGoogleSheets() async {
    try {
      final response = await http.get(
        Uri.parse(
          'https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values/$range?key=$apiKey',
        ),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final rows = data['values'];

        if (rows != null && rows.length > 1) {
          // Get the last row of the spreadsheet
          final lastRow = rows.last;
          setState(() {
            vibrationData = [
              lastRow[1] ?? 'N/A', // Vibrasi 1 (Kolom B)
              lastRow[2] ?? 'N/A', // Vibrasi 2 (Kolom C)
              lastRow[3] ?? 'N/A', // Vibrasi 3 (Kolom D)
              lastRow[4] ?? 'N/A', // Vibrasi 4 (Kolom E)
            ];
          });
        } else {
          print('No data found.');
        }
      } else {
        print('Failed to load data from Google Sheets. Status: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching data: $e');
    }
  }

  Future<void> _launchURL(String url) async {
  final Uri uri = Uri.parse(url); // Parse string URL ke dalam objek Uri

  if (await canLaunchUrl(uri)) {
    await launchUrl(
      uri,
      mode: LaunchMode.externalApplication, // Membuka dengan aplikasi eksternal (browser)
    );
  } else {
    throw 'Could not launch $url';
  }
}


  void _initializeData() {
    _database.child('deviceId/control').once().then((DatabaseEvent event) {
      final data = event.snapshot.value as Map;
      setState(() {
        isBuzzerOn = data['switch buzzer'] == 1;
      });
    });
  }

  // Function to log out the user
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Log out from Firebase and Google
    Navigator.pushReplacementNamed(context, '/welcome'); // Redirect to login page
  }

  void _updateSwitch(String switchType, bool isOn) {
    int value = isOn ? 1 : 0;
    String path = switchType == 'switch buzzer' ? 'switch_buzzer' : '';
    _database.child('deviceId/control/$path').set(value);
  }

   Widget _buildVibrationCard(String title, String value) {
    return Card(
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            SizedBox(height: 3),
            Text(value, style: TextStyle(fontSize: 16)),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final dateRange =
        '${DateFormat.d().format(firstDayOfMonth)} ${DateFormat.MMMM().format(firstDayOfMonth)} - ${DateFormat.d().format(lastDayOfMonth)} ${DateFormat.MMMM().format(lastDayOfMonth)} ${now.year}';

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
            image: AssetImage('assets/bg gas.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: kToolbarHeight + 20),
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
                    child: Center(
                      child: Text(
                        dateRange,
                        style: TextStyle(fontSize: 20, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Line Chart Integration
              Container(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width * 0.9, // Maksimal 90% lebar layar
                  maxHeight: 265, // Batas tinggi maksimal
                ),
                child: VibrationChartPage(), // Use the Line Chart widget
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
              SizedBox(height: 10),

              // Vibration Cards
              Row(
                children: [
                  Expanded(
                    child: _buildVibrationCard('Vib 1 (Merah)', '${vibrationData[0]} Kali'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildVibrationCard('Vib 2 (Kuning)', '${vibrationData[1]} Kali'),
                  ),
                ],
              ),
              SizedBox(height: 5),
              Row(
                children: [
                  Expanded(
                    child: _buildVibrationCard('Vib 3 (Hijau)', '${vibrationData[2]} Kali'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildVibrationCard('Vib 4 (Biru)', '${vibrationData[3]} Kali'),
                  ),
                ],
              ),
              SizedBox(height: 5),
               GestureDetector(
                  onTap: () => _launchURL('https://docs.google.com/spreadsheets/d/1k5xMMhA5_t75juJYjNpWNzxGE_lJrA8hL5Zn2De-nwc/edit?usp=sharing'),
                  child: Text(
                    'Klik di sini untuk informasi lebih lanjut',
                    style: TextStyle(
                      fontSize: 16,
                      color: Colors.blue,
                      decoration: TextDecoration.underline,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: buildControlCard('Buzzer', isBuzzerOn, 'switch buzzer'),
                  ),
                ],
              ),
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
            label: 'Logout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.dashboard, color: Colors.white),
            label: 'Dashboard',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person, color: Colors.white),
            label: 'Profile',
          ),
        ],
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        currentIndex: 1, // Profile tab selected by default
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
              _updateSwitch(switchType, value);
              isBuzzerOn = value;
            });
          },
        ),
      ),
    );
  }
}
