import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
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
              title: "Detection Settings",
              icon: Icons.shield_outlined,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _rowTitle("Detection Sensitivity", "Medium"),
                  Slider(
                    value: sensitivity,
                    min: 0,
                    max: 2,
                    divisions: 2,
                    label: ["Low", "Medium", "High"][sensitivity.toInt()],
                    onChanged: (value) {
                      setState(() => sensitivity = value);
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
                  const SizedBox(height: 10),
                  const Text(
                    "Higher sensitivity detects smaller impacts but may cause false alerts.",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  const SizedBox(height: 10),
                  _switchTile(
                    "GPS Location Tracking",
                    "Share location in emergency alerts",
                    gpsEnabled,
                        (val) => setState(() => gpsEnabled = val),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Notifications
            _card(
              title: "Notifications",
              icon: Icons.notifications_outlined,
              child: Column(
                children: [
                  _switchTile(
                    "Push Notifications",
                    "Receive app notifications",
                    pushNotifications,
                        (val) => setState(() => pushNotifications = val),
                  ),
                  _switchTile(
                    "Vibration Alerts",
                    "Vibrate during accident detection",
                    vibrationAlerts,
                        (val) => setState(() => vibrationAlerts = val),
                  ),
                  _dropdownTile(
                    "Emergency Countdown",
                    countdown,
                    ["15 seconds", "30 seconds", "60 seconds"],
                        (val) => setState(() => countdown = val!),
                  ),
                  const Text(
                    "Time before emergency contacts are notified",
                    style: TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Appearance
            _card(
              title: "Appearance",
              icon: Icons.palette_outlined,
              child: _dropdownTile(
                "Theme",
                theme,
                ["Auto (System)", "Light", "Dark"],
                    (val) => setState(() => theme = val!),
              ),
            ),

            const SizedBox(height: 20),

            /// Privacy & Legal
            _card(
              title: "Privacy & Legal",
              icon: Icons.privacy_tip_outlined,
              child: Column(
                children: const [
                  ListTile(
                    title: Text("Privacy Policy"),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  ListTile(
                    title: Text("Terms of Service"),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  ListTile(
                    title: Text("Data Usage"),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 30),

            /// Footer
            const Column(
              children: [
                Text("Smart Ride Safety",
                    style: TextStyle(fontWeight: FontWeight.bold)),
                SizedBox(height: 4),
                Text("Version 1.2.3",
                    style: TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable Card
  Widget _card({
    required String title,
    required IconData icon,
    required Widget child,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
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
              Icon(icon, color: Colors.blue),
              const SizedBox(width: 8),
              Text(title,
                  style: const TextStyle(fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }

  Widget _rowTitle(String left, String right) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(left, style: const TextStyle(fontWeight: FontWeight.w600)),
        Text(right, style: const TextStyle(color: Colors.blue)),
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
}
