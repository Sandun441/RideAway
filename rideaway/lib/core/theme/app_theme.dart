import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../constants/colors.dart';

class AppTheme {
  /// 🌞 LIGHT THEME
  static ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: AppColors.background,
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.light().textTheme,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.black),
    ),
    cardColor: Colors.white,
    dividerColor: Colors.grey.shade300,
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(AppColors.primary),
      trackColor: MaterialStateProperty.all(
        AppColors.primary.withOpacity(0.4),
      ),
    ),
  );

  /// 🌙 DARK THEME
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    primaryColor: AppColors.primary,
    scaffoldBackgroundColor: const Color(0xFF121212),
    textTheme: GoogleFonts.interTextTheme(
      ThemeData.dark().textTheme,
    ),
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: Color(0xFF1E1E1E),
      foregroundColor: Colors.white,
      iconTheme: IconThemeData(color: Colors.white),
    ),
    cardColor: const Color(0xFF1E1E1E),
    dividerColor: Colors.grey.shade700,
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.all(AppColors.primary),
      trackColor: MaterialStateProperty.all(
        AppColors.primary.withOpacity(0.5),
      ),
    ),
  );
}
