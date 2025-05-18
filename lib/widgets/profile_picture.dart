import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ProfilePicture extends ConsumerWidget {
  const ProfilePicture({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Stack profile picture and edit button overlay
    return const Stack(
      children: [
        _ProfilePicture(),       // Circular profile icon
        _SelectPictureOptions(), // Edit button positioned over picture
      ],
    );
  }
}

class _SelectPictureOptions extends ConsumerWidget {
  const _SelectPictureOptions();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Positioned(
      left: 70,
      bottom: 0,
      child: Container(
        alignment: Alignment.center,
        height: 30,
        width: 30,
        decoration: const BoxDecoration(
          color: Colors.white70,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          padding: EdgeInsets.zero,
          onPressed: () {
            // Navigate to profile screen if not already there
            if (ModalRoute.of(context)?.settings.name != '/profile') {
              Navigator.pushNamed(context, '/profile');
            }
          }, 
          icon: const Icon(Icons.edit, size: 18,)
        )
      ), 
    );
  }
}

class _ProfilePicture extends StatelessWidget {
  const _ProfilePicture();

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        // Navigate to profile screen on tap, if not already there
        if (ModalRoute.of(context)?.settings.name != '/profile') {
          Navigator.pushNamed(context, '/profile');
        }
      },
      child: Container(
        height: 100,
        width: 100,
        decoration: BoxDecoration(
          color: Colors.grey[300], // Background color of avatar circle
          shape: BoxShape.circle,
        ),
        child: const Center(child: Icon(Icons.person, size: 80)) // Default person icon
      ),
    );
  }
}
