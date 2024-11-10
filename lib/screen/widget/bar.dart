import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:firebase_database/firebase_database.dart';

class ChartData {
  ChartData(this.sensor, this.value) : assert(value >= 0, 'Value cannot be negative');

  final String sensor;
  final double value;
}

class VibrationChart extends StatefulWidget {
  @override
  _VibrationChartState createState() => _VibrationChartState();
}

class _VibrationChartState extends State<VibrationChart> {
  final DatabaseReference _databaseReference = FirebaseDatabase.instance.ref();
  List<ChartData> _chartData = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _fetchVibrationData();
  }

  void _fetchVibrationData() {
    _databaseReference.child('deviceId/monitor/vib_value').once().then((DatabaseEvent event) {
      final dataSnapshot = event.snapshot;
      if (dataSnapshot.value != null) {
        final Map<String, dynamic> data = Map<String, dynamic>.from(dataSnapshot.value as Map);
        setState(() {
          _chartData = data.entries.map((entry) => ChartData(entry.key, entry.value.toDouble())).toList();
          _isLoading = false;
        });
      } else {
        setState(() {
          _isLoading = false;
        });
      }
    }).catchError((error) {
      setState(() {
        _isLoading = false;
      });
      print('Error fetching data: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? Center(child: CircularProgressIndicator())
        : buildVibrationChart(_chartData);
  }
}

Widget buildVibrationChart(List<ChartData> chartData) {
  return Container(
    height: 200,
    padding: EdgeInsets.symmetric(horizontal: 16.0),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
    ),
    child: SfCartesianChart(
      margin: EdgeInsets.zero,
      plotAreaBorderWidth: 0,
      title: ChartTitle(text: 'Getaran'),
      primaryXAxis: CategoryAxis(
        title: AxisTitle(text: ''),
        isVisible: true,
      ),
      primaryYAxis: NumericAxis(
        title: AxisTitle(text: ''),
        labelStyle: TextStyle(fontSize: 10),
        maximum: 100, // Adjust the Y-axis max as needed
      ),
      series: <CartesianSeries>[
        BarSeries<ChartData, String>(
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.sensor,
          yValueMapper: (ChartData data, _) => data.value,
          name: 'Getaran',
          color: Color.fromRGBO(97, 15, 28, 1.0),
          dataLabelSettings: DataLabelSettings(isVisible: true),
          width: 0.5,
        ),
      ],
    ),
  );
}
