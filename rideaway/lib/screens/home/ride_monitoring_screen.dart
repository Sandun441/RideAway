import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/collision_detection_service.dart';
import '../../services/sms_service.dart';

class RideMonitoringScreen extends StatefulWidget {
  const RideMonitoringScreen({super.key});

  @override
  State<RideMonitoringScreen> createState() => _RideMonitoringScreenState();
}

class _RideMonitoringScreenState extends State<RideMonitoringScreen> {
  late CollisionDetectionService _collisionService;
  final SmsService _smsService = SmsService();
  bool _isMonitoring = false;
  String _statusMessage = "Ready to start";

  @override
  void initState() {
    super.initState();
    _collisionService = CollisionDetectionService(
      onCollisionDetected: _handleCollision,
    );
    // Auto-start monitoring when screen opens? Or wait for user?
    // Let's auto-start for "Start Monitoring" flow.
    _startMonitoring();
  }

  void _startMonitoring() {
    _collisionService.startMonitoring();
    setState(() {
      _isMonitoring = true;
      _statusMessage = "Monitoring Active";
    });
  }

  void _stopMonitoring() {
    _collisionService.stopMonitoring();
    setState(() {
      _isMonitoring = false;
      _statusMessage = "Monitoring Paused";
    });
  }

  Future<void> _handleCollision() async {
    // 1. Stop monitoring to prevent duplicate triggers
    _stopMonitoring();

    // 2. Navigate to "Accident Detected" immediately so user sees it
    // In a real app, we might give a 10s countdown to cancel.
    // For this MVP, we send immediately or just go to the screen.
    // The requirement: "when collition detect, automatically send sms"

    // Let's send SMS first or in parallel
    try {
      await _smsService.sendEmergencySms();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.alertSent);
      }
    } catch (e) {
      // If SMS fails, still show accident screen but maybe with error?
      // Or just go to accident screen which lets them try again.
      print("Error sending SMS: $e");
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.accident);
      }
    }
  }

  @override
  void dispose() {
    _collisionService.stopMonitoring();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text("Ride Monitor"),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => Navigator.pop(context), // Stop & Exit
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Pulsing Animation or Icon
            Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isMonitoring
                    ? theme.colorScheme.primary.withOpacity(0.1)
                    : Colors.grey.withOpacity(0.1),
                border: Border.all(
                  color: _isMonitoring
                      ? theme.colorScheme.primary
                      : Colors.grey,
                  width: 2,
                ),
              ),
              child: Icon(
                Icons.directions_bike,
                size: 80,
                color: _isMonitoring ? theme.colorScheme.primary : Colors.grey,
              ),
            ),
            const SizedBox(height: 40),
            Text(_statusMessage, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 10),
            const Text(
              "Keep the app open while riding",
              style: TextStyle(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed: _isMonitoring ? _stopMonitoring : _startMonitoring,
              icon: Icon(_isMonitoring ? Icons.pause : Icons.play_arrow),
              label: Text(
                _isMonitoring ? "Pause Monitoring" : "Resume Monitoring",
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),
            // Test Button for Debugging
            TextButton(
              onPressed: _handleCollision,
              child: const Text("Simulate Collision (Test)"),
            ),
          ],
        ),
      ),
    );
  }
}
