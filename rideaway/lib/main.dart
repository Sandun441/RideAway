import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'controllers/theme_controller.dart'; // Import the theme controller
import 'routes/app_routes.dart';
import 'screens/splash/splash_screen.dart';
import 'screens/onboarding/onboarding_screen.dart';
import 'screens/auth/login_screen.dart';
import 'screens/auth/registration_screen.dart';
import 'screens/home/home_screen.dart';
import 'screens/profile/profile_screen.dart';
import 'screens/accident/accident_detected_screen.dart'; // Ensure these are created or comment them out
import 'screens/accident/alert_sent_screen.dart'; // Ensure these are created or comment them out
import 'screens/settings/settings_screen.dart'; // Import settings

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // Wrap MaterialApp in ValueListenableBuilder to listen to theme changes
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeController.themeMode,
      builder: (context, currentMode, _) {
        return MaterialApp(
          title: 'RideAway',
          debugShowCheckedModeBanner: false,

          // Theme Setup
          themeMode: currentMode,
          theme: ThemeData(
            primarySwatch: Colors.blue,
            scaffoldBackgroundColor: const Color(0xFFF5F7FA),
            useMaterial3: true,
            brightness: Brightness.light,
          ),
          darkTheme: ThemeData(
            brightness: Brightness.dark,
            useMaterial3: true,
          ),

          initialRoute: AppRoutes.splash,

          // REMOVED 'const' from the routes below to fix your error
          routes: {
            AppRoutes.splash: (_) => const SplashScreen(),
            AppRoutes.onboarding: (_) => const OnboardingScreen(),
            AppRoutes.login: (_) => const LoginScreen(),
            AppRoutes.registration: (_) => const RegistrationScreen(),
            AppRoutes.home: (_) => const HomeScreen(),
            AppRoutes.profile: (_) => const ProfileScreen(),
            AppRoutes.settings: (_) => const SettingsScreen(),

            // If these screens have non-final fields, remove 'const' like this:
            AppRoutes.accident: (_) => const AccidentDetectedScreen(),
            AppRoutes.alertSent: (_) => const AlertSentScreen(),
          },
        );
      },
    );
  }
}
