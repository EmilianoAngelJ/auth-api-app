import 'package:flutter/material.dart';
import 'package:phone_input/phone_input_package.dart';
import 'package:auth_api_app/theme/colors.dart';

/// Custom phone input form field using the `phone_input_package`.
/// Supports initial value, validation, and change/save callbacks.
class PhoneFormField extends StatelessWidget {
  final dynamic Function(PhoneNumber?)? onSaved;
  final void Function(PhoneNumber?)? onChanged;
  final PhoneNumber initialValue;

  const PhoneFormField({
    super.key,
    this.onSaved,
    this.onChanged,
    required this.initialValue,
  });

  @override
  Widget build(BuildContext context) {
    return PhoneInput(
      countrySelectorNavigator: const CountrySelectorNavigator.searchDelegate(),
      defaultCountry: IsoCode.MX, // Default country for phone input
      keyboardType: const TextInputType.numberWithOptions(),
      initialValue: initialValue, // Pre-fills phone input if available
      decoration: InputDecoration(
        labelText: 'Phone number',
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
      onChanged: onChanged,
      onSaved: onSaved,
      validator: (phoneNumber) {
        if (phoneNumber == null) {
          return 'Phone number is required';
        }
        return null;
      },
    );
  }
}
