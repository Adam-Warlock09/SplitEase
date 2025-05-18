import 'package:flutter/material.dart';

class AppStyles {
  static const cardRadius = BorderRadius.all(Radius.circular(16));
  static const contentPadding = EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  );
  static const shadow = BoxShadow(
    color: Colors.black12,
    blurRadius: 6,
    offset: Offset(0, 2),
  );
}
