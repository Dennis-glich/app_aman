import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

class ChartData {
  ChartData(this.sensor, this.value) : assert(value >= 0, 'Value cannot be negative');

  final String sensor;
  final double value;
}

// Sample data for vibration monitoring
List<ChartData> getSampleVibrationData() {
  // Ensure that all values are non-null and valid
  return [
    ChartData('S1', 3), 
    ChartData('S2', 4),
    ChartData('S3', 5),
    ChartData('S4', 1),
  ];
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
        maximum: 15, // Sesuaikan maksimum Y-axis sesuai data
      ),
      series: <CartesianSeries>[
        BarSeries<ChartData, String>(
          dataSource: chartData,
          xValueMapper: (ChartData data, _) => data.sensor,
          yValueMapper: (ChartData data, _) => data.value,
          name: 'Getaran',
          color: Colors.red[300],
          dataLabelSettings: DataLabelSettings(isVisible: true),
          width: 0.2,
        ),
      ],
    ),
  );
}
