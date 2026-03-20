import 'dart:async';
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../routes/app_routes.dart';
import '../../services/sms_service.dart';

class AccidentDetectedScreen extends StatefulWidget {
  const AccidentDetectedScreen({super.key});

  @override
  State<AccidentDetectedScreen> createState() =>
      _AccidentDetectedScreenState();
}

class _AccidentDetectedScreenState extends State<AccidentDetectedScreen>
    with SingleTickerProviderStateMixin {
  int _countdown = 30;
  Timer? _timer;
  bool _isSending = false;
  final SmsService _smsService = SmsService();

  @override
  void initState() {
    super.initState();
    _startCountdown();
  }

  void _startCountdown() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        timer.cancel();
        _sendAlert();
      } else {
        setState(() => _countdown--);
      }
    });
  }

  Future<void> _sendAlert() async {
    setState(() => _isSending = true);

    try {
      await _smsService.sendEmergencySms();
      if (mounted) {
        Navigator.pushReplacementNamed(context, AppRoutes.alertSent);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Alert error: ${e.toString().replaceFirst('Exception: ', '')}"),
            backgroundColor: Colors.red,
          ),
        );
        // Still navigate to alert sent screen
        Navigator.pushReplacementNamed(context, AppRoutes.alertSent);
      }
    }
  }

  void _cancelAlert() {
    _timer?.cancel();
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (_) => false,
    );
  }

  Future<void> _callEmergencyServices() async {
    final Uri phoneUri = Uri(scheme: 'tel', path: '911');
    if (await canLaunchUrl(phoneUri)) {
      await launchUrl(phoneUri);
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Text("Accident Detected!"),
        automaticallyImplyLeading: false,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              /// Warning Icon
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.red.withOpacity(0.15),
                ),
                child: const Icon(
                  Icons.warning_amber_rounded,
                  size: 64,
                  color: Colors.red,
                ),
              ),

              const SizedBox(height: 24),

              Text(
                "Possible Accident Detected",
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 12),

              Text(
                "Emergency alerts will be sent in",
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: Colors.grey,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 20),

              /// Countdown Timer
              if (!_isSending) ...[
                Container(
                  width: 100,
                  height: 100,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.red, width: 4),
                  ),
                  child: Center(
                    child: Text(
                      "$_countdown",
                      style: const TextStyle(
                        fontSize: 42,
                        fontWeight: FontWeight.bold,
                        color: Colors.red,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  "seconds",
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ] else ...[
                const CircularProgressIndicator(),
                const SizedBox(height: 12),
                Text(
                  "Sending alerts...",
                  style: theme.textTheme.bodyLarge,
                ),
              ],

              const SizedBox(height: 32),

              /// Cancel Button
              if (!_isSending)
                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _cancelAlert,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.close),
                    label: const Text(
                      "I'm OK — Cancel Alert",
                      style: TextStyle(fontSize: 16),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              /// Send Now Button
              if (!_isSending)
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _timer?.cancel();
                      _sendAlert();
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: Colors.red),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    icon: const Icon(Icons.send, color: Colors.red),
                    label: const Text(
                      "Send Alert Now",
                      style: TextStyle(color: Colors.red),
                    ),
                  ),
                ),

              const SizedBox(height: 16),

              /// Call Emergency Services
              TextButton.icon(
                onPressed: _callEmergencyServices,
                icon: const Icon(Icons.phone, color: Colors.red),
                label: const Text(
                  "Call Emergency Services",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
