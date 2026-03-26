import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 2));
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user != null && !user.isAnonymous) {
      // Already logged in — go home
      Navigator.of(context).pushReplacementNamed(AppRoutes.home);
    } else {
      // Check if user has seen onboarding before
      final prefs = await SharedPreferences.getInstance();
      final seenOnboarding = prefs.getBool('seen_onboarding') ?? false;
      if (!mounted) return;

      if (seenOnboarding) {
        Navigator.of(context).pushReplacementNamed(AppRoutes.login);
      } else {
        Navigator.of(context).pushReplacementNamed(AppRoutes.onboarding);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.directions_bike,
                size: 80, color: theme.colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'RideAway',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'Detect & Alert',
              style: theme.textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}
