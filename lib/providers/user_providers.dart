import 'package:auth_api_app/models/user_payload.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth_api_app/services/firebase_services/firebase_services_users.dart';
 
// Provider that creates an instance of UserServices
final userServiceProvider = Provider<UserServices>((ref) {
  return UserServices();
});

// FutureProvider.family to fetch user information based on the given idToken
final userProvider = FutureProvider.family<Map<String, dynamic>, String>((ref, idToken) async {
  final userService = ref.watch(userServiceProvider);
  return await userService.getUser(idToken);
});

// FutureProvider.family to update user info, automatically disposed when no longer used
final updateUserProvider = FutureProvider.autoDispose.family<String?, UserPayload>((ref, UserPayload payload) async {
  final userService = ref.watch(userServiceProvider);

  try {
    // Call updateUser method with fields from UserPayload
    final successMessage = await userService.updateUser(
      payload.idToken!,
      payload.user!.name!,
      payload.user!.surnames!,
      payload.user!.gender!,
      payload.user!.birthday!,
      payload.user!.isoCode!,
      payload.user!.phoneNumber!
    );

    // Invalidate cached userProvider to refresh user data after update
    ref.invalidate(userProvider);
    return successMessage;

  } catch (e) {
    // Forward exceptions for handling in UI or caller
    throw Exception(e);
  }
});

// FutureProvider.family to update user email, automatically disposed
final updateEmailProvider = FutureProvider.autoDispose.family((ref, UserPayload payload) async {
  final userService = ref.watch(userServiceProvider);

  try {
    // Call updateEmail with email and password from UserPayload
    final responseMessage = await userService.updateEmail(
      payload.idToken!, 
      payload.user!.email!, 
      payload.user!.password!
    );

    // Invalidate cached userProvider to refresh user data after email update
    ref.invalidate(userProvider);
    return responseMessage;

  } catch (e) {
    throw Exception('$e');
  }
});