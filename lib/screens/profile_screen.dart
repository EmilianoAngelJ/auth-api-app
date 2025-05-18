import 'package:auth_api_app/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth_api_app/global/toast.dart';
import 'package:auth_api_app/providers/global_providers.dart';
import 'package:auth_api_app/providers/token_providers.dart';
import 'package:auth_api_app/providers/user_providers.dart';
import 'package:auth_api_app/theme/colors.dart';
import 'package:auth_api_app/widgets/widgets.dart';
import 'package:phone_input/phone_input_package.dart';

/// Main profile screen scaffold
class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: CustomAppbar(
        title: 'Profile',
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(15),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ProfilePicture(), // Display user profile image
            VerticalSpace(height: 20),
            ProfileForm(), // Form for editing profile details
          ],
        ),
      ),
    );
  }
}

/// Stateful widget to handle profile form and submission logic
class ProfileForm extends ConsumerStatefulWidget {
  const ProfileForm({super.key});

  @override
  ConsumerState<ConsumerStatefulWidget> createState() => _ProfileFormState();
}

class _ProfileFormState extends ConsumerState<ProfileForm> {
  final _formKey = GlobalKey<FormState>();

  // Form field values
  String? _name;
  String? _surnames;
  PhoneNumber? _phone;
  DateTime? _birthday;
  String? _gender;

  /// Marks form as changed so the update button can be enabled
  void onFieldChanged() {
    ref.read(formChangeProvider.notifier).setChanged();
  }

  /// Submits the form and updates user data via `updateUserProvider`
  Future<String?> _saveForm() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      final idToken = ref.watch(authTokenProvider)['idToken'];

      // Ensure token is available before continuing
      if (idToken == null) {
        showToast(message: 'idToken Error', backgroundColor: AppColors.redFeedback);
        return null;
      }

      // Construct user payload for update
      final params = UserPayload(
        idToken: idToken,
        user: UserModel(
          name: _name!,
          surnames: _surnames!,
          gender: _gender!,
          birthday: _birthday!,
          isoCode: _phone!.isoCode,
          phoneNumber: _phone!.nsn,
        ),
      );

      try {
        // Await user update response and show feedback
        final successMessage = await ref.read(updateUserProvider(params).future);
        showToast(message: '$successMessage', backgroundColor: AppColors.greenFeedback);
      } catch (e) {
        showToast(message: '$e', backgroundColor: AppColors.redFeedback);
      } finally {
        // Reset form state and hide keyboard
        ref.read(formChangeProvider.notifier).resetChanged();
        FocusScope.of(context).unfocus();
      }
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    // Get idToken to fetch and update user data
    final idToken = ref.watch(authTokenProvider)['idToken'];

    // If token isn't available, show loading indicator
    if (idToken == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    final hasChanges = ref.watch(formChangeProvider);
    final userAsyncValue = ref.watch(userProvider(idToken));

    // Handle user data states
    return userAsyncValue.when(
      data: (userData) {
        return Form(
          key: _formKey,
          child: Column(
            children: [
              _buildNameField(userData),
              _buildSurnamesField(userData),
              _buildGenderField(userData),
              const VerticalSpace(height: 20),
              _buildBirthdayField(userData),
              _buildPhoneField(userData),
              const VerticalSpace(height: 20),
              EmailFormField(initialValue: userData['email']),
              _buildSaveButton(hasChanges),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator.adaptive()),
      error: (error, stack) => Text('$error'),
    );
  }

  /// Input field for user's first name
  Widget _buildNameField(Map<String, dynamic>? userData) {
    return ProfileTextFormField(
      initialValue: userData?['name'] ?? '',
      labelText: 'Name',
      validatorText: 'A name is required',
      onChanged: (newValue) {
        onFieldChanged();
        _name = newValue;
      },
      onSaved: (newValue) => _name = newValue!,
    );
  }

  /// Input field for user's surnames
  Widget _buildSurnamesField(Map<String, dynamic>? userData) {
    return ProfileTextFormField(
      initialValue: userData?['surnames'] ?? '',
      labelText: 'Surnames',
      hintText: 'Last Names',
      validatorText: 'Surnames are required',
      onChanged: (newValue) {
        onFieldChanged();
        _surnames = newValue;
      },
      onSaved: (newValue) => _surnames = newValue!,
    );
  }

  /// Dropdown selector for gender
  Widget _buildGenderField(Map<String, dynamic>? userData) {
    return GenderDropDownFormField(
      initialValue: userData?['gender'] ?? '',
      isSignUp: false,
      onChanged: (newValue) {
        onFieldChanged();
        _gender = newValue!;
      },
      onSaved: (newValue) => _gender = newValue!,
    );
  }

  /// Date picker for birthday
  Widget _buildBirthdayField(Map<String, dynamic>? userData) {
    final birthdayData = userData?['birthday'];

    // Convert Firestore timestamp to DateTime
    DateTime birthday = DateTime.fromMillisecondsSinceEpoch(
      birthdayData['_seconds'] * 1000 + birthdayData['_nanoseconds'] ~/ 1000000,
    );

    return BirthdateFormField(
      initialValue: (userData?['birthday'] != null) ? birthday : null,
      onChanged: (newValue) {
        onFieldChanged();
        _birthday = newValue!;
      },
      onSaved: (newValue) => _birthday = newValue!,
    );
  }

  /// Phone number input using international phone input widget
  Widget _buildPhoneField(Map<String, dynamic>? userData) {
    return PhoneFormField(
      initialValue: PhoneNumber(
        isoCode: IsoCode.values.firstWhere(
          (isoCode) => isoCode.name == (userData?['IsoCode'] ?? 'MX'),
          orElse: () => IsoCode.MX,
        ),
        nsn: userData?['phoneNumber'] ?? '',
      ),
      onChanged: (newValue) {
        onFieldChanged();
        _phone = newValue;
      },
      onSaved: (newValue) => _phone = newValue!,
    );
  }

  /// Save button enabled only when form has changes
  Widget _buildSaveButton(bool hasChanges) {
    return ElevatedButton(
      onPressed: hasChanges ? _saveForm : null,
      child: const Text(
        'Update',
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
