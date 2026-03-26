import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:url_launcher/url_launcher.dart';
import 'contact_service.dart';

class EmailService {
  final ContactService _contactService = ContactService();
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> sendEmergencyEmail({String? location}) async {
    final user = _auth.currentUser;
    final String userName = user?.displayName ?? 'A rider';
    final String locString = location ?? 'Unknown location';

    final String subject = '🚨 EMERGENCY: RideAway Accident Alert';
    final String body =
        '$userName may have been in an accident and needs help!\n\n'
        '📍 Last known location: $locString\n\n'
        'This alert was sent automatically by the RideAway Safety App.';

    // Get contacts that have email addresses
    try {
      final contactsList = await _contactService.getContacts().first;

      // Filter contacts with an email address
      final emailContacts = contactsList.where((c) => c.email.isNotEmpty).toList();

      if (emailContacts.isNotEmpty) {
        // Send to all contacts with emails via mailto: (comma-separated)
        final recipients = emailContacts.map((c) => c.email).join(',');
        final emailUri = Uri(
          scheme: 'mailto',
          path: recipients,
          query: _encodeQueryParameters({'subject': subject, 'body': body}),
        );

        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
          debugPrint('Opened email client with ${emailContacts.length} recipients.');
        } else {
          debugPrint('Could not launch email client.');
        }
      } else {
        // No email contacts found — open blank email with body pre-filled
        debugPrint('No contacts with email found. Opening blank email.');
        final emailUri = Uri(
          scheme: 'mailto',
          path: '',
          query: _encodeQueryParameters({'subject': subject, 'body': body}),
        );
        if (await canLaunchUrl(emailUri)) {
          await launchUrl(emailUri);
        }
      }
    } catch (e) {
      debugPrint('Error in EmailService: $e');
    }
  }

  String _encodeQueryParameters(Map<String, String> params) {
    return params.entries
        .map((e) => '${Uri.encodeComponent(e.key)}=${Uri.encodeComponent(e.value)}')
        .join('&');
  }
}
