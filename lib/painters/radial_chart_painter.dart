import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'base_chart_painter.dart';

/// Custom painter for radial/radar charts
class RadialChartPainter extends BaseChartPainter {
  final double lineWidth;
  final bool showPoints;
  final double animationProgress;

  RadialChartPainter({
    required super.theme,
    required super.dataSets,
    super.showGrid,
    super.showLabel,
    this.lineWidth = 3.0,
    this.showPoints = true,
    this.animationProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (dataSets.isEmpty || dataSets.first.dataPoints.isEmpty) return;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;
    final dataSet = dataSets.first;
    final points = dataSet.dataPoints;
    final maxValue = points.map((p) => p.y).reduce(math.max) * 1.2;

    // Draw grid circles with professional styling
    if (showGrid && theme.showGrid) {
      final gridPaint = Paint()
        ..color = theme.gridColor.withOpacity(0.4)
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke;

      for (int i = 1; i <= 5; i++) {
        final gridRadius = radius * (i / 5);
        canvas.drawCircle(center, gridRadius, gridPaint);
      }
    }

    // Draw grid lines (spokes) with better styling
    final angleStep = 2 * math.pi / points.length;
    for (int i = 0; i < points.length; i++) {
      final angle = i * angleStep - math.pi / 2;
      final endX = center.dx + math.cos(angle) * radius;
      final endY = center.dy + math.sin(angle) * radius;

      final gridPaint = Paint()
        ..color = theme.gridColor.withOpacity(0.4)
        ..strokeWidth = 0.5
        ..style = PaintingStyle.stroke;

      canvas.drawLine(center, Offset(endX, endY), gridPaint);

      // Draw labels with professional styling
      if (showLabel && points[i].label != null) {
        final labelX = center.dx + math.cos(angle) * (radius + 25);
        final labelY = center.dy + math.sin(angle) * (radius + 25);

        final textSpan = TextSpan(
          text: points[i].label!,
          style: TextStyle(
            color: theme.textColor.withOpacity(0.9),
            fontSize: 12,
            fontWeight: FontWeight.w500,
            letterSpacing: 0.2,
          ),
        );
        final textPainter = TextPainter(
          text: textSpan,
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout();
        textPainter.paint(
          canvas,
          Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2),
        );
      }
    }

    // Draw data shape with animation
    final path = Path();
    for (int i = 0; i < points.length; i++) {
      final angle = i * angleStep - math.pi / 2;
      final animatedValue = points[i].y * animationProgress;
      final valueRadius = radius * (animatedValue / maxValue);
      final x = center.dx + math.cos(angle) * valueRadius;
      final y = center.dy + math.sin(angle) * valueRadius;

      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    path.close();

    // Fill with professional gradient
    final fillPaint = Paint()
      ..shader = RadialGradient(
        center: Alignment.center,
        colors: [
          dataSet.color.withOpacity(0.3),
          dataSet.color.withOpacity(0.1),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius))
      ..style = PaintingStyle.fill;
    canvas.drawPath(path, fillPaint);

    // Stroke with subtle glow
    final strokePaint = Paint()
      ..color = dataSet.color
      ..strokeWidth = lineWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.5);
    canvas.drawPath(path, strokePaint);

    // Draw points with professional styling
    if (showPoints) {
      for (int i = 0; i < points.length; i++) {
        final angle = i * angleStep - math.pi / 2;
        final valueRadius = radius * (points[i].y / maxValue);
        final x = center.dx + math.cos(angle) * valueRadius;
        final y = center.dy + math.sin(angle) * valueRadius;
        final point = Offset(x, y);

        // Outer glow
        final glowPaint = Paint()
          ..color = dataSet.color.withOpacity(0.2)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 6, glowPaint);
        
        // Main point
        final pointPaint = Paint()
          ..color = dataSet.color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 4.5, pointPaint);
        
        // Inner highlight
        final highlightPaint = Paint()
          ..color = Colors.white.withOpacity(0.8)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, 2, highlightPaint);
        
        // Border
        final borderPaint = Paint()
          ..color = theme.backgroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(point, 4.5, borderPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant RadialChartPainter oldDelegate) {
    if (oldDelegate.animationProgress != animationProgress) return true;
    if (oldDelegate.lineWidth != lineWidth) return true;
    if (oldDelegate.showPoints != showPoints) return true;
    
    // Use parent's shouldRepaint for theme and data
    return super.shouldRepaint(oldDelegate);
  }
}

