import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../services/auth_service.dart';
import '../../services/db_service.dart';
import '../../routes/app_routes.dart';
import 'edit_profile_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Map<String, dynamic> _userData = {};
  String _fullName = "Loading...";
  String _email = "Loading...";
  String _phone = "Not set";
  String _location = "Not set";
  String _initials = "..";

  bool _isVerified = false;
  bool _isLoading = true;

  bool _missingPhone = true;
  bool _missingLocation = true;
  bool _missingContact = true;

  @override
  void initState() {
    super.initState();
    _fetchUserData();
  }

  Future<void> _fetchUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;

    try {
      final data = await DatabaseService().getUser(user.uid);

      final contacts = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('contacts')
          .get();

      if (!mounted) return;

      bool hasText(String? v) => v != null && v.trim().isNotEmpty;

      setState(() {
        _userData = data ?? {};
        _fullName = data?['fullName'] ?? "Unknown";
        _email = data?['email'] ?? user.email ?? "Unknown";
        _phone = hasText(data?['phone']) ? data!['phone'] : "Not set";
        _location =
            hasText(data?['location']) ? data!['location'] : "Not set";

        _initials = _fullName
            .split(' ')
            .map((e) => e.isNotEmpty ? e[0] : '')
            .take(2)
            .join()
            .toUpperCase();

        _missingPhone = !hasText(data?['phone']);
        _missingLocation = !hasText(data?['location']);
        _missingContact = contacts.docs.isEmpty;

        _isVerified =
            !_missingPhone && !_missingLocation && !_missingContact;

        _isLoading = false;
      });
    } catch (e) {
      debugPrint("Profile error: $e");
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _navigateToEdit() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => EditProfileScreen(currentData: _userData),
      ),
    );

    if (result == true) {
      setState(() => _isLoading = true);
      _fetchUserData();
    }
  }

  void _handleSignOut() async {
    await AuthService().signOut();
    if (!mounted) return;
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.login,
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Profile"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined),
            onPressed: _navigateToEdit,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  _card(
                    theme,
                    child: Column(
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: colors.primary,
                              child: Text(
                                _initials,
                                style: TextStyle(
                                  color: colors.onPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment:
                                    CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _fullName,
                                    style: theme.textTheme.titleMedium
                                        ?.copyWith(
                                            fontWeight:
                                                FontWeight.bold),
                                  ),
                                  const SizedBox(height: 6),
                                  Container(
                                    padding:
                                        const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 4),
                                    decoration: BoxDecoration(
                                      color: _isVerified
                                          ? colors.primaryContainer
                                          : colors.errorContainer,
                                      borderRadius:
                                          BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize:
                                          MainAxisSize.min,
                                      children: [
                                        Icon(
                                          _isVerified
                                              ? Icons.verified
                                              : Icons
                                                  .warning_amber_rounded,
                                          size: 16,
                                          color: _isVerified
                                              ? colors
                                                  .onPrimaryContainer
                                              : colors
                                                  .onErrorContainer,
                                        ),
                                        const SizedBox(width: 6),
                                        Text(
                                          _isVerified
                                              ? "Verified Account"
                                              : "Action Required",
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight:
                                                FontWeight.bold,
                                            color: _isVerified
                                                ? colors
                                                    .onPrimaryContainer
                                                : colors
                                                    .onErrorContainer,
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

                        if (!_isVerified) ...[
                          const SizedBox(height: 16),
                          Divider(color: colors.outlineVariant),
                          Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Complete profile to verify:",
                              style:
                                  theme.textTheme.labelSmall,
                            ),
                          ),
                          const SizedBox(height: 8),
                          if (_missingPhone)
                            _missingItem(
                                theme, "Add Phone Number"),
                          if (_missingLocation)
                            _missingItem(
                                theme, "Add Location"),
                          if (_missingContact)
                            _missingItem(theme,
                                "Add Emergency Contact"),
                        ],

                        const SizedBox(height: 16),
                        Divider(color: colors.outlineVariant),
                        _infoRow(
                            theme, Icons.email_outlined, _email),
                        _infoRow(theme,
                            Icons.phone_outlined, _phone),
                        _infoRow(
                            theme,
                            Icons.location_on_outlined,
                            _location),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  _card(
                    theme,
                    title: "Safety Features",
                    child: Column(
                      children: [
                        _featureTile(theme, "Accident Detection",
                            "Ready", colors.primary),
                        _featureTile(
                            theme,
                            "Location Sharing",
                            _missingLocation
                                ? "Missing"
                                : "Ready",
                            _missingLocation
                                ? colors.error
                                : colors.secondary),
                        _featureTile(
                            theme,
                            "Emergency Contacts",
                            _missingContact
                                ? "Empty"
                                : "Configured",
                            _missingContact
                                ? colors.error
                                : colors.primary),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: OutlinedButton.icon(
                      onPressed: _handleSignOut,
                      icon: Icon(Icons.logout,
                          color: colors.error),
                      label: Text(
                        "Sign Out",
                        style:
                            TextStyle(color: colors.error),
                      ),
                      style: OutlinedButton.styleFrom(
                        side:
                            BorderSide(color: colors.error),
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }



  Widget _card(ThemeData theme,
      {String? title, required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (title != null) ...[
            Text(title,
                style: theme.textTheme.titleSmall
                    ?.copyWith(
                        fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
          ],
          child,
        ],
      ),
    );
  }

  Widget _infoRow(
      ThemeData theme, IconData icon, String text) {
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(icon, size: 18, color: colors.outline),
          const SizedBox(width: 8),
          Text(text, style: theme.textTheme.bodyMedium),
        ],
      ),
    );
  }

  Widget _missingItem(ThemeData theme, String text) {
    final colors = theme.colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          Icon(Icons.cancel,
              size: 14, color: colors.error),
          const SizedBox(width: 8),
          Text(text,
              style: TextStyle(
                  fontSize: 13, color: colors.error)),
        ],
      ),
    );
  }

  Widget _featureTile(ThemeData theme, String title,
      String status, Color color) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: CircleAvatar(
        radius: 18,
        backgroundColor: color.withOpacity(0.15),
        child: Icon(
          status == "Empty" || status == "Missing"
              ? Icons.priority_high
              : Icons.check,
          color: color,
          size: 16,
        ),
      ),
      title:
          Text(title, style: theme.textTheme.bodyMedium),
      trailing: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: color.withOpacity(0.15),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          status,
          style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
