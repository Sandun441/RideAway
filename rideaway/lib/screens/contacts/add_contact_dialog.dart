import 'package:flutter/material.dart';
import '../../models/contact_model.dart';
import '../../services/contact_service.dart';

class AddContactDialog extends StatefulWidget {
  final ContactModel? contact;

  const AddContactDialog({super.key, this.contact});

  @override
  State<AddContactDialog> createState() => _AddContactDialogState();
}

class _AddContactDialogState extends State<AddContactDialog> {
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _relationController;

  final ContactService _service = ContactService();
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.contact?.name ?? '');
    _phoneController = TextEditingController(text: widget.contact?.phone ?? '');
    _relationController = TextEditingController(
      text: widget.contact?.relation ?? '',
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _phoneController.dispose();
    _relationController.dispose();
    super.dispose();
  }

  Future<void> _saveContact() async {
    if (_nameController.text.isEmpty ||
        _phoneController.text.isEmpty ||
        _relationController.text.isEmpty) {
      _showSnack("All fields are required");
      return;
    }

    setState(() => isLoading = true);

    final model = ContactModel(
      id: widget.contact?.id ?? '',
      name: _nameController.text.trim(),
      phone: _phoneController.text.trim(),
      relation: _relationController.text.trim(),
    );

    try {
      if (widget.contact == null) {
        await _service.addContact(model);
      } else {
        await _service.updateContact(model);
      }
      if (mounted) Navigator.pop(context);
    } catch (e) {
      _showSnack("Error saving contact");
    } finally {
      if (mounted) setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colors = theme.colorScheme;

    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      backgroundColor: theme.cardColor,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            /// HEADER
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: colors.primary.withOpacity(0.15),
                  child: Icon(Icons.person_add_outlined, color: colors.primary),
                ),
                const SizedBox(width: 12),
                Text(
                  widget.contact == null
                      ? "Add Emergency Contact"
                      : "Edit Contact",
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            /// NAME
            _inputField(
              context,
              controller: _nameController,
              label: "Name",
              icon: Icons.person_outline,
            ),

            const SizedBox(height: 14),

            /// PHONE
            _inputField(
              context,
              controller: _phoneController,
              label: "Phone Number",
              icon: Icons.phone_outlined,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 14),

            /// RELATION
            _inputField(
              context,
              controller: _relationController,
              label: "Relation",
              icon: Icons.group_outlined,
            ),

            const SizedBox(height: 24),

            /// ACTION BUTTONS
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: isLoading ? null : () => Navigator.pop(context),
                    child: const Text("Cancel"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isLoading ? null : _saveContact,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: colors.primary,
                      foregroundColor: colors.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            height: 18,
                            width: 18,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text("Save"),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// INPUT FIELD (THEME AWARE)
  Widget _inputField(
    BuildContext context, {
    required TextEditingController controller,
    required String label,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
  }) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: isDark ? Colors.grey.shade800 : Colors.grey.shade100,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
  }
}
