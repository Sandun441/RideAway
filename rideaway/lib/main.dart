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
import 'screens/accident/accident_detected_screen.dart';
import 'screens/accident/alert_sent_screen.dart';

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
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, mode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.darkTheme,
          themeMode: mode,

          home: const LoginScreen(),
          routes: {
            AppRoutes.home: (_) => const HomeScreen(),
            AppRoutes.contacts: (_) => const ContactsScreen(),
            AppRoutes.settings: (_) => const SettingsScreen(),
            AppRoutes.history: (_) => const RideHistoryScreen(),
            AppRoutes.profile: (_) => const ProfileScreen(),
            AppRoutes.accident: (_) => const AccidentDetectedScreen(),
            AppRoutes.alertSent: (_) => const AlertSentScreen(),
          },
        );
      },
    );
  }
}
