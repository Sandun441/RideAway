import 'package:flutter/material.dart';
import '../../routes/app_routes.dart';

class AlertSentScreen extends StatelessWidget {
  const AlertSentScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.green,
        foregroundColor: Colors.white,
        title: const Text("Emergency Alert Sent"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            /// SUCCESS CARD
            _card(
              context,
              child: Column(
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.green.withOpacity(0.15),
                    child: const Icon(
                      Icons.check,
                      color: Colors.green,
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    "Alert Successfully Sent",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    "Your emergency contacts have been notified of your accident",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Text(
                      "Sent at 2:34 PM",
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            /// MAP / LOCATION
            Container(
              height: 120,
              width: double.infinity,
              decoration: BoxDecoration(
                color: isDark ? Colors.grey.shade800 : Colors.green.shade50,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: const [
                  Icon(Icons.location_on, size: 30, color: Colors.red),
                  SizedBox(height: 6),
                  Text(
                    "Downtown Park Trail, Mile 3.2",
                    style: TextStyle(fontSize: 13),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// CONTACTS NOTIFIED
            _sectionTitle("Contacts Notified"),
            _card(
              context,
              child: Column(
                children: const [
                  _ContactTile(
                    name: "Mom",
                    phone: "+1 (555) 123-4567",
                    tag: "Family",
                  ),
                  _ContactTile(
                    name: "Dr. Sarah Wilson",
                    phone: "+1 (555) 987-6543",
                    tag: "Doctor",
                  ),
                  _ContactTile(
                    name: "Emergency Services",
                    phone: "911",
                    tag: "Emergency",
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ALERT DETAILS
            _sectionTitle("Alert Details"),
            _card(
              context,
              child: Column(
                children: const [
                  _DetailRow("Time Detected", "2:34:12 PM"),
                  _DetailRow("Location", "Downtown Park Trail"),
                  _DetailRow("Impact Level", "High", valueColor: Colors.red),
                  _DetailRow("Speed at Impact", "23 mph"),
                ],
              ),
            ),

            const SizedBox(height: 24),

            /// ACTION BUTTONS
            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushNamedAndRemoveUntil(
                    context,
                    AppRoutes.home,
                    (_) => false,
                  );
                },
                child: const Text("Return to Home"),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton(
                onPressed: () {},
                child: const Text("Call Emergency Services"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// CARD
  Widget _card(BuildContext context, {required Widget child}) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: child,
    );
  }

  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        title,
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
    );
  }
}

/// CONTACT TILE
class _ContactTile extends StatelessWidget {
  final String name;
  final String phone;
  final String tag;

  const _ContactTile({
    required this.name,
    required this.phone,
    required this.tag,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: const CircleAvatar(
        backgroundColor: Colors.green,
        child: Icon(Icons.phone, color: Colors.white, size: 18),
      ),
      title: Text(name),
      subtitle: Text(phone),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.grey.shade200,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(tag, style: const TextStyle(fontSize: 12)),
      ),
    );
  }
}

/// DETAIL ROW
class _DetailRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;

  const _DetailRow(this.label, this.value, {this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(color: Colors.grey)),
          Text(
            value,
            style: TextStyle(fontWeight: FontWeight.w600, color: valueColor),
          ),
        ],
      ),
    );
  }
}
