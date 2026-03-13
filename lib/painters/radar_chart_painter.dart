import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/painters/base_chart_painter.dart';
import 'package:save_points_chart/utils/format_utils.dart';

/// A custom painter for rendering radar/spider charts.
///
/// This painter handles the rendering of radar charts with multiple axes
/// arranged in a circle, forming a polygon shape.
class RadarChartPainter extends BaseChartPainter {
  /// The list of radar data sets.
  final List<RadarDataSet> radarDataSets;

  /// The maximum value for the radar axes.
  final double maxValue;

  /// The number of grid levels to display.
  final int gridLevels;

  /// The animation progress value between 0.0 and 1.0.
  final double animationProgress;

  /// The currently selected point interaction result.
  final ChartInteractionResult? selectedPoint;

  /// Creates a radar chart painter.
  const RadarChartPainter({
    required super.theme,
    required this.radarDataSets,
    this.maxValue = 100.0,
    this.gridLevels = 5,
    this.animationProgress = 1.0,
    this.selectedPoint,
    super.showGrid,
    super.showAxis,
    super.showLabel,
  }) : super(dataSets: const []); // Empty for radar chart

  @override
  void paint(Canvas canvas, Size size) {
    if (radarDataSets.isEmpty) return;

    // Validate size
    if (!size.width.isFinite || !size.height.isFinite || size.width <= 0 || size.height <= 0) {
      return;
    }

    // Use the first dataset to determine number of axes
    final firstDataSet = radarDataSets.first;
    final numAxes = firstDataSet.dataPoints.length;
    if (numAxes < 3) return; // Need at least 3 axes

    // Calculate center and radius
    final center = Offset(size.width / 2, size.height / 2);
    // Use theme padding to determine radius
    final padding = math.max(theme.padding.top, theme.padding.bottom);
    final radius = math.min(size.width, size.height) / 2 - padding;

    // Validate radius
    if (!radius.isFinite || radius <= 0) {
      return;
    }

    // Draw grid circles
    if (showGrid && theme.showGrid) {
      final gridPaint = Paint()
        ..color = theme.gridColor.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.0;

      for (int level = 1; level <= gridLevels; level++) {
        final levelRadius = (radius * level) / gridLevels;
        canvas.drawCircle(center, levelRadius, gridPaint);
      }
    }

    // Draw axes lines
    if (showAxis && theme.showAxis) {
      final axisPaint = Paint()
        ..color = theme.axisColor.withValues(alpha: 0.6)
        ..strokeWidth = 1.0
        ..style = PaintingStyle.stroke;

      for (int i = 0; i < numAxes; i++) {
        final angle = (2 * math.pi * i / numAxes) - (math.pi / 2);
        final endPoint = Offset(center.dx + radius * math.cos(angle), center.dy + radius * math.sin(angle));
        canvas.drawLine(center, endPoint, axisPaint);
      }
    }

    // Draw axis labels
    if (showLabel && showAxis && theme.showAxis) {
      final textStyle = TextStyle(
        color: theme.axisColor.withValues(alpha: 0.8),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );

      for (int i = 0; i < numAxes; i++) {
        final angle = (2 * math.pi * i / numAxes) - (math.pi / 2);
        final labelPoint = Offset(
          center.dx + (radius + 20) * math.cos(angle),
          center.dy + (radius + 20) * math.sin(angle),
        );

        final label = firstDataSet.dataPoints[i].label;
        final textPainter = TextPainter(
          text: TextSpan(text: label, style: textStyle),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        textPainter.layout();

        // Center the text
        final textOffset = Offset(labelPoint.dx - textPainter.width / 2, labelPoint.dy - textPainter.height / 2);
        textPainter.paint(canvas, textOffset);
      }
    }

    // Draw value labels on axes
    if (showLabel && showAxis && theme.showAxis) {
      final valueTextStyle = TextStyle(
        color: theme.axisColor.withValues(alpha: 0.6),
        fontSize: 10,
        fontWeight: FontWeight.w400,
      );

      for (int level = 1; level <= gridLevels; level++) {
        final value = ChartFormatUtils.formatValue(maxValue * level / gridLevels);
        final levelRadius = (radius * level) / gridLevels;
        final labelPoint = Offset(center.dx, center.dy - levelRadius);

        final textPainter = TextPainter(
          text: TextSpan(text: value, style: valueTextStyle),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final textOffset = Offset(labelPoint.dx - textPainter.width - 5, labelPoint.dy - textPainter.height / 2);
        textPainter.paint(canvas, textOffset);
      }
    }

    // Draw radar polygons for each dataset
    for (int dsIndex = 0; dsIndex < radarDataSets.length; dsIndex++) {
      final dataSet = radarDataSets[dsIndex];
      if (dataSet.dataPoints.length != numAxes) continue;

      final path = Path();
      final points = <Offset>[];

      // Calculate points
      for (int i = 0; i < numAxes; i++) {
        final angle = (2 * math.pi * i / numAxes) - (math.pi / 2);
        final rawValue = dataSet.dataPoints[i].value;

        // Validate value
        if (!rawValue.isFinite || !maxValue.isFinite || maxValue <= 0) {
          continue;
        }

        final value = rawValue.clamp(0.0, maxValue);
        final normalizedValue = (value / maxValue) * animationProgress;
        final pointRadius = radius * normalizedValue;

        // Validate calculated values
        if (!pointRadius.isFinite || !angle.isFinite) {
          continue;
        }

        final point = Offset(center.dx + pointRadius * math.cos(angle), center.dy + pointRadius * math.sin(angle));

        // Validate point coordinates
        if (!point.dx.isFinite || !point.dy.isFinite) {
          continue;
        }

        points.add(point);

        if (i == 0) {
          path.moveTo(point.dx, point.dy);
        } else {
          path.lineTo(point.dx, point.dy);
        }
      }
      path.close();

      // Draw filled polygon
      final fillPaint = Paint()
        ..color = dataSet.color.withValues(alpha: 0.3)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, fillPaint);

      // Check if any point in this dataset is selected
      bool hasSelectedPoint = false;
      if (selectedPoint != null && selectedPoint!.isHit) {
        hasSelectedPoint = selectedPoint!.datasetIndex == dsIndex;
      }

      // Draw polygon outline - thicker border if selected
      final outlinePaint = Paint()
        ..color = dataSet.color
        ..style = PaintingStyle.stroke
        ..strokeWidth = hasSelectedPoint ? 4.0 : 2.0;
      canvas.drawPath(path, outlinePaint);

      // Draw selected border overlay
      if (hasSelectedPoint) {
        final selectedBorderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = 3.0;
        canvas.drawPath(path, selectedBorderPaint);
      }

      // Draw points
      final pointPaint = Paint()
        ..color = dataSet.color
        ..style = PaintingStyle.fill;
      for (int i = 0; i < points.length; i++) {
        final point = points[i];
        final isSelected =
            selectedPoint != null &&
            selectedPoint!.isHit &&
            selectedPoint!.datasetIndex == dsIndex &&
            selectedPoint!.elementIndex == i;

        // Draw point with border if selected
        if (isSelected) {
          // Outer glow
          final glowPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.5)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(point, 8, glowPaint);
          // Border
          final borderPaint = Paint()
            ..color = Colors.white
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0;
          canvas.drawCircle(point, 6, borderPaint);
        }
        canvas.drawCircle(point, isSelected ? 6 : 4, pointPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant RadarChartPainter oldDelegate) {
    return super.shouldRepaint(oldDelegate) ||
        oldDelegate.radarDataSets != radarDataSets ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.gridLevels != gridLevels ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedPoint != selectedPoint;
  }
}
