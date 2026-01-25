import 'package:flutter/material.dart';

class AppTheme {
  static const Color primaryBlue = Color(0xFF2962FF);
  static const Color backgroundWhite = Color(0xFFF8F9FA); 
  static const Color textBlack = Color(0xFF1A1A1A);

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryBlue,
      scaffoldBackgroundColor: backgroundWhite,
      fontFamily: 'Inter', 
      
      // REMOVED cardTheme to fix your error
      
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryBlue,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 56),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          elevation: 2,
        ),
      ),
    );
  }
}