import 'package:flutter/material.dart';
import 'package:auth_api_app/theme/colors.dart';

const preferredSizeAppbar = Size.fromHeight(50);

class AppTheme {

  static ThemeData ligthTheme = ThemeData(
    
    scaffoldBackgroundColor: AppColors.backgroundColor,

    // Icons Theme
    iconTheme: const IconThemeData(
      size: 24
    ),

    // Text Theme
    textTheme: const TextTheme(
      headlineMedium: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
      titleLarge: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      titleMedium: TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
      bodyLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.normal),
      bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.normal),
      labelLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.normal),
      labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.normal, height: 1.5)
    ),

    // Textselection Theme
    textSelectionTheme: TextSelectionThemeData(
      cursorColor: Colors.black,
      selectionColor: AppColors.primaryColor.withValues(alpha: 0.3),
      selectionHandleColor: AppColors.primaryColor
    ),

    // FilledButton Theme
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        )
      )
    ),

    // FloatingActionButton Theme
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: AppColors.primaryColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10)
      )
    ),

    // AppBar Theme
    appBarTheme: const AppBarTheme(
      elevation: 0,
      backgroundColor: AppColors.primaryColor,
      // AppBar Icon
      iconTheme: IconThemeData(
        color: AppColors.backgroundColor,
        size: 30
      ),
      // AppBar title
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),

    // BottomNavigationBar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.tertiaryColor,
      unselectedItemColor: Colors.black54,
    ),

    // TabBar Theme
    tabBarTheme: TabBarTheme(
      labelColor: AppColors.tertiaryColor,
      indicatorColor: AppColors.primaryColor,
      splashFactory: InkRipple.splashFactory,
      overlayColor: WidgetStatePropertyAll<Color?>(AppColors.tertiaryColor.withValues(alpha: 0.1),)
    ), 

    // Elevetaded Button Theme
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primaryColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10)
        )
      )
    ),

    // InputDecoration Theme
    inputDecorationTheme: const InputDecorationTheme(
      floatingLabelStyle: TextStyle(
        color: AppColors.primaryColor,
        fontSize: 16,
        fontWeight: FontWeight.w600
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          color: Colors.black45,
          width: 1.5
        )
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(10)),
        borderSide: BorderSide(
          color: AppColors.primaryColor,
          width: 2
        )
      ),
    )
  );
}
