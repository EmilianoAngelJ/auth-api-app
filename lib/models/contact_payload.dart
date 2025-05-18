import 'package:auth_api_app/models/models.dart';

/// Payload model used to send data when creating a new contact.
/// Combines the user's Firebase ID token (for authentication) with the contact data.
class CreateContactPayload {
  /// Firebase ID token used for authenticating the request.
  final String idToken;

  /// The contact information to be created.
  final ContactModel contact;

  /// Creates a [CreateContactPayload] instance.
  CreateContactPayload({
    required this.idToken,
    required this.contact,
  });
}
