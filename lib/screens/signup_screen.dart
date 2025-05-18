import 'package:auth_api_app/models/models.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth_api_app/global/toast.dart';
import 'package:auth_api_app/theme/colors.dart';
import 'package:phone_input/phone_input_package.dart';

import 'package:auth_api_app/providers/auth_providers.dart';
import 'package:auth_api_app/providers/global_providers.dart';

import '../widgets/widgets.dart';

/// Screen for user registration
class SignUpScreen extends StatelessWidget {
  const SignUpScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Key used to manage form validation and state
    final formKey = GlobalKey<FormState>();

    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15),
            child: SingleChildScrollView(
              child: Column(
                children: <Widget>[
                  // App logo
                  Center(
                      child: Image.asset(
                    'assets/logo.png',
                    height: 170,
                  )),
                  // Title
                  Text(
                    'Create an account',
                    style: Theme.of(context).textTheme.headlineMedium,
                  ),
                  const VerticalSpace(height: 20),
                  // Form with all fields
                  _LogInForm(formKey: formKey),
                  const VerticalSpace(height: 20),
                  // Submit button
                  _LogInButton(formKey: formKey),
                  const VerticalSpace(height: 10),
                  // Redirect to login if already registered
                  const _SignUpText(),
                  const VerticalSpace(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Contains the registration form inputs
class _LogInForm extends ConsumerWidget {
  const _LogInForm({
    required this.formKey,
  });

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Form(
      key: formKey,
      child: Column(
        children: [
          // Email input
          CustomTextFormField(
            labelText: 'Email',
            hintText: 'john.doe@mail.com',
            prefixIcon: Icons.mail,
            isPassword: false,
            isConfirmPassword: false,
            isMail: true,
            validatorText: 'Email is required',
            onSaved: (newValue) {
              ref.read(emailProvider.notifier).state = newValue!;
            },
          ),
          const VerticalSpace(height: 20),
          // First name input
          CustomTextFormField(
            labelText: 'Name',
            hintText: 'Your name',
            prefixIcon: Icons.person,
            isPassword: false,
            isConfirmPassword: false,
            isMail: false,
            validatorText: 'Name is required',
            onSaved: (newValue) {
              ref.read(nameProvider.notifier).state = newValue!;
            },
          ),
          const VerticalSpace(height: 20),
          // Surnames input
          CustomTextFormField(
            labelText: 'Surnames',
            hintText: 'Last Names',
            prefixIcon: Icons.person,
            isPassword: false,
            isConfirmPassword: false,
            isMail: false,
            validatorText: 'Surnames are required',
            onSaved: (newValue) {
              ref.read(surnamesProvider.notifier).state = newValue!;
            },
          ),
          const VerticalSpace(height: 20),
          // Date of birth picker
          BirthdateFormField(
            initialValue: null,
            onSaved: (newValue) {
              ref.read(birthdayProvider.notifier).state = newValue!;
            },
          ),
          // Gender dropdown
          GenderDropDownFormField(
            initialValue: null,
            isSignUp: true,
            icon: Icons.wc,
            onChanged: (newValue) {},
            onSaved: (newValue) {
              ref.read(genderProvider.notifier).state = newValue!;
            },
          ),
          const VerticalSpace(height: 20),
          // Phone input
          PhoneFormField(
            initialValue: PhoneNumber(
              isoCode: IsoCode.values.firstWhere(
                (isoCode) => isoCode.name == ('MX'),
                orElse: () => IsoCode.MX,
              ),
              nsn: '',
            ),
            onSaved: (newValue) {
              ref.read(phoneProvider.notifier).state = newValue!;
            },
          ),
          const VerticalSpace(height: 20),
          // Password input
          CustomTextFormField(
            labelText: 'Password',
            hintText: '********',
            prefixIcon: Icons.lock,
            validatorText: 'Password is required',
            isPassword: true,
            isConfirmPassword: false,
            isMail: false,
            visibilityProvider: passwordSignUpVisibilityProvider,
            passwordProvider: passwordProvider,
            onChanged: (value) {
              ref.read(passwordProvider.notifier).state = value!;
            },
            onSaved: (newValue) {
              ref.read(passwordProvider.notifier).state = newValue!;
            },
          ),
          const VerticalSpace(height: 20),
          // Confirm password input
          CustomTextFormField(
            labelText: 'Confirm password',
            hintText: '********',
            prefixIcon: Icons.lock,
            validatorText: 'This field is required',
            isPassword: true,
            isMail: false,
            isConfirmPassword: true,
            visibilityProvider: confirmPasswordVisibilityProvider,
            passwordProvider: passwordProvider,
            onSaved: (newValue) {},
          ),
        ],
      ),
    );
  }
}

/// Registration button widget
class _LogInButton extends ConsumerWidget {
  const _LogInButton({
    required this.formKey,
  });

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SignButton(
      text: 'Sign Up',
      onPressed: () async {
        // Validate form fields
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();

          // Read values from providers
          String email = ref.read(emailProvider);
          String name = ref.read(nameProvider);
          String surnames = ref.read(surnamesProvider);
          String gender = ref.read(genderProvider);
          DateTime? birthday = ref.read(birthdayProvider);
          String password = ref.read(passwordProvider);
          PhoneNumber? number = ref.read(phoneProvider);

          // Reset loading state
          ref.read(loadingProvider.notifier).state = false;

          // Build user model for registration
          final params = UserModel(
            email: email,
            password: password,
            name: name,
            surnames: surnames,
            gender: gender,
            birthday: birthday!,
            isoCode: number!.isoCode,
            phoneNumber: number.nsn,
          );

          try {
            // Call registration function
            final success = await ref.read(signUpUserProvider(params).future);

            if (success) {
              // Navigate to home if successful
              Navigator.pushReplacementNamed(context, "/home");
            }
          } catch (e) {
            // Show error toast if registration fails
            showToast(message: '$e');
          } finally {
            // Reset loading state
            ref.read(loadingProvider.notifier).state = true;
          }
        }
      },
    );
  }
}

/// Widget to redirect to login if user already has an account
class _SignUpText extends StatelessWidget {
  const _SignUpText();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          'Have an account already?. ',
          style: Theme.of(context).textTheme.labelLarge,
        ),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/login');
          },
          child: const Text(
            'Log In',
            style: TextStyle(
              color: AppColors.secondaryColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        )
      ],
    );
  }
}
