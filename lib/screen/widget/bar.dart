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
  _listenToVibrationData();  // Mendengarkan data getaran real-time
  _fetchVibrationTotalData(); // Menampilkan total getaran yang sudah dihitung
  _resetIfNewMonth();         // Memeriksa apakah perlu mereset data sensor
}

void _listenToVibrationData() {
  _databaseReference.child('deviceId/monitor/vib_value').onValue.listen((DatabaseEvent event) {
    final dataSnapshot = event.snapshot;
    if (dataSnapshot.value != null) {
      final Map<String, dynamic> data = Map<String, dynamic>.from(dataSnapshot.value as Map);

      // Tambahkan jumlah getaran ke Firebase di `vib_total` jika `vib_value` adalah 1
      data.forEach((sensor, value) {
        if (value == 1) {
          _databaseReference.child('deviceId/monitor/vib_total/$sensor').once().then((DatabaseEvent totalEvent) {
            final currentTotal = (totalEvent.snapshot.value ?? 0) as int;
            _databaseReference.child('deviceId/monitor/vib_total/$sensor').set(currentTotal + 1);
          });
        }
      });
    }
  });
}

  void _fetchVibrationTotalData() {
    _databaseReference.child('deviceId/monitor/vib_total').onValue.listen((DatabaseEvent event) {
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
    });
  }

void _resetIfNewMonth() {
  final currentMonth = DateTime.now().month;
  _databaseReference.child('deviceId/monitor/last_reset_month').once().then((DatabaseEvent event) {
    final lastMonth = event.snapshot.value ?? currentMonth;
    
    if (lastMonth != currentMonth) {
      // Reset total getaran untuk semua sensor
      _databaseReference.child('deviceId/monitor/vib_total').set({
        'S1': 0,
        'S2': 0,
        'S3': 0,
        'S4': 0,
      });
      
      // Simpan bulan reset terakhir di Firebase
      _databaseReference.child('deviceId/monitor/last_reset_month').set(currentMonth);
    }
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
