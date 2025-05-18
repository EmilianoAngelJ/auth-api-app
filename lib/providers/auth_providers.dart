import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_input/phone_input_package.dart';
import 'package:auth_api_app/global/toast.dart';
import 'package:auth_api_app/models/models.dart';
import 'package:auth_api_app/providers/session_provider.dart';
import 'package:auth_api_app/providers/token_providers.dart';
import 'package:auth_api_app/services/firebase_services_auth.dart';
import 'package:auth_api_app/theme/colors.dart';

/// State providers to hold and manage the form input values
final birthdayProvider = StateProvider<DateTime?>((ref) => null);
final confirmPasswordProvider = StateProvider<String?>((ref) => null);
final emailProvider = StateProvider<String>((ref) => '');
final genderProvider = StateProvider<String>((ref) => '');
final nameProvider = StateProvider<String>((ref) => '');
final passwordProvider = StateProvider<String>((ref) => '');
final phoneProvider = StateProvider<PhoneNumber?>((ref) => null);
final surnamesProvider = StateProvider<String>((ref) => '');

/// State providers to track form validation errors
final emailErrorProvider = StateProvider<String?>((ref) => null);
final passwordErrorProvider = StateProvider<String?>((ref) => null);

/// Provides an instance of the authentication service class
final authServiceProvider = Provider<AuthServices>((ref) {
  return AuthServices();
});

/// Handles user sign-up using email and password
/// Returns a `Future<bool>` indicating success or failure
final signUpUserProvider = FutureProvider.family<bool, UserModel>((ref, UserModel params) async {
  final authService = ref.watch(authServiceProvider);
  final authSessionNotifier = ref.read(sessionProvider.notifier);

  try {
    // Attempt to sign up with the given user details
    final tokens = await authService.signUpEmailPassword(
      params.email!,
      params.password!,
      params.name!,
      params.surnames!,
      params.gender!,
      params.birthday!,
      params.isoCode!,
      params.phoneNumber!
    );

    // If tokens are returned, store them and initialize the session
    if (tokens != null) {
      final idToken = tokens['idToken'];
      final refreshToken = tokens['refreshToken'];

      ref.read(authTokenProvider.notifier).saveTokens(idToken!, refreshToken!);
      await authSessionNotifier.initializeSession(idToken, refreshToken);

      // Show success feedback
      showToast(message: "Bienvenido", backgroundColor: AppColors.greenFeedback);
      return true;
    }
  } catch (e) {
    // Show error feedback on failure
    showToast(message: "$e", backgroundColor: AppColors.redFeedback);
    return false;
  }

  // Fallback in case something went wrong
  return false;
});

/// Handles user log-in using email and password
/// Returns a `Future<bool>` indicating success or failure
final logInUserProvider = FutureProvider.family<bool, UserModel>((ref, UserModel params) async {
  final authServices = ref.watch(authServiceProvider);
  final authSessionNotifier = ref.read(sessionProvider.notifier);

  try {
    // Attempt to log in with email and password
    final tokens = await authServices.logInEmailPassword(params.email!, params.password!);
    
    if (tokens != null) {
      final idToken = tokens['idToken'];
      final refreshToken = tokens['refreshToken'];

      // Save the new tokens and initialize user session
      ref.read(authTokenProvider.notifier).saveTokens(idToken!, refreshToken!);
      await authSessionNotifier.initializeSession(idToken, refreshToken);

      // Show success feedback
      showToast(message: "Bienvenido", backgroundColor: AppColors.greenFeedback);
      return true;
    }
  } catch (e) {
    // Show error feedback
    showToast(message: "$e", backgroundColor: AppColors.redFeedback);
    return false;
  }

  // Fallback in case of no tokens returned
  return false;
});