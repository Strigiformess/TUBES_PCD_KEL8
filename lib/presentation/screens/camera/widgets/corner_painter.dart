import 'package:flutter/material.dart';

class CornerPainter extends CustomPainter {
  final Color color;
  
  CornerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    const double d = 30.0;

    // Sudut Kiri Atas
    canvas.drawLine(const Offset(0, 0), const Offset(d, 0), paint);
    canvas.drawLine(const Offset(0, 0), const Offset(0, d), paint);
    // Sudut Kanan Atas
    canvas.drawLine(Offset(size.width, 0), Offset(size.width - d, 0), paint);
    canvas.drawLine(Offset(size.width, 0), Offset(size.width, d), paint);
    // Sudut Kiri Bawah
    canvas.drawLine(Offset(0, size.height), Offset(d, size.height), paint);
    canvas.drawLine(Offset(0, size.height), Offset(0, size.height - d), paint);
    // Sudut Kanan Bawah
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width - d, size.height), paint);
    canvas.drawLine(Offset(size.width, size.height), Offset(size.width, size.height - d), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}