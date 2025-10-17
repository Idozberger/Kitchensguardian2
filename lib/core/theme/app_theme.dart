import 'package:flutter/material.dart';
import 'package:foodkitchen/core/global/functions/resize.dart';
import 'package:foodkitchen/core/theme/app_colors.dart';

class AppTheme {
  // Light Theme
  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      // Primary Color used throughout the app
      primaryColor: AppColors.primaryColor,
      drawerTheme: const DrawerThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.zero),
      ),

      // AppBar Styling
      appBarTheme: const AppBarTheme(
        elevation: 0, // no shadow
        scrolledUnderElevation: 0,
        centerTitle: true,
        backgroundColor: Colors.white, // appbar bg
        foregroundColor: Colors.black, // title & icons
      ),

      //  Scaffold background color
      scaffoldBackgroundColor: Colors.white,

      // Icon Theme (default color for icons)
      iconTheme: const IconThemeData(color: Colors.black87, size: 24),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor, // button bg
          foregroundColor: Colors.white, // button text color
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(h(22)), // rounded corners
          ),
          textStyle: TextStyle(
            fontSize: t(14),
            fontWeight: FontWeight.w500,
            color: Colors.black,
          ),
          elevation: 0,
          fixedSize: Size(double.maxFinite, h(45)),
          maximumSize: Size(double.maxFinite, h(45)),
          minimumSize: Size(double.maxFinite, h(45)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          backgroundColor: Colors.transparent,
          side: BorderSide(color: AppColors.primaryColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(h(22)),
          ),
          textStyle: TextStyle(
            fontSize: t(14),
            fontWeight: FontWeight.w500,
            color: AppColors.primaryColor,
          ),
          elevation: 0,
          fixedSize: Size(double.maxFinite, h(45)),
          maximumSize: Size(double.maxFinite, h(45)),
          minimumSize: Size(double.maxFinite, h(45)),
        ),
      ),

      progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.white),
      // Text Theme (typography for light mode)
      textTheme: TextTheme(
        bodyLarge: TextStyle(
          fontFamily: "SFProDisplay",
          color: Colors.black,
          fontSize: t(16),
        ),
        bodyMedium: TextStyle(
          fontFamily: "SFProDisplay",
          color: Colors.black,
          fontSize: t(15),
          fontWeight: FontWeight.w500,
        ),
        bodySmall: TextStyle(
          fontFamily: "SFProDisplay",
          color: Colors.black,
          fontSize: t(13),
        ),
        headlineLarge: TextStyle(
          fontFamily: "SFProDisplay",
          color: Colors.black,
          fontSize: t(16),
          fontWeight: FontWeight.w500,
        ),
        headlineMedium: TextStyle(
          fontFamily: "SFProDisplay",
          color: Color(0xff787878),
          fontSize: t(14),
          fontWeight: FontWeight.w500,
        ),
        headlineSmall: TextStyle(
          fontFamily: "SFProDisplay",
          color: Color(0xff8D8C8C),
          fontSize: t(13),
          fontWeight: FontWeight.w400,
        ),
      ),

      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        elevation: 0,
        showUnselectedLabels: true,
        selectedItemColor: AppColors.primaryColor,

        selectedLabelStyle: TextStyle(
          color: AppColors.primaryColor,
          fontSize: h(12),
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: TextStyle(
          color: AppColors.unSelectedBottomItemColor,
          fontSize: h(12),
          fontWeight: FontWeight.w500,
        ),
        unselectedItemColor: AppColors.unSelectedBottomItemColor,
        type: BottomNavigationBarType.fixed,
      ),

      // Input Field Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
    );
  }

  // Dark Theme
  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,

      // AppBar Styling
      appBarTheme: const AppBarTheme(
        elevation: 0,
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),

      // Scaffold background color
      scaffoldBackgroundColor: Colors.black,

      // Icon Theme (default color for icons in dark mode)
      iconTheme: const IconThemeData(color: Colors.white70, size: 24),

      // Progressive Indicator
      progressIndicatorTheme: ProgressIndicatorThemeData(color: Colors.black),

      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryColor,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(h(22)),
          ),
          elevation: 0,
          fixedSize: Size(double.maxFinite, h(40)),
          maximumSize: Size(double.maxFinite, h(40)),
          minimumSize: Size(double.maxFinite, h(40)),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(h(22)),
          ),
          elevation: 0,
          fixedSize: Size(double.maxFinite, h(40)),
          maximumSize: Size(double.maxFinite, h(40)),
          minimumSize: Size(double.maxFinite, h(40)),
        ),
      ),

      // Text Theme (typography for dark mode)
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: Colors.white),
        bodyMedium: TextStyle(color: Colors.white70),
        bodySmall: TextStyle(color: Colors.white60),
      ),

      // Input Field Theme
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: Colors.grey),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: AppColors.primaryColor, width: 2),
        ),
      ),
    );
  }
}
