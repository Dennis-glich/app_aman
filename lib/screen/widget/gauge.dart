import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_gauges/gauges.dart';

Widget buildSensorCardWithGauge(String title, double reading) {
  return Container(
    height: 200,
    padding: EdgeInsets.all(16),
    decoration: BoxDecoration(
      color: Colors.grey[200],
      borderRadius: BorderRadius.circular(12),
    ),
    child: Column(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(fontSize: 16)),
            Icon(Icons.sensors),
          ],
        ),
        // Gauge widget for Gas & Asap
        Expanded(
          child: SfRadialGauge(
            axes: <RadialAxis>[
              RadialAxis(
                interval: 100,
                startAngle: 0,
                endAngle: 360,
                minimum: 0,
                maximum: 2000,
                showTicks: false,
                showLabels: false,
                axisLineStyle: AxisLineStyle(thickness: 10),
                pointers: <GaugePointer>[
                  RangePointer(
                    value: reading,
                    width: 10,
                    color: Color.fromRGBO(97, 15, 28, 1.0),
                    enableAnimation: true,
                    cornerStyle: CornerStyle.bothCurve,
                  ),
                ],
                annotations: <GaugeAnnotation>[
                  GaugeAnnotation(
                    widget: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Text(
                          '$reading',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 25,
                          ),
                        ),
                        Text(
                          'ppm',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.grey[600],
                          ),
                        ),
                      ],
                    ),
                    angle: 90,
                    positionFactor: 0.1,
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    ),
  );
}
