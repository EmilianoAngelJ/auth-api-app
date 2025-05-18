import 'package:auth_api_app/models/models.dart';
import 'package:auth_api_app/providers/user_providers.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:auth_api_app/global/toast.dart';
import 'package:auth_api_app/widgets/add_space.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Displays a read-only email field that triggers a modal for updating the email.
class EmailFormField extends StatelessWidget {
  final String initialValue;

  const EmailFormField({super.key, required this.initialValue});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: TextFormField(
        initialValue: initialValue,
        readOnly: true, // prevent editing directly here
        decoration: InputDecoration(
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10),
            borderSide: const BorderSide(
              color: Color(0xffEE8845), // accent color for focus
              width: 2,
            ),
          ),
        ),
        onTap: () {
          _showModal(context); // show update email modal when tapped
        },
      ),
    );
  }

  /// Shows the bottom sheet modal for email and password input
  Future<void> _showModal(BuildContext context) async {
    final TextEditingController emailController = TextEditingController();
    final TextEditingController passwordController = TextEditingController();

    return showModalBottomSheet<void>(
      context: context,
      builder: (BuildContext context) {
        return Container(
          height: MediaQuery.of(context).size.height * 0.5,
          padding: const EdgeInsets.symmetric(horizontal: 15.0, vertical: 15.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const ModalHeader(),
              const VerticalSpace(height: 15),
              // Input for new email
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  labelText: 'New Email',
                  floatingLabelStyle: const TextStyle(color: Colors.black87),
                  border: _borderDecoretation(),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xffEE8845),
                      width: 2,
                    ),
                  ),
                ),
              ),
              const VerticalSpace(height: 20),
              // Input for current password (needed to reauthenticate)
              TextField(
                controller: passwordController,
                decoration: InputDecoration(
                  labelText: 'Password',
                  floatingLabelStyle: const TextStyle(color: Colors.black87),
                  border: _borderDecoretation(),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(
                      color: Color(0xffEE8845),
                      width: 2,
                    ),
                  ),
                ),
                obscureText: true,
              ),
              Expanded(child: Container()), // pushes buttons to bottom
              ModalButtons(
                emailController: emailController,
                passwordController: passwordController,
              ),
              const VerticalSpace(height: 20),
            ],
          ),
        );
      },
    );
  }

  // Common border style to avoid duplication
  OutlineInputBorder _borderDecoretation() =>
      OutlineInputBorder(borderRadius: BorderRadius.circular(10));
}

/// Modal header showing title and instructions
class ModalHeader extends StatelessWidget {
  const ModalHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return const Column(
      children: [
        Text(
          'Update Email',
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        Divider(),
        Text(
          'Enter your new email address and password to continue.',
          style: TextStyle(fontSize: 16),
        ),
      ],
    );
  }
}

/// Buttons row for Cancel and Continue actions
class ModalButtons extends StatelessWidget {
  const ModalButtons({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.red,
            textStyle:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),
          onPressed: () {
            Navigator.pop(context); // dismiss modal
          },
          child: const Text(
            'Cancel',
            style: TextStyle(color: Colors.white),
          ),
        ),
        UpdateEmailButton(
          emailController: emailController,
          passwordController: passwordController,
        ),
      ],
    );
  }
}

/// Button that triggers the email update logic
class UpdateEmailButton extends ConsumerWidget {
  const UpdateEmailButton({
    super.key,
    required this.emailController,
    required this.passwordController,
  });

  final TextEditingController emailController;
  final TextEditingController passwordController;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElevatedButton(
      child: const Text('Continue',
          style: TextStyle(
              color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
      onPressed: () async {
        final newEmail = emailController.text;
        final password = passwordController.text;
        final user = FirebaseAuth.instance.currentUser;

        if (user != null) {
          final credential = EmailAuthProvider.credential(
              email: user.email!, password: password);

          try {
            await user.reauthenticateWithCredential(credential);
            await user.verifyBeforeUpdateEmail(newEmail);

            // Creates a payload with the new email and password
            final payload = UserPayload(
              idToken: await user.getIdToken(), 
              user: UserModel(email: newEmail, password: password),
            );
            
            final message = await ref.read(updateEmailProvider(payload).future);
            Navigator.of(context).pop();
            showToast(message: '$message', backgroundColor: Colors.green);
          } catch (e) {
            //Catch error de contraseña o mail no valido
            Navigator.of(context).pop();
            showToast(message: 'Invalid email and/or password.');
          }
        }
      },
    );
  }
}
