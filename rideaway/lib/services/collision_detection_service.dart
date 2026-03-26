import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';

class CollisionDetectionService {
  StreamSubscription<AccelerometerEvent>? _subscription;
  final Function() onCollisionDetected;

  bool _isMonitoring = false;
  DateTime? _lastCollisionTime;

  // Threshold map based on sensitivity setting (0=Low, 1=Medium, 2=High)
  // Values are in m/s² — normal gravity ≈ 9.8 m/s²
  static const Map<int, double> _thresholdMap = {
    0: 55.0, // Low — only detect very hard impacts
    1: 40.0, // Medium — balanced (default)
    2: 25.0, // High — detect smaller impacts (more false positives)
  };

  double _collisionThreshold = 40.0;

  CollisionDetectionService({required this.onCollisionDetected});

  /// Load sensitivity from SharedPreferences and start listening
  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    // Read sensitivity setting
    final prefs = await SharedPreferences.getInstance();
    final sensitivityIndex = (prefs.getDouble('setting_sensitivity') ?? 1).toInt();
    _collisionThreshold = _thresholdMap[sensitivityIndex] ?? 40.0;

    _isMonitoring = true;
    _subscription = accelerometerEventStream(
      samplingPeriod: SensorInterval.gameInterval,
    ).listen((AccelerometerEvent event) {
      final gForce = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));
      if (gForce > _collisionThreshold) {
        _handlePotentialCollision();
      }
    });
  }

  void _handlePotentialCollision() {
    final now = DateTime.now();
    // Debounce: prevent multiple triggers within 5 seconds
    if (_lastCollisionTime != null &&
        now.difference(_lastCollisionTime!) < const Duration(seconds: 5)) {
      return;
    }
    _lastCollisionTime = now;
    onCollisionDetected();
  }

  void stopMonitoring() {
    _subscription?.cancel();
    _subscription = null;
    _isMonitoring = false;
  }
}
