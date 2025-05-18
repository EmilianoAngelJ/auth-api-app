import 'package:flutter/material.dart';
import 'package:auth_api_app/theme/colors.dart';

/// Dropdown form field for selecting gender with validation.
/// Shows an optional prefix icon if `isSignUp` is true.
class GenderDropDownFormField extends StatelessWidget {
  final void Function(String?)? onChanged;
  final void Function(String?)? onSaved;
  final bool isSignUp;
  final IconData? icon;
  final String? initialValue;

  const GenderDropDownFormField({
    super.key,
    this.onChanged,
    this.onSaved,
    required this.isSignUp,
    this.icon,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<String?>(
      value: initialValue,
      dropdownColor: Colors.white,
      decoration: InputDecoration(
        prefixIcon: isSignUp && icon != null ? Icon(icon) : null,
        labelText: 'Gender',
        floatingLabelStyle: const TextStyle(color: Colors.black87),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black54),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
      items: ['Male', 'Female', 'Other']
          .map((gender) => DropdownMenuItem(
                value: gender,
                child: Text(gender),
              ))
          .toList(),
      onChanged: onChanged,
      validator: (value) {
        if (value == null || value.isEmpty) {
          return 'Gender is required';
        }
        return null;
      },
      onSaved: onSaved,
    );
  }
}
