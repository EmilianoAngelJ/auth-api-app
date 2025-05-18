import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

// Create an instance of FlutterSecureStorage to persist data securely
const secureStorage = FlutterSecureStorage(); 

// StateNotifier to manage authentication tokens (idToken and refreshToken)
class AuthTokensNotifier extends StateNotifier<Map<String, String?>> {
  // Initialize state with null tokens and load stored tokens immediately
  AuthTokensNotifier() : super({'idToken': null, 'refreshToken': null}) {
    loadTokens();
  }
 
  // Load tokens from secure storage when app starts
  Future<void> loadTokens() async {
    final idToken = await secureStorage.read(key: 'auth_token');
    final refreshToken = await secureStorage.read(key: 'refresh_token');
    // Update state with loaded tokens (can be null if not stored)
    state = {'idToken': idToken, 'refreshToken': refreshToken};
  }

  // Save both tokens to secure storage and update state
  Future<void> saveTokens(String idToken, String refreshToken) async {
    await secureStorage.write(key: 'auth_token', value: idToken);
    await secureStorage.write(key: 'refresh_token', value: refreshToken);
    state = {'idToken': idToken, 'refreshToken': refreshToken};
  }

  // Delete both tokens from secure storage and clear state
  Future<void> deleteTokens() async {
    await secureStorage.delete(key: 'auth_token');
    await secureStorage.delete(key: 'refresh_token');
    state = {'idToken': null, 'refreshToken': null};
  }
}

// Provider to expose the AuthTokensNotifier and current tokens state
final authTokenProvider = StateNotifierProvider<AuthTokensNotifier, Map<String, String?>>((ref) {
  return AuthTokensNotifier();
});
