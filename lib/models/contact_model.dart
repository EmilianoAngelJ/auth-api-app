/// A model representing a single contact entry.
/// Used for data serialization and deserialization when interacting with the API.
class ContactModel {

  final String? id;
  final String name;
  final String contactType;

  /// Creates a [ContactModel] instance.
  ContactModel({
    this.id,
    required this.name,
    required this.contactType,
  });
}
