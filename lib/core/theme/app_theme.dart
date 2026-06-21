import 'package:flutter/material.dart';

class AppTheme {
  static const primaryColor = Color(0xFFFF8A65);
  static const backgroundColor = Color(0xFFFFFDF9);
  static const textColor = Color(0xFF4E342E);

  static final List<BoxShadow> softShadow = [
    BoxShadow(color: primaryColor.withValues(alpha:0.08), blurRadius: 12, offset: const Offset(0, 6))
  ];

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: primaryColor,
      scaffoldBackgroundColor: backgroundColor,
      fontFamily: 'Gulim',
      textTheme: const TextTheme(
        bodyLarge: TextStyle(fontFamily: 'Gulim', fontWeight: FontWeight.bold),
        bodyMedium: TextStyle(fontFamily: 'Gulim', fontWeight: FontWeight.bold),
        titleLarge: TextStyle(fontFamily: 'Gulim', fontWeight: FontWeight.bold),
      ).apply(bodyColor: textColor, displayColor: textColor),
      useMaterial3: true,
    );
  }
}