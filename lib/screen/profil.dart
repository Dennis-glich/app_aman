import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';
import 'services/auth_service.dart';

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

  void _fetchUserProfile() async {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    if (userId != null) {
      try {
        DatabaseEvent event = await _database.child('users/$userId').once();
        Map<dynamic, dynamic>? data = event.snapshot.value as Map<dynamic, dynamic>?;

        if (data != null) {
          setState(() {
            fullName = data['fullName'] ?? 'User';
            email = data['email'] ?? 'user@example.com';
            profileImagePath = data['profileImage'] ?? 'assets/default_profil.png';
          });
        }
      } catch (e) {
        setState(() {
          fullName = 'Error fetching data';
        });
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      File imageFile = File(pickedFile.path);
      await _updateProfileImage(imageFile);
    }
  }

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
          SnackBar(content: Text('Gagal mengganti foto profil: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Bagian atas dengan warna merah dan header
          Container(
            height: MediaQuery.of(context).size.height * 0.3,
            color: const Color.fromRGBO(97, 15, 28, 1.0),
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Icon(Icons.arrow_back, color: Colors.white),
                      ),
                      Spacer(),
                      Text(
                        'Profile',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Spacer(),
                      SizedBox(width: 32),
                    ],
                  ),
                ),
                Stack(
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 40.0, left: 16.0, right: 16.0),
                      child: Row(
                        children: [
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Icon(Icons.arrow_back, color: Colors.white),
                          ),
                          Spacer(),
                          Text(
                            'Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Spacer(),
                          SizedBox(width: 32),
                        ],
                      ),
                    ),
                    Align(
                      alignment: Alignment.center,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(height: 80),
                          GestureDetector(
                            onTap: _pickImage,
                            child: CircleAvatar(
                              radius: 50,
                              backgroundImage: profileImagePath.startsWith('assets/')
                                  ? AssetImage(profileImagePath) as ImageProvider
                                  : FileImage(File(profileImagePath)),
                              child: Align(
                                alignment: Alignment.bottomRight,
                                child: Icon(
                                  Icons.camera_alt,
                                  color: Colors.white,
                                  size: 30,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                )
              ],
            ),
          ),
          // Informasi pengguna
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow(Icons.person, "Username", fullName),
                  _buildInfoRow(Icons.email, "Email", email),
                ],
              ),
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

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: Row(
        children: [
          Icon(icon, color: Colors.grey),
          SizedBox(width: 16),
          Text(
            "$label:",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: TextStyle(fontSize: 16),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }
}
