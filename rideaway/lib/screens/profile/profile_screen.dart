import 'package:flutter/material.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () {}),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Profile Card
            _card(
              context,
              child: Column(
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        radius: 28,
                        backgroundColor: theme.colorScheme.primary,
                        child: const Text(
                          "AJ",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Alex Johnson",
                              style: theme.textTheme.bodyLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              "Cycling enthusiast since 2020",
                              style: theme.textTheme.bodySmall,
                            ),
                            const SizedBox(height: 6),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.green.withOpacity(0.15),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: const Text(
                                "Verified Rider",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.green,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _infoRow(
                    context,
                    Icons.email_outlined,
                    "alex.johnson@email.com",
                  ),
                  _infoRow(context, Icons.phone_outlined, "+1 (555) 123-4567"),
                  _infoRow(
                    context,
                    Icons.location_on_outlined,
                    "San Francisco, CA",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Riding Statistics
            _card(
              context,
              title: "Riding Statistics",
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: const [
                  _StatItem(
                    value: "47",
                    label: "Total Rides",
                    color: Colors.blue,
                  ),
                  _StatItem(
                    value: "342 km",
                    label: "Distance",
                    color: Colors.green,
                  ),
                  _StatItem(
                    value: "98%",
                    label: "Safety Score",
                    color: Colors.purple,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Safety Features
            _card(
              context,
              title: "Safety Features",
              child: Column(
                children: [
                  _featureTile("Accident Detection", "Enabled", Colors.green),
                  _featureTile("Location Sharing", "Active", Colors.blue),
                  _featureTile("Emergency Contacts", "Configured", Colors.grey),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Account
            _card(
              context,
              title: "Account",
              child: Column(
                children: const [
                  ListTile(
                    title: Text("Privacy Settings"),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  ListTile(
                    title: Text("Notification Preferences"),
                    trailing: Icon(Icons.chevron_right),
                  ),
                  ListTile(
                    title: Text("Help & Support"),
                    trailing: Icon(Icons.chevron_right),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// Footer
            Column(
              children: [
                Text(
                  "Smart Ride Safety",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Version 1.2.3 · Terms · Privacy",
                  style: theme.textTheme.bodySmall,
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// Sign Out
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () => Navigator.pop(context),
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  "Sign Out",
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Reusable Card (THEME AWARE)
  Widget _card(BuildContext context, {String? title, required Widget child}) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
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
          if (title != null) ...[
            Text(
              title,
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String text) {
    final theme = Theme.of(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: Row(
        children: [
          Icon(icon, size: 18, color: theme.iconTheme.color),
          const SizedBox(width: 8),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }
}

/// Statistic Item
class _StatItem extends StatelessWidget {
  final String value;
  final String label;
  final Color color;

  const _StatItem({
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
        const SizedBox(height: 4),
        Text(label, style: theme.textTheme.bodySmall),
      ],
    );
  }
}

/// Feature Tile
Widget _featureTile(String title, String status, Color color) {
  return ListTile(
    leading: CircleAvatar(
      radius: 18,
      backgroundColor: color.withOpacity(0.15),
      child: Icon(Icons.check, color: color),
    ),
    title: Text(title),
    trailing: Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(status, style: TextStyle(color: color, fontSize: 12)),
    ),
  );
}
