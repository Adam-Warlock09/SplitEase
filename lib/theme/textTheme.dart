import 'package:flutter/material.dart';

class AppTextStyles {
  static TextStyle heading(BuildContext context) {
    return TextStyle(
      fontSize: 24,
      fontWeight: FontWeight.bold,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle subheading(BuildContext context) {
    return TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle body(BuildContext context) {
    return TextStyle(
      fontSize: 14,
      color: Theme.of(context).colorScheme.onSurface,
    );
  }

  static TextStyle button(BuildContext context) {
    return TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w500,
      color: Theme.of(context).colorScheme.primary,
    );
  }
}
