import 'dart:async';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class CollisionDetectionService {
  StreamSubscription<UserAccelerometerEvent>? _accelSubscription;
  StreamSubscription<GyroscopeEvent>? _gyroSubscription;
  Timer? _samplingTimer;
  Interpreter? _interpreter;

  final Function() onCollisionDetected;

  bool _isMonitoring = false;
  DateTime? _lastCollisionTime;

  // TFLite Variables
  final List<List<double>> _sensorBuffer = []; // stores [ax, ay, az, gx, gy, gz]
  final int _windowSize = 100;
  int _consecutiveHighProbCrashes = 0;

  // Latest sensor readings
  double _ax = 0.0, _ay = 0.0, _az = 0.0;
  double _gx = 0.0, _gy = 0.0, _gz = 0.0;

  CollisionDetectionService({required this.onCollisionDetected});

  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    try {
      _interpreter = await Interpreter.fromAsset('assets/ml/crash_detector.tflite');
      print('Model loaded successfully');
      if (_interpreter != null) {
        var inputTensors = _interpreter!.getInputTensors();
        for (var tensor in inputTensors) {
          print('DBG_INPUT_SHAPE: name=${tensor.name}, shape=${tensor.shape}, type=${tensor.type}');
        }
        var outputTensors = _interpreter!.getOutputTensors();
        for (var tensor in outputTensors) {
          print('DBG_OUTPUT_SHAPE: name=${tensor.name}, shape=${tensor.shape}, type=${tensor.type}');
        }
      }
    } catch (e) {
      print('Failed to load model: $e');
    }

    _isMonitoring = true;

    _accelSubscription = userAccelerometerEventStream().listen((event) {
      _ax = event.x;
      _ay = event.y;
      _az = event.z;
    });

    _gyroSubscription = gyroscopeEventStream().listen((event) {
      _gx = event.x;
      _gy = event.y;
      _gz = event.z;
    });

    // Sample sensors at 50Hz (every 20ms)
    _samplingTimer = Timer.periodic(const Duration(milliseconds: 20), (timer) {
      // Prevent inference on dead/zeroed sensor data (common on emulators or before first sensor event).
      // A pure (0,0,0) reading looks like free-fall to the ML model!
      if (_ax == 0.0 && _ay == 0.0 && _az == 0.0) return;

      _sensorBuffer.add([_ax, _ay, _az, _gx, _gy, _gz]);

      if (_sensorBuffer.length >= _windowSize) {
        _performInference();
        _sensorBuffer.clear();
      }
    });
  }

  void _performInference() {
    if (_interpreter == null) return;

    var input = [_sensorBuffer];
    var output = List<List<double>>.generate(1, (_) => List<double>.filled(1, 0.0));

    try {
      _interpreter!.run(input, output);
      double crashProbability = output[0][0];
      print('Crash probability: $crashProbability');

      if (crashProbability > 0.85) {
        _consecutiveHighProbCrashes++;
        if (_consecutiveHighProbCrashes >= 2) {
          _handlePotentialCollision();
          _consecutiveHighProbCrashes = 0; 
        }
      } else {
        _consecutiveHighProbCrashes = 0;
      }
    } catch (e) {
      print('Inference error: $e');
    }
  }

  void _handlePotentialCollision() {
    final now = DateTime.now();
    if (_lastCollisionTime != null &&
        now.difference(_lastCollisionTime!) < const Duration(seconds: 5)) {
      return;
    }
    _lastCollisionTime = now;
    onCollisionDetected();
  }

  void stopMonitoring() {
    _accelSubscription?.cancel();
    _accelSubscription = null;
    _gyroSubscription?.cancel();
    _gyroSubscription = null;
    _samplingTimer?.cancel();
    _samplingTimer = null;
    _interpreter?.close();
    _interpreter = null;
    _isMonitoring = false;
    _sensorBuffer.clear();
    _consecutiveHighProbCrashes = 0;
  }
}
