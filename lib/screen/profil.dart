import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String profileImagePath = 'assets/default_profil.png';
  String fullname = 'User';
  String email = 'user@example.com';
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        email = user.email ?? 'user@example.com';
      });

      DatabaseReference userRef = FirebaseDatabase.instance.ref("users/${user.uid}");
      final snapshot = await userRef.child('fullname').get();
      if (snapshot.exists) {
        setState(() {
          fullname = snapshot.value as String;
        });
      }
    }
  }

  // Method to switch pages when bottom navigation item is tapped
  void onTabTapped(int index) {
    setState(() {
      _currentIndex = index;
    });
    switch (index) {
      case 0:
        Navigator.pushNamed(context, '/home'); // Replace with your route names
        break;
      case 1:
        Navigator.pushNamed(context, '/dashboard');
        break;
      case 2:
        Navigator.pushNamed(context, '/profil');
        break;
    }
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
                        buildProfileField('Username', fullname),
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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: onTabTapped,
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
