import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';
import '../../services/collision_detection_service.dart';
import '../../services/ride_service.dart';
import '../../models/ride_model.dart';

class RideMonitoringScreen extends StatefulWidget {
  const RideMonitoringScreen({super.key});

  @override
  State<RideMonitoringScreen> createState() => _RideMonitoringScreenState();
}

class _RideMonitoringScreenState extends State<RideMonitoringScreen>
    with SingleTickerProviderStateMixin {
  late CollisionDetectionService _collisionService;
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  bool _isMonitoring = false;
  String _statusMessage = 'Ready to start';
  DateTime? _rideStartTime;

  @override
  void initState() {
    super.initState();

    // Pulse animation for the monitoring indicator
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.9, end: 1.1).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _collisionService = CollisionDetectionService(
      onCollisionDetected: _handleCollision,
    );
    _startMonitoring();
  }

  Future<void> _startMonitoring() async {
    await _collisionService.startMonitoring();
    _rideStartTime = DateTime.now();
    if (mounted) {
      setState(() {
        _isMonitoring = true;
        _statusMessage = 'Monitoring Active';
      });
    }
  }

  void _stopMonitoring() {
    _collisionService.stopMonitoring();
    setState(() {
      _isMonitoring = false;
      _statusMessage = 'Monitoring Paused';
    });
  }

  Future<void> _handleCollision() async {
    _stopMonitoring();
    await _saveRide(RideStatus.incident);
    if (mounted) {
      Navigator.pushReplacementNamed(context, AppRoutes.accident);
    }
  }


  Future<void> _saveRide(RideStatus status, {String? alertNote}) async {
    if (_rideStartTime == null) return;
    try {
      final ride = RideModel(
        id: '',
        title: 'Ride on ${_formatDate(DateTime.now())}',
        status: status,
        startTime: _rideStartTime!,
        endTime: DateTime.now(),
        alertNote: alertNote,
      );
      await RideService().saveRide(ride);
    } catch (e) {
      debugPrint('Error saving ride: $e');
    }
  }

  String _formatDate(DateTime dt) {
    return '${dt.day}/${dt.month}/${dt.year}';
  }

  @override
  void dispose() {
    _collisionService.stopMonitoring();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ride Monitor'),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () async {
            _stopMonitoring();
            await _saveRide(RideStatus.safe);
            if (mounted) Navigator.pop(context);
          },
        ),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Monitoring Visual Indicator
            AnimatedBuilder(
              animation: _pulseAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: _isMonitoring ? _pulseAnimation.value : 1.0,
                  child: child,
                );
              },
              child: Container(
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
                  color:
                      _isMonitoring ? theme.colorScheme.primary : Colors.grey,
                ),
              ),
            ),
            const SizedBox(height: 40),
            Text(_statusMessage, style: theme.textTheme.headlineSmall),
            const SizedBox(height: 10),
            Text(
              'Keep the app open while riding',
              style:
                  theme.textTheme.bodyMedium?.copyWith(color: Colors.grey),
            ),
            const SizedBox(height: 40),
            ElevatedButton.icon(
              onPressed:
                  _isMonitoring ? _stopMonitoring : _startMonitoring,
              icon: Icon(_isMonitoring ? Icons.pause : Icons.play_arrow),
              label: Text(
                _isMonitoring ? 'Pause Monitoring' : 'Resume Monitoring',
              ),
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(
                  horizontal: 32,
                  vertical: 16,
                ),
              ),
            ),
            const SizedBox(height: 20),

          ],
        ),
      ),
    );
  }
}
