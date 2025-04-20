import 'package:flutter/material.dart';

class AppBorders {
  static BorderRadius borderRadiusSm = BorderRadius.circular(8);
  static BorderRadius borderRadiusMd = BorderRadius.circular(12);
  static BorderRadius borderRadiusLg = BorderRadius.circular(20);

  static OutlineInputBorder inputBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Colors.grey),
  );

  static OutlineInputBorder focusedBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFEF233C), width: 1.5),
  );

  static OutlineInputBorder focusedDarkBorder = OutlineInputBorder(
    borderRadius: BorderRadius.circular(12),
    borderSide: const BorderSide(color: Color(0xFFFF6B6B), width: 1.5),
  );
}
