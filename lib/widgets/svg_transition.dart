import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:kita_kerja/lib/utils.dart';

class SvgPathTransition extends StatelessWidget {
  final Animation<double> animation;
  final Color strokeColor1;
  final Color strokeColor2;

  const SvgPathTransition({
    super.key,
    required this.animation,
    this.strokeColor1 = Utils.primary,
    this.strokeColor2 = Utils.secondary,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: animation,
      builder: (context, child) {
        if (animation.value <= 0.0 || animation.value >= 1.0) {
          return const SizedBox.shrink();
        }

        return Positioned.fill(
          child: IgnorePointer(
            child: RepaintBoundary(
              child: CustomPaint(
                size: Size.infinite,
                painter: _SvgWipePainter(
                  progress: animation.value,
                  color1: strokeColor1,
                  color2: strokeColor2,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _SvgWipePainter extends CustomPainter {
  final double progress;
  final Color color1;
  final Color color2;

  _SvgWipePainter({
    required this.progress,
    required this.color1,
    required this.color2,
  });

  static final Path _path1 = Path()
    ..moveTo(227.549, 1818.76)
    ..cubicTo(227.549, 1818.76, 406.016, 2207.75, 569.049, 2130.26)
    ..cubicTo(843.431, 1999.85, -264.104, 1002.3, 227.549, 876.262)
    ..cubicTo(552.918, 792.849, 773.647, 2456.11, 1342.05, 2130.26)
    ..cubicTo(1885.43, 1818.76, 14.9644, 455.772, 760.548, 137.262)
    ..cubicTo(1342.05, -111.152, 1663.5, 2266.35, 2209.55, 1972.76)
    ..cubicTo(2755.6, 1679.18, 1536.63, 384.467, 1826.55, 137.262)
    ..cubicTo(2013.5, -22.1463, 2209.55, 381.262, 2209.55, 381.262);

  static final Path _path2 = Path()
    ..moveTo(1661.28, 2255.51)
    ..cubicTo(1661.28, 2255.51, 2311.09, 1960.37, 2111.78, 1817.01)
    ..cubicTo(1944.47, 1696.67, 718.456, 2870.17, 499.781, 2255.51)
    ..cubicTo(308.969, 1719.17, 2457.51, 1613.83, 2111.78, 963.512)
    ..cubicTo(1766.05, 313.198, 427.949, 2195.17, 132.281, 1455.51)
    ..cubicTo(-155.219, 736.292, 2014.78, 891.514, 1708.78, 252.012)
    ..cubicTo(1437.81, -314.29, 369.471, 909.169, 132.281, 566.512)
    ..cubicTo(18.1772, 401.672, 244.781, 193.012, 244.781, 193.012);

  static final List<PathMetric> _metrics1 = _path1.computeMetrics().toList();
  static final List<PathMetric> _metrics2 = _path2.computeMetrics().toList();

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    // Skala kanvas agar menutupi seluruh layar desktop/mobile bahkan di aspek rasio lebar
    const double svgW = 2453.0;
    const double svgH = 2535.0;

    canvas.save();

    // Scale dan translate dengan sedikit overlap (1.1x) agar tidak ada celah di sudut
    final double scaleX = (size.width / svgW) * 1.12;
    final double scaleY = (size.height / svgH) * 1.12;
    final double offsetX = (size.width - (svgW * scaleX)) / 2;
    final double offsetY = (size.height - (svgH * scaleY)) / 2;

    canvas.translate(offsetX, offsetY);
    canvas.scale(scaleX, scaleY);

    double strokeWidth;
    double startRatio;
    double endRatio;

    // Peak stroke width ditingkatkan hingga 1700 agar menutup 100% layar tanpa celah
    const double minStroke = 250.0;
    const double maxStroke = 1700.0;

    if (progress <= 0.5) {
      // Fase 1 (Wipe In): 0.0 -> 0.5
      final t = Curves.easeInOutCubic.transform(progress / 0.5);
      strokeWidth = lerpDouble(minStroke, maxStroke, t)!;
      startRatio = 0.0;
      endRatio = t;
    } else {
      // Fase 2 (Wipe Out): 0.5 -> 1.0
      final t = Curves.easeInOutCubic.transform((progress - 0.5) / 0.5);
      strokeWidth = lerpDouble(maxStroke, minStroke, t)!;
      startRatio = t;
      endRatio = 1.0;
    }

    final paint1 = Paint()
      ..color = color1
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final paint2 = Paint()
      ..color = color2
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    // Gambar Path 1 (Primary) dan Path 2 (Secondary)
    _drawSegment(canvas, _metrics1, paint1, startRatio, endRatio);
    _drawSegment(canvas, _metrics2, paint2, startRatio, endRatio);

    canvas.restore();
  }

  void _drawSegment(
    Canvas canvas,
    List<PathMetric> metrics,
    Paint paint,
    double startRatio,
    double endRatio,
  ) {
    for (final metric in metrics) {
      final start = metric.length * startRatio;
      final end = metric.length * endRatio;
      if (end > start) {
        final extracted = metric.extractPath(start, end);
        canvas.drawPath(extracted, paint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _SvgWipePainter oldDelegate) {
    return oldDelegate.progress != progress ||
        oldDelegate.color1 != color1 ||
        oldDelegate.color2 != color2;
  }
}
