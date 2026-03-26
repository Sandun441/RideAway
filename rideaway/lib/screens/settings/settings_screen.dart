import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/theme/theme_controller.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  double sensitivity = 1; // 0 = Low, 1 = Medium, 2 = High
  bool gpsEnabled = true;
  bool pushNotifications = true;
  bool vibrationAlerts = true;
  String countdown = "30 seconds";
  String theme = "Auto (System)";

  // SharedPreferences keys
  static const String _keySensitivity = 'setting_sensitivity';
  static const String _keyGps = 'setting_gps';
  static const String _keyPush = 'setting_push';
  static const String _keyVibration = 'setting_vibration';
  static const String _keyCountdown = 'setting_countdown';

  String get sensitivityLabel =>
      ["Low", "Medium", "High"][sensitivity.toInt()];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      sensitivity = prefs.getDouble(_keySensitivity) ?? 1;
      gpsEnabled = prefs.getBool(_keyGps) ?? true;
      pushNotifications = prefs.getBool(_keyPush) ?? true;
      vibrationAlerts = prefs.getBool(_keyVibration) ?? true;
      countdown = prefs.getString(_keyCountdown) ?? "30 seconds";

      // Sync dropdown with current theme
      final mode = ThemeController.themeMode.value;
      if (mode == ThemeMode.dark) {
        theme = "Dark";
      } else if (mode == ThemeMode.light) {
        theme = "Light";
      } else {
        theme = "Auto (System)";
      }
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is double) {
      await prefs.setDouble(key, value);
    } else if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is String) {
      await prefs.setString(key, value);
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeData = Theme.of(context);

    return Scaffold(
      backgroundColor: themeData.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Settings"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Detection Settings
            _card(
              context,
              title: "Detection Settings",
              icon: Icons.shield_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _rowTitle(context, "Detection Sensitivity", sensitivityLabel),
                  Slider(
                    value: sensitivity,
                    min: 0,
                    max: 2,
                    divisions: 2,
                    label: sensitivityLabel,
                    onChanged: (value) {
                      setState(() => sensitivity = value);
                      _saveSetting(_keySensitivity, value);
                    },
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: const [
                      Text("Low"),
                      Text("Medium"),
                      Text("High"),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    "Higher sensitivity detects smaller impacts but may cause false alerts.",
                    style: themeData.textTheme.bodySmall,
                  ),
                  const SizedBox(height: 10),
                  _switchTile(
                    "GPS Location Tracking",
                    "Share location in emergency alerts",
                    gpsEnabled,
                    (val) {
                      setState(() => gpsEnabled = val);
                      _saveSetting(_keyGps, val);
                    },
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Notifications
            _card(
              context,
              title: "Notifications",
              icon: Icons.notifications_outlined,
              child: Column(
                children: [
                  _switchTile(
                    "Push Notifications",
                    "Receive app notifications",
                    pushNotifications,
                    (val) {
                      setState(() => pushNotifications = val);
                      _saveSetting(_keyPush, val);
                    },
                  ),
                  _switchTile(
                    "Vibration Alerts",
                    "Vibrate during accident detection",
                    vibrationAlerts,
                    (val) {
                      setState(() => vibrationAlerts = val);
                      _saveSetting(_keyVibration, val);
                    },
                  ),
                  _dropdownTile(
                    "Emergency Countdown",
                    countdown,
                    ["15 seconds", "30 seconds", "60 seconds"],
                    (val) {
                      setState(() => countdown = val!);
                      _saveSetting(_keyCountdown, val!);
                    },
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 16, bottom: 8),
                    child: Text(
                      "Time before emergency contacts are notified",
                      style: themeData.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Appearance
            _card(
              context,
              title: "Appearance",
              icon: Icons.palette_outlined,
              child: _dropdownTile(
                "Theme",
                theme,
                ["Auto (System)", "Light", "Dark"],
                (val) {
                  setState(() => theme = val!);

                  if (val == "Light") {
                    ThemeController.setThemeMode(ThemeMode.light);
                  } else if (val == "Dark") {
                    ThemeController.setThemeMode(ThemeMode.dark);
                  } else {
                    ThemeController.setThemeMode(ThemeMode.system);
                  }
                },
              ),
            ),

            const SizedBox(height: 20),

            /// Privacy & Legal
            _card(
              context,
              title: "Privacy & Legal",
              icon: Icons.privacy_tip_outlined,
              child: Column(
                children: [
                  ListTile(
                    title: const Text("Privacy Policy"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showInfoDialog(
                      context,
                      'Privacy Policy',
                      'RideAway collects your location data and contact information solely for emergency '  
                      'alert purposes. This data is never shared with third parties and is stored '
                      'securely in Firebase.',
                    ),
                  ),
                  ListTile(
                    title: const Text("Terms of Service"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showInfoDialog(
                      context,
                      'Terms of Service',
                      'By using RideAway, you agree to use the app responsibly. The app is provided '
                      '"as-is" and should not be relied upon as your sole safety device. Always '
                      'follow local traffic laws.',
                    ),
                  ),
                  ListTile(
                    title: const Text("Data Usage"),
                    trailing: const Icon(Icons.chevron_right),
                    onTap: () => _showInfoDialog(
                      context,
                      'Data Usage',
                      'RideAway stores your profile, emergency contacts, and ride history in Google '
                      'Firebase Firestore. Sensor data (accelerometer) is processed locally on your '
                      'device and never uploaded.',
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// Footer
            Column(
              children: [
                Text(
                  "RideAway",
                  style: themeData.textTheme.titleMedium
                      ?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                Text(
                  "Version 1.0.0",
                  style: themeData.textTheme.bodySmall,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable widgets

  Widget _card(
    BuildContext context, {
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    final themeData = Theme.of(context);

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: themeData.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: themeData.colorScheme.primary),
              const SizedBox(width: 8),
              Text(
                title,
                style: themeData.textTheme.titleMedium
                    ?.copyWith(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _rowTitle(BuildContext context, String left, String right) {
    final themeData = Theme.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left,
            style: themeData.textTheme.bodyMedium
                ?.copyWith(fontWeight: FontWeight.w600)),
        Text(right,
            style:
                themeData.textTheme.bodyMedium?.copyWith(color: Colors.blue)),
      ],
    );
  }

  Widget _switchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return SwitchListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      subtitle: Text(subtitle),
      value: value,
      onChanged: onChanged,
    );
  }

  Widget _dropdownTile(
    String title,
    String value,
    List<String> items,
    Function(String?) onChanged,
  ) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      title: Text(title),
      trailing: DropdownButton<String>(
        value: value,
        underline: const SizedBox(),
        items: items
            .map(
              (e) => DropdownMenuItem(value: e, child: Text(e)),
            )
            .toList(),
        onChanged: onChanged,
      ),
    );
  }

  void _showInfoDialog(BuildContext context, String title, String content) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title),
        content: Text(content),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}
