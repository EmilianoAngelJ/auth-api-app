import 'package:auth_api_app/models/models.dart';

/// A payload container for user session data, typically used
/// when making authenticated requests to your backend.
class UserPayload {
  /// The Firebase ID token used for authentication/authorization.
  String? idToken;

  /// The authenticated Firebase user object.
  UserModel? user;

  UserPayload({
    this.idToken,
    this.user,
  });
}
