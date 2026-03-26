import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'contact_service.dart';

class EmailService {
  final ContactService _contactService = ContactService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendEmergencyEmail({String? location}) async {
    // 1. Check if there are contacts to conceptually match SmsService parity
    try {
      final contactsList = await _contactService.getContacts().first;
      if (contactsList.isEmpty) {
        debugPrint(
            "No emergency contacts found, but proceeding to open email client.");
      }
    } catch (e) {
      debugPrint("Error fetching contacts: $e");
    }

    // 2. Prepare message details
    final user = _auth.currentUser;
    final String userName = user?.displayName ?? "A rider";
    final String locString = location ?? "Unknown location";

    final String subject = "🚨 TEST: RideAway Accident Alert";
    final String body =
        "This is a simulated accident alert for testing. $userName has been involved in a simulated accident. My location: $locString.";

    // 3. Create mailto URI
    final Uri emailLaunchUri = Uri(
      scheme: 'mailto',
      path: '', // No specific recipient since contacts don't store emails
      query: _encodeQueryParameters(<String, String>{
        'subject': subject,
        'body': body,
      }),
    );

    // 4. Launch Email Client
    try {
      if (await canLaunchUrl(emailLaunchUri)) {
        await launchUrl(emailLaunchUri);
        debugPrint("Opened email client successfully.");
      } else {
        debugPrint("Could not launch email client.");
      }
    } catch (e) {
      debugPrint("Error launching email client: $e");
    }
  }

  String? _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((MapEntry<String, String> e) =>
            '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
