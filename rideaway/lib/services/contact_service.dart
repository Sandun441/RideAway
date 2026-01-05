import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/contact_model.dart';

class ContactService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  CollectionReference get _contactsRef {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception("User not logged in");
    }

    return _firestore
        .collection('users')
        .doc(user.uid)
        .collection('contacts');
  }

  /// ADD
  Future<void> addContact(ContactModel contact) async {
    await _contactsRef.add(contact.toMap());
  }

  /// UPDATE
  Future<void> updateContact(ContactModel contact) async {
    await _contactsRef.doc(contact.id).update(contact.toMap());
  }

  /// DELETE
  Future<void> deleteContact(String id) async {
    await _contactsRef.doc(id).delete();
  }

  /// STREAM
  Stream<List<ContactModel>> getContacts() {
    return _contactsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        return ContactModel.fromFirestore(
          doc.id,
          doc.data() as Map<String, dynamic>,
        );
      }).toList();
    });
  }
}
