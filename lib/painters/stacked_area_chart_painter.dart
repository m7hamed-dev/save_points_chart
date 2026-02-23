import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/painters/base_chart_painter.dart';

/// Painter for stacked area charts.
///
/// Expects [dataSets] to be cumulative (each dataset's y is sum of all previous).
/// The widget constructs cumulative datasets so this painter focuses on drawing.
class StackedAreaChartPainter extends BaseChartPainter {
  final double lineWidth;
  final double curveSmoothness;
  final double animationProgress;
  final ChartInteractionResult? selectedPoint;
  final ChartInteractionResult? hoveredPoint;

  const StackedAreaChartPainter({
    required super.theme,
    required super.dataSets,
    super.showGrid,
    super.showAxis,
    super.showLabel,
    this.lineWidth = 3.0,
    this.curveSmoothness = 0.35,
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
    
    final chartSize = Size(
      size.width - leftPadding - rightPadding,
      size.height - topPadding - bottomPadding,
    );
    final chartOffset = Offset(leftPadding, topPadding);

    if (dataSets.isEmpty) return;

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    // Data is cumulative already, so maxY is simply top layer max.
    for (final dataSet in dataSets) {
      final point = dataSet.dataPoint;
      if (point.x < minX) minX = point.x;
      if (point.x > maxX) maxX = point.x;
      if (point.y > maxY) maxY = point.y;
    }

    if (!minX.isFinite ||
        !maxX.isFinite ||
        !maxY.isFinite ||
        minX == double.infinity) {
      return;
    }

    final minY = 0.0;
    final maxYAdjusted = getNiceMaxY(maxY);
    final xRange = maxX - minX;
    final xPadding = (xRange > 0 && xRange.isFinite) ? xRange * 0.05 : 0.0;

    if (chartSize.width <= 0 ||
        chartSize.height <= 0 ||
        !chartSize.width.isFinite ||
        !chartSize.height.isFinite) {
      return;
    }

    canvas.save();
    canvas.translate(chartOffset.dx, chartOffset.dy);

    drawGrid(canvas, chartSize, minX, maxX, minY, maxYAdjusted);
    drawAxes(canvas, chartSize, minX, maxX, minY, maxYAdjusted);

    // Group points by color (series)
    final Map<Color, List<ChartDataPoint>> seriesMap = {};
    // Also track the order of colors to maintain consistent stacking
    final List<Color> colorOrder = [];
    
    for (final dataSet in dataSets) {
      if (!seriesMap.containsKey(dataSet.color)) {
        seriesMap[dataSet.color] = [];
        colorOrder.add(dataSet.color);
      }
      seriesMap[dataSet.color]!.add(dataSet.dataPoint);
    }

    // Sort points within each series by X
    for (final series in seriesMap.values) {
      series.sort((a, b) => a.x.compareTo(b.x));
    }

    // Identify all unique X values for stacking logic
    final Set<double> xValues = {};
    for (final ds in dataSets) {
      xValues.add(ds.dataPoint.x);
    }
    final sortedX = xValues.toList()..sort();

    // Map to store the "top" line of the previous layer at each X
    final Map<double, double> previousLayerY = {
      for (var x in sortedX) x: 0.0
    };

    for (int i = 0; i < colorOrder.length; i++) {
      final color = colorOrder[i];
      final points = seriesMap[color]!;
      
      // Create a map for quick lookup of current series Y at X
      final Map<double, double> currentYMap = {
        for (var p in points) p.x: p.y
      };

      // Construct points for the current layer (top line)
      // We iterate sortedX to ensure we have points at all X positions
      final List<Offset> topPoints = [];
      final List<Offset> bottomPoints = [];

      for (final x in sortedX) {
        if (currentYMap.containsKey(x)) {
          final yTop = currentYMap[x]!;
          final yBottom = previousLayerY[x]!;
          
          topPoints.add(pointToCanvas(
            ChartDataPoint(x: x, y: yTop), 
            chartSize, minX - xPadding, maxX + xPadding, minY, maxYAdjusted
          ));
          
          bottomPoints.add(pointToCanvas(
            ChartDataPoint(x: x, y: yBottom), 
            chartSize, minX - xPadding, maxX + xPadding, minY, maxYAdjusted
          ));
          
          // Update previous layer for next iteration
          previousLayerY[x] = yTop;
        }
      }

      if (topPoints.isEmpty) continue;

      final totalPoints = topPoints.length;
      final animatedPoints = (totalPoints * animationProgress).ceil();
      
      // If animation is in progress, we only draw a subset of points
      // But for area fill, we need to be careful.
      // Easiest is to clip the path or just draw subset.
      
      final visibleTopPoints = topPoints.sublist(0, math.min(animatedPoints, topPoints.length));
      final visibleBottomPoints = bottomPoints.sublist(0, math.min(animatedPoints, bottomPoints.length));
      
      if (visibleTopPoints.isEmpty) continue;

      // Draw the area
      final path = Path();
      path.moveTo(visibleTopPoints.first.dx, visibleTopPoints.first.dy);
      
      // Draw top curve
      for (int j = 1; j < visibleTopPoints.length; j++) {
        final p0 = visibleTopPoints[j - 1];
        final p1 = visibleTopPoints[j];
        final dx = p1.dx - p0.dx;
        
        final cp1 = Offset(p0.dx + dx * curveSmoothness, p0.dy);
        final cp2 = Offset(p1.dx - dx * curveSmoothness, p1.dy);
        
        path.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
      }
      
      // Draw bottom curve (backwards)
      for (int j = visibleBottomPoints.length - 1; j >= 0; j--) {
        final p = visibleBottomPoints[j];
        if (j == visibleBottomPoints.length - 1) {
          path.lineTo(p.dx, p.dy);
        } else {
          final pNext = visibleBottomPoints[j + 1]; // Previous in iteration
          final dx = pNext.dx - p.dx; // Negative
          
          // Control points for backward curve (optional, lineTo is safer for bottom)
          // Using lineTo ensures no weird overlaps with previous layer's top curve
          path.lineTo(p.dx, p.dy);
        }
      }
      path.close();

      // Draw fill
      final paint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..style = PaintingStyle.fill;
      canvas.drawPath(path, paint);
      
      // Draw stroke
      final strokePaint = Paint()
        ..color = color
        ..strokeWidth = lineWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      
      // Create path for stroke (only top line)
      final strokePath = Path();
      strokePath.moveTo(visibleTopPoints.first.dx, visibleTopPoints.first.dy);
      for (int j = 1; j < visibleTopPoints.length; j++) {
        final p0 = visibleTopPoints[j - 1];
        final p1 = visibleTopPoints[j];
        final dx = p1.dx - p0.dx;
        final cp1 = Offset(p0.dx + dx * curveSmoothness, p0.dy);
        final cp2 = Offset(p1.dx - dx * curveSmoothness, p1.dy);
        strokePath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, p1.dx, p1.dy);
      }
      canvas.drawPath(strokePath, strokePaint);

      // Draw points
      for (int j = 0; j < visibleTopPoints.length; j++) {
        final point = visibleTopPoints[j];
        
        // Find original point for interaction check
        // We need to find the dataset index for this point
        // Since we grouped by color, we can iterate original dataSets to find match
        // This is slow but accurate
        int datasetIndex = -1;
        int elementIndex = -1;
        
        // Find matching point in original data
        // Note: xValues are doubles, equality check might be tricky, use epsilon
        final xVal = sortedX[j];
        for(int d=0; d<dataSets.length; d++) {
          if (dataSets[d].color == color && (dataSets[d].dataPoint.x - xVal).abs() < 0.0001) {
            datasetIndex = d;
            // elementIndex is usually index within a series, but here each point is a dataset?
            // The interaction model passes pointIndex. 
            // In other charts, pointIndex is index within the dataset's points list.
            // But here ChartDataSet has 1 point.
            // So elementIndex is likely 0.
            elementIndex = 0; 
            break;
          }
        }

        final isSelected = selectedPoint != null &&
            selectedPoint!.isHit &&
            selectedPoint!.datasetIndex == datasetIndex;
            
        final isHovered = hoveredPoint != null &&
            hoveredPoint!.isHit &&
            hoveredPoint!.datasetIndex == datasetIndex;

        final radius = isSelected ? 6.0 : (isHovered ? 5.0 : 4.0);
        
        final pointPaint = Paint()
          ..color = color
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, radius, pointPaint);

        final borderPaint = Paint()
          ..color = isSelected ? Colors.white : theme.backgroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = isSelected ? 3.0 : 1.5;
        canvas.drawCircle(point, radius, borderPaint);
      }
    }

    canvas.restore();

    // Axis labels on top of translated canvas
    canvas.save();
    canvas.translate(chartOffset.dx, chartOffset.dy);
    drawAxisLabels(
      canvas,
      chartSize,
      minX - xPadding,
      maxX + xPadding,
      minY,
      maxYAdjusted,
      dataSets: dataSets,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant StackedAreaChartPainter oldDelegate) {
    if (oldDelegate.animationProgress != animationProgress) return true;
    if (oldDelegate.lineWidth != lineWidth) return true;
    if (oldDelegate.curveSmoothness != curveSmoothness) return true;
    if (oldDelegate.selectedPoint != selectedPoint) return true;
    if (oldDelegate.hoveredPoint != hoveredPoint) return true;
    return super.shouldRepaint(oldDelegate);
  }
}
