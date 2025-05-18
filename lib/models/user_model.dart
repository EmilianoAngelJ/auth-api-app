import 'package:phone_input/phone_input_package.dart';

/// A model representing user data used during registration or profile editing.
class UserModel {
  String? name;           // User's first name
  String? surnames;       // User's last name(s)
  String? gender;         // User's gender (e.g., 'male', 'female', 'other')
  DateTime? birthday;       // User's birthdate in YYYY-MM-DD format
  IsoCode? isoCode;        // Country ISO code for phone (e.g., '+1', '+44')
  String? phoneNumber;    // User's phone number
  String? email;          // User's email address
  String? password;       // User's password (optional depending on use)

  /// Creates a [UserModel] instance with optional fields.
  UserModel({
    this.name,
    this.surnames,
    this.gender,
    this.birthday,
    this.isoCode,
    this.phoneNumber,
    this.email,
    this.password,
  });
}
