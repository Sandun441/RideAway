import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save user data after registration
  Future<void> saveUser(String uid, String name, String email) async {
    try {
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'fullName': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        // We will add 'emergencyContacts' here later
        'emergencyContacts': [],
      });
    } catch (e) {
      print("Error saving user: $e");
    }
  }
}
