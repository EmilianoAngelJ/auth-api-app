import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phone_input/phone_input_package.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:auth_api_app/global/toast.dart';
import 'package:auth_api_app/providers/auth_providers.dart';

/// Handles HTTP authentication with custom Node.js backend
class AuthServices {
  // Set base URL depending on platform (emulator vs local)
  final String baseUrl = Platform.isAndroid ? 'http://10.0.2.2:3300/auth' : 'http://localhost:3300/auth';

  /// Register user via custom backend API and return tokens
  Future<Map<String, String?>?> signUpEmailPassword(
    String email,
    String password,
    String name,
    String surnames,
    String gender,
    DateTime birthday,
    IsoCode isoCode,
    String phoneNumber,
  ) async {
    final url = Uri.parse('$baseUrl/signup');
    try {
      final body = json.encode({
        'email': email,
        'password': password,
        'name': name,
        'surnames': surnames,
        'gender': gender,
        'birthdayIso': birthday.toIso8601String(),
        'IsoCode': isoCode.name, // Country code (e.g. MX, US)
        'phoneNumber': phoneNumber,
      });

      final response = await http.post(
        url,
        body: body,
        headers: { 'Content-Type': 'application/json' },
      ).timeout(const Duration(seconds: 30));

      if (response.statusCode == 201) {
        // On success, return tokens
        final idToken = jsonDecode(response.body)['idToken'];
        final refreshToken = jsonDecode(response.body)['refreshToken'];
        return { 'idToken': idToken, 'refreshToken': refreshToken };
      } else if (response.statusCode == 400) {
        throw Exception('${jsonDecode(response.body)['error']}');
      }
    } catch (e) {
      throw Exception('$e');
    }
    return null;
  }

  /// Log in using backend API and return tokens
  Future<Map<String, String?>?> logInEmailPassword(String email, String password) async {
    final url = Uri.parse('$baseUrl/login');
    try {
      final body = jsonEncode({
        "email": email,
        "password": password,
      });

      final response = await http.post(
        url,
        body: body,
        headers: { 'Content-Type': 'application/json' },
      );

      if (response.statusCode == 200) {
        final idToken = jsonDecode(response.body)['idToken'];
        final refreshToken = jsonDecode(response.body)['refreshToken'];
        return { 'idToken': idToken, 'refreshToken': refreshToken };
      } else if (response.statusCode == 401) {
        throw Exception('${jsonDecode(response.body)['error']}');
      }
    } catch (e) {
      throw Exception('Server error: $e');
    }
    return null;
  }

  /// Refresh expired ID token using the backend and return new tokens
  Future<Map<String, String?>?> refreshTokens(String refreshToken) async {
    final url = Uri.parse('$baseUrl/refresh-tokens');
    final body = jsonEncode({ "refreshToken": refreshToken });

    try {
      final response = await http.post(
        url,
        body: body,
        headers: { "Content-Type": "application/json" },
      );

      if (response.statusCode == 200) {
        final idToken = jsonDecode(response.body)['idToken'];
        final newRefreshToken = jsonDecode(response.body)['refreshToken'];
        return { 'idToken': idToken, 'refreshToken': newRefreshToken };
      }
    } catch (e) {
      throw Exception('Error actualizando los tokens');
    }
    return null;
  }
}

/// Direct interaction with Firebase Auth and Firestore (fallback or dev use)
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign up user with Firebase Auth and store profile in Firestore
  Future<User?> signUpEmailPassword(
    BuildContext context,
    String email,
    String password,
    String name,
    String surnames,
    String gender,
    DateTime birthday,
    String phone,
    IsoCode isoCode,
  ) async {
    try {
      // Firebase Auth sign-up
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Store user data in Firestore
      var userUid = _auth.currentUser!.uid;
      var db = FirebaseFirestore.instance;

      await db.collection('users').doc(userUid).set({
        'name': name,
        'email': email,
        'surnames': surnames,
        'gender': gender,
        'birthday': birthday,
        'phoneNumber': phone,
        'IsoCode': isoCode.name,
      });

      showToast(message: "User is successfully created", backgroundColor: Colors.green);
      return userCredential.user;

    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        showToast(message: 'The password provided is too weak.');
      } else if (e.code == 'email-already-in-use') {
        showToast(message: 'The account already exists for that email.');
      } else {
        showToast(message: 'Authentication failed: $e');
      }
    } catch (e) {
      showToast(message: 'An unexpected error occurred: $e');
    }
    return null;
  }

  /// Log in with Firebase Auth directly (only if not using backend)
  Future<User?> logInEmailPassword(String email, String password, WidgetRef ref) async {
    // Reset form field errors
    ref.read(emailErrorProvider.notifier).state = null;
    ref.read(passwordErrorProvider.notifier).state = null;

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'invalid-credential') {
        showToast(message: 'Correo o contraseña incorrecto(s)', backgroundColor: Colors.red);
      } else if (e.code == 'wrong-password') {
        showToast(message: 'Contraseña Incorrecta');
      }
    }
    return null;
  }
}
