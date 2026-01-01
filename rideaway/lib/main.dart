import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart'; // Add this import
import 'firebase_options.dart'; // Add this import (auto-generated)

import 'core/theme/app_theme.dart';
import 'routes/app_routes.dart';

import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/accident/accident_detected_screen.dart';
import 'screens/accident/alert_sent_screen.dart';
import 'screens/contacts/contacts_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/history/ride_history_screen.dart';
import 'screens/profile/profile_screen.dart';

// Change main to async to support initialization
void main() async {
  // Ensure the framework is fully initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase with the correct platform options
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const SmartRideApp());
}

class SmartRideApp extends StatelessWidget {
  const SmartRideApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      routes: {
        AppRoutes.splash: (_) => const SplashScreen(),
        AppRoutes.onboarding: (_) => const OnboardingScreen(),
        AppRoutes.login: (_) => const LoginScreen(),
        AppRoutes.home: (_) => const HomeScreen(),
        AppRoutes.accident: (_) => const AccidentDetectedScreen(),
        AppRoutes.alertSent: (_) => const AlertSentScreen(),
        AppRoutes.contacts: (_) => const ContactsScreen(),
        AppRoutes.settings: (_) => const SettingsScreen(),
        AppRoutes.profile: (_) => const ProfileScreen(),
        AppRoutes.history: (_) => const RideHistoryScreen(),
      },
    );
  }
}
