import 'package:flutter/material.dart';

class FullBox extends StatelessWidget {
  final Widget child;
  const FullBox({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.all(32),
      child: child,
    );
  }
}