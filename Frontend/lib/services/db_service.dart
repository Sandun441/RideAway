import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> saveUser(String uid, String name, String email) async {
    try {
      final userDoc = _db.collection('users').doc(uid);
      final snapshot = await userDoc.get();

      // ONLY create a new document if the user DOES NOT exist yet
      if (!snapshot.exists) {
        await userDoc.set({
          'uid': uid,
          'fullName': name,
          'email': email,
          'phone': '',
          'location': '',
          'createdAt': FieldValue.serverTimestamp(),
          'emergencyContacts': [],
        });
      }
      // If snapshot.exists is true, we do NOTHING.
      // This preserves your phone/location data on future logins.
    } catch (e) {
      print("Error saving user: $e");
    }
  }

  // 2. READ: Get user profile data
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

  // 3. UPDATE: Update specific profile fields (Phone, Location, Name)
  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      // 'update' only changes the fields you send it, leaving others (like email) alone
      await _db.collection('users').doc(uid).update(data);
    } catch (e) {
      print("Error updating profile: $e");
      throw e; // We throw the error so the UI knows to show a SnackBar
    }
  }
}
