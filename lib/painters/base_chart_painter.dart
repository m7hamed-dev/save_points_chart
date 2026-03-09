import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/utils/format_utils.dart';

/// Base painter for all chart types with common utilities.
///
/// This abstract class provides shared functionality for rendering charts,
/// including grid lines, axes, labels, and coordinate transformations.
/// All chart painters should extend this class to inherit these features.
///
/// ## Features
/// - Automatic grid and axis rendering
/// - Optimized coordinate transformations
/// - Efficient repaint detection
/// - Batched drawing operations
///
/// ## Example
/// ```dart
/// class MyChartPainter extends BaseChartPainter {
///   MyChartPainter({
///     required super.theme,
///     required super.dataSets,
///   });
///
///   @override
///   void paint(Canvas canvas, Size size) {
///     // Draw grid and axes
///     drawGrid(canvas, size, minX, maxX, minY, maxY);
///     drawAxes(canvas, size, minX, maxX, minY, maxY);
///
///     // Draw your chart content
///     // ...
///
///     // Draw labels
///     drawAxisLabels(canvas, size, minX, maxX, minY, maxY);
///   }
/// }
/// ```
///
/// See also:
/// - [CustomPainter] for the base Flutter painter class
/// - [ChartTheme] for chart styling
abstract class BaseChartPainter extends CustomPainter {
  /// Creates a base chart painter.
  ///
  /// [theme] and [dataSets] are required. Visibility flags default to true.
  const BaseChartPainter({
    required this.theme,
    required this.dataSets,
    this.showGrid = true,
    this.showAxis = true,
    this.showLabel = true,
  });

  /// The theme to use for styling the chart.
  ///
  /// Controls colors, fonts, and visual appearance of grid, axes, and labels.
  final ChartTheme theme;

  /// The data sets to render in the chart.
  ///
  /// Must not be empty. Each dataset represents a series in the chart.
  final List<ChartDataSet> dataSets;

  /// Whether to show grid lines.
  ///
  /// Defaults to true. Grid lines help users read values from the chart.
  final bool showGrid;

  /// Whether to show axis lines.
  ///
  /// Defaults to true. Axis lines mark the boundaries of the chart area.
  final bool showAxis;

  /// Whether to show axis labels.
  ///
  /// Defaults to true. Labels display numeric values along the axes.
  final bool showLabel;

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
      if (oldDs.color != newDs.color) {
        return true;
      }
      // Compare data point
      final oldPoint = oldDs.dataPoint;
      final newPoint = newDs.dataPoint;
      if (oldPoint.x != newPoint.x || oldPoint.y != newPoint.y) {
        return true;
      }
    }

    return false;
  }

  /// Convert data point to canvas coordinates (optimized).
  ///
  /// Transforms a data point from data space (x, y values) to canvas space
  /// (pixel coordinates). This method includes comprehensive validation to
  /// prevent NaN and Infinity values that could cause rendering issues.
  ///
  /// Parameters:
  /// - [point] - The data point to transform
  /// - [size] - The size of the canvas
  /// - [minX], [maxX], [minY], [maxY] - The data bounds
  ///
  /// Returns an [Offset] representing the canvas position, or a safe fallback
  /// position if the input is invalid.
  ///
  /// ## Example
  /// ```dart
  /// final canvasPos = pointToCanvas(
  ///   ChartDataPoint(x: 10, y: 20),
  ///   Size(400, 300),
  ///   0, 100, 0, 50,
  /// );
  /// canvas.drawCircle(canvasPos, 5, paint);
  /// ```
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

    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= 0) {
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

  /// Draw grid lines (optimized with batched operations).
  ///
  /// Renders horizontal grid lines to help users read values from the chart.
  /// Uses batched path operations for better performance.
  ///
  /// Parameters:
  /// - [canvas] - The canvas to draw on
  /// - [size] - The size of the chart area
  /// - [minX], [maxX], [minY], [maxY] - The data bounds (used for spacing)
  ///
  /// The grid will only be drawn if [showGrid] is true and the theme
  /// allows grid display. Grid lines are drawn with a semi-transparent color
  /// to avoid obscuring the chart data.
  ///
  /// ## Example
  /// ```dart
  /// drawGrid(canvas, chartSize, 0, 100, 0, 50);
  /// ```
  void drawGrid(
    Canvas canvas,
    Size size,
    double minX,
    double maxX,
    double minY,
    double maxY,
  ) {
    if (!showGrid || !theme.showGrid) return;

    // Create paint with enhanced styling (dashed/dotted look)
    final gridPaint = Paint()
      ..color = theme.gridColor.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Horizontal grid lines only (more professional)
    // Pre-calculate y positions and batch draw
    const horizontalLines = 5;
    final lineSpacing = size.height / horizontalLines;
    
    // Draw dashed horizontal lines
    for (int i = 1; i < horizontalLines; i++) {
      final y = lineSpacing * i;
      _drawDashedLine(canvas, Offset(0, y), Offset(size.width, y), gridPaint);
    }
    
    // Vertical grid lines (very subtle, solid)
    final verticalLines = 6;
    final verticalSpacing = size.width / verticalLines;
    final verticalPaint = Paint()
      ..color = theme.gridColor.withValues(alpha: 0.2)
      ..strokeWidth = 0.5
      ..style = PaintingStyle.stroke;
    
    final verticalPath = Path();
    for (int i = 1; i < verticalLines; i++) {
      final x = verticalSpacing * i;
      verticalPath.moveTo(x, 0);
      verticalPath.lineTo(x, size.height);
    }
    canvas.drawPath(verticalPath, verticalPaint);
  }
  
  /// Helper to draw dashed lines
  void _drawDashedLine(Canvas canvas, Offset p1, Offset p2, Paint paint, {double dashWidth = 4, double dashSpace = 4}) {
    final path = Path();
    final maxLength = (p2 - p1).distance;
    final dx = (p2.dx - p1.dx) / maxLength;
    final dy = (p2.dy - p1.dy) / maxLength;
    var currentDistance = 0.0;
    
    while (currentDistance < maxLength) {
      final startX = p1.dx + dx * currentDistance;
      final startY = p1.dy + dy * currentDistance;
      
      // Draw dash
      final endDistance = math.min(currentDistance + dashWidth, maxLength);
      final endX = p1.dx + dx * endDistance;
      final endY = p1.dy + dy * endDistance;
      
      path.moveTo(startX, startY);
      path.lineTo(endX, endY);
      
      currentDistance += dashWidth + dashSpace;
    }
    
    canvas.drawPath(path, paint);
  }

  /// Draw axis lines.
  ///
  /// Renders the X-axis (bottom) and Y-axis (left) to mark the boundaries
  /// of the chart area. Uses a clean, minimal style for professional appearance.
  ///
  /// Parameters:
  /// - [canvas] - The canvas to draw on
  /// - [size] - The size of the chart area
  /// - [minX], [maxX], [minY], [maxY] - The data bounds (not used, kept for API consistency)
  ///
  /// The axes will only be drawn if [showAxis] is true and the theme
  /// allows axis display.
  ///
  /// ## Example
  /// ```dart
  /// drawAxes(canvas, chartSize, 0, 100, 0, 50);
  /// ```
  void drawAxes(
    Canvas canvas,
    Size size,
    double minX,
    double maxX,
    double minY,
    double maxY,
  ) {
    if (!showAxis || !theme.showAxis) return;

    // Enhanced axis styling with better visibility
    final axisPaint = Paint()
      ..color = theme.axisColor.withValues(alpha: 0.5)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // X-axis (bottom) - Clean solid line
    canvas.drawLine(
      Offset(0, size.height),
      Offset(size.width, size.height),
      axisPaint,
    );

    // Y-axis (left) - Clean solid line
    // canvas.drawLine(const Offset(0, 0), Offset(0, size.height), axisPaint);
    
    // Only draw ticks on Y axis for a cleaner look
    const yTicks = 5;
    final ySpacing = size.height / yTicks;
    for (int i = 0; i <= yTicks; i++) {
      final y = size.height - (ySpacing * i);
      // Small tick mark
      canvas.drawLine(Offset(-4, y), Offset(0, y), axisPaint);
    }
  }

  /// Draw axis labels (optimized with text style caching).
  ///
  /// Renders numeric labels along the X and Y axes to help users read values.
  /// Uses efficient text rendering with cached styles and smart formatting.
  ///
  /// Parameters:
  /// - [canvas] - The canvas to draw on
  /// - [size] - The size of the chart area
  /// - [minX], [maxX], [minY], [maxY] - The data bounds for label values
  ///
  /// Labels are automatically formatted (integers when possible, decimals otherwise).
  /// The number of labels is automatically adjusted based on the chart size.
  ///
  /// The labels will only be drawn if [showLabel] and [showAxis] are true.
  ///
  /// If [dataSets] are provided, labels from [ChartDataPoint.label] will be
  /// used for X-axis labels when available, falling back to numeric values.
  ///
  /// ## Example
  /// ```dart
  /// drawAxisLabels(canvas, chartSize, 0, 100, 0, 50);
  /// // Or with data points for custom labels:
  /// drawAxisLabels(canvas, chartSize, 0, 100, 0, 50, dataSets: dataSets);
  /// ```
  void drawAxisLabels(
    Canvas canvas,
    Size size,
    double minX,
    double maxX,
    double minY,
    double maxY, {
    List<ChartDataSet>? dataSets,
  }) {
    if (!showLabel || !showAxis || !theme.showAxis) return;

    // Validate size and ranges
    if (size.width <= 0 || size.height <= 0) return;
    if (!size.width.isFinite || !size.height.isFinite) return;

    final xRange = maxX - minX;
    final yRange = maxY - minY;

    // Validate ranges are valid and non-zero
    if (!xRange.isFinite || !yRange.isFinite) return;

    // Use theme text style if available
    final textStyle = theme.axisLabelStyle ?? TextStyle(
      color: theme.axisColor.withValues(alpha: 0.8),
      fontSize: 11,
      fontWeight: FontWeight.w500,
      letterSpacing: 0.2,
    );

    // X-axis labels - use labels from data points if available
    final xLabelsCount =
        math.max(1, math.min(6, (xRange > 0 ? xRange : 1).ceil().toInt()));
    if (xLabelsCount > 0 && xRange > 0) {
      // Try to use labels from data points
      if (dataSets != null &&
          dataSets.isNotEmpty &&
          dataSets.any((ds) => ds.dataPoint.label != null)) {
        // Use labels from data points - show labels at actual data point positions
        // Use a map to deduplicate labels by x position (only show one label per x value)
        final Map<double, String> xLabels = {};
        for (final dataSet in dataSets) {
          final point = dataSet.dataPoint;

          // Skip if no label or invalid x value
          if (point.label == null || !point.x.isFinite) continue;

          // Store label for this x position (first label wins if duplicates exist)
          if (!xLabels.containsKey(point.x)) {
            xLabels[point.x] = point.label!;
          }
        }

        // Draw labels for unique x positions
        for (final entry in xLabels.entries) {
          final xValue = entry.key;
          final label = entry.value;

          // Calculate x position based on point.x
          final normalizedX = xRange > 0 ? (xValue - minX) / xRange : 0.5;
          final x = normalizedX * size.width;

          // Only draw if within chart bounds
          if (!x.isFinite || x < 0 || x > size.width) continue;

          final textPainter = TextPainter(
            text: TextSpan(text: label, style: textStyle),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();

          _paintRotatedLabel(
            canvas,
            textPainter,
            Offset(x, size.height + 12), // Increased padding
            theme.xAxisLabelRotation,
          );
        }
      } else {
        // Fall back to numeric labels
        final xStep = size.width / xLabelsCount;

        for (int i = 0; i <= xLabelsCount; i++) {
          final x = xStep * i;
          if (!x.isFinite) continue;

          final value = minX + xRange * (i / xLabelsCount);
          if (!value.isFinite) continue;

          final displayValue = ChartFormatUtils.formatValue(value, fractionDigits: 1);

          final textPainter = TextPainter(
            text: TextSpan(text: displayValue, style: textStyle),
            textDirection: TextDirection.ltr,
          );
          textPainter.layout();

          // For numeric labels, use theme rotation (no per-point rotation available)
          _paintRotatedLabel(
            canvas,
            textPainter,
            Offset(x, size.height + 12), // Increased padding
            theme.xAxisLabelRotation,
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

        final displayValue = ChartFormatUtils.formatValue(value, fractionDigits: 1);

        final textPainter = TextPainter(
          text: TextSpan(text: displayValue, style: textStyle),
          textDirection: TextDirection.ltr,
        );
        textPainter.layout();

        // Position label to the left of the Y-axis, centered vertically
        // Ensure we don't go too far left (assuming standard padding)
        final labelX = -textPainter.width - 12; // Increased padding
        
        _paintRotatedLabel(
          canvas,
          textPainter,
          Offset(labelX, y),
          theme.yAxisLabelRotation,
        );
      }
    }
  }

  /// Paints a text label with rotation support.
  ///
  /// This helper method handles rotation of axis labels. The rotation is applied
  /// around the label's center point.
  ///
  /// Parameters:
  /// - [canvas] - The canvas to paint on
  /// - [textPainter] - The text painter with laid out text
  /// - [position] - The position where the label should be painted (center point)
  /// - [rotationDegrees] - Rotation angle in degrees (0 = horizontal)
  void _paintRotatedLabel(
    Canvas canvas,
    TextPainter textPainter,
    Offset position,
    int rotationDegrees,
  ) {
    if (!position.dx.isFinite || !position.dy.isFinite) return;
    
    if (rotationDegrees == 0) {
      // No rotation - simple paint (centered)
      final offsetX = position.dx - textPainter.width / 2;
      final offsetY = position.dy - textPainter.height / 2;
      if (offsetX.isFinite && offsetY.isFinite) {
        textPainter.paint(canvas, Offset(offsetX, offsetY));
      }
      return;
    }

    // Convert degrees to radians
    final rotationRadians = rotationDegrees * math.pi / 180.0;

    // Apply rotation around the center point
    canvas.save();
    
    // Translate to the rotation center
    canvas.translate(position.dx, position.dy);
    
    // Apply rotation (in radians)
    canvas.rotate(rotationRadians);
    
    // Paint text centered at origin (after translation and rotation)
    final textOffset = Offset(
      -textPainter.width / 2,
      -textPainter.height / 2,
    );
    textPainter.paint(canvas, textOffset);
    
    canvas.restore();
  }

  /// Helper to calculate a "nice" maximum Y value for axis scaling.
  ///
  /// Returns a value slightly larger than [maxY] that is a multiple of
  /// 1, 2, 5, or 10 times a power of 10, ensuring clean axis intervals.
  ///
  /// Parameters:
  /// - [maxY] - The maximum data value
  /// - [targetIntervals] - Desired number of intervals (default 5)
  double getNiceMaxY(double maxY, {int targetIntervals = 5}) {
    if (maxY <= 0) return 1.0;
    
    final rawStep = maxY / targetIntervals;
    final magnitude = math.pow(10, (math.log(rawStep) / math.ln10).floor()).toDouble();
    final normalizedStep = rawStep / magnitude;
    
    double niceStep;
    if (normalizedStep <= 1.0) {
      niceStep = 1.0;
    } else if (normalizedStep <= 2.0) {
      niceStep = 2.0;
    } else if (normalizedStep <= 5.0) {
      niceStep = 5.0;
    } else {
      niceStep = 10.0;
    }
    
    final step = niceStep * magnitude;
    return step * targetIntervals;
  }

  /// Get data bounds (to be overridden by subclasses).
  ///
  /// This method is a placeholder for subclasses to implement custom
  /// bounds calculation logic. The default implementation does nothing.
  ///
  /// Parameters:
  /// - [getValue] - Function to extract a value from a data point
  /// - [combine] - Function to combine two values (e.g., min or max)
  ///
  /// ## Example Implementation
  /// ```dart
  /// @override
  /// void getDataBounds(
  ///   double Function(ChartDataPoint) getValue,
  ///   double Function(double, double) combine,
  /// ) {
  ///   double result = getValue(dataSets.first.dataPoint);
  ///   for (final dataSet in dataSets) {
  ///     final point = dataSet.dataPoint;
  ///     result = combine(result, getValue(point));
  ///     }
  ///   }
  ///   // Store result...
  /// }
  /// ```
  @protected
  void getDataBounds(
    double Function(ChartDataPoint) getValue,
    double Function(double, double) combine,
  ) {
    // This will be overridden by subclasses
  }
}