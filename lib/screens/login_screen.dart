import 'package:auth_api_app/models/user_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth_api_app/global/toast.dart';
import 'package:auth_api_app/providers/auth_providers.dart';
import 'package:auth_api_app/providers/global_providers.dart';
import 'package:auth_api_app/theme/colors.dart';

import '../widgets/widgets.dart';

/// Main screen for user login
class LogInScreen extends StatelessWidget {
  const LogInScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Key to manage and validate the form
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
                  Center(child: Image.asset('assets/logo.png', height: 200,)),
                  const VerticalSpace(height: 20),

                  // Title
                  Text('Sign in with your account', style: Theme.of(context).textTheme.headlineMedium,),
                  const VerticalSpace(height: 20),

                  // Login form (email + password)
                  _LogInForm(formKey: formKey),
                  const VerticalSpace(height: 20),

                  // Submit login button
                  _LogInButton(formKey: formKey),
                  const VerticalSpace(height: 10),

                  // Link to sign-up screen
                  const _SignUpText(),
                  const VerticalSpace(height: 40),

                  // You can re-enable social login options here if needed
                  // const SignInOptions(),
                  const VerticalSpace(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Form widget for email and password fields
class _LogInForm extends ConsumerWidget {
  const _LogInForm({
    required this.formKey,
  });

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch error messages for validation feedback
    final emailError = ref.watch(emailErrorProvider);
    final passwordError = ref.watch(passwordErrorProvider);

    return Form(
      key: formKey,
      child: Column(
        children: [
          // Email field
          CustomTextFormField(
            labelText: 'Email',
            hintText: 'john.doe@mail.com',
            prefixIcon: Icons.mail,
            isPassword: false,
            isConfirmPassword: false,
            isMail: true,
            validatorText: emailError ?? 'Email is required',
            onSaved: (newValue) {
              ref.read(emailProvider.notifier).state = newValue!;
            },
          ),
          const VerticalSpace(height: 20),

          // Password field
          CustomTextFormField(
            labelText: 'Password',
            hintText: '********',
            prefixIcon: Icons.lock,
            isPassword: true,
            isMail: false,
            isConfirmPassword: false,
            validatorText: passwordError ?? 'Password is required',
            visibilityProvider: passwordLogInVisibilityProvider,
            onSaved: (newValue) {
              ref.read(passwordProvider.notifier).state = newValue!;
            },
          ),
        ],
      )
    );
  }
}

/// Button that triggers the login process
class _LogInButton extends ConsumerWidget {
  const _LogInButton({
    required this.formKey,
  });

  final GlobalKey<FormState> formKey;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return SignButton(
      text: 'Sign In',
      onPressed: () async {
        if (formKey.currentState!.validate()) {
          formKey.currentState!.save();

          // Read email and password from state
          String email = ref.read(emailProvider);
          String password = ref.read(passwordProvider);

          // Start loading state
          ref.read(loadingProvider.notifier).state = false;

          final params = UserModel(email: email, password: password);

          try {
            // Attempt login using the auth provider
            final success = await ref.read(logInUserProvider(params).future);

            if (success) {
              // Navigate to home on success
              Navigator.pushReplacementNamed(context, "/home");
            }
          } catch (e) {
            // Show error toast
            showToast(message: '$e');
          } finally {
            // Stop loading
            ref.read(loadingProvider.notifier).state = true;
          }
        }
      },
    );
  }
}

/// Text + navigation to the sign-up screen
class _SignUpText extends StatelessWidget {
  const _SignUpText();

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text("Don't have an account yet? ", style: Theme.of(context).textTheme.labelLarge,),
        GestureDetector(
          onTap: () {
            Navigator.pushNamed(context, '/signup');
          },
          child: const Text(
            'Create one',
            style: TextStyle(
              color: AppColors.secondaryColor,
              fontSize: 16,
              fontWeight: FontWeight.bold
            ),
          )
        )
      ],
    );
  }
}
