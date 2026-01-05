import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/db_service.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> currentData;

  const EditProfileScreen({super.key, required this.currentData});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _locationController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Pre-fill controllers with existing data
    _nameController =
        TextEditingController(text: widget.currentData['fullName']);
    _phoneController =
        TextEditingController(text: widget.currentData['phone'] ?? '');
    _locationController =
        TextEditingController(text: widget.currentData['location'] ?? '');
  }

  void _saveProfile() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      String uid = FirebaseAuth.instance.currentUser!.uid;

      // Prepare data to update
      Map<String, dynamic> updates = {
        'fullName': _nameController.text.trim(),
        'phone': _phoneController.text.trim(),
        'location': _locationController.text.trim(),
      };

      // Call Database Service
      await DatabaseService().updateUserProfile(uid, updates);

      if (mounted) {
        Navigator.pop(
            context, true); // Return 'true' to indicate update success
      }
    } catch (e) {
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Error updating profile: $e")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Edit Profile")),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              _buildTextField("Full Name", _nameController, Icons.person),
              const SizedBox(height: 16),
              _buildTextField("Phone Number", _phoneController, Icons.phone,
                  isPhone: true),
              const SizedBox(height: 16),
              _buildTextField(
                  "Location (City)", _locationController, Icons.location_on),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _saveProfile,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                  child: _isLoading
                      ? const CircularProgressIndicator(color: Colors.white)
                      : const Text("Save Changes",
                          style: TextStyle(color: Colors.white, fontSize: 16)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(
      String label, TextEditingController controller, IconData icon,
      {bool isPhone = false}) {
    return TextFormField(
      controller: controller,
      keyboardType: isPhone ? TextInputType.phone : TextInputType.text,
      validator: (value) => value!.isEmpty ? "This field is required" : null,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        filled: true,
        fillColor: Colors.grey.shade50,
      ),
    );
  }
}
