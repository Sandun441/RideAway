import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Save user data (Existing)
  Future<void> saveUser(String uid, String name, String email) async {
    try {
      await _db.collection('users').doc(uid).set({
        'uid': uid,
        'fullName': name,
        'email': email,
        'createdAt': FieldValue.serverTimestamp(),
        'emergencyContacts': [],
      });
    } catch (e) {
      print("Error saving user: $e");
    }
  }

  // NEW: Get user data by UID
  Future<Map<String, dynamic>?> getUser(String uid) async {
    try {
      DocumentSnapshot doc = await _db.collection('users').doc(uid).get();
      if (doc.exists) {
        return doc.data() as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print("Error fetching user: $e");
      return null;
    }
  }
}
