import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'package:app_aman/screen/services/auth_service.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String profileImagePath = 'assets/default_profil.png';
  String fullName = 'User';
  String email = 'user@example.com';

  final DatabaseReference _database = FirebaseDatabase.instance.ref();
  final picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _fetchUserProfile();
    _loadUserData();
    _checkProfileImage();  
  }

  // Fetch profile image from Firebase
  void _checkProfileImage() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;
    if (userId != null) {
      final snapshot = await _database.child('users/$userId/profileImage').once();
      if (snapshot.snapshot.value != null) {
        setState(() {
          profileImagePath = snapshot.snapshot.value.toString(); 
        });
      } else {
        setState(() {
          profileImagePath = 'assets/default_profil.png';  
        });
      }
    }
  }

  // Fetch user profile from Firebase Realtime Database
  void _fetchUserProfile() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      try {
        DatabaseEvent event = await _database.child('users/$userId').once();
        Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          setState(() {
            fullName = data['fullName'] ?? 'User';
            profileImagePath = data['profileImage'] ?? 'assets/default_profil.png';
          });
        }
      } catch (e) {
        setState(() {
          fullName = 'Error fetching data';
          profileImagePath = 'assets/default_profil.png';
        });
      }
    }
  }

  // Load user email
  void _loadUserData() async {
    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      setState(() {
        email = user.email ?? 'user@example.com';
      });
    }
  }

  // Pick image from gallery
  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _updateProfileImage(imageFile);
    }
  }

  // Update profile image in Firebase
  Future<void> _updateProfileImage(File imageFile) async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      try {
        final directory = await getApplicationDocumentsDirectory();
        final path = '${directory.path}/profile_${userId}_${DateTime.now().millisecondsSinceEpoch}.png';
        final savedImage = await imageFile.copy(path);

        await _database.child('users/$userId').update({'profileImage': savedImage.path});

        setState(() {
          profileImagePath = savedImage.path;
        });
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update profile image: $e')),
        );
      }
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
                // Profile Header
                Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [ Color.fromRGBO(97, 15, 28, 1.0), Color.fromRGBO(97, 15, 28, 1.0)],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
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
                            'Profile',
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
                          onTap: _pickImage,
                          child: Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle, // Bentuk border melingkar
                              border: Border.all(
                                color: Colors.white, // Warna border
                                width: 4.0, // Ketebalan border
                              ),
                            ),
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: profileImagePath.startsWith('assets/')
                                  ? AssetImage(profileImagePath) as ImageProvider
                                  : FileImage(File(profileImagePath)),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        fullName,
                        style: TextStyle(
                          fontSize: 20,
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),

                // Account Info Section
                Expanded(
                  child: Container(
                    margin: EdgeInsets.only(top: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        
                      ),
                    ),
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        buildProfileField('Name', fullName),
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
        currentIndex: 2, // Profile tab selected by default
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

  Widget buildProfileField(String label, String value) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontSize: 16)),
          Text(value, style: TextStyle(fontSize: 16, color: Colors.black54)),
        ],
      ),
    );
  }
}
