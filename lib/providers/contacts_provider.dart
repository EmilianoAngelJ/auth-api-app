import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:auth_api_app/models/contact_payload.dart';
import 'package:auth_api_app/providers/token_providers.dart';
import 'package:auth_api_app/services/firebase_services/firebase_services_contacts.dart';

/// Provides an instance of the ContactsServices class
final contactsServiceProvider = Provider<ContactsServices>((ref) {
  return ContactsServices();
});

/// Fetches the list of contacts using the given [idToken]
/// Returns a Future of a List of Map objects (each representing a contact)
final contactsProvider = FutureProvider.family<List<Map<String, dynamic>>, String>((ref, String idToken) async {
  final contactsServices = ref.watch(contactsServiceProvider);
  return await contactsServices.getContacts(idToken);
});

/// Creates a new contact using the provided payload (idToken and contact data)
/// Returns a Future<String> with a success or error message
final createContactProvider = FutureProvider.family<String, CreateContactPayload>((ref, CreateContactPayload payload) async {
  final contactsServices = ref.watch(contactsServiceProvider);

  try {
    // Call the service to create the contact
    final responseMessage = await contactsServices.createContact(
      payload.idToken,
      payload.contact.name,
      payload.contact.contactType,
    );

    // Invalidate the contact list to trigger refetch
    ref.invalidate(contactsProvider);

    return responseMessage;
  } catch (e) {
    // Catch and rethrow for UI or logger to handle
    throw Exception('$e');
  }
});

/// Deletes a contact by its [contactId] using the stored idToken
/// Returns a Future<String> with a success or error message
final deleteContactProvider = FutureProvider.family<String, String>((ref, String contactId) async {
  final contactsServices = ref.watch(contactsServiceProvider);

  // Get the current user's ID token from the token provider
  final idToken = ref.watch(authTokenProvider)['idToken'];

  // Guard clause: ensure token is present
  if (idToken == null) {
    throw Exception('No ID token found');
  }

  try {
    // Attempt to delete the contact
    final responseMessage = await contactsServices.deleteContact(idToken, contactId);

    // Invalidate the contact list for the current token
    ref.invalidate(contactsProvider(idToken));

    return responseMessage;
  } catch (e) {
    throw Exception('$e');
  }
});
