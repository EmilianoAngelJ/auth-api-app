import 'package:auth_api_app/global/toast.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth_api_app/providers/contacts_provider.dart';
import 'package:auth_api_app/providers/token_providers.dart';
import 'package:auth_api_app/theme/colors.dart';
import 'package:auth_api_app/widgets/widgets.dart';

/// Main screen displaying user's contacts and allowing creation of new ones.
class ContactsPage extends ConsumerWidget {
  const ContactsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      body: const Padding(
        padding: EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ContactsPageHeader(), // Static header
              ContactsListView(),   // Dynamic contact list
              VerticalSpace(height: 15),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        // Opens modal to register new contact
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true,
            builder: (context) => const ContactForm(),
          );
        },
        child: const Icon(
          Icons.add,
          color: AppColors.backgroundColor,
        ),
      ),
    );
  }
}

/// Displays the screen title and description.
class ContactsPageHeader extends StatelessWidget {
  const ContactsPageHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Wrap(
        children: [
          Text(
            'Your Contacts',
            style: Theme.of(context).textTheme.headlineMedium,
          ),
          Text(
            'Register and manage your contacts from here',
            style: Theme.of(context).textTheme.labelLarge,
          ),
        ],
      ),
    );
  }
}

/// Retrieves and displays contacts from the API based on the user's token.
class ContactsListView extends ConsumerWidget {
  const ContactsListView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get ID token required for authenticated requests
    final idToken = ref.watch(authTokenProvider)['idToken'];

    if (idToken == null) {
      return const Center(child: CircularProgressIndicator());
    }

    // Fetch contacts using token
    final contactsAsyncValue = ref.watch(contactsProvider(idToken));

    // Handle different async states
    return contactsAsyncValue.when(
      data: (contacts) {
        return ListView.separated(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          itemCount: contacts.length,
          itemBuilder: (context, index) {
            final contact = contacts[index];
            return ContactCard(
              contactName: contact['name'],
              contactType: contact['contactType'],
              contactId: contact['contactId'],
            );
          },
          separatorBuilder: (context, index) => const SizedBox(height: 15),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, _) => Center(child: Text('Error: $error')),
    );
  }
}

/// Represents a visual card for a single contact, with delete functionality.
class ContactCard extends ConsumerWidget {
  final String contactName;
  final String contactType;
  final String contactId;

  const ContactCard({
    super.key,
    required this.contactName,
    required this.contactType,
    required this.contactId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: 70,
      padding: const EdgeInsets.all(10),
      decoration: _contactCardDecoration(),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Contact info (name + type)
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                contactName,
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Text(
                contactType,
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),

          // Delete button with feedback
          IconButton(
            onPressed: () async {
              try {
                final message =
                    await ref.watch(deleteContactProvider(contactId).future);
                showToast(
                  message: message,
                  backgroundColor: AppColors.redFeedback,
                );
              } catch (e) {
                showToast(
                  message: '$e',
                  backgroundColor: AppColors.redFeedback,
                );
              }
            },
            icon: const Icon(
              Icons.delete_outlined,
              color: AppColors.redFeedback,
              size: 30,
            ),
          ),
        ],
      ),
    );
  }

  /// Returns decoration used for each contact card.
  BoxDecoration _contactCardDecoration() {
    return BoxDecoration(
      color: AppColors.backgroundColor,
      borderRadius: BorderRadius.circular(10),
      border: Border.all(
        color: Colors.black45,
        width: 1.5,
      ),
    );
  }
}
