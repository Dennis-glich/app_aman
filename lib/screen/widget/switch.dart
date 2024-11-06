import 'package:flutter/material.dart';
import 'package:app_aman/screen/preofilteam.dart';
import 'package:app_aman/screen/profil.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  bool isLoading = true;
  String? uid;
  bool? buzzerStatus;
  bool? doorStatus;
  bool? exhaustFanStatus;

  @override
  void initState() {
    super.initState();
    uid = FirebaseAuth.instance.currentUser?.uid;
    fetchDeviceStatus();
  }

  Future<void> fetchDeviceStatus() async {
    if (uid != null) {
      DatabaseReference userRef = FirebaseDatabase.instance.ref().child('users/$uid/devices');

      userRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;
        if (data != null) {
          setState(() {
            buzzerStatus = data['buzzer'] as bool?;
            doorStatus = data['door'] as bool?;
            exhaustFanStatus = data['exhaustFan'] as bool?;
            isLoading = false;
          });
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = "${now.day}-${now.month}-${now.year}";

    if (isLoading) {
      return Center(child: CircularProgressIndicator());
    }

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
      drawer: buildDrawer(context),
      body: buildBody(formattedDate),
      bottomNavigationBar: buildBottomNavigationBar(context),
    );
  }

  Drawer buildDrawer(BuildContext context) {
    return Drawer(
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
    );
  }

  Widget buildBody(String formattedDate) {
    return SafeArea(
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(height: 20),
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
                        child: buildControlCard('Buzzer', buzzerStatus ?? false),
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: buildControlCard('Pintu', doorStatus ?? false),
                      ),
                    ],
                  ),
                  SizedBox(height: 10),
                  buildControlCard('Exhaust Fan', exhaustFanStatus ?? false),
                  SizedBox(height: 20),
                  // Additional content...
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Container buildBottomNavigationBar(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.red[300],
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: BottomNavigationBar(
        backgroundColor: Colors.transparent,
        items: [
          BottomNavigationBarItem(
            icon: Icon(Icons.home, color: Colors.white),
            label: 'Home',
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
        currentIndex: 1,
        onTap: (index) {
          switch (index) {
            case 0:
              // Navigate to Home
              break;
            case 1:
              // Stay on Dashboard
              break;
            case 2:
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => ProfilePage()),
              );
              break;
          }
        },
      ),
    );
  }

  Widget buildControlCard(String title, bool isActive) {
    return Container(
      height: 80, // Adjust the height if needed
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
              // Handle toggle here, update Firebase
            },
          ),
        ],
      ),
    );
  }
}
