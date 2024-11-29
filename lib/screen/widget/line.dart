import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:http/http.dart' as http;

class VibrationChartPage extends StatefulWidget {
  const VibrationChartPage({super.key});

  @override
  _VibrationChartPageState createState() => _VibrationChartPageState();
}

class _VibrationChartPageState extends State<VibrationChartPage> {
  List<FlSpot> sensor1Data = [];
  List<FlSpot> sensor2Data = [];
  List<FlSpot> sensor3Data = [];
  List<FlSpot> sensor4Data = [];
  List<String> timestamps = [];

  final String spreadsheetId = '1k5xMMhA5_t75juJYjNpWNzxGE_lJrA8hL5Zn2De-nwc';
  final String range = 'History!A:E';

  @override
  void initState() {
    super.initState();
    fetchDataFromGoogleSheets();
  }

  Future<void> fetchDataFromGoogleSheets() async {
    final response = await http.get(
      Uri.parse(
        'https://sheets.googleapis.com/v4/spreadsheets/$spreadsheetId/values/$range?key=AIzaSyCsvyziDI4jFMmuQP5e3_6Yjf5h3s9hsBs',
      ),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      final rows = data['values'];

      if (rows != null && rows.isNotEmpty) {
        _updateChartData(rows);
      } else {
        print('No data found.');
      }
    } else {
      print('Failed to load data from Google Sheets.');
    }
  }

  void _updateChartData(List<dynamic> rows) {
    sensor1Data.clear();
    sensor2Data.clear();
    sensor3Data.clear();
    sensor4Data.clear();
    timestamps.clear();

    // Parse last 10 rows
    final lastFiveRows = rows.sublist((rows.length - 10).clamp(1, rows.length));
    for (int i = 0; i < lastFiveRows.length; i++) {
      final row = lastFiveRows[i];
      if (row.length < 5) continue;

      try {
        DateTime timestamp = DateTime.parse(row[0]);
        timestamps.add(timestamp.toString());

        sensor1Data.add(FlSpot(i.toDouble(), double.tryParse(row[1]) ?? 0));
        sensor2Data.add(FlSpot(i.toDouble(), double.tryParse(row[2]) ?? 0));
        sensor3Data.add(FlSpot(i.toDouble(), double.tryParse(row[3]) ?? 0));
        sensor4Data.add(FlSpot(i.toDouble(), double.tryParse(row[4]) ?? 0));
      } catch (e) {
        print('Error parsing row: $row');
      }
    }

    setState(() {});
  }

  // Fungsi untuk menghitung nilai maksimum dengan margin
  double calculateMaxY() {
    final allValues = [
      ...sensor1Data.map((e) => e.y),
      ...sensor2Data.map((e) => e.y),
      ...sensor3Data.map((e) => e.y),
      ...sensor4Data.map((e) => e.y),
    ];
    if (allValues.isEmpty) return 10; // Default maxY jika tidak ada data
    double maxYValue = allValues.reduce((a, b) => a > b ? a : b);
    return maxYValue + (maxYValue * 0.7); // Tambahkan margin 70%
  }

  Widget buildVibrationCard() {
    return Container(
      height: 265,
      child: Container(
        decoration: BoxDecoration(
          color: Colors.black,
          border: Border.all(color: Color.fromRGBO(97, 15, 28, 1.0), width: 4),
          borderRadius: BorderRadius.circular(5),
        ),
        child: LineChart(
          LineChartData(
            gridData: FlGridData(
              show: true,
              drawVerticalLine: true,
              getDrawingHorizontalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.5),
                strokeWidth: 1,
              ),
              getDrawingVerticalLine: (value) => FlLine(
                color: Colors.grey.withOpacity(0.5),
                strokeWidth: 1,
              ),
            ),
            titlesData: FlTitlesData(
              leftTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 25,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toString(),
                      style: const TextStyle(color: Colors.white, fontSize: 8),
                    );
                  },
                ),
              ),
              rightTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 15,
                  getTitlesWidget: (value, meta) {
                    return Text(
                      value.toString(),
                      style: const TextStyle(color: Colors.black, fontSize: 8),
                    );
                  }, 
                ),
              ),
              topTitles: AxisTitles(
                sideTitles: SideTitles(
                    showTitles: true,
                    reservedSize: 15,
                    getTitlesWidget: (value, meta) {
                    return Text(
                      value.toString(),
                      style: const TextStyle(color: Colors.black, fontSize: 8),
                    );
                  },
                  ),
              ),
              bottomTitles: AxisTitles(
                sideTitles: SideTitles(
                  showTitles: true,
                  reservedSize: 15,
                  interval: 1,
                  getTitlesWidget: (value, meta) {
                    int index = value.toInt();
                    if (index >= 0 && index < timestamps.length) {
                      final time = DateTime.parse(timestamps[index]);
                      return Text(
                        '${time.hour}:${time.minute.toString().padLeft(2, '0')}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 8),
                      );
                    }
                    return const Text('');
                  },
                ),
              ),
            ),
            
            borderData: FlBorderData(
              show: true,
              border: Border.all(color: Colors.grey, width: 1),
            ),
            minY: 0, // Nilai minimum sumbu Y
            maxY: calculateMaxY(), 
            lineBarsData: [
              LineChartBarData(
                spots: sensor1Data,
                isCurved: true,
                color: Colors.red,
                barWidth: 3,
                dotData: FlDotData(show: true),
              ),
              LineChartBarData(
                spots: sensor2Data,
                isCurved: true,
                color: Colors.yellow,
                barWidth: 3,
                dotData: FlDotData(show: true),
              ),
              LineChartBarData(
                spots: sensor3Data,
                isCurved: true,
                color: Colors.green,
                barWidth: 3,
                dotData: FlDotData(show: true),
              ),
              LineChartBarData(
                spots: sensor4Data,
                isCurved: true,
                color: Colors.blue,
                barWidth: 3,
                dotData: FlDotData(show: true),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            buildVibrationCard(),
          ],
        ),
      ),
    );
  }
}
