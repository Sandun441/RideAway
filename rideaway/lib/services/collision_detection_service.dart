import 'dart:async';
import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Normalization constants extracted from training pipeline (04_cnn_model.ipynb)
// X_train_mean = np.mean(X_train, axis=(0,1))  shape: (6,)
// X_train_std  = np.std (X_train, axis=(0,1))  shape: (6,)
// Axes order: [acc_x, acc_y, acc_z, gyro_x, gyro_y, gyro_z]
// ─────────────────────────────────────────────────────────────────────────────
const List<double> _kNormMean = [
  -0.025634, // acc_x
  -0.059088, // acc_y
  -0.002480, // acc_z
   0.021144, // gyro_x
   0.021613, // gyro_y
   0.029625, // gyro_z
];

const List<double> _kNormStd = [
  2.461121, // acc_x
  2.511723, // acc_y
  2.507216, // acc_z
  0.943263, // gyro_x
  1.049961, // gyro_y
  1.076128, // gyro_z
];

// ─────────────────────────────────────────────────────────────────────────────
// Pipeline constants — must exactly match 04_cnn_model.ipynb / model_config.json
// ─────────────────────────────────────────────────────────────────────────────
const int _kWindowSize = 100; // timesteps per inference window
const int _kStepSize   = 50;  // samples to advance before next inference
                               // (50% overlap, matches training step=50)
const int _kConsecutiveRequired = 2; // windows above threshold to confirm crash

class CollisionDetectionService {
  // ── Public API ──────────────────────────────────────────────────────────────
  final void Function() onCollisionDetected;

  CollisionDetectionService({required this.onCollisionDetected});

  // ── Private state ───────────────────────────────────────────────────────────
  Interpreter? _interpreter;
  SharedPreferences? _prefs;

  StreamSubscription<UserAccelerometerEvent>? _accelSub;
  StreamSubscription<GyroscopeEvent>? _gyroSub;

  /// Circular buffer holding the most recent sensor rows [ax, ay, az, gx, gy, gz].
  /// Capped at _kWindowSize to bound memory; we explicitly manage the tail slice.
  final Queue<List<double>> _buffer = Queue<List<double>>();

  // Latest raw readings — updated on every sensor event
  double _ax = 0.0, _ay = 0.0, _az = 0.0;
  double _gx = 0.0, _gy = 0.0, _gz = 0.0;

  // How many samples we have added since the last inference
  int _samplesSinceInference = 0;

  // Gyroscope ready flag (first event fires at different time than accel)
  bool _gyroReady = false;

  int _consecutiveHighProb = 0;
  DateTime? _lastCollisionTime;
  bool _isMonitoring = false;

  // ── Start / stop ─────────────────────────────────────────────────────────────

  Future<void> startMonitoring() async {
    if (_isMonitoring) return;

    // ── Load SharedPreferences (for sensitivity setting) ──────────────────────
    try {
      _prefs = await SharedPreferences.getInstance();
    } catch (e) {
      _log('SharedPreferences init failed: $e');
    }

    // ── Load TFLite model ─────────────────────────────────────────────────────
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/ml/crash_detector.tflite',
      );
      _debugModelShapes();
    } catch (e) {
      _log('Model load failed: $e');
      // Continue — service will skip inference while interpreter is null
    }

    _isMonitoring = true;
    _buffer.clear();
    _samplesSinceInference = 0;
    _consecutiveHighProb = 0;
    _gyroReady = false;

    // ── Subscribe to sensor streams ──────────────────────────────────────────
    // We use event-driven sampling (no periodic Timer).
    // The accelerometer stream fires at ~50 Hz on most Android/iOS devices,
    // which matches the 50 Hz training sample rate exactly.
    // Each accelerometer event triggers one sample to be appended.
    // The gyroscope events update a "latest gyro" snapshot used in each sample.

    _gyroSub = gyroscopeEventStream().listen((event) {
      _gx = event.x;
      _gy = event.y;
      _gz = event.z;
      _gyroReady = true;
    }, onError: (e) => _log('Gyro error: $e'));

    _accelSub = userAccelerometerEventStream().listen((event) {
      _ax = event.x;
      _ay = event.y;
      _az = event.z;

      // ── Data validity guard ───────────────────────────────────────────────
      // Skip only when ALL six values are zero (dead sensor / emulator boot).
      // Gravity on Z gives ~9.8 m/s² normally, so this fires only on true zeros.
      if (_ax == 0.0 && _ay == 0.0 && _az == 0.0 &&
          _gx == 0.0 && _gy == 0.0 && _gz == 0.0) {
        return;
      }

      // Wait until at least one gyro event has fired to avoid a stale zero row
      if (!_gyroReady) return;

      // ── Append sample ─────────────────────────────────────────────────────
      _buffer.addLast([_ax, _ay, _az, _gx, _gy, _gz]);
      _samplesSinceInference++;

      // Keep buffer length bounded at windowSize to minimise memory churn
      while (_buffer.length > _kWindowSize) {
        _buffer.removeFirst();
      }

      // ── Sliding-window trigger ───────────────────────────────────────────
      // Fire inference when:
      //   • we have collected a full window (≥ 100 samples), AND
      //   • at least _kStepSize new samples have arrived since the last run.
      // This gives 50% overlap, identical to training (step=50).
      if (_buffer.length >= _kWindowSize &&
          _samplesSinceInference >= _kStepSize) {
        _samplesSinceInference = 0;
        _performInference();
      }
    }, onError: (e) => _log('Accel error: $e'));
  }

  void stopMonitoring() {
    if (!_isMonitoring) return;
    _isMonitoring = false;

    _accelSub?.cancel();
    _accelSub = null;
    _gyroSub?.cancel();
    _gyroSub = null;

    // Dispose interpreter after cancelling subscriptions to avoid a race where
    // an in-flight _performInference call still holds a reference.
    _interpreter?.close();
    _interpreter = null;

    _buffer.clear();
    _samplesSinceInference = 0;
    _consecutiveHighProb = 0;
    _gyroReady = false;
  }

  // ── Inference ────────────────────────────────────────────────────────────────

  void _performInference() {
    final interpreter = _interpreter;
    if (interpreter == null || !_isMonitoring) return;

    // ── 1. Snapshot the window ───────────────────────────────────────────────
    // Take the latest _kWindowSize samples from the circular buffer.
    // Because we cap _buffer at _kWindowSize, toList() gives exactly 100 rows.
    final rawWindow = _buffer.toList(); // List<List<double>>, length 100

    // ── 2. Normalize each axis independently ─────────────────────────────────
    // Formula: x_norm = (x - mean) / std
    // Applied per-axis to match (X_train - X_train_mean) / X_train_std in notebook.
    final normWindow = List<List<double>>.generate(_kWindowSize, (t) {
      final row = rawWindow[t];
      return List<double>.generate(6, (axis) {
        final std = _kNormStd[axis] > 0.0 ? _kNormStd[axis] : 1.0;
        return (row[axis] - _kNormMean[axis]) / std;
      });
    });

    // ── 3. Build input tensor [1, 100, 6] ───────────────────────────────────
    // tflite_flutter expects nested Lists that mirror the tensor shape:
    // outermost list = batch (size 1), then time (100), then features (6).
    final input = [normWindow]; // shape: [1][100][6]

    // ── 4. Build output tensor [1, 1] ────────────────────────────────────────
    final output = List<List<double>>.generate(
      1,
      (_) => List<double>.filled(1, 0.0),
    );

    // ── 5. Run inference ─────────────────────────────────────────────────────
    try {
      interpreter.run(input, output);
      final crashProbability = output[0][0];
      _log('Crash probability: ${crashProbability.toStringAsFixed(4)}');
      _evaluateProbability(crashProbability);
    } catch (e) {
      _log('Inference error: $e');
    }
  }

  // ── Threshold + consecutive-window logic ─────────────────────────────────────

  void _evaluateProbability(double prob) {
    final threshold = _getCrashThreshold();

    if (prob > threshold) {
      _consecutiveHighProb++;
      _log('High-prob window $_consecutiveHighProb / $_kConsecutiveRequired');
      if (_consecutiveHighProb >= _kConsecutiveRequired) {
        _consecutiveHighProb = 0;
        _handlePotentialCollision();
      }
    } else {
      // Single below-threshold window resets the counter (conservative but safe).
      // If you want less sensitivity to brief dips, you can use a decay instead:
      //   _consecutiveHighProb = max(0, _consecutiveHighProb - 1);
      _consecutiveHighProb = (_consecutiveHighProb > 0)
    ? _consecutiveHighProb - 1
    : 0;
    }
  }

  void _handlePotentialCollision() {
    if (!_isMonitoring) return;

    // De-bounce: ignore if a collision was already reported within 5 seconds
    final now = DateTime.now();
    if (_lastCollisionTime != null &&
        now.difference(_lastCollisionTime!) < const Duration(seconds: 5)) {
      return;
    }
    _lastCollisionTime = now;
    onCollisionDetected();
  }

  // ── Sensitivity / threshold ──────────────────────────────────────────────────

  double _getCrashThreshold() {
    if (_prefs == null) return 0.45; // default: medium
    final sensitivityIndex = _prefs!.getDouble('setting_sensitivity') ?? 1.0;
    if (sensitivityIndex == 0.0) return 0.85; // low sensitivity
    if (sensitivityIndex == 1.0) return 0.45; // medium sensitivity
    return 0.05;                               // high sensitivity
  }

  // ── Debug helpers ────────────────────────────────────────────────────────────

  void _debugModelShapes() {
    final interp = _interpreter;
    if (interp == null) return;
    for (final t in interp.getInputTensors()) {
      _log('MODEL INPUT  name=${t.name} shape=${t.shape} dtype=${t.type}');
    }
    for (final t in interp.getOutputTensors()) {
      _log('MODEL OUTPUT name=${t.name} shape=${t.shape} dtype=${t.type}');
    }
  }

  void _log(String msg) => debugPrint('[CollisionDetection] $msg');
}
