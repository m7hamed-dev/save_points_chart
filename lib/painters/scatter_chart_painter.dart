import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/painters/base_chart_painter.dart';

/// A custom painter for rendering scatter charts.
///
/// This painter handles the rendering of scatter charts including:
/// - Multiple data series with different point styles
/// - Interactive selection and hover states
/// - Customizable point sizes and shapes
/// - Professional grid and axis rendering
class ScatterChartPainter extends BaseChartPainter {
  /// The size of each scatter point in pixels.
  final double pointSize;

  /// The animation progress value between 0.0 and 1.0.
  final double animationProgress;

  /// The currently selected point interaction result.
  final ChartInteractionResult? selectedPoint;

  /// The currently hovered point interaction result.
  final ChartInteractionResult? hoveredPoint;

  /// Creates a scatter chart painter.
  const ScatterChartPainter({
    required super.theme,
    required super.dataSets,
    super.showGrid,
    super.showAxis,
    super.showLabel,
    this.pointSize = 8.0,
    this.animationProgress = 1.0,
    this.selectedPoint,
    this.hoveredPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Use theme padding
    final leftPadding = theme.padding.left;
    final rightPadding = theme.padding.right;
    final topPadding = theme.padding.top;
    final bottomPadding = theme.padding.bottom;

    final chartSize = Size(size.width - leftPadding - rightPadding, size.height - topPadding - bottomPadding);
    final chartOffset = Offset(leftPadding, topPadding);

    if (dataSets.isEmpty) return;

    // Validate chart size
    if (!chartSize.width.isFinite || !chartSize.height.isFinite || chartSize.width <= 0 || chartSize.height <= 0) {
      return;
    }

    // Calculate bounds
    double minX = .infinity;
    double maxX = double.negativeInfinity;
    double minY = .infinity;
    double maxY = double.negativeInfinity;

    for (final dataSet in dataSets) {
      final point = dataSet.dataPoint;
      if (point.x < minX) minX = point.x;
      if (point.x > maxX) maxX = point.x;
      if (point.y < minY) minY = point.y;
      if (point.y > maxY) maxY = point.y;
    }

    // Validate bounds
    if (!minX.isFinite || !maxX.isFinite || !minY.isFinite || !maxY.isFinite || minX == .infinity) {
      return;
    }

    // Add padding to bounds
    final xRange = maxX - minX;
    final yRange = maxY - minY;
    minX -= xRange * 0.1;
    maxX += xRange * 0.1;
    minY -= yRange * 0.1;
    maxY += yRange * 0.1;

    // Save canvas state
    canvas.save();
    canvas.translate(chartOffset.dx, chartOffset.dy);

    // Draw grid and axes (background)
    drawGrid(canvas, chartSize, minX, maxX, minY, maxY);
    drawAxes(canvas, chartSize, minX, maxX, minY, maxY);

    // Draw scatter points with Dribbble-like glow styling
    for (int datasetIndex = 0; datasetIndex < dataSets.length; datasetIndex++) {
      final dataSet = dataSets[datasetIndex];
      final color = dataSet.color;
      final point = dataSet.dataPoint;

      // Validate point data
      if (!point.x.isFinite || !point.y.isFinite) {
        continue;
      }

      final canvasPoint = pointToCanvas(point, chartSize, minX, maxX, minY, maxY);

      // Validate canvas point
      if (!canvasPoint.dx.isFinite || !canvasPoint.dy.isFinite) {
        continue;
      }

      // Check if this point is selected or hovered
      final isSelected = selectedPoint?.datasetIndex == datasetIndex && selectedPoint?.elementIndex == 0;
      final isHovered = hoveredPoint?.datasetIndex == datasetIndex && hoveredPoint?.elementIndex == 0;

      // Determine point size and color based on state
      final currentSize = isSelected || isHovered ? pointSize * 1.5 : pointSize;
      final currentColor = isSelected || isHovered ? color.withValues(alpha: 1.0) : color.withValues(alpha: 0.8);

      // Draw point with animation
      final animatedSize = currentSize * animationProgress;
      if (animatedSize > 0 && animatedSize.isFinite) {
        // Outer glow
        if (isSelected || isHovered) {
          final outerPaint = Paint()
            ..color = currentColor.withValues(alpha: 0.3)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(canvasPoint, animatedSize * 1.8, outerPaint);
        }

        // Main dot
        final fillPaint = Paint()
          ..color = currentColor
          ..style = PaintingStyle.fill;
        canvas.drawCircle(canvasPoint, animatedSize, fillPaint);

        // Inner highlight
        final highlightPaint = Paint()
          ..color = Colors.white.withValues(alpha: 0.85)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(canvasPoint, animatedSize * 0.4, highlightPaint);

        // Border (white if selected, card-colored otherwise)
        final borderPaint = Paint()
          ..color = isSelected ? Colors.white : theme.backgroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 2.5 : 1.8;
        canvas.drawCircle(canvasPoint, animatedSize, borderPaint);
      }
    }

    // Optional crosshair on hovered/selected point
    final interaction = hoveredPoint ?? selectedPoint;
    if (interaction != null && interaction.isHit && interaction.point != null) {
      final crosshairPos = pointToCanvas(interaction.point!, chartSize, minX, maxX, minY, maxY);
      drawCrosshair(canvas, chartSize, position: crosshairPos);
    }

    canvas.restore();

    // Axis labels above everything for clarity
    canvas.save();
    canvas.translate(chartOffset.dx, chartOffset.dy);
    drawAxisLabels(canvas, chartSize, minX, maxX, minY, maxY, dataSets: dataSets);
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant ScatterChartPainter oldDelegate) {
    return super.shouldRepaint(oldDelegate) ||
        oldDelegate.pointSize != pointSize ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedPoint != selectedPoint ||
        oldDelegate.hoveredPoint != hoveredPoint;
  }
}
