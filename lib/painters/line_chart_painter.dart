import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/painters/base_chart_painter.dart';

/// Custom painter for line charts
class LineChartPainter extends BaseChartPainter {
  final double lineWidth;
  final bool showArea;
  final bool showPoints;
  final double curveSmoothness;
  final double animationProgress;
  final ChartInteractionResult? selectedPoint;
  final ChartInteractionResult? hoveredPoint;

  const LineChartPainter({
    required super.theme,
    required super.dataSets,
    super.showGrid,
    super.showAxis,
    super.showLabel,
    this.lineWidth = 3.0,
    this.showArea = true,
    this.showPoints = true,
    this.curveSmoothness = 0.35,
    this.animationProgress = 1.0,
    this.selectedPoint,
    this.hoveredPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Professional padding (constants for performance)
    const leftPadding = 50.0;
    const rightPadding = 20.0;
    const topPadding = 20.0;
    const bottomPadding = 40.0;
    final chartSize = Size(
      size.width - leftPadding - rightPadding,
      size.height - topPadding - bottomPadding,
    );
    final chartOffset = const Offset(leftPadding, topPadding);

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

    if (minX == double.infinity ||
        !minX.isFinite ||
        !maxX.isFinite ||
        !maxY.isFinite) {
      return; // No valid data
    }

    final minY = 0.0; // Always start from 0 for better visualization

    // Ensure maxY is positive and valid
    // Add extra padding to account for bezier curve overshoot and point radius
    // Bezier curves can extend beyond data points, so we need more padding
    final maxYAdjusted = maxY > 0 ? maxY * 1.2 : 1.0; // Increased from 1.15 to 1.2

    // Add padding for X axis to prevent points from being cut off
    // Calculate padding that accounts for point radius (max 6.5px) and glow (max 10px)
    final xRange = maxX - minX;
    final maxPointRadius = 10.0; // Maximum radius including glow
    final xPaddingInPixels = maxPointRadius;
    
    // Convert pixel padding to data units
    // If chartSize.width is available, convert pixels to data range
    final xPadding = (xRange > 0 && xRange.isFinite && chartSize.width > 0)
        ? (xPaddingInPixels / chartSize.width) * xRange
        : (xRange > 0 && xRange.isFinite) ? xRange * 0.08 : 0.0; // Fallback to 8% if width not available

    // Validate chart size
    if (!chartSize.width.isFinite ||
        !chartSize.height.isFinite ||
        chartSize.width <= 0 ||
        chartSize.height <= 0) {
      return;
    }

    // Save canvas state
    canvas.save();
    canvas.translate(chartOffset.dx, chartOffset.dy);
    
    // Clip to chart bounds to prevent lines/areas from extending outside
    canvas.clipRect(Rect.fromLTWH(0, 0, chartSize.width, chartSize.height));

    // Draw grid
    drawGrid(canvas, chartSize, minX, maxX, minY, maxYAdjusted);

    // Draw axes
    drawAxes(canvas, chartSize, minX, maxX, minY, maxYAdjusted);

    // Group datasets by color to draw lines
    final Map<Color, List<ChartDataPoint>> colorGroups = {};
    for (final dataSet in dataSets) {
      if (!colorGroups.containsKey(dataSet.color)) {
        colorGroups[dataSet.color] = [];
      }
      colorGroups[dataSet.color]!.add(dataSet.dataPoint);
    }

    // Draw each color group as a separate line
    for (final entry in colorGroups.entries) {
      final color = entry.key;
      final pointsList = entry.value;
      
      if (pointsList.isEmpty) continue;

      // Sort points by x coordinate for proper line drawing
      pointsList.sort((a, b) => a.x.compareTo(b.x));

      // Convert points to canvas coordinates with padding
      final points = pointsList
          .map((point) {
            return pointToCanvas(
              point,
              chartSize,
              minX - xPadding,
              maxX + xPadding,
              minY,
              maxYAdjusted,
            );
          })
          .where((offset) => offset.dx.isFinite && offset.dy.isFinite)
          .toList();

      // Skip if no valid points
      if (points.isEmpty) continue;

      // Draw area fill with professional gradient and animation
      if (showArea) {
        final areaPath = Path();
        areaPath.moveTo(points.first.dx, chartSize.height);

        // Use same animated points as line
        final totalPoints = points.length;
        final animatedPoints = (totalPoints * animationProgress).ceil();

        // Create smooth bezier curve
        for (int i = 0; i < animatedPoints && i < points.length; i++) {
          final currentPoint = points[i];
          // Validate point before using
          if (!currentPoint.dx.isFinite || !currentPoint.dy.isFinite) continue;

          if (i == 0) {
            areaPath.lineTo(currentPoint.dx, currentPoint.dy);
          } else {
            final prevPoint = points[i - 1];
            // Validate previous point
            if (!prevPoint.dx.isFinite || !prevPoint.dy.isFinite) continue;

            // Interpolate the last point if animation is in progress
            Offset targetPoint = currentPoint;
            if (i == animatedPoints - 1 && animationProgress < 1.0) {
              final partialProgress =
                  (animationProgress * totalPoints) - (i - 1);
              final lerpedPoint =
                  Offset.lerp(prevPoint, currentPoint, partialProgress);
              if (lerpedPoint != null &&
                  lerpedPoint.dx.isFinite &&
                  lerpedPoint.dy.isFinite) {
                targetPoint = lerpedPoint;
              }
            }

            final dx = targetPoint.dx - prevPoint.dx;
            if (!dx.isFinite) continue;

            final controlPoint1 = Offset(
              prevPoint.dx + dx * curveSmoothness,
              prevPoint.dy,
            );
            final controlPoint2 = Offset(
              targetPoint.dx - dx * curveSmoothness,
              targetPoint.dy,
            );

            // Validate control points before using
            if (!controlPoint1.dx.isFinite ||
                !controlPoint1.dy.isFinite ||
                !controlPoint2.dx.isFinite ||
                !controlPoint2.dy.isFinite ||
                !targetPoint.dx.isFinite ||
                !targetPoint.dy.isFinite) {
              continue;
            }

            areaPath.cubicTo(
              controlPoint1.dx,
              controlPoint1.dy,
              controlPoint2.dx,
              controlPoint2.dy,
              targetPoint.dx,
              targetPoint.dy,
            );
          }
        }

        // Complete the area path
        if (animatedPoints > 0 && points.isNotEmpty) {
          Offset lastPoint;
          if (animatedPoints == points.length) {
            lastPoint = points.last;
          } else {
            final lerpedPoint = Offset.lerp(
              points[animatedPoints - 1],
              points[math.min(animatedPoints, points.length - 1)],
              animationProgress,
            );
            lastPoint = (lerpedPoint != null &&
                    lerpedPoint.dx.isFinite &&
                    lerpedPoint.dy.isFinite)
                ? lerpedPoint
                : points.last;
          }

          if (lastPoint.dx.isFinite && lastPoint.dy.isFinite) {
            areaPath.lineTo(lastPoint.dx, chartSize.height);
          }
        }
        areaPath.close();

        // Enhanced multi-stop gradient with better visual appeal
        final areaPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.5 * animationProgress),
              color.withValues(alpha: 0.25 * animationProgress),
              color.withValues(alpha: 0.1 * animationProgress),
              color.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.3, 0.7, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, chartSize.width, chartSize.height))
          ..style = PaintingStyle.fill;

        canvas.drawPath(areaPath, areaPaint);
        
        // Add subtle border highlight for depth
        final borderPaint = Paint()
          ..color = color.withValues(alpha: 0.3 * animationProgress)
          ..strokeWidth = 1.0
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;
        canvas.drawPath(areaPath, borderPaint);
      }

      // Draw line with smooth bezier curves and animation
      final linePath = Path();
      if (points.isNotEmpty &&
          points.first.dx.isFinite &&
          points.first.dy.isFinite) {
        linePath.moveTo(points.first.dx, points.first.dy);
      }

      // Calculate how many points to draw based on animation progress
      final totalPoints = points.length;
      final animatedPoints = (totalPoints * animationProgress).ceil();

      for (int i = 1; i < animatedPoints && i < points.length; i++) {
        final prevPoint = points[i - 1];
        final currentPoint = points[i];

        // Validate points before using
        if (!prevPoint.dx.isFinite ||
            !prevPoint.dy.isFinite ||
            !currentPoint.dx.isFinite ||
            !currentPoint.dy.isFinite) {
          continue;
        }

        final dx = currentPoint.dx - prevPoint.dx;
        if (!dx.isFinite) continue;

        // Interpolate the last point if animation is in progress
        Offset targetPoint = currentPoint;
        if (i == animatedPoints - 1 && animationProgress < 1.0) {
          final partialProgress = (animationProgress * totalPoints) - (i - 1);
          final lerpedPoint =
              Offset.lerp(prevPoint, currentPoint, partialProgress);
          if (lerpedPoint != null &&
              lerpedPoint.dx.isFinite &&
              lerpedPoint.dy.isFinite) {
            targetPoint = lerpedPoint;
          }
        }

        // Better bezier control points for smoother curves
        final controlPoint1 = Offset(
          prevPoint.dx + dx * curveSmoothness,
          prevPoint.dy,
        );
        final controlPoint2 = Offset(
          targetPoint.dx - dx * curveSmoothness,
          targetPoint.dy,
        );

        // Validate control points before using
        if (!controlPoint1.dx.isFinite ||
            !controlPoint1.dy.isFinite ||
            !controlPoint2.dx.isFinite ||
            !controlPoint2.dy.isFinite ||
            !targetPoint.dx.isFinite ||
            !targetPoint.dy.isFinite) {
          continue;
        }

        linePath.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          targetPoint.dx,
          targetPoint.dy,
        );
      }

      // Enhanced line styling with better glow and gradient
      final linePaint = Paint()
        ..shader = LinearGradient(
          colors: [
            color,
            color.withValues(alpha: 0.9),
            color,
          ],
          stops: const [0.0, 0.5, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, chartSize.width, chartSize.height))
        ..strokeWidth = lineWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.5);

      canvas.drawPath(linePath, linePaint);

      // Draw a brighter overlay for depth
      final overlayPaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..strokeWidth = lineWidth * 0.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(linePath, overlayPaint);

      // Draw points with professional styling and animation
      if (showPoints) {
        final totalPoints = points.length;
        final animatedPoints = (totalPoints * animationProgress).ceil();

        for (int i = 0; i < animatedPoints && i < points.length; i++) {
          final point = points[i];

          // Validate point before using
          if (!point.dx.isFinite || !point.dy.isFinite) continue;

          final pointOpacity = i < animatedPoints - 1 ? 1.0 : animationProgress;

          // Find the corresponding dataset index
          final dataPoint = pointsList[i];
          int datasetIndex = -1;
          for (int j = 0; j < dataSets.length; j++) {
            if (dataSets[j].dataPoint == dataPoint) {
              datasetIndex = j;
              break;
            }
          }

          // Check if this point is selected or hovered
          final isSelected = selectedPoint != null &&
              selectedPoint!.isHit &&
              selectedPoint!.datasetIndex == datasetIndex &&
              selectedPoint!.elementIndex == 0;

          final isHovered = hoveredPoint != null &&
              hoveredPoint!.isHit &&
              hoveredPoint!.datasetIndex == datasetIndex &&
              hoveredPoint!.elementIndex == 0;

          // Outer glow with animation (larger if selected or hovered)
          final glowRadius = isSelected ? 10.0 : (isHovered ? 8.0 : 6.0);
          final glowOpacity = isSelected ? 0.4 : (isHovered ? 0.3 : 0.2);
          final glowPaint = Paint()
            ..color =
                color.withValues(alpha: glowOpacity * pointOpacity)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(point, glowRadius, glowPaint);

          // Main point with animation (larger if selected or hovered)
          final pointRadius = isSelected ? 6.5 : (isHovered ? 5.5 : 4.5);
          final pointPaint = Paint()
            ..color = color.withValues(alpha: pointOpacity)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(point, pointRadius, pointPaint);

          // Inner highlight with animation
          final highlightPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.8 * pointOpacity)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(point, 2, highlightPaint);

          // Border with animation (thicker and white if selected)
          final borderWidth = isSelected ? 3.0 : (isHovered ? 2.0 : 1.5);
          final borderPaint = Paint()
            ..color = isSelected ? Colors.white : theme.backgroundColor
            ..style = PaintingStyle.stroke
            ..strokeWidth = borderWidth;
          canvas.drawCircle(point, pointRadius, borderPaint);
        }
      }
    }

    canvas.restore();

    // Draw axis labels with proper bounds
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
  bool shouldRepaint(covariant LineChartPainter oldDelegate) {
    if (oldDelegate.animationProgress != animationProgress) return true;
    if (oldDelegate.lineWidth != lineWidth) return true;
    if (oldDelegate.showArea != showArea) return true;
    if (oldDelegate.showPoints != showPoints) return true;
    if (oldDelegate.curveSmoothness != curveSmoothness) return true;
    if (oldDelegate.selectedPoint != selectedPoint) return true;
    if (oldDelegate.hoveredPoint != hoveredPoint) return true;

    // Use parent's shouldRepaint for theme and data
    return super.shouldRepaint(oldDelegate);
  }
}
