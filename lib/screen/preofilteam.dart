import 'package:flutter/material.dart';

class TeamProfilePage extends StatefulWidget {
  @override
  _TeamProfilePageState createState() => _TeamProfilePageState();
}

class _TeamProfilePageState extends State<TeamProfilePage> {
  int _currentIndex = 0;

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
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home'); // Navigasi ke halaman Home
              break;
            case 1:
              Navigator.pushNamed(context, '/dashboard'); // Navigasi ke halaman Dashboard
              break;
            case 2:
              Navigator.pushNamed(context, '/profil'); // Navigasi ke halaman Settings
              break;
          }
        },
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
}
