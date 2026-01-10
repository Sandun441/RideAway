import 'package:flutter_background_messenger/flutter_background_messenger.dart';
import 'package:permission_handler/permission_handler.dart';
import '../models/contact_model.dart';
import 'contact_service.dart';

class SmsService {
  final ContactService _contactService = ContactService();
  final _messenger = FlutterBackgroundMessenger();

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
        try {
          // Using sendSMS from flutter_background_messenger
          final bool? success = await _messenger.sendSMS(
            phoneNumber: contact.phone,
            message: message,
          );

          if (success != true) {
            print("Failed to send to ${contact.name}");
          } else {
            print("Sent to ${contact.name}");
          }
        } catch (e) {
          print("Error sending to ${contact.name}: $e");
        }
      }
    }
  }
}
