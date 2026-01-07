import 'package:flutter/material.dart';
import '../../models/contact_model.dart';
import '../../services/contact_service.dart';
import 'add_contact_dialog.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  final ContactService _contactService = ContactService();

  void _openContactDialog([ContactModel? contact]) {
    showDialog(
      context: context,
      builder: (_) => AddContactDialog(contact: contact),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Emergency Contacts"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            onPressed: () => _openContactDialog(),
            icon: Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: colors.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(Icons.add, color: Colors.white, size: 20),
            ),
          ),
          const SizedBox(width: 12),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            /// INFO BOX
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: isDark
                    ? colors.surfaceContainerHighest
                    : colors.primary.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                "These contacts will be automatically notified if an accident is detected. "
                "We recommend adding at least 2–3 trusted contacts.",
                style: theme.textTheme.bodySmall,
              ),
            ),

            const SizedBox(height: 20),

            /// CONTACT LIST
            Expanded(
              child: StreamBuilder<List<ContactModel>>(
                stream: _contactService.getContacts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (!snapshot.hasData || snapshot.data!.isEmpty) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.people_outline,
                            size: 48,
                            color: isDark ? Colors.grey : Colors.grey.shade600,
                          ),
                          const SizedBox(height: 12),
                          const Text("No emergency contacts added"),
                        ],
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: snapshot.data!.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 14),
                    itemBuilder: (context, index) {
                      final contact = snapshot.data![index];
                      return _contactCard(
                        context,
                        contact: contact,
                        onEdit: () => _openContactDialog(contact),
                        onDelete: () async {
                          await _contactService.deleteContact(contact.id);
                        },
                      );
                    },
                  );
                },
              ),
            ),

            /// ADD ANOTHER CONTACT
            const SizedBox(height: 10),
            SizedBox(
              width: double.infinity,
              height: 46,
              child: OutlinedButton.icon(
                onPressed: () => _openContactDialog(),
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

  /// CONTACT CARD
  Widget _contactCard(
    BuildContext context, {
    required ContactModel contact,
    required VoidCallback onEdit,
    required VoidCallback onDelete,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardColor,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 22,
            backgroundColor: isDark
                ? Colors.grey.shade800
                : Colors.blue.withOpacity(0.12),
            child: Icon(
              Icons.person_outline,
              color: isDark ? Colors.grey.shade300 : Colors.blue,
            ),
          ),
          const SizedBox(width: 12),

          /// DETAILS
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  contact.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(contact.phone, style: theme.textTheme.bodySmall),
                const SizedBox(height: 2),
                Text(
                  contact.relation,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          ),

          /// ACTIONS
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: onEdit),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: Colors.red),
            onPressed: onDelete,
          ),
        ],
      ),
    );
  }
}
