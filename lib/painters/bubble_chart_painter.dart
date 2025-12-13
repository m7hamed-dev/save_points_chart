import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/painters/base_chart_painter.dart';

/// A custom painter for rendering bubble charts.
///
/// This painter handles the rendering of bubble charts where each point
/// has x, y coordinates and a size (radius) representing a third dimension.
class BubbleChartPainter extends BaseChartPainter {
  /// The minimum bubble size in pixels.
  final double minBubbleSize;

  /// The maximum bubble size in pixels.
  final double maxBubbleSize;

  /// The animation progress value between 0.0 and 1.0.
  final double animationProgress;

  /// The currently selected bubble interaction result.
  final ChartInteractionResult? selectedBubble;

  /// The currently hovered bubble interaction result.
  final ChartInteractionResult? hoveredBubble;

  /// The list of bubble data sets.
  final List<BubbleDataSet> bubbleDataSets;

  /// Creates a bubble chart painter.
  const BubbleChartPainter({
    required super.theme,
    required this.bubbleDataSets,
    super.showGrid,
    super.showAxis,
    super.showLabel,
    this.minBubbleSize = 5.0,
    this.maxBubbleSize = 30.0,
    this.animationProgress = 1.0,
    this.selectedBubble,
    this.hoveredBubble,
  }) : super(dataSets: const []); // Empty for bubble chart

  @override
  void paint(Canvas canvas, Size size) {
    final leftPadding = 50.0;
    final rightPadding = 20.0;
    final topPadding = 20.0;
    final bottomPadding = 40.0;
    final chartSize = Size(
      size.width - leftPadding - rightPadding,
      size.height - topPadding - bottomPadding,
    );
    final chartOffset = Offset(leftPadding, topPadding);

    if (bubbleDataSets.isEmpty) return;

    // Calculate bounds
    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double minY = double.infinity;
    double maxY = double.negativeInfinity;
    double minSize = double.infinity;
    double maxSize = double.negativeInfinity;

    for (final dataSet in bubbleDataSets) {
      for (final point in dataSet.dataPoints) {
        if (point.x < minX) minX = point.x;
        if (point.x > maxX) maxX = point.x;
        if (point.y < minY) minY = point.y;
        if (point.y > maxY) maxY = point.y;
        if (point.size < minSize) minSize = point.size;
        if (point.size > maxSize) maxSize = point.size;
      }
    }

    // Add padding to bounds
    final xRange = maxX - minX;
    final yRange = maxY - minY;
    minX -= xRange * 0.1;
    maxX += xRange * 0.1;
    minY -= yRange * 0.1;
    maxY += yRange * 0.1;

    // Calculate size range
    final sizeRange = maxSize - minSize;
    final sizeScale =
        sizeRange > 0 ? (maxBubbleSize - minBubbleSize) / sizeRange : 1.0;

    // Save canvas state
    canvas.save();
    canvas.translate(chartOffset.dx, chartOffset.dy);

    // Draw grid
    drawGrid(canvas, chartSize, minX, maxX, minY, maxY);

    // Draw axes
    drawAxes(canvas, chartSize, minX, maxX, minY, maxY);

    // Draw axis labels
    drawAxisLabels(canvas, chartSize, minX, maxX, minY, maxY);

    // Draw bubbles
    for (int datasetIndex = 0;
        datasetIndex < bubbleDataSets.length;
        datasetIndex++) {
      final dataSet = bubbleDataSets[datasetIndex];
      final color = dataSet.color;

      for (int pointIndex = 0;
          pointIndex < dataSet.dataPoints.length;
          pointIndex++) {
        final point = dataSet.dataPoints[pointIndex];
        final canvasPoint = pointToCanvas(
          ChartDataPoint(x: point.x, y: point.y),
          chartSize,
          minX,
          maxX,
          minY,
          maxY,
        );

        // Check if this bubble is selected or hovered
        final isSelected = selectedBubble?.datasetIndex == datasetIndex &&
            selectedBubble?.elementIndex == pointIndex;
        final isHovered = hoveredBubble?.datasetIndex == datasetIndex &&
            hoveredBubble?.elementIndex == pointIndex;

        // Calculate bubble size
        final normalizedSize = sizeRange > 0
            ? minBubbleSize + (point.size - minSize) * sizeScale
            : (minBubbleSize + maxBubbleSize) / 2;
        final currentSize =
            (isSelected || isHovered ? normalizedSize * 1.2 : normalizedSize) *
                animationProgress;

        final currentColor = isSelected || isHovered
            ? color.withValues(alpha: 0.9)
            : color.withValues(alpha: 0.7);

        // Draw bubble with gradient
        if (currentSize > 0) {
          // Outer glow for selected/hovered
          if (isSelected || isHovered) {
            final glowPaint = Paint()
              ..color = currentColor.withValues(alpha: 0.2)
              ..style = PaintingStyle.fill;
            canvas.drawCircle(canvasPoint, currentSize * 1.5, glowPaint);
          }

          // Main bubble with gradient
          final gradient = RadialGradient(
            colors: [
              currentColor,
              currentColor.withValues(alpha: 0.5),
            ],
          );
          final bubblePaint = Paint()
            ..shader = gradient.createShader(
              Rect.fromCircle(
                center: canvasPoint,
                radius: currentSize,
              ),
            )
            ..style = PaintingStyle.fill;

          canvas.drawCircle(canvasPoint, currentSize, bubblePaint);

          // Border
          final borderPaint = Paint()
            ..color = theme.backgroundColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = 2.0;
          canvas.drawCircle(canvasPoint, currentSize, borderPaint);
        }
      }
    }

    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant BubbleChartPainter oldDelegate) {
    return super.shouldRepaint(oldDelegate) ||
        oldDelegate.minBubbleSize != minBubbleSize ||
        oldDelegate.maxBubbleSize != maxBubbleSize ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedBubble != selectedBubble ||
        oldDelegate.hoveredBubble != hoveredBubble ||
        oldDelegate.bubbleDataSets != bubbleDataSets;
  }
}
