class ContactModel {
  final String id;
  final String name;
  final String phone;
  final String relation;

  ContactModel({
    required this.id,
    required this.name,
    required this.phone,
    required this.relation,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'phone': phone,
      'relation': relation,
      'createdAt': DateTime.now(),
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
    );
  }
}
