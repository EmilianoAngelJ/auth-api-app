import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth_api_app/providers/token_providers.dart';
import 'package:auth_api_app/screens/screens.dart';

class AppRouter {
  // Define route names as static strings to avoid typos and enable reuse
  static String wrapperRoute = '/wraper';       // Initial loading/wrapper screen route
  static String homeScreenRoute = '/home';      // Main/home screen route
  static String loginScreenRoute = '/login';    // Login screen route
  static String signUpScreenRoute = '/signup';  // Sign up screen route
  static String profileScreenRoute = '/profile';// User profile screen route

  // Map routes to widget builder functions
  static Map<String, Widget Function (BuildContext)> routes = {
    wrapperRoute: (context) => const Wrapper(),
    homeScreenRoute: (context) => const HomeScreen(),
    loginScreenRoute: (context) => const LogInScreen(),
    signUpScreenRoute: (context) => const SignUpScreen(),
    profileScreenRoute: (context) => const ProfileScreen(),
  };
}

// Wrapper widget to decide which screen to show depending on authentication status
class Wrapper extends ConsumerWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Watch auth tokens provider to reactively rebuild on token changes
    final authTokens = ref.watch(authTokenProvider);

    // If idToken exists, user is authenticated, show HomeScreen
    if (authTokens['idToken'] != null) {
      return const HomeScreen();
    } else {
      // Otherwise, redirect to LogInScreen for authentication
      return const LogInScreen();
    }
  }
}
