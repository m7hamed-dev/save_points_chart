import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/painters/base_chart_painter.dart';
import 'package:save_points_chart/widgets/bar_chart_widget.dart';

/// A custom painter for rendering bar charts with animations and interactions.
///
/// This painter handles the rendering of bar charts including:
/// - Single and grouped bar layouts
/// - Smooth animations with staggered effects
/// - Interactive selection and hover states
/// - Rounded corners and gradient fills
/// - Professional grid and axis rendering
///
/// The painter extends [BaseChartPainter] to inherit common chart rendering
/// functionality like grid, axes, and labels.
///
/// See also:
/// - [BarChartWidget] for the widget that uses this painter
class BarChartPainter extends BaseChartPainter {
  /// The width of each bar in pixels.
  ///
  /// Defaults to 20.0 pixels. For grouped bars, this determines the width
  /// of each bar in a group.
  final double barWidth;

  /// The border radius for rounded bar corners.
  ///
  /// Defaults to 8.0 pixels. Set to 0.0 for square bars.
  final double borderRadius;

  /// Whether bars should be grouped when multiple data sets are provided.
  ///
  /// When true and multiple data sets exist, bars are grouped side-by-side.
  /// When false, only the first data set is rendered.
  /// Defaults to false.
  final bool isGrouped;

  /// The animation progress value between 0.0 and 1.0.
  ///
  /// Controls the animation state of the bars. 0.0 means no animation,
  /// 1.0 means fully animated. Used for staggered bar animations.
  /// Defaults to 1.0.
  final double animationProgress;

  /// The currently selected bar interaction result.
  ///
  /// Contains information about which bar is selected, including dataset
  /// index and element index. Null if no bar is selected.
  final ChartInteractionResult? selectedBar;

  /// The currently hovered bar interaction result.
  ///
  /// Contains information about which bar is being hovered over, including
  /// dataset index and element index. Null if no bar is hovered.
  final ChartInteractionResult? hoveredBar;

  /// Creates a bar chart painter.
  ///
  /// [theme] and [dataSets] are required and passed to the base class.
  /// [barWidth] defaults to 20.0 pixels.
  /// [borderRadius] defaults to 8.0 pixels.
  /// [isGrouped] defaults to false.
  /// [animationProgress] defaults to 1.0 (fully animated).
  ///
  /// The painter will render bars with rounded corners, gradients, and
  /// visual feedback for selected/hovered states.
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
    this.hoveredBar,
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
      final point = dataSet.dataPoint;
      if (point.x < minX) minX = point.x;
      if (point.x > maxX) maxX = point.x;
      if (point.y > maxY) maxY = point.y;
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

    // Group points by x-coordinate for grouped bars
    final Map<double, List<ChartDataSet>> groupedByX = {};
    for (final dataSet in dataSets) {
      final x = dataSet.dataPoint.x;
      groupedByX.putIfAbsent(x, () => []).add(dataSet);
    }

    final sortedXValues = groupedByX.keys.toList()..sort();
    final maxGroups = sortedXValues.length;

    if (isGrouped && groupedByX.length > 1) {
      // Grouped bars - group by x coordinate
      final groupSpacing = chartSize.width / (maxGroups + 1);
      final barSpacing = barWidth * 0.2;

      for (int groupIndex = 0;
          groupIndex < sortedXValues.length;
          groupIndex++) {
        final xValue = sortedXValues[groupIndex];
        final groupDataSets = groupedByX[xValue]!;
        double currentX = groupSpacing * (groupIndex + 1);

        for (final dataSet in groupDataSets) {
          final point = dataSet.dataPoint;

          // Validate point data to prevent NaN
          if (!point.y.isFinite || point.y < 0 || maxYAdjusted <= 0) {
            continue;
          }

          final barHeight = (point.y / maxYAdjusted) * chartSize.height;
          final barY = chartSize.height - barHeight;

          // Stagger animation for grouped bars
          final barIndex = groupIndex / maxGroups;
          final barProgress = math.max(
            0.0,
            math.min(1.0, (animationProgress - barIndex * 0.3) / 0.7),
          );

          // Check if this bar is selected or hovered
          final datasetIndex = dataSets.indexOf(dataSet);
          final isSelected = selectedBar != null &&
              selectedBar!.isHit &&
              selectedBar!.datasetIndex == datasetIndex &&
              selectedBar!.elementIndex == 0;
          final isHovered = hoveredBar != null &&
              hoveredBar!.isHit &&
              hoveredBar!.datasetIndex == datasetIndex &&
              hoveredBar!.elementIndex == 0;

          _drawRoundedBar(
            canvas,
            Offset(currentX - barWidth / 2, barY),
            barWidth,
            barHeight,
            dataSet.color,
            barProgress,
            isSelected: isSelected,
            isHovered: isHovered,
          );

          currentX += barWidth + barSpacing;
        }
      }
    } else {
      // Single bars with animation
      final totalBars = dataSets.length;
      for (int i = 0; i < dataSets.length; i++) {
        final dataSet = dataSets[i];
        final point = dataSet.dataPoint;

        // Validate point data to prevent NaN
        if (!point.x.isFinite ||
            !point.y.isFinite ||
            point.y < 0 ||
            maxYAdjusted <= 0) {
          continue;
        }

        final xRange = maxXAdjusted - minXAdjusted;
        final x = xRange > 0
            ? ((point.x - minXAdjusted) / xRange) * chartSize.width
            : chartSize.width / 2;
        final barHeight = (point.y / maxYAdjusted) * chartSize.height;
        final barY = chartSize.height - barHeight;

        // Stagger animation for each bar
        final barIndex = i / totalBars;
        final barProgress = math.max(
          0.0,
          math.min(1.0, (animationProgress - barIndex * 0.3) / 0.7),
        );

        // Check if this bar is selected or hovered
        final isSelected = selectedBar != null &&
            selectedBar!.isHit &&
            selectedBar!.datasetIndex == i &&
            selectedBar!.elementIndex == 0;
        final isHovered = hoveredBar != null &&
            hoveredBar!.isHit &&
            hoveredBar!.datasetIndex == i &&
            hoveredBar!.elementIndex == 0;

        _drawRoundedBar(
          canvas,
          Offset(x - barWidth / 2, barY),
          barWidth,
          barHeight,
          dataSet.color,
          barProgress,
          isSelected: isSelected,
          isHovered: isHovered,
        );
      }
    }

    canvas.restore();

    // Draw axis labels
    canvas.save();
    canvas.translate(chartOffset.dx, chartOffset.dy);
    drawAxisLabels(
      canvas,
      chartSize,
      minXAdjusted,
      maxXAdjusted,
      minY,
      maxYAdjusted,
      dataSets: dataSets,
    );
    canvas.restore();
  }

  void _drawRoundedBar(
    Canvas canvas,
    Offset position,
    double width,
    double height,
    Color color,
    double barProgress, {
    bool isSelected = false,
    bool isHovered = false,
  }) {
    // Animate bar height
    final animatedHeight = height * barProgress;
    final animatedY = position.dy + (height - animatedHeight);

    // Add elevation if selected or hovered
    final elevation = isSelected ? 4.0 : (isHovered ? 2.0 : 0.0);
    final adjustedY = animatedY - elevation;
    final adjustedHeight = animatedHeight + elevation;

    // Validate dimensions to prevent NaN in gradient
    if (!position.dx.isFinite ||
        !adjustedY.isFinite ||
        !width.isFinite ||
        !adjustedHeight.isFinite ||
        width <= 0 ||
        adjustedHeight <= 0) {
      return;
    }

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

    // Add subtle highlight on top (brighter if selected or hovered)
    final highlightRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(position.dx, adjustedY, width, adjustedHeight * 0.2),
      Radius.circular(borderRadius),
    );
    final highlightAlpha = isSelected ? 0.4 : (isHovered ? 0.3 : 0.2);
    final highlightPaint = Paint()
      ..color = Colors.white.withValues(alpha: highlightAlpha)
      ..style = PaintingStyle.fill;
    canvas.drawRRect(highlightRect, highlightPaint);

    // Add border if selected or hovered (white for selected)
    if (isSelected || isHovered) {
      final borderWidth = isSelected ? 3.0 : 2.0;
      final borderPaint = Paint()
        ..color = isSelected ? Colors.white : color.withValues(alpha: 0.6)
        ..style = PaintingStyle.stroke
        ..strokeWidth = borderWidth;
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
    if (oldDelegate.hoveredBar != hoveredBar) return true;

    // Use parent's shouldRepaint for theme and data
    return super.shouldRepaint(oldDelegate);
  }
}
