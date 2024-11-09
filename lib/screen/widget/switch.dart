import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:app_aman/screen/widget/gauge.dart';
import 'package:app_aman/screen/preofilteam.dart';
import 'package:app_aman/screen/getaran.dart';
import 'package:app_aman/screen/profil.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  bool isBuzzerOn = false;
  bool isDoorOpen = false;
  bool isExhaustFanOn = false;
  double gasLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _initializeData();
  }

  // Fungsi untuk inisialisasi data dari Firebase
  void _initializeData() {
    _database.child('deviceId/control').once().then((DatabaseEvent event) {
      final data = event.snapshot.value as Map;
      setState(() {
        isBuzzerOn = data['switch buzzer'] == 1;
        isDoorOpen = data['switch pintu'] == 1;
        isExhaustFanOn = data['switch exhaust fan'] == 1;
      });
    });

    _database.child('deviceId/monitor/value gas').onValue.listen((DatabaseEvent event) {
      final value = event.snapshot.value;
      setState(() {
        gasLevel = value != null ? double.parse(value.toString()) : 0.0;
      });
    });
  }

  // Fungsi untuk memperbarui status switch ke Firebase
  void _updateSwitch(String switchName, bool isOn) {
    int value = isOn ? 1 : 0;
    _database.child('deviceId/control/$switchName').set(value);
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = "${now.day}-${now.month}-${now.year}";

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu, size: 32),
          onPressed: () {
            scaffoldKey.currentState?.openDrawer();
          },
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Image.asset(
              'assets/Aman .PNG',
              width: 45,
              height: 45,
            ),
          ),
        ],
      ),
      drawer: Drawer(
        width: 250,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.red[300],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/Aman .PNG',
                    width: 45,
                    height: 45,
                  ),
                  SizedBox(height: 10),
                  Text(
                    'AMAN',
                    style: TextStyle(
                      fontSize: 24,
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ProfilePage()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Team Profile'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => TeamProfilePage()),
                );
              },
            ),
          ],
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset(
              'assets/bg gas.jpg',
              fit: BoxFit.cover,
              alignment: Alignment.center,
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 10),
                    Text(
                      'Hi, User',
                      style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Welcome to AMAN',
                      style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                    ),
                    SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 350,
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Colors.red[300],
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Today, $formattedDate',
                              style: TextStyle(fontSize: 16),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: buildControlCard('Buzzer', isBuzzerOn, 'switch buzzer'),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: buildControlCard('Pintu', isDoorOpen, 'switch pintu'),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        buildControlCard('Exhaust Fan', isExhaustFanOn, 'switch exhaust fan'),
                        SizedBox(height: 100),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: buildSensorCardWithGauge('Gas & Asap', gasLevel), // Gauge for gas level
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: buildGetaranCard(context), // Getaran card
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.red[300],
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text('Status', style: TextStyle(fontSize: 18, color: Colors.white)),
                              Icon(Icons.settings, color: Colors.white, size: 24),
                            ],
                          ),
                          SizedBox(height: 10),
                          Container(
                            height: 100,
                            child: Image.asset(
                              'assets/Vector.png',
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            'Aman',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
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
              // Tetap di halaman Dashboard
              break;
            case 2:
              Navigator.pushNamed(context, '/profil');
              break;
          }
        },
      ),
    );
  }

  // Modified buildControlCard to handle Firebase updates
  Widget buildControlCard(String title, bool isActive, String switchName) {
    return Container(
      height: 80,
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey[200],
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(title, style: TextStyle(fontSize: 16)),
          Switch(
            value: isActive,
            onChanged: (value) {
              setState(() {
                if (switchName == 'switch buzzer') {
                  isBuzzerOn = value;
                } else if (switchName == 'switch pintu') {
                  isDoorOpen = value;
                } else if (switchName == 'switch exhaust fan') {
                  isExhaustFanOn = value;
                }
                _updateSwitch(switchName, value);
              });
            },
          ),
        ],
      ),
    );
  }
   Widget buildGetaranCard(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => GetaranMonitoring()),
        );
      },
      child: Container(
        height: 200,
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Getaran', style: TextStyle(fontSize: 16)),
                Icon(Icons.sensors),
              ],
            ),
            Expanded(
              child: Container(
                width: double.infinity,
                child: ClipRRect(
                  borderRadius: BorderRadius.vertical(bottom: Radius.circular(12)),
                  child: Image.asset(
                    'assets/chart_line.png',
                    fit: BoxFit.fill,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
