import 'package:cloud_firestore/cloud_firestore.dart';

class ContactModel {
  final String id;
  final String name;
  final String phone;
  final String relation;
  final String email; // NEW: for email alerts

  ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
    this.email = '',
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'relation': relation,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(), // Fixed: server timestamp
    };
  }

  factory ContactModel.fromFirestore(
    String id,
    Map<String, dynamic> data,
  ) {
    return ContactModel(
      id: id,
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      relation: data['relation'] ?? '',
      email: data['email'] ?? '',
    );
  }
}
