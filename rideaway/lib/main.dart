import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'firebase_options.dart';

import 'core/theme/app_theme.dart';
import 'core/theme/theme_controller.dart';
import 'routes/app_routes.dart';

import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/contacts/contacts_screen.dart';
import 'screens/settings/settings_screen.dart';
import 'screens/history/ride_history_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/auth/RegistrationScreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  final auth = FirebaseAuth.instance;
  if (auth.currentUser == null) {
    await auth.signInAnonymously();
  }

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
        AppRoutes.registration: (_) => const RegistrationScreen(),
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
