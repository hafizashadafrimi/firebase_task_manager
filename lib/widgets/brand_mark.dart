import 'package:flutter/material.dart';

import '../core/theme.dart';

class BrandMark extends StatelessWidget {
  const BrandMark({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: const Color(0xFFEEF2FF),
        borderRadius: BorderRadius.circular(size * 0.28),
      ),
      child: Icon(
        Icons.flutter_dash,
        color: AppColors.primary,
        size: size * 0.52,
      ),
    );
  }
}

class GoogleMark extends StatelessWidget {
  const GoogleMark({super.key, this.size = 22});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(painter: _GoogleGPainter()),
    );
  }
}

class _GoogleGPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final stroke = size.width * 0.18;
    final rect = Rect.fromLTWH(stroke / 2, stroke / 2, size.width - stroke, size.height - stroke);
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke
      ..strokeCap = StrokeCap.round;

    paint.color = const Color(0xFF4285F4);
    canvas.drawArc(rect, -0.2, 1.8, false, paint);
    paint.color = const Color(0xFF34A853);
    canvas.drawArc(rect, 1.6, 1.1, false, paint);
    paint.color = const Color(0xFFFBBC05);
    canvas.drawArc(rect, 2.7, 0.8, false, paint);
    paint.color = const Color(0xFFEA4335);
    canvas.drawArc(rect, 3.5, 1.2, false, paint);

    final bar = Paint()..color = const Color(0xFF4285F4);
    canvas.drawRect(
      Rect.fromLTWH(size.width * 0.5, size.height * 0.42, size.width * 0.38, stroke),
      bar,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class FieldLabel extends StatelessWidget {
  const FieldLabel(this.text, {super.key});

  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.6,
          color: AppColors.label,
        ),
      ),
    );
  }
}
