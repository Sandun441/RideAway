import 'dart:async';
import 'dart:math';
import 'package:sensors_plus/sensors_plus.dart';

class CollisionDetectionService {
  StreamSubscription<AccelerometerEvent>? _subscription;
  final Function() onCollisionDetected;

  // Customizable threshold for collision detection (in Gs)
  // 4G is a reasonable starting point for a "hard fall" or impact
  // Normal gravity is 1G (~9.8 m/s^2)
  final double collisionThreshold =
      40.0; // using raw values m/s^2? No, sensors_plus returns m/s^2. 1G = 9.8. 4G ~= 40.

  bool _isMonitoring = false;
  DateTime? _lastCollisionTime;

  CollisionDetectionService({required this.onCollisionDetected});

  void startMonitoring() {
    if (_isMonitoring) return;

    _isMonitoring = true;
    _subscription = accelerometerEvents.listen((AccelerometerEvent event) {
      double gForce = sqrt(pow(event.x, 2) + pow(event.y, 2) + pow(event.z, 2));

      // Check if force exceeds threshold
      if (gForce > collisionThreshold) {
        _handlePotentialCollision();
      }
    });
  }

  void _handlePotentialCollision() {
    final now = DateTime.now();
    // Debounce collisions (e.g., prevent multiple triggers for the same event)
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
