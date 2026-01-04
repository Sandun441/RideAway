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
    _nameController =
        TextEditingController(text: widget.contact?.name ?? '');
    _phoneController =
        TextEditingController(text: widget.contact?.phone ?? '');
    _relationController =
        TextEditingController(text: widget.contact?.relation ?? '');
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
      _showSnack("All fields required");
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
    return AlertDialog(
      title:
      Text(widget.contact == null ? "Add Contact" : "Edit Contact"),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: "Name"),
          ),
          TextField(
            controller: _phoneController,
            decoration: const InputDecoration(labelText: "Phone"),
            keyboardType: TextInputType.phone,
          ),
          TextField(
            controller: _relationController,
            decoration: const InputDecoration(labelText: "Relation"),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: isLoading ? null : () => Navigator.pop(context),
          child: const Text("Cancel"),
        ),
        ElevatedButton(
          onPressed: isLoading ? null : _saveContact,
          child: isLoading
              ? const SizedBox(
            height: 18,
            width: 18,
            child: CircularProgressIndicator(strokeWidth: 2),
          )
              : const Text("Save"),
        ),
      ],
    );
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(msg)));
  }
}
