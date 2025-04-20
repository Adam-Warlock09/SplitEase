import 'package:flutter/material.dart';
import 'colorTheme.dart';
import 'appBorders.dart';

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.background,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.light().copyWith(
        primary: AppColors.primary,
        secondary: AppColors.accent,
        surface: AppColors.background,
        onPrimary: Colors.white,
        onSurface: AppColors.text,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        border: AppBorders.inputBorder,
        enabledBorder: AppBorders.inputBorder,
        focusedBorder: AppBorders.focusedBorder,
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.darkBackground,
      fontFamily: 'Inter',
      colorScheme: const ColorScheme.dark().copyWith(
        primary: AppColors.darkPrimary,
        secondary: AppColors.darkAccent,
        surface: AppColors.darkBackground,
        onPrimary: Colors.white,
        onSurface: AppColors.darkText,
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.darkSurface,
        border: AppBorders.inputBorder,
        enabledBorder: AppBorders.inputBorder,
        focusedBorder: AppBorders.focusedDarkBorder,
      ),
    );
  }
}
