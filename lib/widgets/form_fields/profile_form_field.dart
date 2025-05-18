import 'package:auth_api_app/theme/colors.dart';
import 'package:flutter/material.dart';

/// Reusable text form field for profile inputs.
/// Supports initial value, validation, read-only mode, and callbacks.
class ProfileTextFormField extends StatelessWidget {
  final String initialValue;
  final String labelText;
  final String? hintText;
  final String validatorText;
  final bool? readOnly;
  final void Function(String)? onChanged;
  final FormFieldSetter<String> onSaved;

  const ProfileTextFormField({
    super.key,
    required this.initialValue,
    required this.labelText,
    required this.validatorText,
    required this.onSaved,
    required this.onChanged,
    this.hintText,
    this.readOnly,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20), // Spacing below field
      child: TextFormField(
        readOnly: readOnly ?? false, // Optionally make field read-only
        initialValue: initialValue, // Pre-fill with current profile data
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          floatingLabelStyle: const TextStyle(color: Colors.black87),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: AppColors.primaryColor,
              width: 2,
            ),
          ),
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return validatorText; // Show error if empty
          }
          return null;
        },
        onChanged: onChanged,
        onSaved: onSaved,
      ),
    );
  }
}
