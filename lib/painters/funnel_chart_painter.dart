import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';

/// Custom painter for funnel charts
class FunnelChartPainter extends CustomPainter {
  final ChartTheme theme;
  final List<PieData> data;
  final double animationProgress;
  final ChartInteractionResult? selectedSegment;

  const FunnelChartPainter({
    required this.theme,
    required this.data,
    this.animationProgress = 1.0,
    this.selectedSegment,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Validate size
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= 0) {
      return;
    }

    // Sort data by value (largest to smallest for funnel - top to bottom)
    final sortedData = List<PieData>.from(data)
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = sortedData.fold<double>(0, (sum, item) => sum + item.value);

    // Validate total
    if (!total.isFinite || total <= 0) {
      return;
    }

    const padding = 40.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;
    final centerX = size.width / 2;

    // Validate dimensions
    if (!chartWidth.isFinite ||
        !chartHeight.isFinite ||
        chartWidth <= 0 ||
        chartHeight <= 0) {
      return;
    }

    // Calculate cumulative heights
    double cumulativeHeight = 0.0;

    for (int i = 0; i < sortedData.length; i++) {
      final segment = sortedData[i];

      // Validate segment value
      if (!segment.value.isFinite || segment.value < 0) {
        continue;
      }

      final percentage = segment.value / total;
      final segmentHeight = chartHeight * percentage * animationProgress;

      // Validate calculated dimensions
      if (!percentage.isFinite ||
          !segmentHeight.isFinite ||
          segmentHeight <= 0) {
        continue;
      }

      // Find original index in unsorted data
      final originalIndex = data.indexOf(segment);
      final segmentIndex = originalIndex >= 0 ? originalIndex : i;

      // Check if this segment is selected
      final isSelected = selectedSegment != null &&
          selectedSegment!.isHit &&
          selectedSegment!.elementIndex == segmentIndex;

      // Calculate width at this level (funnel narrows downward)
      final topWidth = chartWidth;
      final bottomWidth = chartWidth * 0.3; // Bottom is 30% of top
      final currentY = cumulativeHeight;
      final nextY = cumulativeHeight + segmentHeight;

      // Calculate width at current and next level
      final progress = currentY / chartHeight;
      final nextProgress = nextY / chartHeight;
      final currentWidth = topWidth - (topWidth - bottomWidth) * progress;
      final nextWidth = topWidth - (topWidth - bottomWidth) * nextProgress;

      // Draw trapezoid segment (inverted from pyramid)
      final path = Path()
        ..moveTo(centerX - currentWidth / 2, padding + currentY)
        ..lineTo(centerX + currentWidth / 2, padding + currentY)
        ..lineTo(centerX + nextWidth / 2, padding + nextY)
        ..lineTo(centerX - nextWidth / 2, padding + nextY)
        ..close();

      // Gradient fill
      final gradient = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          segment.color,
          segment.color.withValues(alpha: 0.7),
        ],
      );

      final paint = Paint()
        ..shader = gradient.createShader(path.getBounds())
        ..style = PaintingStyle.fill;

      canvas.drawPath(path, paint);

      // Highlight selected segment
      if (isSelected) {
        final highlightPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.2)
          ..style = PaintingStyle.fill;
        canvas.drawPath(path, highlightPaint);
      }

      // Border - thicker and more visible for selected
      final borderPaint = Paint()
        ..color =
            isSelected ? Colors.white : segment.color.withValues(alpha: 0.5)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 4.0 : 2.0;
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

      if (textPainter.width < currentWidth * 0.9) {
        textPainter.paint(
          canvas,
          Offset(
            centerX - textPainter.width / 2,
            labelY - textPainter.height / 2,
          ),
        );
      }

      cumulativeHeight += segmentHeight;
    }
  }

  @override
  bool shouldRepaint(covariant FunnelChartPainter oldDelegate) {
    return oldDelegate.theme != theme ||
        oldDelegate.data != data ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedSegment != selectedSegment;
  }
}
