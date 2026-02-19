import 'package:flutter/material.dart';
import '../constants/app_constants.dart';

/// Dark, high-contrast theme optimised for visually impaired users.
class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppConstants.primaryBlue,
      scaffoldBackgroundColor: AppConstants.darkBackground,
      fontFamily: 'Roboto',
      colorScheme: const ColorScheme.dark(
        primary: AppConstants.primaryBlue,
        secondary: AppConstants.accentBlue,
        surface: AppConstants.surfaceDark,
        error: AppConstants.dangerRed,
        onPrimary: AppConstants.textWhite,
        onSecondary: AppConstants.textWhite,
        onSurface: AppConstants.textWhite,
        onError: AppConstants.textWhite,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppConstants.surfaceDark,
        foregroundColor: AppConstants.textWhite,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: AppConstants.textWhite,
          fontSize: AppConstants.fontSizeHeading,
          fontWeight: FontWeight.w700,
          letterSpacing: 1.2,
        ),
      ),
      cardTheme: CardTheme(
        color: AppConstants.cardDark,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppConstants.primaryBlue,
          foregroundColor: AppConstants.textWhite,
          minimumSize: const Size(double.infinity, AppConstants.buttonHeight),
          textStyle: const TextStyle(
            fontSize: AppConstants.fontSizeButton,
            fontWeight: FontWeight.w700,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardRadius),
          ),
          elevation: 6,
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppConstants.surfaceDark,
        selectedItemColor: AppConstants.primaryBlue,
        unselectedItemColor: AppConstants.textSecondary,
        selectedLabelStyle: TextStyle(
          fontSize: AppConstants.fontSizeCaption,
          fontWeight: FontWeight.w700,
        ),
        unselectedLabelStyle: TextStyle(fontSize: AppConstants.fontSizeCaption),
        type: BottomNavigationBarType.fixed,
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontSize: AppConstants.fontSizeTitle,
          fontWeight: FontWeight.w800,
          color: AppConstants.textWhite,
        ),
        headlineMedium: TextStyle(
          fontSize: AppConstants.fontSizeHeading,
          fontWeight: FontWeight.w700,
          color: AppConstants.textWhite,
        ),
        bodyLarge: TextStyle(
          fontSize: AppConstants.fontSizeBody,
          color: AppConstants.textWhite,
        ),
        bodyMedium: TextStyle(
          fontSize: AppConstants.fontSizeBody,
          color: AppConstants.textSecondary,
        ),
        labelLarge: TextStyle(
          fontSize: AppConstants.fontSizeButton,
          fontWeight: FontWeight.w700,
          color: AppConstants.textWhite,
        ),
      ),
    );
  }
}
