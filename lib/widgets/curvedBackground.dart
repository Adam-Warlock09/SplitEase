import 'package:flutter/material.dart';

class CurvedBackground extends StatelessWidget {
  const CurvedBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return CustomPaint(size: Size.infinite, painter: BackgroundPainter());
  }
}

class BackgroundPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final leftPaint = Paint()..color = Color(0xFF94E2E6);
    final rightPaint = Paint()..color = Color(0xFFA0A1E8);

    final path = Path();
    path.moveTo(0, 0);
    path.lineTo(size.width * 0.55, 0);

    path.cubicTo(
      size.width * 0.2,
      size.height * 0.4,
      size.width * 1.1,
      size.height * 0.5,
      size.width * 0.5,
      size.height,
    );

    path.lineTo(0, size.height);
    path.close();

    final rightRect = Rect.fromLTWH(0, 0, size.width, size.height);
    canvas.drawRect(rightRect, rightPaint);
    canvas.drawPath(path, leftPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
