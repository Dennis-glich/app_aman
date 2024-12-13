import 'package:app_aman/screen/services/auth_service.dart';
import 'package:flutter/material.dart';

class TeamProfilePage extends StatefulWidget {
  @override
  _TeamProfilePageState createState() => _TeamProfilePageState();
}

class _TeamProfilePageState extends State<TeamProfilePage> {

  // Function to log out the user
  void logoutUser(BuildContext context) async {
    final authService = AuthService();
    await authService.signOut(context);
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
}
