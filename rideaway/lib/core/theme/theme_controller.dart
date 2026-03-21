import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeController {
  static final ValueNotifier<ThemeMode> themeMode =
      ValueNotifier(ThemeMode.light);

  static const String _themeKey = 'theme_mode';

  static void toggleTheme(bool isDark) {
    themeMode.value = isDark ? ThemeMode.dark : ThemeMode.light;
    _saveTheme();
  }

  static void setThemeMode(ThemeMode mode) {
    themeMode.value = mode;
    _saveTheme();
  }

  static Future<void> _saveTheme() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, themeMode.value.name);
  }

  static Future<void> loadSavedTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final saved = prefs.getString(_themeKey);
    if (saved != null) {
      switch (saved) {
        case 'dark':
          themeMode.value = ThemeMode.dark;
          break;
        case 'light':
          themeMode.value = ThemeMode.light;
          break;
        case 'system':
          themeMode.value = ThemeMode.system;
          break;
      }
    }
  }
}
