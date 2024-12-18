import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:app_aman/screen/widget/gauge.dart';
import 'package:app_aman/screen/preofilteam.dart';
import 'package:app_aman/screen/Vibrasi.dart';
import 'package:app_aman/screen/profil.dart';
import 'package:app_aman/screen/services/auth_service.dart';
import 'package:intl/intl.dart';

class DashboardPage extends StatefulWidget {
  @override
  _DashboardPageState createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {
  final GlobalKey<ScaffoldState> scaffoldKey = GlobalKey<ScaffoldState>();
  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  String fullName = 'User';
  String statusMessage = "Device not connected";
  double gasLevel = 0.0;
  bool isBuzzerOn = false;
  bool isDoorOpen = false;
  bool isExhaustFanOn = false;
  bool isDoorManual = false;
  bool isConnected = false;

  @override
  void initState() {
    super.initState();
    _initializeData();
    _fetchFullName();
    _loadInitialValues();
    checkConnectivity();
  }

void checkConnectivity() {
  // Referensi ke path Firebase
  final DatabaseReference _database = FirebaseDatabase.instance
      .ref("deviceId/monitor/vib_total/timestamp");

  // Mendengarkan perubahan data di path
  _database.onValue.listen((event) {
    final timestampString = event.snapshot.value as String?;
    if (timestampString != null) {
      try {
        // Parsing timestamp dari string
        final timestamp =
            DateFormat("yyyy-MM-dd HH:mm:ss").parse(timestampString);
        final currentTime = DateTime.now();

        setState(() {
          isConnected = currentTime.difference(timestamp).inSeconds <= 10;
        });
      } catch (e) {
        setState(() {
          isConnected = false;
        });
      }
    } else {
      setState(() {
        isConnected = false;
      });
    }
  });
}

  // Ambil nilai awal dari Realtime Database
  void _loadInitialValues() async {
    try {
      final DataSnapshot snapshot = await _database.child('deviceId/control').get();
      if (snapshot.exists) {
        setState(() {
          isBuzzerOn = snapshot.child('switch_buzzer').value == 1;
          isDoorOpen = snapshot.child('switch_pintu').value == 1;
          isExhaustFanOn = snapshot.child('switch_exhaust').value == 1;
          isDoorManual = snapshot.child('switch_kontrolPintu').value == 1;
        });
      }
    } catch (e) {
      print('Error loading initial values: $e');
    }
  }

    String _getSwitchPath(String switchType) {
    return 'deviceId/control/$switchType';
  }

  // Update nilai di Realtime Database
  void _updateSwitch(String switchType, bool isOn) {
    int value = isOn ? 1 : 0;
    String path = _getSwitchPath(switchType);
    _database.child(path).set(value).catchError((error) {
      print('Error updating $switchType at $path: $error');
    });
  }


  // Function to initialize data from Firebase (for gas level, and status)
  void _initializeData() {
    // Mendengarkan perubahan pada level gas
    _database.child('deviceId/monitor/gas_value').onValue.listen((DatabaseEvent event) {
      final value = event.snapshot.value;
      setState(() {
        gasLevel = value != null ? double.parse(value.toString()) : 0.0;
      });
    });

    // Mendengarkan perubahan pada status
    _database.child('deviceId/monitor/status').onValue.listen((DatabaseEvent event) {
      final status = event.snapshot.value;
      setState(() {
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
  void logoutUser(BuildContext context) async {
  final authService = AuthService();
  await authService.signOut(context);
}


  void _showInfoDialog(BuildContext context, List<String> messages) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Informasi"),
            Divider(), // Garis pemisah di bawah judul
          ],
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: messages
                .map((message) => Padding(
                      padding: const EdgeInsets.only(bottom: 8.0),
                      child: Text(
                        message,
                        style: TextStyle(fontSize: 14),
                        textAlign: TextAlign.justify,
                      ),
                    ))
                .toList(),
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
                            child: buildControlCard(
                              'Buzzer',
                              isBuzzerOn,
                              'switch_buzzer',
                              'Nyala',
                              'Mati',
                            ),
                          ),
                          Expanded(
                            child: buildControlCard(
                              'Exhaust',
                              isExhaustFanOn,
                              'switch_exhaust',
                              'Nyala',
                              'Mati',
                            ),
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
                              child: buildControlCard(
                                'Kontrol',
                                isDoorManual,
                                'switch_kontrolPintu',
                                'Manual',
                                'Otomatis',
                              ),
                            ),
                            Expanded(
                              child: buildControlCard(
                                'Pintu',
                                isDoorOpen,
                                'switch_pintu',
                                'Terbuka',
                                'Tertutup',
                              ),
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
                    SizedBox(height: 15),
                    Container(
                      width: double.infinity,
                      height: 220,
                      padding: EdgeInsets.only(bottom: 10, left: 20, right: 5),
                      decoration: BoxDecoration(
                        color: Color.fromRGBO(97, 15, 28, 1.0),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Color.fromRGBO(97, 15, 28, 1.0), // Mengubah warna border menjadi merah
                          width: 3, // Menentukan ketebalan border
                        ),
                        image: DecorationImage(
                          image: AssetImage('assets/Graph.gif'),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    'Status',
                                    style: TextStyle(fontSize: 18, color: Colors.white),
                                  ),
                                  SizedBox(width: 8), // Memberikan jarak antara tulisan dan emoji
                                  Text(
                                    isConnected ? "😊" : "😢",
                                    style: TextStyle(fontSize: 24),
                                  ),
                                ],
                              ),
                              IconButton(
                                icon: Icon(Icons.info_outline, color: Colors.white, size: 24),
                                onPressed: () {
                                  _showInfoDialog(
                                    context,
                                    [
                                      "(Jika emoji Menunjukan senyum maka device terhubung, namun jika emoji menunjukkan wajah sedih maka device tidak terhubung)",
                                      "",
                                      "Indikator Bahaya: ",
                                      "- Aman: Gas <=1000",
                                      "- Bahaya: Gas >1000 dan <=2000",
                                      "- Sangat Berbahaya: Gas >2000",
                                      "Jika Getaran > 567 Perbulan (Perlu dimaintenance)",
                                      
                                    ],
                                  );
                                },
                              ),
                            ],
                          ),
                          SizedBox(height: 115),
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
                    )
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
            icon: Icon(Icons.logout, color: Colors.white),
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
        currentIndex: 1, // Dashboard tab selected by default
        onTap: (index) async {
          switch (index) {
            case 0:
              // Panggil fungsi signOut dari AuthService
              final authService = AuthService();
              try {
                await authService.signOut(context);
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Gagal logout: $e')),
                );
              }
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
    elevation: 5,
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: Stack(
      children: [
        ListTile(
          contentPadding: EdgeInsets.only(left: 10,right: 13),
          title: Text(title),
          subtitle: Text(isOn ? onText : offText), // Gunakan teks kustom
          trailing: Switch(
            value: isOn,
            onChanged: (value) {
              setState(() {
                  _updateSwitch(switchType, value);
                  switch (switchType) {
                    case 'switch_pintu':
                      isDoorOpen = value;
                      break;
                    case 'switch_kontrolPintu':
                      isDoorManual = value;
                      break;
                    case 'switch_exhaust':
                      isExhaustFanOn = value;
                      break;
                    case 'switch_buzzer':
                      isBuzzerOn = value;
                      break;
                    default:
                      throw ArgumentError('Switch type tidak valid: $switchType');
                  }
                });
            },
          ),
        ),
          if (switchType == 'switch_pintu') // Tampilkan ikon hanya untuk switch pintu
            Positioned(
              top: 5, // Atur jarak dari atas
              right: 5, // Atur jarak dari kanan
              child: GestureDetector(
                onTap: () => _showInfoDialog(
                  context, ["Switch pintu hanya akan berfungsi bilamana switch kontrol dalam keadaan manual, jika tidak maka pintu hanya akan bergerak sesuai arahan alat."]
                  ),
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
        margin: EdgeInsets.all(0),
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
                  margin: EdgeInsets.only(left: 14), // Tambahkan margin di sini
                  child: Text('Getaran', style: TextStyle(fontSize: 16)),
                ),
                Container(
                  margin: EdgeInsets.only(right: 14), // Tambahkan margin di sini
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
                      fit: BoxFit.contain,
                    ),
                  ),
                  SizedBox(height: 5),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center, // Menempatkan di tengah
                    children: [
                      Text(
                        'Ketuk untuk melihat', // Teks di samping ikon
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      SizedBox(width: 8), // Jarak antara ikon dan teks
                      Icon(Icons.open_in_new, color: Colors.black), // Ikon
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
