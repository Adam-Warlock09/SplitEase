import 'package:flutter/material.dart';
import 'appColors.dart';
import 'appTextStyles.dart';

class AppTheme {
  // Light theme doesn't need context anymore
  static ThemeData lightTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      primaryColor: AppColors.primaryLight,
      colorScheme: ColorScheme.light(
        primary: AppColors.primaryLight,
        secondary: AppColors.secondaryLight,
        error: AppColors.errorLight,
        surface: AppColors.backgroundLight,
        onSurface: AppColors.surfaceLight,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline1(context),
        displayMedium: AppTextStyles.headline2(context),
        bodyLarge: AppTextStyles.bodyText(context),
        bodyMedium: AppTextStyles.label(context),
        bodySmall: AppTextStyles.caption(context),
      ),
    );
  }

  // Dark theme doesn't need context anymore
  static ThemeData darkTheme(BuildContext context) {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      primaryColor: AppColors.primaryDark,
      colorScheme: ColorScheme.dark(
        primary: AppColors.primaryDark,
        secondary: AppColors.secondaryDark,
        error: AppColors.errorDark,
        surface: AppColors.backgroundDark,
        onSurface: AppColors.surfaceDark,
      ),
      textTheme: TextTheme(
        displayLarge: AppTextStyles.headline1(context),
        displayMedium: AppTextStyles.headline2(context),
        bodyLarge: AppTextStyles.bodyText(context),
        bodyMedium: AppTextStyles.label(context),
        bodySmall: AppTextStyles.caption(context),
      ),
    );
  }

  // Dynamically get theme based on current mode
  static ThemeData getTheme(BuildContext context) {
    final brightness = Theme.of(context).brightness;
    return brightness == Brightness.dark
        ? darkTheme(context)
        : lightTheme(context);
  }
}
