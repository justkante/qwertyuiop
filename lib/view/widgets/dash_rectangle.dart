import 'dart:math' as math;

import 'package:flutter/material.dart';

class DashedRectanglePainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashWidth;
  final double dashSpace;
  final double borderRadius;

  DashedRectanglePainter({
    required this.color,
    this.strokeWidth = 2.0,
    this.dashWidth = 5.0,
    this.dashSpace = 3.0,
    this.borderRadius = 0.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));
    final path = Path()..addRRect(rrect);

    final pathMetrics = path.computeMetrics();

    for (final pathMetric in pathMetrics) {
      final totalLength = pathMetric.length;
      double distance = 0.0;

      while (distance < totalLength) {
        final dashEnd = math.min(distance + dashWidth, totalLength);
        final dashPath = pathMetric.extractPath(distance, dashEnd);
        canvas.drawPath(dashPath, paint);
        distance = dashEnd + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
