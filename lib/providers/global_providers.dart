import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Tracks whether a form has been changed (used for validation or enabling actions)
class FormChangeNotifier extends StateNotifier<bool> {
  FormChangeNotifier() : super(false);

  /// Mark the form as changed
  void setChanged() {
    state = true;
  }

  /// Reset the changed state (e.g., after saving)
  void resetChanged() {
    state = false;
  }
}

/// Global provider to monitor form change state
final formChangeProvider = StateNotifierProvider<FormChangeNotifier, bool>(
  (ref) => FormChangeNotifier(),
);

/// Controls the visibility state of password input fields
class PasswordVisibilityNotifier extends StateNotifier<bool> {
  PasswordVisibilityNotifier() : super(true); // true = hidden by default

  /// Toggle the password visibility
  void toggle() {
    state = !state;
  }
}

/// Controls visibility of the password field in the **Sign Up** form
final passwordSignUpVisibilityProvider = StateNotifierProvider<PasswordVisibilityNotifier, bool>(
  (ref) => PasswordVisibilityNotifier(),
);

/// Controls visibility of the password field in the **Log In** form
final passwordLogInVisibilityProvider = StateNotifierProvider<PasswordVisibilityNotifier, bool>(
  (ref) => PasswordVisibilityNotifier(),
);

/// Controls visibility of the **Confirm Password** field in the Sign Up form
final confirmPasswordVisibilityProvider = StateNotifierProvider<PasswordVisibilityNotifier, bool>(
  (ref) => PasswordVisibilityNotifier(),
);

/// Global loading state, can be used for general UI loading overlays or spinners
final loadingProvider = StateProvider<bool>((ref) => true);
