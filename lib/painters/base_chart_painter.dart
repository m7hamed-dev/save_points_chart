import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/models/chart_data.dart';

/// Base painter for all chart types with common utilities
abstract class BaseChartPainter extends CustomPainter {
  final ChartTheme theme;
  final List<ChartDataSet> dataSets;
  final bool showGrid;
  final bool showAxis;
  final bool showLabel;

  BaseChartPainter({
    required this.theme,
    required this.dataSets,
    this.showGrid = true,
    this.showAxis = true,
    this.showLabel = true,
  });

  @override
  bool shouldRepaint(covariant BaseChartPainter oldDelegate) {
    // Quick reference equality check first (most common case)
    if (identical(oldDelegate.dataSets, dataSets) &&
        identical(oldDelegate.theme, theme)) {
      if (oldDelegate.showGrid == showGrid &&
          oldDelegate.showAxis == showAxis &&
          oldDelegate.showLabel == showLabel) {
        return false; // Nothing changed
      }
    }

    if (oldDelegate.theme != theme) return true;
    if (oldDelegate.dataSets.length != dataSets.length) return true;
    if (oldDelegate.showGrid != showGrid) return true;
    if (oldDelegate.showAxis != showAxis) return true;
    if (oldDelegate.showLabel != showLabel) return true;

    // Deep comparison of datasets (only if reference equality failed)
    for (int i = 0; i < dataSets.length; i++) {
      if (i >= oldDelegate.dataSets.length) return true;
      final oldDs = oldDelegate.dataSets[i];
      final newDs = dataSets[i];

      // Quick reference check for each dataset
      if (identical(oldDs, newDs)) continue;
      if (oldDs.label != newDs.label ||
          oldDs.color != newDs.color ||
          oldDs.dataPoints.length != newDs.dataPoints.length) {
        return true;
      }
      // Compare data points
      for (int j = 0; j < newDs.dataPoints.length; j++) {
        if (j >= oldDs.dataPoints.length) return true;
        final oldPoint = oldDs.dataPoints[j];
        final newPoint = newDs.dataPoints[j];
        if (oldPoint.x != newPoint.x || oldPoint.y != newPoint.y) {
          return true;
        }
      }
    }

    return false;
  }

  /// Convert data point to canvas coordinates (optimized)
  Offset pointToCanvas(
    ChartDataPoint point,
    Size size,
    double minX,
    double maxX,
    double minY,
    double maxY,
  ) {
    // Validate inputs
    if (!point.x.isFinite || !point.y.isFinite) {
      return Offset(size.width / 2, size.height / 2);
    }

    if (!size.width.isFinite || !size.height.isFinite || 
        size.width <= 0 || size.height <= 0) {
      return const Offset(0, 0);
    }

    if (!minX.isFinite || !maxX.isFinite || !minY.isFinite || !maxY.isFinite) {
      return Offset(size.width / 2, size.height / 2);
    }

    // Pre-calculate ranges for better performance
    final xRange = maxX - minX;
    final yRange = maxY - minY;

    // Avoid division by zero or invalid ranges
    if (xRange <= 0 || !xRange.isFinite || yRange <= 0 || !yRange.isFinite) {
      return Offset(size.width / 2, size.height / 2);
    }

    // Calculate coordinates with validation
    final x = ((point.x - minX) / xRange) * size.width;
    final y = size.height - ((point.y - minY) / yRange) * size.height;

    // Validate calculated values are finite before returning
    if (!x.isFinite || !y.isFinite) {
      return Offset(size.width / 2, size.height / 2);
    }

    return Offset(x, y);
  }

  /// Draw grid lines (optimized with batched operations)
  void drawGrid(
    Canvas canvas,
    Size size,
    double minX,
    double maxX,
    double minY,
    double maxY,
  ) {
    if (!showGrid || !theme.showGrid) return;

    // Create paint once
    final paint = Paint()
      ..color = theme.gridColor.withValues(alpha: 0.5)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;

    // Horizontal grid lines only (more professional)
    // Pre-calculate y positions and batch draw
    const horizontalLines = 5;
    final lineSpacing = size.height / horizontalLines;
    final path = Path();

    for (int i = 1; i < horizontalLines; i++) {
      final y = lineSpacing * i;
      path.moveTo(0, y);
      path.lineTo(size.width, y);
    }

    canvas.drawPath(path, paint);
  }

  /// Draw axes
  void drawAxes(
    Canvas canvas,
    Size size,
    double minX,
    double maxX,
    double minY,
    double maxY,
  ) {
    if (!showAxis || !theme.showAxis) return;

    final paint = Paint()
      ..color = theme.axisColor.withValues(alpha: 0.6)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // X-axis (bottom) - only bottom axis for cleaner look
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      paint,
    );

    // Y-axis (left)
    canvas.drawLine(const Offset(0, 0), Offset(0, size.height), paint);
  }

  /// Draw axis labels (optimized with text style caching)
  void drawAxisLabels(
    Canvas canvas,
    Size size,
    double minX,
    double maxX,
    double minY,
    double maxY,
  ) {
    if (!showLabel || !showAxis || !theme.showAxis) return;

    // Validate size and ranges
    if (size.width <= 0 || size.height <= 0) return;
    if (!size.width.isFinite || !size.height.isFinite) return;

    final xRange = maxX - minX;
    final yRange = maxY - minY;

    // Validate ranges are valid and non-zero
    if (!xRange.isFinite || !yRange.isFinite) return;

    // Cache text style
    final textStyle = TextStyle(
      color: theme.axisColor.withValues(alpha: 0.8),
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
    );

    // X-axis labels - better formatting with pre-calculated values
    final xLabelsCount = math.max(1, math.min(6, (xRange > 0 ? xRange : 1).ceil().toInt()));
    if (xLabelsCount > 0 && xRange > 0) {
      final xStep = size.width / xLabelsCount;

      for (int i = 0; i <= xLabelsCount; i++) {
        final x = xStep * i;
        if (!x.isFinite) continue;

        final value = minX + xRange * (i / xLabelsCount);
        if (!value.isFinite) continue;

        final displayValue =
            value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);

        final textPainter = TextPainter(
          text: TextSpan(text: displayValue, style: textStyle),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final offsetX = x - textPainter.width / 2;
        final offsetY = size.height + 8;

        // Validate offset values before painting
        if (offsetX.isFinite && offsetY.isFinite) {
          textPainter.paint(
            canvas,
            Offset(offsetX, offsetY),
          );
        }
      }
    }

    // Y-axis labels - better formatting with pre-calculated values
    const yLabels = 5;
    if (yLabels > 0 && yRange > 0) {
      final yStep = size.height / yLabels;

      for (int i = 0; i <= yLabels; i++) {
        final y = size.height - yStep * i;
        if (!y.isFinite) continue;

        final value = minY + yRange * (i / yLabels);
        if (!value.isFinite) continue;

        final displayValue =
            value % 1 == 0 ? value.toInt().toString() : value.toStringAsFixed(1);

        final textPainter = TextPainter(
          text: TextSpan(text: displayValue, style: textStyle),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        final offsetX = -textPainter.width - 8;
        final offsetY = y - textPainter.height / 2;

        // Validate offset values before painting
        if (offsetX.isFinite && offsetY.isFinite) {
          textPainter.paint(
            canvas,
            Offset(offsetX, offsetY),
          );
        }
      }
    }
  }

  /// Get data bounds
  void getDataBounds(
    double Function(ChartDataPoint) getValue,
    double Function(double, double) combine,
  ) {
    // This will be overridden by subclasses
  }
}
