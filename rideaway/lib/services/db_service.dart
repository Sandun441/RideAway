import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. SAVE USER (Fixed to prevent overwriting)
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

  // ... keep getUser and updateUserProfile the same ...
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

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      // Use .set with merge: true instead of .update()
      // This creates the document if it's missing!
      await _db.collection('users').doc(uid).set(data, SetOptions(merge: true));
      print("Profile sync successful for UID: $uid");
    } catch (e) {
      print("Error in DatabaseService: $e");
      rethrow;
    }
  }
}
