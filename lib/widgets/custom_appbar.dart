import 'package:flutter/material.dart';
import 'package:auth_api_app/theme/theme.dart';

class CustomAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const CustomAppbar({
    super.key,
    required this.title,
  });

  @override
  Size get preferredSize => preferredSizeAppbar;

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
    );
  }
}
