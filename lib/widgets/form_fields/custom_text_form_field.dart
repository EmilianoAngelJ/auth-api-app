import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth_api_app/providers/global_providers.dart';
import 'package:auth_api_app/theme/colors.dart';

/// A customizable text form field supporting:
/// - validation for required, email format, password rules, and confirm password matching,
/// - optional password visibility toggle,
/// - initial value, onSaved, and onChanged callbacks.
class CustomTextFormField extends ConsumerWidget {
  final String? initialValue;
  final String? validatorText;
  final String hintText;
  final String labelText;
  final IconData prefixIcon;
  final bool isPassword;
  final bool isMail;
  final bool isConfirmPassword;
  final Function(String?) onSaved;
  final StateNotifierProvider<PasswordVisibilityNotifier, bool>? visibilityProvider;
  final Function(String?)? onChanged;
  final StateProvider<String?>? passwordProvider;

  const CustomTextFormField({
    super.key,
    required this.validatorText,
    required this.hintText,
    required this.labelText,
    required this.prefixIcon,
    required this.isPassword,
    required this.isConfirmPassword,
    required this.isMail,
    required this.onSaved,
    this.visibilityProvider,
    this.passwordProvider,
    this.onChanged,
    this.initialValue,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch password visibility state if provider is given
    final seePassword = visibilityProvider != null 
      ? ref.watch(visibilityProvider!) 
      : false;

    return TextFormField(
      initialValue: initialValue,
      decoration: InputDecoration(
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
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: Colors.black54),
        ),
        filled: true,
        fillColor: Colors.white,
        hintText: hintText,
        labelText: labelText,
        errorStyle: const TextStyle(height: 1.5),
        floatingLabelStyle: const TextStyle(color: Colors.black87),
        prefixIcon: Icon(prefixIcon),

        // Show toggle button for password visibility if applicable
        suffixIcon: isPassword && visibilityProvider != null
          ? SeeUnseePassword(visibilityProvider: visibilityProvider!)
          : null,
      ),

      // Validation logic for required, email, password strength, and password confirmation
      validator: (value) {
        if (value == null || value.isEmpty)  {
          return validatorText;
        } else if (isMail && !isValidEmail(value)) {
          return 'Invalid email';
        } else if (isPassword && !isValidPassword(value)) {
          return '•Min: 8 characters\n•At least one uppercase letter\n•At least one special character\n•At least one number';
        } else if (isConfirmPassword && passwordProvider != null) {
          final originalPassword = ref.watch(passwordProvider!);
          if (originalPassword != value) {
            return 'Passwords do not match';
          }
        } 
        return null;
      },

      onSaved: onSaved,
      onChanged: onChanged,

      // Obscure text if it's a password and visibility is off
      obscureText: isPassword ? seePassword : false,
    );
  }

  // Basic email validation using regex
  bool isValidEmail(String email) {
    final RegExp emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$");
    return emailRegex.hasMatch(email);
  }

  // Password validation for minimum length (can expand to stronger rules)
  bool isValidPassword(String password) {
    final RegExp emailRegex = RegExp(r'^.{8,}$');
    // More complex pattern commented out:
    // r'^(?=.*[A-Z])(?=.*[a-z])(?=.*[0-9])(?=.*[!@#\$&*~]).{8,}$'
    return emailRegex.hasMatch(password);
  }
}

/// Password visibility toggle button widget.
/// Watches a visibility provider to toggle password visibility icon.
class SeeUnseePassword extends ConsumerWidget {
  final StateNotifierProvider<PasswordVisibilityNotifier, bool> visibilityProvider;

  const SeeUnseePassword({super.key, required this.visibilityProvider});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool seePassword = ref.watch(visibilityProvider);

    return IconButton(
      onPressed: () {
        // Toggle the password visibility state
        ref.read(visibilityProvider.notifier).toggle();
      },
      icon: seePassword
        ? const Icon(Icons.visibility_off)
        : const Icon(Icons.visibility),
    );
  }
}
