import 'dart:ui';

import 'package:flutter/material.dart';

class AppTheme {
  
  static const Color midnight = Color(0xFF080810);
  static const Color ink = Color(0xff031110);
  static const Color carbon = Color(0xff1B1B0E);
  static const Color onyx = Color(0xff00120B);
  static const Color mahogany = Color(0xff37000A);
  static const Color periwinkle = Color(0xff998FC7);
  static const Color offwhite = Color(0xFFDDF4FF);

  static const List<Color> defaultColors = [
    ink,
    carbon,
    onyx,
    mahogany,
    periwinkle,
  ];

  static final ColorScheme colorScheme = ColorScheme(
    brightness: Brightness.dark,
    primary: periwinkle,
    onPrimary: ink,
    secondary: carbon,
    onSecondary: ink.withValues(alpha: 0.85),

    surface: carbon,
    onSurface: periwinkle,
    error: mahogany,
    onError: Colors.white,
  );

  static final ThemeData appTheme = ThemeData(
    colorScheme: colorScheme,
    scaffoldBackgroundColor: midnight,

    primaryColor: periwinkle,
    canvasColor: carbon,
    appBarTheme: AppBarTheme(
      elevation: 0,
      backgroundColor: carbon,
      foregroundColor: periwinkle,
      iconTheme: IconThemeData(color: periwinkle),
      titleTextStyle: TextStyle(
        color: periwinkle,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    ),
    textTheme: TextTheme(
      displayLarge: TextStyle(color: periwinkle),
      displayMedium: TextStyle(color: periwinkle),
      displaySmall: TextStyle(color: periwinkle),
      headlineLarge: TextStyle(color: periwinkle),
      headlineMedium: TextStyle(color: periwinkle),
      headlineSmall: TextStyle(color: periwinkle),
      titleLarge: TextStyle(color: ink),
      titleMedium: TextStyle(color: periwinkle),
      titleSmall: TextStyle(color: periwinkle),
      bodyLarge: TextStyle(color: periwinkle),
      bodyMedium: TextStyle(color: periwinkle),
      bodySmall: TextStyle(color: periwinkle),
      labelLarge: TextStyle(color: periwinkle),
      labelMedium: TextStyle(color: periwinkle),
      labelSmall: TextStyle(color: periwinkle),
    ),
    iconTheme: IconThemeData(color: periwinkle),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: periwinkle,
      foregroundColor: ink,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        foregroundColor: ink,
        backgroundColor: periwinkle,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: carbon.withValues(alpha: 0.9),
      focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: periwinkle),
        borderRadius: BorderRadius.circular(8),
      ),
      enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(color: periwinkle.withValues(alpha: .1)),
        borderRadius: BorderRadius.circular(8),
      ),
      labelStyle: TextStyle(color: periwinkle),
    ),
    cardColor: carbon,
    dividerColor: periwinkle.withValues(alpha: 0.2),
    dialogBackgroundColor: carbon,
    snackBarTheme: SnackBarThemeData(
      backgroundColor: mahogany,
      contentTextStyle: TextStyle(color: periwinkle),
    ),
  );
}
