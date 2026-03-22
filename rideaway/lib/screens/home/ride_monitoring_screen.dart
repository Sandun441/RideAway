import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/collision_detection_service.dart';
import '../../services/email_service.dart';

class RideMonitoringScreen extends StatefulWidget {
  const RideMonitoringScreen({super.key});

  @override
  State<RideMonitoringScreen> createState() => _RideMonitoringScreenState();
}

class _RideMonitoringScreenState extends State<RideMonitoringScreen> {
  late CollisionDetectionService _collisionService;
  bool _isMonitoring = false;
  String _statusMessage = "Ready to start";

  @override
  void initState() {
    super.initState();
    _collisionService = CollisionDetectionService(
      onCollisionDetected: _handleCollision,
    );
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
    // Stop monitoring to prevent duplicate triggers
    _stopMonitoring();

    // Navigate to the countdown screen — it will handle SMS sending
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.accident);
    }
  }

  Future<void> _handleSimulatedAccident() async {
    _stopMonitoring();

    // Call the new EmailService
    final emailService = EmailService();
    await emailService.sendEmergencyEmail(
        location: 'Simulated Location (e.g. Lat: 40.7128, Lng: -74.0060)');

    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.accident);
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
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Monitoring Visual Indicator
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
            Text(
              "Keep the app open while riding",
              style: theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
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
            const SizedBox(height: 10),
            ElevatedButton.icon(
              onPressed: _handleSimulatedAccident,
              icon: const Icon(Icons.email),
              label: const Text("Test: Send Simulated Email Alert"),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
