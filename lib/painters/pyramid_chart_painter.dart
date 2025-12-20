import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/theme/chart_theme.dart';

/// Custom painter for pyramid charts
class PyramidChartPainter extends CustomPainter {
  final ChartTheme theme;
  final List<PieData> data;
  final double animationProgress;

  const PyramidChartPainter({
    required this.theme,
    required this.data,
    this.animationProgress = 1.0,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Sort data by value (largest to smallest for pyramid)
    final sortedData = List<PieData>.from(data)
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = sortedData.fold<double>(0, (sum, item) => sum + item.value);
    if (total == 0) return;

    const padding = 40.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;
    final centerX = size.width / 2;

    // Calculate cumulative heights
    double cumulativeHeight = 0.0;

    for (int i = 0; i < sortedData.length; i++) {
      final segment = sortedData[i];
      final percentage = segment.value / total;
      final segmentHeight = chartHeight * percentage * animationProgress;

      // Calculate width at this level (pyramid tapers)
      final baseWidth = chartWidth;
      final topWidth = chartWidth * 0.3; // Top is 30% of base
      final currentY = cumulativeHeight;
      final nextY = cumulativeHeight + segmentHeight;

      // Calculate width at current and next level
      final progress = currentY / chartHeight;
      final nextProgress = nextY / chartHeight;
      final currentWidth = baseWidth - (baseWidth - topWidth) * progress;
      final nextWidth = baseWidth - (baseWidth - topWidth) * nextProgress;

      // Draw trapezoid segment
      final path = Path()
        ..moveTo(centerX - currentWidth / 2, padding + currentY)
        ..lineTo(centerX + currentWidth / 2, padding + currentY)
        ..lineTo(centerX + nextWidth / 2, padding + nextY)
        ..lineTo(centerX - nextWidth / 2, padding + nextY)
        ..close();

      // Gradient fill
      final gradient = LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          segment.color,
          segment.color.withValues(alpha: 0.7),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(path.getBounds())
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, paint);

      // Border
      final borderPaint = Paint()
        ..color = segment.color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.0;
      canvas.drawPath(path, borderPaint);

      // Label
      final labelY = padding + currentY + segmentHeight / 2;
      final textStyle = TextStyle(
        color: theme.textColor,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      );

      final textPainter = TextPainter(
        text: TextSpan(
          text: '${segment.label}\n${(percentage * 100).toStringAsFixed(1)}%',
          style: textStyle,
        ),
        textAlign: TextAlign.center,
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();

      if (textPainter.width < nextWidth * 0.9) {
        textPainter.paint(
          canvas,
          Offset(
              centerX - textPainter.width / 2, labelY - textPainter.height / 2,),
        );
      }

      cumulativeHeight += segmentHeight;
    }
  }

  @override
  bool shouldRepaint(covariant PyramidChartPainter oldDelegate) {
    return oldDelegate.theme != theme ||
        oldDelegate.data != data ||
        oldDelegate.animationProgress != animationProgress;
  }
}
