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
    // Pre-calculate ranges for better performance
    final xRange = maxX - minX;
    final yRange = maxY - minY;

    // Avoid division by zero
    if (xRange == 0 || yRange == 0) {
      return Offset(size.width / 2, size.height / 2);
    }

    final x = ((point.x - minX) / xRange) * size.width;
    final y = size.height - ((point.y - minY) / yRange) * size.height;
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

    // Cache text style
    final textStyle = TextStyle(
      color: theme.axisColor.withValues(alpha: 0.8),
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
    );

    // X-axis labels - better formatting with pre-calculated values
    final xLabels = math.min(6, (maxX - minX).ceil().toInt());
    final xRange = maxX - minX;
    final xStep = size.width / xLabels;

    for (int i = 0; i <= xLabels; i++) {
      final x = xStep * i;
      final value = minX + xRange * (i / xLabels);
      final displayValue = value % 1 == 0
          ? value.toInt().toString()
          : value.toStringAsFixed(1);

      final textPainter = TextPainter(
        text: TextSpan(text: displayValue, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(x - textPainter.width / 2, size.height + 8),
      );
    }

    // Y-axis labels - better formatting with pre-calculated values
    const yLabels = 5;
    final yRange = maxY - minY;
    final yStep = size.height / yLabels;

    for (int i = 0; i <= yLabels; i++) {
      final y = size.height - yStep * i;
      final value = minY + yRange * (i / yLabels);
      final displayValue = value % 1 == 0
          ? value.toInt().toString()
          : value.toStringAsFixed(1);

      final textPainter = TextPainter(
        text: TextSpan(text: displayValue, style: textStyle),
        textDirection: TextDirection.ltr,
      );
      textPainter.layout();
      textPainter.paint(
        canvas,
        Offset(-textPainter.width - 8, y - textPainter.height / 2),
      );
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
