import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth_api_app/providers/global_providers.dart';

class SignButton extends ConsumerWidget {
  final String text;
  final Function() onPressed;

  const SignButton({
    super.key, 
    required this.text, 
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch loading state to toggle button content
    bool loading = ref.watch(loadingProvider);

    return FilledButton(
      onPressed: onPressed,
      child: Container(
        padding: const EdgeInsets.all(5),
        height: 50,
        width: 410,      
        child: Center(
          // Show text when not loading; otherwise show a loading spinner
          child: loading 
            ? Text(
                text, 
                style: const TextStyle(
                  fontWeight: FontWeight.bold, 
                  fontSize: 16,
                ),
              )
            : const CircularProgressIndicator(color: Colors.white),
        ),
      ),
    );
  }
}
