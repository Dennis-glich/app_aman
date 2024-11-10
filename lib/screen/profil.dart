import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String profileImagePath = 'assets/default_profil.png';
  String fullName = 'User'; // Default value for fullName
  String email = 'user@example.com';

  final DatabaseReference _database = FirebaseDatabase.instance.ref();

  @override
  void initState() {
    super.initState();
    _fetchFullName(); // Fetch the user's full name
    _loadUserData();
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

  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        email = user.email ?? 'user@example.com';
      });
    }
  }

  // Function to log out the user
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Log out from Firebase and Google
    Navigator.pushReplacementNamed(context, '/home'); // Redirect to login page
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Stack(
        children: [
          SafeArea(
            child: Column(
              children: [
                // Header with profile picture
                Container(
                  color: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.arrow_back, color: Colors.black),
                          ),
                          Spacer(),
                          Text(
                            'Profil Saya',
                            style: TextStyle(
                              color: Colors.black,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          SizedBox(width: 32),
                        ],
                      ),
                      SizedBox(height: 20),
                      Center(
                        child: GestureDetector(
                          onTap: () async {
                            final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
                            if (pickedFile != null) {
                              setState(() {
                                profileImagePath = pickedFile.path;
                              });
                            }
                          },
                          child: CircleAvatar(
                            radius: 50,
                            backgroundImage: AssetImage(profileImagePath),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                
                // Profile Details Container
                Expanded(
                  child: Container(
                    margin: const EdgeInsets.only(top: 20),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(20),
                        topRight: Radius.circular(20),
                      ),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildProfileField('Username', fullName), // Using fullName here
                        buildProfileField('Email', email),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
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

  Widget buildProfileField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(fontSize: 16),
          ),
          Text(
            value,
            style: TextStyle(fontSize: 16, color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
