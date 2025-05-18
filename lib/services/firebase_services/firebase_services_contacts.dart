import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

/// Service class to handle API operations for user contacts
class ContactsServices {
  // Set base URL based on platform (emulator vs. localhost)
  final String baseUrl = Platform.isAndroid
      ? 'http://10.0.2.2:3300/contacts' // Android emulator localhost
      : 'http://localhost:3300/contacts'; // iOS or Web

  /// Fetches all contacts associated with the user
  ///
  /// [idToken] is the Firebase ID token used for authentication
  /// Returns a list of contact maps (decoded JSON objects)
  Future<List<Map<String, dynamic>>> getContacts(String idToken) async {
    final url = Uri.parse('$baseUrl/');
    try {
      final response = await http.get(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json',
        },
      );

      // If successful, parse and return the contact list
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.cast<Map<String, dynamic>>();
      } else {
        // Handle unsuccessful response
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      // Rethrow any network or decoding error
      throw Exception('$e');
    }
  }

  /// Creates a new contact
  ///
  /// [idToken] - Firebase ID token
  /// [name] - Name of the contact
  /// [contactType] - Type/category of the contact
  ///
  /// Returns a success message string from the backend
  Future<String> createContact(String idToken, String name, String contactType) async {
    final url = Uri.parse('$baseUrl/create-contact');

    final body = jsonEncode({
      'name': name,
      'contactType': contactType,
    });

    try {
      final response = await http.post(
        url,
        body: body,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json'
        },
      );

      // If successful, return the message
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body)['message'];
        return responseBody;
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }

  /// Deletes a contact by its ID
  ///
  /// [idToken] - Firebase ID token
  /// [contactId] - ID of the contact to delete
  ///
  /// Returns a success message from the server
  Future<String> deleteContact(String idToken, String contactId) async {
    final url = Uri.parse('$baseUrl/delete-contact/$contactId');

    try {
      final response = await http.delete(
        url,
        headers: {
          'Authorization': 'Bearer $idToken',
          'Content-Type': 'application/json'
        },
      );

      // Return confirmation message if successful
      if (response.statusCode == 200) {
        final responseBody = jsonDecode(response.body)['message'];
        return responseBody;
      } else {
        throw Exception('Error: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('$e');
    }
  }
}
