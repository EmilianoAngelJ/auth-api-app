import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:auth_api_app/pages/pages.dart';

/// A tab-based view to organize contacts into "Favorite" and "Frequent".
/// This widget uses [DefaultTabController] to enable navigation between two tabs.
class FavoritesPage extends ConsumerWidget {
  const FavoritesPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Scaffold(
      body: DefaultTabController(
        length: 2, // Number of tabs
        child: Column(
          children: <Widget>[
            // Tab bar at the top with two tabs
            TabBar(
              tabs: [
                Tab(text: 'Favorite'),
                Tab(text: 'Frequent'),
              ],
            ),
            // Tab view showing corresponding pages for each tab
            Expanded(
              child: TabBarView(
                children: <Widget>[
                  FavoriteContactsPage(),
                  FrequentContactsPage(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
