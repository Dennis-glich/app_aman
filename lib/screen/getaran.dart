import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'widget/bar.dart';

class GetaranMonitoring extends StatefulWidget {
  @override
  _GetaranMonitoringState createState() => _GetaranMonitoringState();
}

class _GetaranMonitoringState extends State<GetaranMonitoring> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    // Data getaran untuk masing-masing sensor
    final List<ChartData> chartData = getSampleVibrationData();

    final now = DateTime.now();
    final firstDayOfMonth = DateTime(now.year, now.month, 1);
    final lastDayOfMonth = DateTime(now.year, now.month + 1, 0);
    final dateRange = '${DateFormat.d().format(firstDayOfMonth)} ${DateFormat.MMMM().format(firstDayOfMonth)} - ${DateFormat.d().format(lastDayOfMonth)} ${DateFormat.MMMM().format(lastDayOfMonth)} ${now.year}';

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: Text('Monitoring Getaran'),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/bg gas.jpg'), // Set background image
            fit: BoxFit.cover,
          ),
        ),
        child: SingleChildScrollView( // Make the content scrollable
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              SizedBox(height: kToolbarHeight + 20),
              // Tanggal dengan border dan background
              Container(
                padding: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.red[300],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.redAccent, width: 1),
                ),
                child: Text(
                  dateRange,
                  style: TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              SizedBox(height: 30),

              // Container untuk Graph/Chart dengan border merah
              Container(
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.red[300]!, width: 2), // Border merah
                  borderRadius: BorderRadius.circular(12),
                ),
                child: buildVibrationChart(chartData), // Pass the chartData here
              ),
              SizedBox(height: 20),

              // Label untuk data masing-masing sensor
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.bar_chart, color: Colors.red[300]),
                  SizedBox(width: 5),
                  Text(
                    'Data Masing-Masing Sensor',
                    style: TextStyle(fontSize: 18, color: Colors.red[300]),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Vibration Cards untuk masing-masing sensor
              Row(
                children: [
                  Expanded(
                    child: _buildVibrationCard('Vibrasi 1', '${chartData[0].value.toInt()} Kali'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildVibrationCard('Vibrasi 2', '${chartData[1].value.toInt()} Kali'),
                  ),
                ],
              ),
              SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: _buildVibrationCard('Vibrasi 3', '${chartData[2].value.toInt()} Kali'),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: _buildVibrationCard('Vibrasi 4', '${chartData[3].value.toInt()} Kali'),
                  ),
                ],
              ),
              SizedBox(height: 20),

              // Switch Buzzer
              Container(
                width: double.infinity,
                padding: EdgeInsets.all(16.0),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.8),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Buzzer',
                      style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                    Switch(
                      value: false, // State of the switch (you can change this to manage state)
                      onChanged: (value) {
                        // Handle switch state change
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
          switch (index) {
            case 0:
              Navigator.pushNamed(context, '/home');
              break;
            case 1:
              Navigator.pushNamed(context, '/dashboard');
              break;
            case 2:
              Navigator.pushNamed(context, '/profil');
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

  // Fungsi pembantu untuk membuat kartu getaran
  Widget _buildVibrationCard(String title, String count) {
    return Card(
      color: Colors.red.shade100,
      child: Container(
        padding: EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(title, style: TextStyle(fontSize: 16)),
            SizedBox(height: 10),
            Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
