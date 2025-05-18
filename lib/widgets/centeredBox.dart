import 'dart:ui';
import 'package:flutter/material.dart';
import '../theme/appBorders.dart';

class CenteredBox extends StatelessWidget {
  final Widget child;
  final double blurRadius;
  final double maxWidth;
  final double maxHeight;
  final Color frostColor;

  const CenteredBox({
    Key? key,
    required this.child,
    this.blurRadius = 10.0,
    this.maxWidth = 1800.0,
    this.maxHeight = 1200.0,
    this.frostColor = const Color(0x66FFFFFF),
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final screenSize = MediaQuery.of(context).size;

    final boxWidth =
        screenSize.width * 0.9 > maxWidth
            ? maxWidth
            : screenSize.width * 0.9;
    final boxHeight =
        screenSize.height * 0.9 > maxHeight
            ? maxHeight
            : screenSize.height * 0.9;

    return Center(
      child: ClipRRect(
        borderRadius: AppBorders.borderRadiusSm,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: blurRadius, sigmaY: blurRadius),
          child: Container(
            width: boxWidth,
            height: boxHeight,
            decoration: BoxDecoration(
              color: frostColor,
              borderRadius: AppBorders.borderRadiusSm,
              border: Border.all(color: Colors.white.withAlpha(51), width: 1.0),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withAlpha(25),
                  blurRadius: 10,
                  spreadRadius: 5,
                ),
              ],
            ),
            child: child,
          ),
        ),
      ),
    );
  }
}
