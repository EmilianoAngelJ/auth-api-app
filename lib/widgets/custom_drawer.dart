import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth_api_app/global/toast.dart';
import 'package:auth_api_app/providers/session_provider.dart';
import 'package:auth_api_app/providers/token_providers.dart';
import 'package:auth_api_app/providers/user_providers.dart';
import 'package:auth_api_app/screens/screens.dart';
import 'package:auth_api_app/theme/colors.dart';
import 'package:auth_api_app/widgets/widgets.dart';

class CustomDrawer extends StatelessWidget {
  const CustomDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 330, // Fixed width for drawer
      child: Drawer(
        child: SingleChildScrollView(
          child: Column(
            children: [
              _DrawerHeader(),  // Header with user info
              const _DrawerBody() // Menu options below header
            ],
          ),
        ),
      ),
    );
  }
}

class _DrawerBody extends ConsumerWidget {
  const _DrawerBody();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authSessionNotifier = ref.read(sessionProvider.notifier);
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.person),
          title: Text('Profile', style: Theme.of(context).textTheme.bodyLarge,),
          onTap: () {
            Navigator.pushNamed(context, '/profile'); // Navigate to Profile screen
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: Text('Log out', style: Theme.of(context).textTheme.bodyLarge,),
          onTap: () async {
            authSessionNotifier.logout(); // Clear session state
            await ref.read(authTokenProvider.notifier).deleteTokens(); // Delete stored tokens
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => const LogInScreen()),
              (Route<dynamic> route) => false, // Remove all previous routes
            );
            showToast(message: "Logged out", backgroundColor: Colors.green); // Show feedback toast
          },
        ),
      ]
    );
  }
}

class _DrawerHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Read current idToken from authTokenProvider
    final idToken = ref.watch(authTokenProvider)['idToken'];

    // Show loading indicator if token is not yet available
    if (idToken == null) {
      return const Center(child: CircularProgressIndicator.adaptive());
    }

    // Fetch user data asynchronously using the idToken
    final userAsyncValue = ref.watch(userProvider(idToken));
    return userAsyncValue.when(
      data: (userData) {
        // User data successfully fetched, display header with profile info
        return Container(
          height: 200,
          width: MediaQuery.of(context).size.width,
          padding: const EdgeInsets.only(top: 40, left: 15),
          color: AppColors.primaryColor,
          child: Row(
            children: [
              const ProfilePicture(), // User profile picture widget
              const HorizontalSpace(width: 10),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      'Welcome!',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      userData['name'] ?? 'Nombre no disponible', // Display user name or fallback
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      userData['email'] ?? 'Email no disponible', // Display user email or fallback
                      style: const TextStyle(
                        fontSize: 18,
                      ),
                    ),
                  ],
                ),
              )
            ],
          ),
        );
      },
      loading: () => const SafeArea(
        child: Padding(
          padding: EdgeInsets.all(15),
          child: CircularProgressIndicator.adaptive(), // Show while user data is loading
        ),
      ),
      error: (error, stack) {
        // Show error message if user data loading fails
        return SafeArea(child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Text('$error'), 
        ));
      } 
    );
  }
}
