import 'dart:math' as math;
import 'package:flutter/material.dart';
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

  LineChartPainter({
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
      for (final point in dataSet.dataPoints) {
        if (point.x < minX) minX = point.x;
        if (point.x > maxX) maxX = point.x;
        if (point.y > maxY) maxY = point.y;
      }
    }

    if (minX == double.infinity) return; // No valid data

    final minY = 0.0; // Always start from 0 for better visualization
    final maxYAdjusted = maxY * 1.15;

    // Add small padding for X axis
    final xRange = maxX - minX;
    final xPadding = xRange * 0.05;

    // Save canvas state
    canvas.save();
    canvas.translate(chartOffset.dx, chartOffset.dy);

    // Draw grid
    drawGrid(canvas, chartSize, minX, maxX, minY, maxYAdjusted);

    // Draw axes
    drawAxes(canvas, chartSize, minX, maxX, minY, maxYAdjusted);

    // Draw each dataset
    for (final dataSet in dataSets) {
      if (dataSet.dataPoints.isEmpty) continue;

      // Convert points to canvas coordinates with padding
      final points = dataSet.dataPoints.map((point) {
        return pointToCanvas(
          point,
          chartSize,
          minX - xPadding,
          maxX + xPadding,
          minY,
          maxYAdjusted,
        );
      }).toList();

      // Draw area fill with professional gradient and animation
      if (showArea) {
        final areaPath = Path();
        areaPath.moveTo(points.first.dx, chartSize.height);

        // Use same animated points as line
        final totalPoints = points.length;
        final animatedPoints = (totalPoints * animationProgress).ceil();

        // Create smooth bezier curve
        for (int i = 0; i < animatedPoints; i++) {
          if (i == 0) {
            areaPath.lineTo(points[i].dx, points[i].dy);
          } else {
            final prevPoint = points[i - 1];
            final currentPoint = points[i];

            // Interpolate the last point if animation is in progress
            Offset targetPoint = currentPoint;
            if (i == animatedPoints - 1 && animationProgress < 1.0) {
              final partialProgress =
                  (animationProgress * totalPoints) - (i - 1);
              targetPoint =
                  Offset.lerp(prevPoint, currentPoint, partialProgress)!;
            }

            final dx = targetPoint.dx - prevPoint.dx;
            final controlPoint1 = Offset(
              prevPoint.dx + dx * curveSmoothness,
              prevPoint.dy,
            );
            final controlPoint2 = Offset(
              targetPoint.dx - dx * curveSmoothness,
              targetPoint.dy,
            );
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
        if (animatedPoints > 0) {
          final lastPoint = animatedPoints == points.length
              ? points.last
              : Offset.lerp(
                  points[animatedPoints - 1],
                  points[math.min(animatedPoints, points.length - 1)],
                  animationProgress,
                )!;
          areaPath.lineTo(lastPoint.dx, chartSize.height);
        }
        areaPath.close();

        // Professional multi-stop gradient with animation opacity
        final areaPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              dataSet.color.withValues(alpha: 0.4 * animationProgress),
              dataSet.color.withValues(alpha: 0.15 * animationProgress),
              dataSet.color.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, chartSize.width, chartSize.height))
          ..style = PaintingStyle.fill;

        canvas.drawPath(areaPath, areaPaint);
      }

      // Draw line with smooth bezier curves and animation
      final linePath = Path();
      linePath.moveTo(points.first.dx, points.first.dy);

      // Calculate how many points to draw based on animation progress
      final totalPoints = points.length;
      final animatedPoints = (totalPoints * animationProgress).ceil();

      for (int i = 1; i < animatedPoints; i++) {
        final prevPoint = points[i - 1];
        final currentPoint = points[i];
        final dx = currentPoint.dx - prevPoint.dx;

        // Interpolate the last point if animation is in progress
        Offset targetPoint = currentPoint;
        if (i == animatedPoints - 1 && animationProgress < 1.0) {
          final partialProgress = (animationProgress * totalPoints) - (i - 1);
          targetPoint = Offset.lerp(prevPoint, currentPoint, partialProgress)!;
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
        linePath.cubicTo(
          controlPoint1.dx,
          controlPoint1.dy,
          controlPoint2.dx,
          controlPoint2.dy,
          targetPoint.dx,
          targetPoint.dy,
        );
      }

      // Professional line styling with subtle glow
      final linePaint = Paint()
        ..color = dataSet.color
        ..strokeWidth = lineWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

      canvas.drawPath(linePath, linePaint);

      // Draw a brighter overlay for depth
      final overlayPaint = Paint()
        ..color = dataSet.color.withValues(alpha: 0.6)
        ..strokeWidth = lineWidth * 0.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(linePath, overlayPaint);

      // Draw points with professional styling and animation
      if (showPoints) {
        final totalPoints = points.length;
        final animatedPoints = (totalPoints * animationProgress).ceil();

        for (int i = 0; i < animatedPoints; i++) {
          final point = points[i];
          final pointOpacity = i < animatedPoints - 1 ? 1.0 : animationProgress;

          // Check if this point is selected or hovered
          final isSelected = selectedPoint != null &&
              selectedPoint!.isHit &&
              selectedPoint!.datasetIndex == dataSets.indexOf(dataSet) &&
              selectedPoint!.elementIndex == i;

          final isHovered = hoveredPoint != null &&
              hoveredPoint!.isHit &&
              hoveredPoint!.datasetIndex == dataSets.indexOf(dataSet) &&
              hoveredPoint!.elementIndex == i;

          // Outer glow with animation (larger if selected or hovered)
          final glowRadius = isSelected ? 10.0 : (isHovered ? 8.0 : 6.0);
          final glowOpacity = isSelected ? 0.4 : (isHovered ? 0.3 : 0.2);
          final glowPaint = Paint()
            ..color =
                dataSet.color.withValues(alpha: glowOpacity * pointOpacity)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(point, glowRadius, glowPaint);

          // Main point with animation (larger if selected or hovered)
          final pointRadius = isSelected ? 6.5 : (isHovered ? 5.5 : 4.5);
          final pointPaint = Paint()
            ..color = dataSet.color.withValues(alpha: pointOpacity)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(point, pointRadius, pointPaint);

          // Inner highlight with animation
          final highlightPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.8 * pointOpacity)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(point, 2, highlightPaint);

          // Border with animation (thicker if selected or hovered)
          final borderWidth = isSelected ? 2.5 : (isHovered ? 2.0 : 1.5);
          final borderPaint = Paint()
            ..color = theme.backgroundColor
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
