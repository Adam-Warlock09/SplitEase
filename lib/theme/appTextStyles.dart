import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:split_ease/theme/appColors.dart';

class AppTextStyles {
  // App Name / Huge Heading (e.g., "SplitEase")
  static TextStyle brandHeadlineLight() {
    return GoogleFonts.itim(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: AppColors.onSurfaceLight,
    );
  }

  // Section Headings (e.g., Dashboard, Groups, etc.)
  static TextStyle sectionHeadingLight() {
    return GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurfaceLight,
    );
  }

  // Titles and Subtitles
  static TextStyle titleLight() {
    return GoogleFonts.raleway(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurfaceLight,
    );
  }

  // Body Text
  static TextStyle bodyLight() {
    return GoogleFonts.openSans(
      fontSize: 16,
      color: AppColors.onSurfaceLight,
    );
  }

  // Caption
  static TextStyle captionLight() {
    return GoogleFonts.openSans(
      fontSize: 12,
      color: AppColors.onSurfaceLight.withAlpha(153),
    );
  }

  static TextStyle brandHeadlineDark() {
    return GoogleFonts.itim(
      fontSize: 36,
      fontWeight: FontWeight.bold,
      color: AppColors.onSurfaceDark,
    );
  }

  // Section Headings (e.g., Dashboard, Groups, etc.)
  static TextStyle sectionHeadingDark() {
    return GoogleFonts.poppins(
      fontSize: 24,
      fontWeight: FontWeight.w600,
      color: AppColors.onSurfaceDark,
    );
  }

  // Titles and Subtitles
  static TextStyle titleDark() {
    return GoogleFonts.raleway(
      fontSize: 18,
      fontWeight: FontWeight.w500,
      color: AppColors.onSurfaceDark,
    );
  }

  // Body Text
  static TextStyle bodyDark() {
    return GoogleFonts.openSans(
      fontSize: 16,
      color: AppColors.onSurfaceDark,
    );
  }

  // Caption
  static TextStyle captionDark() {
    return GoogleFonts.openSans(
      fontSize: 12,
      color: AppColors.onSurfaceDark.withAlpha(153),
    );
  }
}
