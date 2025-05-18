import 'dart:convert';
import 'dart:io';
import 'package:phone_input/phone_input_package.dart';
import 'package:http/http.dart' as http;

/// Service class to manage user-related API operations
class UserServices {
  // Base URL that adapts based on platform (Android emulator vs. localhost)
  final String baseUrl =
      Platform.isAndroid ? 'http://10.0.2.2:3300/users' : 'http://localhost:3300/users';

  /// Fetches the current authenticated user's data
  ///
  /// [idToken] - Firebase ID token for auth
  /// Returns user data as a map
  Future<Map<String, dynamic>> getUser(String idToken) async {
    final url = Uri.parse('$baseUrl/');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        // Success: Return decoded user data
        final Map<String, dynamic> data = jsonDecode(response.body);
        return data;
      } else if (response.statusCode == 404) {
        // User not found
        final error = jsonDecode(response.body);
        throw Exception("Error: ${error['message']}");
      } else if (response.statusCode == 500) {
        // Internal server error
        final error = jsonDecode(response.body);
        throw Exception("Error: ${error['message']}");
      } else {
        // Any other unexpected status
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  /// Updates user profile data
  ///
  /// Params include [name], [surnames], [gender], [birthday], [isoCode] and [phoneNumber]
  /// Returns a response message or null
  Future<String?> updateUser(
    String idToken,
    String name,
    String surnames,
    String gender,
    DateTime birthday,
    IsoCode isoCode,
    String phoneNumber,
  ) async {
    final url = Uri.parse('$baseUrl/update-user');

    // Construct request body
    final body = json.encode({
      'name': name,
      'surnames': surnames,
      'gender': gender,
      'birthdayIso': birthday.toIso8601String(),
      'IsoCode': isoCode.name, 
      'phoneNumber': phoneNumber,
    });

    try {
      final response = await http.put(
        url,
        body: body,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      // Handle various responses
      if (response.statusCode == 200 ||
          response.statusCode == 401 ||
          response.statusCode == 404) {
        return jsonDecode(response.body)['message'];
      } else if (response.statusCode == 500) {
        return jsonDecode(response.body)['error'];
      }
    } catch (e) {
      throw Exception('Error $e');
    }

    return null; // Return null if no matching status code was handled
  }

  /// Updates the user's email address
  ///
  /// Requires the [newEmail] and current [password] for verification
  /// Returns a status message from the server
  Future<String?> updateEmail(String idToken, String newEmail, String password) async {
    final Uri url = Uri.parse('$baseUrl/update-email');

    final body = jsonEncode({
      'newEmail': newEmail,
      'password': password,
    });

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      final statusMessage = jsonDecode(response.body)['message'];
      return statusMessage;
    } catch (e) {
      throw Exception('Error al actualizar correo');
    }
  }
}
