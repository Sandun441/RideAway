import 'package:cloud_firestore/cloud_firestore.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
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
=======
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
    } catch (e) {
      print("Error saving user: $e");
    }
  }

<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
  // NEW: Get user data by UID
=======
  // ... keep getUser and updateUserProfile the same ...
>>>>>>> Stashed changes
=======
  // ... keep getUser and updateUserProfile the same ...
>>>>>>> Stashed changes
=======
  // ... keep getUser and updateUserProfile the same ...
>>>>>>> Stashed changes
=======
  // ... keep getUser and updateUserProfile the same ...
>>>>>>> Stashed changes
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
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
=======
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      await _db.collection('users').doc(uid).update(data);
    } catch (e) {
      print("Error updating profile: $e");
      throw e;
    }
  }
<<<<<<< Updated upstream
<<<<<<< Updated upstream
<<<<<<< Updated upstream
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
=======
>>>>>>> Stashed changes
}
