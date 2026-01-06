import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../../services/db_service.dart';
import '../../routes/app_routes.dart';
import 'edit_profile_screen.dart'; // Ensure you created this file from the previous step
import 'package:cloud_firestore/cloud_firestore.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Data Variables
  Map<String, dynamic> _userData =
      {}; // Store raw data for passing to Edit Screen
  String _fullName = "Loading...";
  String _email = "Loading...";
  String _phone = "Not set";
  String _location = "Not set";
  String _initials = "..";

  // Verification State
  bool _isVerified = false;
  bool _isLoading = true;

  // Track specific missing items for the UI
  bool _missingPhone = true;
  bool _missingLocation = true;
  bool _missingContact = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  void _fetchUserData() async {
    final User? currentUser = FirebaseAuth.instance.currentUser;

    if (currentUser != null) {
      try {
        // 1. Fetch main user document (for Name, Phone, Location)
        final data = await DatabaseService().getUser(currentUser.uid);

        // 2. NEW: Fetch the contacts sub-collection to check if it's empty
        // This looks at /users/UID/contacts
        final contactSnapshot = await FirebaseFirestore.instance
            .collection('users')
            .doc(currentUser.uid)
            .collection('contacts')
            .get();

        if (data != null && mounted) {
          setState(() {
            _userData = data;
            _fullName = data['fullName'] ?? "Unknown";
            _email = data['email'] ?? currentUser.email;

            // Helper to check if string is valid
            bool hasText(String? val) => val != null && val.trim().isNotEmpty;

            _phone = hasText(data['phone']) ? data['phone'] : "Not set";
            _location = hasText(data['location'])
                ? data['location']
                : "Not set";

            // Initials Logic
            if (_fullName.isNotEmpty && _fullName != "Loading...") {
              _initials = _fullName
                  .trim()
                  .split(' ')
                  .map((l) => l.isNotEmpty ? l[0] : '')
                  .take(2)
                  .join()
                  .toUpperCase();
            }

            // --- REFRESHED VERIFICATION LOGIC ---
            _missingPhone = !hasText(data['phone']);
            _missingLocation = !hasText(data['location']);

            // This is the fix: It counts the documents in your sub-collection
            _missingContact = contactSnapshot.docs.isEmpty;

            // Verified only if all 3 requirements are met
            _isVerified =
                !_missingPhone && !_missingLocation && !_missingContact;

            _isLoading = false;
          });
        }
      } catch (e) {
        debugPrint("Error fetching data: $e");
        if (mounted) setState(() => _isLoading = false);
      }
    }
  }

  // 2. Navigate to Edit Screen
  void _navigateToEdit() async {
    // We wait for the result. If 'true' returned, it means data changed.
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(currentData: _userData),
      ),
    );

    // Refresh data if saved
    if (result == true) {
      setState(() => _isLoading = true);
      _fetchUserData();
    }
  }

  // 3. Handle Sign Out
  void _handleSignOut() async {
    await AuthService().signOut();
    if (mounted) {
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.login,
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _navigateToEdit, // Connected Edit Function
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  /// Profile Card
                  _card(
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue,
                              child: Text(
                                _initials,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _fullName,
                                    style: const TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 6),

                                  // --- VERIFIED / UNVERIFIED BADGE ---
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 5,
                                    ),
                                    decoration: BoxDecoration(
                                      color: _isVerified
                                          ? Colors.green.shade100
                                          : Colors.orange.shade100,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _isVerified
                                              ? Icons.verified
                                              : Icons.warning_amber_rounded,
                                          size: 16,
                                          color: _isVerified
                                              ? Colors.green.shade700
                                              : Colors.deepOrange.shade700,
                                        ),
                                        const SizedBox(width: 5),
                                        Text(
                                          _isVerified
                                              ? "Verified Account"
                                              : "Action Required",
                                          style: TextStyle(
                                            fontSize: 12,
                                            color: _isVerified
                                                ? Colors.green.shade800
                                                : Colors.deepOrange.shade800,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        // --- MISSING ITEMS LIST (Only shows if unverified) ---
                        if (!_isVerified) ...[
                          const Divider(),
                          const Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Complete profile to verify:",
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.grey,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_missingPhone) _missingItem("Add Phone Number"),
                          if (_missingLocation) _missingItem("Add Location"),
                          if (_missingContact)
                            _missingItem("Add at least 1 Emergency Contact"),
                          const SizedBox(height: 10),
                        ],

                        const Divider(),
                        _infoRow(Icons.email_outlined, _email),
                        _infoRow(Icons.phone_outlined, _phone),
                        _infoRow(Icons.location_on_outlined, _location),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Statistics Card (Placeholders)
                  _card(
                    title: "Riding Statistics",
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: const [
                        _StatItem(
                          value: "0",
                          label: "Total Rides",
                          color: Colors.blue,
                        ),
                        _StatItem(
                          value: "0 km",
                          label: "Distance",
                          color: Colors.green,
                        ),
                        _StatItem(
                          value: "-",
                          label: "Safety Score",
                          color: Colors.purple,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Safety Features Status
                  _card(
                    title: "Safety Features",
                    child: Column(
                      children: [
                        _featureTile(
                          "Accident Detection",
                          "Ready",
                          Colors.green,
                        ),
                        _featureTile(
                          "Location Sharing",
                          _missingLocation ? "Missing Info" : "Ready",
                          _missingLocation ? Colors.orange : Colors.blue,
                        ),
                        _featureTile(
                          "Emergency Contacts",
                          _missingContact ? "Empty" : "Configured",
                          _missingContact ? Colors.red : Colors.green,
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  /// Footer
                  const Column(
                    children: [
                      Text(
                        "Smart Ride Safety",
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      SizedBox(height: 4),
                      Text(
                        "Version 1.0.0",
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  /// Sign Out Button
                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: _handleSignOut,
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

  // --- HELPER WIDGETS ---

  Widget _missingItem(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          const Icon(Icons.cancel, size: 14, color: Colors.redAccent),
          const SizedBox(width: 8),
          Text(
            text,
            style: const TextStyle(fontSize: 13, color: Colors.redAccent),
          ),
        ],
      ),
    );
  }

  Widget _card({String? title, required Widget child}) {
    return Container(
      width: double.infinity,
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
          if (title != null) ...[
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _infoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey),
          const SizedBox(width: 8),
          Text(text, style: const TextStyle(fontSize: 14)),
        ],
      ),
    );
  }

  Widget _featureTile(String title, String status, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(
          status == "Empty" || status == "Missing Info"
              ? Icons.priority_high
              : Icons.check,
          color: color,
          size: 16,
        ),
      ),
      title: Text(title, style: const TextStyle(fontSize: 14)),
      trailing: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

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
        Text(label, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
