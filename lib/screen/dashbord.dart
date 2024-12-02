import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:app_aman/screen/widget/gauge.dart';
import 'package:app_aman/screen/preofilteam.dart';
import 'package:app_aman/screen/Vibrasi.dart';
import 'package:app_aman/screen/profil.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  String fullName = 'User';
  bool isBuzzerOn = false;
  bool isDoorOpen = false;
  bool isDoorManual =  false;
  bool isExhaustFanOn = false;
  double gasLevel = 0.0;
  String statusMessage = 'Unreadable';


  @override
  void initState() {
    super.initState();
    _initializeData();
    _fetchFullName();
  }

  // Function to initialize data from Firebase (for control switches, gas level, and status)
  void _initializeData() {
    _database.child('deviceId/control').once().then((DatabaseEvent event) {
      final data = event.snapshot.value as Map;
      setState(() {
        isBuzzerOn = data['switch buzzer'] == 1;
        isDoorOpen = data['switch pintu'] == 1;
        isExhaustFanOn = data['switch exhaust fan'] == 1;
        isDoorManual = data['switch kontrol pintu'] == 1;
      });
    });

    _database.child('deviceId/monitor/gas_value').onValue.listen((DatabaseEvent event) {
      final value = event.snapshot.value;
      setState(() {
        gasLevel = value != null ? double.parse(value.toString()) : 0.0;
      });
    });

    // Listen for changes in the status value from Firebase
    _database.child('deviceId/monitor/status').onValue.listen((DatabaseEvent event) {
      final status = event.snapshot.value;
      setState(() {
        // Set the status message based on the value from Firebase
        if (status == 0) {
          statusMessage = 'Aman';
        } else if (status == 1) {
          statusMessage = 'Bahaya';
        } else if (status == 2) {
          statusMessage = 'Sangat Berbahaya';
        } else {
          statusMessage = 'Status Tidak Diketahui';
        }
      });
    });
  }

  // Function to fetch the full name of the current user from Firebase
  void _fetchFullName() {
    String? userId = FirebaseAuth.instance.currentUser?.uid; // Get the logged-in user's UID
    if (userId != null) {
      _database.child('users/$userId/fullName').once().then((DatabaseEvent event) {
        final data = event.snapshot.value;
        setState(() {
          fullName = data != null ? data.toString() : 'User'; // Set fullName or default
        });
      }).catchError((error) {
        setState(() {
          fullName = 'Error fetching name'; // Error handling
        });
      });
    }
  }

  // Function to log out the user
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Log out from Firebase and Google
    Navigator.pushReplacementNamed(context, '/welcome'); // Redirect to login page
  }

  void _updateSwitch(String switchType, bool isOn) {
    int value = isOn ? 1 : 0;

    // Tentukan path berdasarkan tipe switch
    String path;
    switch (switchType) {
      case 'switch kontrol pintu':
        path = 'switch_kontrolPintu';
        break;
      case 'switch pintu':
        path = 'switch_pintu';
      break;
      case 'switch exhaust fan':
        path = 'switch_exhaust';
        break;
      case 'switch buzzer':
        path = 'switch_buzzer';
        break;
      default:
        throw ArgumentError('Switch type tidak valid: $switchType');
    }

    // Update nilai di Firebase
    _database.child('deviceId/control/$path').set(value);
  }

  void _showInfoDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Informasi"),
        content: SingleChildScrollView(
        child: Text(
          "Switch pintu hanya akan berfungsi bilamana switch kontrol dalam keadaan manual, jika tidak maka pintu hanya akan bergerak sesuai arahan alat.",
          textAlign: TextAlign.justify, // Atur perataan teks menjadi justify
          style: TextStyle(fontSize: 14), // Tambahkan styling jika diperlukan
        ),
      ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text("Tutup"),
          ),
        ],
      ),
    );
  }

  String formatDate(DateTime date) {
    List<String> months = [
      "Januari", "Februari", "Maret", "April", "Mei", "Juni",
      "Juli", "Agustus", "September", "Oktober", "November", "Desember"
    ];
    String day = date.day.toString();
    String month = months[date.month - 1];
    String year = date.year.toString();
    return "$day $month $year";
  }

  @override
  Widget build(BuildContext context) {
    DateTime now = DateTime.now();
    String formattedDate = formatDate(now);

    return Scaffold(
      key: scaffoldKey,
      appBar: AppBar(
        backgroundColor: Color.fromRGBO(97, 15, 28, 1.0),
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.menu,color: Colors.white, size: 32),
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
        width: 270,
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Color.fromRGBO(97, 15, 28, 1.0),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Image.asset(
                    'assets/Aman .PNG',
                    width: 45,
                    height: 45,
                  ),
                  SizedBox(height: 55),
                  Text(
                    'AMAN Ajaaa',
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
                    SizedBox(height: 1),
                    Text(
                      'Hi, $fullName',
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
                          width: MediaQuery.of(context).size.width * 0.9,
                          padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                          decoration: BoxDecoration(
                            color: Color.fromRGBO(97, 15, 28, 1.0),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Center(
                            child: Text(
                              'Today, $formattedDate',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 10),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: buildControlCard('Buzzer', isBuzzerOn, 'switch buzzer', 'Nyala', 'Mati'),
                            ),
                            SizedBox(width: 3),
                            Expanded(
                              child: buildControlCard('Exhaus', isExhaustFanOn, 'switch exhaust fan', 'Nyala', 'Mati'),
                            ),
                          ],
                        ),
                    SizedBox(height: 5),    
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Expanded(
                              child: buildControlCard('Kontrol', isDoorManual, 'switch kontrol pintu', 'Manual', 'Auto'),
                            ),
                            SizedBox(width: 3),
                            Expanded(
                              child: buildControlCard('Pintu', isDoorOpen, 'switch pintu', 'Buka', 'Tutup'),
                            ),
                          ],
                        ),
                        SizedBox(height: 10),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: buildSensorCardWithGauge('Gas & Asap', gasLevel),
                            ),
                            SizedBox(width: 10),
                            Expanded(
                              child: buildGetaranCard(context),
                            ),
                          ],
                        ),
                      ],
                    ),
                    SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(97, 15, 28, 1.0),
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
                            width: MediaQuery.of(context).size.width * 0.9,
                            height: 100,
                            child: Image.asset(
                              'assets/Graph.gif',
                              fit: BoxFit.cover,
                            ),
                          ),
                          SizedBox(height: 10),
                          Text(
                            statusMessage,
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
              ]
              ),
            ),
          ),
        )
        ],
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

  // Widget to build control cards (Buzzer, Pintu, Exhaust Fan)
  Widget buildControlCard(String title, bool isOn, String switchType, String onText, String offText) {
    return Card(
    elevation: 4,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Stack(
      children: [
        ListTile(
          title: Text(title),
          subtitle: Text(isOn ? onText : offText), // Gunakan teks kustom
          trailing: Switch(
            value: isOn,
            onChanged: (value) {
              setState(() {
                // Perbarui nilai switch di Firebase
                _updateSwitch(switchType, value);

                // Perbarui status switch lokal
                switch (switchType) {
                  case 'switch pintu':
                    isDoorOpen = value;
                    break;
                  case 'switch kontrol pintu':
                    isDoorManual = value;
                    break;
                  case 'switch exhaust fan':
                    isExhaustFanOn = value;
                    break;
                  case 'switch buzzer':
                    isBuzzerOn = value;
                    break;
                  default:
                    throw ArgumentError('Switch type tidak valid: $switchType');
                }
              });
            },
          ),
        ),
          if (switchType == 'switch pintu') // Tampilkan ikon hanya untuk switch pintu
            Positioned(
              top: 5, // Atur jarak dari atas
              right: 5, // Atur jarak dari kanan
              child: GestureDetector(
                onTap: () => _showInfoDialog(context, title),
                child: Icon(
                  Icons.info_outline,
                  color: Colors.black54,
                  size: 20, // Atur ukuran ikon
                ),
              ),
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
        
        decoration: BoxDecoration(
          color: Colors.grey[200],
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
        
          children: [
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                Container(
                  margin: EdgeInsets.only(left: 16), // Tambahkan margin di sini
                  child: Text('Getaran', style: TextStyle(fontSize: 16)),
                ),
                Container(
                  margin: EdgeInsets.only(right: 16), // Tambahkan margin di sini
                  child: Icon(Icons.sensors),
                ),
              ],
            ),
            SizedBox(height: 25),
            Expanded(
        child: Column(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.vertical(),
              child: Image.asset(
                'assets/chart_line.png',
                
              ),
            ),
            SizedBox(height: 5),
            Row(
              mainAxisAlignment: MainAxisAlignment.center, // Menempatkan di tengah
              children: [
                Icon(Icons.open_in_new, color: Colors.black), // Ikon
                SizedBox(width: 8), // Jarak antara ikon dan teks
                Text(
                  'Ketuk untuk melihat', // Teks di samping ikon
                  style: TextStyle(fontSize: 14, color: Colors.black54),
                ),
                
              ],
            ),
          ],
        ),
      ),
          ],
        ),
      ),
    );
  }
}
