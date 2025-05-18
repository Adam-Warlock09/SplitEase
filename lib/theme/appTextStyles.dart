import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'themeNotifier.dart';
import 'appColors.dart';

class AppTextStyles {
  // Dynamically change text color based on the current theme (light/dark)
  static TextStyle headline1(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.isDarkMode;
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    );
  }

  static TextStyle headline2(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.isDarkMode;
    return TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.w600,
      color: isDark ? AppColors.textPrimaryDark : AppColors.textPrimaryLight,
    );
  }

  static TextStyle bodyText(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.isDarkMode;
    return TextStyle(
      fontSize: 16,
      color:
          isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
    );
  }

  static TextStyle label(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.isDarkMode;
    return TextStyle(
      fontSize: 14,
      color:
          isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
    );
  }

  static TextStyle buttonText(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.isDarkMode;
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      letterSpacing: 1.2,
      color:
          isDark
              ? AppColors.white
              : AppColors.black, // Example for button text color
    );
  }

  static TextStyle caption(BuildContext context) {
    final themeNotifier = Provider.of<ThemeNotifier>(context);
    final isDark = themeNotifier.isDarkMode;
    return TextStyle(
      fontSize: 12,
      color:
          isDark ? AppColors.textSecondaryDark : AppColors.textSecondaryLight,
    );
  }
}
