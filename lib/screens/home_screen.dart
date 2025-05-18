import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:auth_api_app/pages/pages.dart';
import 'package:auth_api_app/providers/session_provider.dart';
import 'package:auth_api_app/providers/token_providers.dart';
import 'package:auth_api_app/widgets/widgets.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  
  @override
  void initState() {
    super.initState();
    // Schedule a microtask to check and refresh tokens right after the widget is built
    Future.microtask(() {
      final tokens = ref.watch(authTokenProvider);
      // Call checkAndRefreshToken with current tokens to ensure valid session
      ref.read(sessionProvider.notifier).checkAndRefreshToken(tokens['idToken'], tokens['refreshToken']);
    });
  }

  // Current index of the selected bottom navigation tab
  int _currentIndex = 1;

  // List of pages to display for each bottom navigation tab
  final List<Widget> _pages = <Widget>[
    const FavoritesPage(),
    const ContactsPage(),
    const Page2(),
    const Page3(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppbar(title: 'Auth Contacts'),
      drawer: const CustomDrawer(),
      // Use IndexedStack to maintain the state of all pages and switch visible one based on _currentIndex
      body: IndexedStack(
        index: _currentIndex,
        children: _pages,
      ),
      bottomNavigationBar: _bottomNavBar(), // Bottom navigation bar widget
    );
  }

  // Build the bottom navigation bar with fixed tabs
  BottomNavigationBar _bottomNavBar() {
    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      fixedColor: Colors.white,
      currentIndex: _currentIndex,
      // Update _currentIndex and rebuild UI when a tab is tapped
      onTap: (int index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(
            Icons.star,
            color: Colors.white,
            size: 30,
          ),
          label: 'Favorites',  
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.person,
            color: Colors.white,
            size: 30,
          ),
          label: 'Contacts',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.history,
            color: Colors.white,
            size: 30,
          ),
          label: 'Recents',
        ),
        BottomNavigationBarItem(
          icon: Icon(
            Icons.settings,
            color: Colors.white,
            size: 30,
          ),
          label: 'Settings',
        ),
      ],
    );
  }
}
