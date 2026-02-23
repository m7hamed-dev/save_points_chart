import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/painters/base_chart_painter.dart';

/// Custom painter for stacked column charts
class StackedColumnChartPainter extends BaseChartPainter {
  final double barWidth;
  final double borderRadius;
  final double animationProgress;
  final ChartInteractionResult? selectedBar;

  const StackedColumnChartPainter({
    required super.theme,
    required super.dataSets,
    super.showGrid,
    super.showAxis,
    super.showLabel,
    this.barWidth = 30.0,
    this.borderRadius = 4.0,
    this.animationProgress = 1.0,
    this.selectedBar,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Use theme padding
    final leftPadding = theme.padding.left;
    final rightPadding = theme.padding.right;
    final topPadding = theme.padding.top;
    final bottomPadding = theme.padding.bottom;
    
    final chartSize = Size(
      size.width - leftPadding - rightPadding,
      size.height - topPadding - bottomPadding,
    );
    final chartOffset = Offset(leftPadding, topPadding);

    if (dataSets.isEmpty) return;

    // Find all unique x values
    final Set<double> xValues = {};
    for (final dataSet in dataSets) {
      xValues.add(dataSet.dataPoint.x);
    }

    if (xValues.isEmpty) return;

    final sortedXValues = xValues.toList()..sort();
    final minX = sortedXValues.first;
    final maxX = sortedXValues.last;

    // Calculate totals per x position for stacking
    final Map<double, double> totalsByX = {};
    for (final dataSet in dataSets) {
      final point = dataSet.dataPoint;
      totalsByX[point.x] = (totalsByX[point.x] ?? 0) + point.y;
    }

    final maxY = totalsByX.values.isEmpty
        ? 1.0
        : totalsByX.values.reduce(math.max) * 1.15;

    final minY = 0.0;

    final xRange = maxX - minX;
    final xPadding = (xRange > 0 && xRange.isFinite) ? xRange * 0.1 : 0.0;

    if (!chartSize.width.isFinite ||
        !chartSize.height.isFinite ||
        chartSize.width <= 0 ||
        chartSize.height <= 0) {
      return;
    }

    canvas.save();
    canvas.translate(chartOffset.dx, chartOffset.dy);

    drawGrid(canvas, chartSize, minX, maxX, minY, maxY);
    drawAxes(canvas, chartSize, minX, maxX, minY, maxY);

    // Draw stacked bars for each x position
    final xStep = chartSize.width / (sortedXValues.length + 1);

    for (int xIndex = 0; xIndex < sortedXValues.length; xIndex++) {
      final xValue = sortedXValues[xIndex];
      final xPos = (xIndex + 1) * xStep;

      // Calculate cumulative heights for stacking
      double cumulativeY = 0.0;

      for (int dataSetIndex = 0;
          dataSetIndex < dataSets.length;
          dataSetIndex++) {
        final dataSet = dataSets[dataSetIndex];
        // Find the point for this dataset at this x value
        ChartDataPoint point;
        if (dataSet.dataPoint.x == xValue) {
          point = dataSet.dataPoint;
        } else {
          point = ChartDataPoint(x: xValue, y: 0);
        }

        // Validate point data
        if (!point.y.isFinite || point.y <= 0 || !maxY.isFinite || maxY <= 0) {
          continue;
        }

        final yHeight = (point.y / maxY) * chartSize.height * animationProgress;
        final yStart = chartSize.height - cumulativeY;
        final yEnd = yStart - yHeight;

        // Validate calculated dimensions
        if (!yHeight.isFinite ||
            !yStart.isFinite ||
            !yEnd.isFinite ||
            yHeight <= 0 ||
            yStart < yEnd) {
          continue;
        }

        final isSelected = selectedBar != null &&
            selectedBar!.isHit &&
            selectedBar!.datasetIndex == dataSetIndex &&
            selectedBar!.elementIndex == xIndex;

        // Draw bar segment
        final barRect = RRect.fromRectAndRadius(
          Rect.fromLTRB(
            xPos - barWidth / 2,
            yEnd,
            xPos + barWidth / 2,
            yStart,
          ),
          Radius.circular(borderRadius),
        );

        // Gradient fill
        final gradient = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            dataSet.color,
            dataSet.color.withValues(alpha: 0.7),
          ],
        );

        final paint = Paint()
          ..shader = gradient.createShader(barRect.outerRect)
          ..style = PaintingStyle.fill;

        canvas.drawRRect(barRect, paint);

        // Highlight selected bar
        if (isSelected) {
          final highlightPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.3)
            ..style = PaintingStyle.fill;
          canvas.drawRRect(barRect, highlightPaint);
        }

        // Border - thicker and more visible for selected
        final borderPaint = Paint()
          ..color =
              isSelected ? Colors.white : dataSet.color.withValues(alpha: 0.3)
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 3.0 : 1.0;
        canvas.drawRRect(barRect, borderPaint);

        cumulativeY += yHeight;
      }
    }

    canvas.restore();

    canvas.save();
    canvas.translate(chartOffset.dx, chartOffset.dy);
    drawAxisLabels(
      canvas,
      chartSize,
      minX - xPadding,
      maxX + xPadding,
      minY,
      maxY,
      dataSets: dataSets,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StackedColumnChartPainter oldDelegate) {
    if (oldDelegate.barWidth != barWidth) return true;
    if (oldDelegate.borderRadius != borderRadius) return true;
    if (oldDelegate.animationProgress != animationProgress) return true;
    if (oldDelegate.selectedBar != selectedBar) return true;

    return super.shouldRepaint(oldDelegate);
  }
}
