import 'package:background_sms/background_sms.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/contact_model.dart';
import 'contact_service.dart';

class SmsService {
  final ContactService _contactService = ContactService();

  Future<bool> requestSmsPermission() async {
    final status = await Permission.sms.request();
    return status.isGranted;
  }

  Future<void> sendEmergencySms({String? location}) async {
    // 1. Check/Request Permission
    if (!await requestSmsPermission()) {
      throw Exception("SMS permission denied");
    }

    // 2. Get Contacts
    // Note: getContacts() returns a Stream. For a one-time fetch we can take the first element.
    // However, since it's a stream of the *list* of contacts, taking first is correct.
    final contactsList = await _contactService.getContacts().first;

    if (contactsList.isEmpty) {
      throw Exception("No emergency contacts found");
    }

    // 3. Prepare Message
    String message = "Help! I've been in an accident!";
    if (location != null) {
      message += " Location: $location";
    }
    message += " - Sent from RideAway";

    // 4. Send to all contacts
    for (var contact in contactsList) {
      if (contact.phone.isNotEmpty) {
        // Clean phone number if necessary
        final result = await BackgroundSms.sendMessage(
          phoneNumber: contact.phone,
          message: message,
        );

        if (result == SmsStatus.failed) {
          print("Failed to send to ${contact.name}");
        }
      }
    }
  }
}
