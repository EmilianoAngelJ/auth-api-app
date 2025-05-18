import 'package:auth_api_app/global/toast.dart';
import 'package:auth_api_app/models/models.dart';
import 'package:auth_api_app/providers/contacts_provider.dart';
import 'package:auth_api_app/providers/token_providers.dart';
import 'package:auth_api_app/theme/colors.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ContactForm extends ConsumerStatefulWidget {
  const ContactForm({super.key});

  @override
  ConsumerState<ContactForm> createState() => _ContactFormState();
}

class _ContactFormState extends ConsumerState<ContactForm> {
  late TextEditingController nameController;
  late TextEditingController contactTypeController;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    // Initialize controllers to handle form input
    nameController = TextEditingController();
    contactTypeController = TextEditingController();
  }

  // Handles form submission: validates, calls provider, shows feedback
  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final idToken = ref.read(authTokenProvider)['idToken'];

      final payload = CreateContactPayload(
        idToken: idToken!,
        contact: ContactModel(
          name: nameController.text,
          contactType: contactTypeController.text,
        ),
      );

      try {
        // Calls async provider to create contact
        final message = await ref.read(createContactProvider(payload).future);
        showToast(message: message, backgroundColor: AppColors.greenFeedback);
      } catch (e) {
        // Show error toast if creation fails
        showToast(message: '$e');
      }
      Navigator.pop(context); // Close form after submission
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      // Avoid keyboard overlapping the form
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(15, 20, 15, 25),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              spacing: 20,
              children: [
                TextFormField(
                  controller: nameController,
                  decoration: InputDecoration(
                    labelText: 'Contact name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Contact name is required';
                    }
                    return null;
                  },
                ),
                TextFormField(
                  controller: contactTypeController,
                  decoration: InputDecoration(
                    labelText: 'Related name',
                    hintText: 'Mom, Dad, etc.',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Related name is required';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: _submitForm,
                  child: const Text(
                    'Save Contact',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
