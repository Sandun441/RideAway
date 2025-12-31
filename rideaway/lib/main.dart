import 'package:flutter/material.dart';
import 'package:sensors_plus/sensors_plus.dart';

void main() => runApp(const BikeSafeApp());

class BikeSafeApp extends StatelessWidget {
  const BikeSafeApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        appBar: AppBar(title: const Text('Bike Accident Detector')),
        body: const SensorMonitor(),
      ),
    );
  }
}

class SensorMonitor extends StatefulWidget {
  const SensorMonitor({super.key});

  @override
  State<SensorMonitor> createState() => _SensorMonitorState();
}

class _SensorMonitorState extends State<SensorMonitor> {
  double _accelX = 0;

  @override
  void initState() {
    super.initState();
    // Start listening to the accelerometer
    userAccelerometerEvents.listen((UserAccelerometerEvent event) {
      setState(() {
        _accelX = event.x;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text('Accelerometer X-axis: ${_accelX.toStringAsFixed(2)}'),
    );
  }
}