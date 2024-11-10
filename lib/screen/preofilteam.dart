import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeamProfilePage extends StatefulWidget {
  @override
  _TeamProfilePageState createState() => _TeamProfilePageState();
}

class _TeamProfilePageState extends State<TeamProfilePage> {

  // Function to log out the user
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut(); // Log out from Firebase and Google
    Navigator.pushReplacementNamed(context, '/home'); // Redirect to login page
  }
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Background Image
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/bg.jpg'),
                fit: BoxFit.cover,
              ),
            ),
          ),
          // Content
          SafeArea(
            child: SingleChildScrollView( // Make the content scrollable
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.pop(context); // Back button functionality
                          },
                          child: Icon(Icons.arrow_back, color: Colors.white),
                        ),
                        Text(
                          'Team Profil',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 32), // Placeholder for alignment
                      ],
                    ),
                  ),
                  SizedBox(height: 20),
                  // Team Image filling the width of the screen
                  Center(
                    child: Container(
                      width: double.infinity, // Set to fill the width of the screen
                      child: Image.asset(
                        'assets/Frame 3.png', // Your combined team image
                        fit: BoxFit.cover, // Adjust to cover the entire width
                      ),
                    ),
                  ),
                  // Spacer for flexible layout
                  SizedBox(height: 20), // Add some space below the image
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
}
