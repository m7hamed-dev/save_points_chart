import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/painters/base_chart_painter.dart';

/// Custom painter for bar charts
class BarChartPainter extends BaseChartPainter {
  final double barWidth;
  final double borderRadius;
  final bool isGrouped;
  final double animationProgress;
  final ChartInteractionResult? selectedBar;

  BarChartPainter({
    required super.theme,
    required super.dataSets,
    super.showGrid,
    super.showAxis,
    super.showLabel,
    this.barWidth = 20.0,
    this.borderRadius = 8.0,
    this.isGrouped = false,
    this.animationProgress = 1.0,
    this.selectedBar,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Professional padding
    final leftPadding = 50.0;
    final rightPadding = 20.0;
    final topPadding = 20.0;
    final bottomPadding = 40.0;
    final chartSize = Size(
      size.width - leftPadding - rightPadding,
      size.height - topPadding - bottomPadding,
    );
    final chartOffset = Offset(leftPadding, topPadding);

    // Calculate bounds (optimized single pass)
    if (dataSets.isEmpty) return;

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    // Single pass through all points for better performance
    for (final dataSet in dataSets) {
      for (final point in dataSet.dataPoints) {
        if (point.x < minX) minX = point.x;
        if (point.x > maxX) maxX = point.x;
        if (point.y > maxY) maxY = point.y;
      }
    }

    if (minX == double.infinity) return; // No valid data

    final minXAdjusted = minX * 0.95;
    final maxXAdjusted = maxX * 1.05;
    final minY = 0.0;
    final maxYAdjusted = maxY * 1.2;

    canvas.save();
    canvas.translate(chartOffset.dx, chartOffset.dy);

    // Draw grid
    drawGrid(canvas, chartSize, minXAdjusted, maxXAdjusted, minY, maxYAdjusted);

    // Draw axes
    drawAxes(canvas, chartSize, minXAdjusted, maxXAdjusted, minY, maxYAdjusted);

    if (isGrouped && dataSets.length > 1) {
      // Grouped bars
      final maxLength =
          dataSets.map((ds) => ds.dataPoints.length).reduce(math.max);
      final groupSpacing = chartSize.width / (maxLength + 1);
      final barSpacing = barWidth * 0.2;

      for (int i = 0; i < maxLength; i++) {
        double currentX = groupSpacing * (i + 1);
        for (final dataSet in dataSets) {
          if (i < dataSet.dataPoints.length) {
            final point = dataSet.dataPoints[i];
            final barHeight = (point.y / maxYAdjusted) * chartSize.height;
            final barY = chartSize.height - barHeight;

            // Stagger animation for grouped bars
            final barIndex = i / maxLength;
            final barProgress = math.max(
                0.0, math.min(1.0, (animationProgress - barIndex * 0.3) / 0.7),);

            // Check if this bar is selected
            final isSelected = selectedBar != null &&
                selectedBar!.isHit &&
                selectedBar!.datasetIndex == dataSets.indexOf(dataSet) &&
                selectedBar!.elementIndex == i;

            _drawRoundedBar(
              canvas,
              Offset(currentX - barWidth / 2, barY),
              barWidth,
              barHeight,
              dataSet.color,
              barProgress,
              isSelected: isSelected,
            );

            currentX += barWidth + barSpacing;
          }
        }
      }
    } else {
      // Single or stacked bars with animation
      final dataSet = dataSets.first;
      final totalBars = dataSet.dataPoints.length;
      for (int i = 0; i < dataSet.dataPoints.length; i++) {
        final point = dataSet.dataPoints[i];
        final xRange = maxXAdjusted - minXAdjusted;
        final x = xRange > 0
            ? ((point.x - minXAdjusted) / xRange) * chartSize.width
            : chartSize.width / 2;
        final barHeight = (point.y / maxYAdjusted) * chartSize.height;
        final barY = chartSize.height - barHeight;

        // Stagger animation for each bar
        final barIndex = i / totalBars;
        final barProgress = math.max(
            0.0, math.min(1.0, (animationProgress - barIndex * 0.3) / 0.7),);

        // Check if this bar is selected
        final isSelected = selectedBar != null &&
            selectedBar!.isHit &&
            selectedBar!.datasetIndex == 0 &&
            selectedBar!.elementIndex == i;

        _drawRoundedBar(
          canvas,
          Offset(x - barWidth / 2, barY),
          barWidth,
          barHeight,
          dataSet.color,
          barProgress,
          isSelected: isSelected,
        );
      }
    }

    canvas.restore();

    // Draw axis labels
    canvas.save();
    canvas.translate(chartOffset.dx, chartOffset.dy);
    drawAxisLabels(
        canvas, chartSize, minXAdjusted, maxXAdjusted, minY, maxYAdjusted,);
    canvas.restore();
  }

  void _drawRoundedBar(Canvas canvas, Offset position, double width,
      double height, Color color, double barProgress,
      {bool isSelected = false,}) {
    // Animate bar height
    final animatedHeight = height * barProgress;
    final animatedY = position.dy + (height - animatedHeight);

    // Add elevation if selected
    final elevation = isSelected ? 4.0 : 0.0;
    final adjustedY = animatedY - elevation;
    final adjustedHeight = animatedHeight + elevation;

    final rect = RRect.fromRectAndRadius(
      Rect.fromLTWH(position.dx, adjustedY, width, adjustedHeight),
      Radius.circular(borderRadius),
    );

    // Professional gradient with multiple stops
    final paint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: 0.9),
          color,
          color.withValues(alpha: 0.8),
        ],
        stops: const [0.0, 0.5, 1.0],
      ).createShader(rect.outerRect)
      ..style = PaintingStyle.fill;

    canvas.drawRRect(rect, paint);

    // Add subtle highlight on top (brighter if selected)
    final highlightRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(position.dx, adjustedY, width, adjustedHeight * 0.2),
      Radius.circular(borderRadius),
    );
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: isSelected ? 0.4 : 0.2)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(highlightRect, highlightPaint);

    // Add border if selected
    if (isSelected) {
      final borderPaint = Paint()
        ..color = color.withValues(alpha: 0.8)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2.5;
      canvas.drawRRect(rect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant BarChartPainter oldDelegate) {
    if (oldDelegate.animationProgress != animationProgress) return true;
    if (oldDelegate.barWidth != barWidth) return true;
    if (oldDelegate.borderRadius != borderRadius) return true;
    if (oldDelegate.isGrouped != isGrouped) return true;
    if (oldDelegate.selectedBar != selectedBar) return true;

    // Use parent's shouldRepaint for theme and data
    return super.shouldRepaint(oldDelegate);
  }
}
