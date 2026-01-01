import 'package:flutter/material.dart';

class ContactsScreen extends StatelessWidget {
  const ContactsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("Emergency Contacts"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // Add contact action (later)
            },
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.blue,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// Info box
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                "These contacts will be automatically notified if an accident is detected. "
                    "We recommend adding at least 2–3 trusted contacts.",
                style: TextStyle(color: Colors.blue),
              ),
            ),

            const SizedBox(height: 20),

            /// Contacts list
            _contactTile(
              name: "Mom",
              phone: "+1 (555) 123-4567",
              relation: "Family",
            ),
            _contactTile(
              name: "Dr. Sarah Wilson",
              phone: "+1 (555) 987-6543",
              relation: "Doctor",
            ),
            _contactTile(
              name: "John - Best Friend",
              phone: "+1 (555) 456-7890",
              relation: "Friend",
            ),

            const SizedBox(height: 20),

            /// Add another contact
            SizedBox(
              width: double.infinity,
              height: 48,
              child: OutlinedButton.icon(
                onPressed: () {
                  // Add another contact
                },
                icon: const Icon(Icons.add),
                label: const Text("Add Another Contact"),
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Contact Card
  Widget _contactTile({
    required String name,
    required String phone,
    required String relation,
  }) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          const CircleAvatar(
            radius: 22,
            backgroundColor: Color(0xFFE3F2FD),
            child: Icon(Icons.person, color: Colors.blue),
          ),
          const SizedBox(width: 12),

          /// Contact info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(phone, style: const TextStyle(fontSize: 13)),
                const SizedBox(height: 2),
                Text(
                  relation,
                  style: const TextStyle(
                    fontSize: 12,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          /// Actions
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.edit, size: 20),
          ),
          IconButton(
            onPressed: () {},
            icon: const Icon(Icons.delete, color: Colors.red, size: 20),
          ),
        ],
      ),
    );
  }
}
