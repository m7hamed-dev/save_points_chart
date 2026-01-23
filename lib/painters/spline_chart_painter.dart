import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/painters/base_chart_painter.dart';

/// Custom painter for spline charts with smooth bezier curves
class SplineChartPainter extends BaseChartPainter {
  final double lineWidth;
  final bool showArea;
  final bool showPoints;
  final double animationProgress;
  final ChartInteractionResult? selectedPoint;
  final ChartInteractionResult? hoveredPoint;

  const SplineChartPainter({
    required super.theme,
    required super.dataSets,
    super.showGrid,
    super.showAxis,
    super.showLabel,
    this.lineWidth = 3.0,
    this.showArea = true,
    this.showPoints = true,
    this.animationProgress = 1.0,
    this.selectedPoint,
    this.hoveredPoint,
  });

  @override
  void paint(Canvas canvas, Size size) {
    const leftPadding = 50.0;
    const rightPadding = 20.0;
    const topPadding = 20.0;
    const bottomPadding = 40.0;
    final chartSize = Size(
      size.width - leftPadding - rightPadding,
      size.height - topPadding - bottomPadding,
    );
    final chartOffset = const Offset(leftPadding, topPadding);

    if (dataSets.isEmpty) return;

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

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
      return;
    }

    final minY = 0.0;
    final maxYAdjusted = maxY > 0 ? maxY * 1.15 : 1.0;

    final xRange = maxX - minX;
    final xPadding = (xRange > 0 && xRange.isFinite) ? xRange * 0.05 : 0.0;

    if (!chartSize.width.isFinite ||
        !chartSize.height.isFinite ||
        chartSize.width <= 0 ||
        chartSize.height <= 0) {
      return;
    }

    canvas.save();
    canvas.translate(chartOffset.dx, chartOffset.dy);

    drawGrid(canvas, chartSize, minX, maxX, minY, maxYAdjusted);
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

      if (points.isEmpty) continue;

      // Draw area fill with smooth spline curves
      if (showArea) {
        final areaPath = Path();
        areaPath.moveTo(points.first.dx, chartSize.height);

        final totalPoints = points.length;
        final animatedPoints = (totalPoints * animationProgress).ceil();

        for (int i = 0; i < animatedPoints && i < points.length; i++) {
          final currentPoint = points[i];
          if (!currentPoint.dx.isFinite || !currentPoint.dy.isFinite) continue;

          if (i == 0) {
            areaPath.lineTo(currentPoint.dx, currentPoint.dy);
          } else {
            final prevPoint = points[i - 1];
            if (!prevPoint.dx.isFinite || !prevPoint.dy.isFinite) continue;

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

            // Higher smoothness for spline (0.5 vs 0.35 for regular line)
            final controlPoint1 = Offset(
              prevPoint.dx + dx * 0.5,
              prevPoint.dy,
            );
            final controlPoint2 = Offset(
              targetPoint.dx - dx * 0.5,
              targetPoint.dy,
            );

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

        final areaPaint = Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              color.withValues(alpha: 0.4 * animationProgress),
              color.withValues(alpha: 0.15 * animationProgress),
              color.withValues(alpha: 0.0),
            ],
            stops: const [0.0, 0.5, 1.0],
          ).createShader(Rect.fromLTWH(0, 0, chartSize.width, chartSize.height))
          ..style = PaintingStyle.fill;

        canvas.drawPath(areaPath, areaPaint);
      }

      // Draw smooth spline line
      final linePath = Path();
      if (points.isNotEmpty &&
          points.first.dx.isFinite &&
          points.first.dy.isFinite) {
        linePath.moveTo(points.first.dx, points.first.dy);
      }

      final totalPoints = points.length;
      final animatedPoints = (totalPoints * animationProgress).ceil();

      for (int i = 1; i < animatedPoints && i < points.length; i++) {
        final prevPoint = points[i - 1];
        final currentPoint = points[i];

        if (!prevPoint.dx.isFinite ||
            !prevPoint.dy.isFinite ||
            !currentPoint.dx.isFinite ||
            !currentPoint.dy.isFinite) {
          continue;
        }

        final dx = currentPoint.dx - prevPoint.dx;
        if (!dx.isFinite) continue;

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

        // Higher smoothness for spline
        final controlPoint1 = Offset(
          prevPoint.dx + dx * 0.5,
          prevPoint.dy,
        );
        final controlPoint2 = Offset(
          targetPoint.dx - dx * 0.5,
          targetPoint.dy,
        );

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

      final linePaint = Paint()
        ..color = color
        ..strokeWidth = lineWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 1.0);

      canvas.drawPath(linePath, linePaint);

      final overlayPaint = Paint()
        ..color = color.withValues(alpha: 0.6)
        ..strokeWidth = lineWidth * 0.5
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;

      canvas.drawPath(linePath, overlayPaint);

      // Draw points
      if (showPoints) {
        final totalPoints = points.length;
        final animatedPoints = (totalPoints * animationProgress).ceil();

        for (int i = 0; i < animatedPoints && i < points.length; i++) {
          final point = points[i];

          if (!point.dx.isFinite || !point.dy.isFinite) continue;

          final pointOpacity = i < animatedPoints - 1 ? 1.0 : animationProgress;

          // Find the dataset index for this color group
          final datasetIndex = dataSets.indexWhere((ds) => ds.color == color);
          final isSelected = selectedPoint != null &&
              selectedPoint!.isHit &&
              selectedPoint!.datasetIndex == datasetIndex &&
              selectedPoint!.elementIndex == i;

          final isHovered = hoveredPoint != null &&
              hoveredPoint!.isHit &&
              hoveredPoint!.datasetIndex == datasetIndex &&
              hoveredPoint!.elementIndex == i;

          final glowRadius = isSelected ? 10.0 : (isHovered ? 8.0 : 6.0);
          final glowOpacity = isSelected ? 0.4 : (isHovered ? 0.3 : 0.2);
          final glowPaint = Paint()
            ..color =
                color.withValues(alpha: glowOpacity * pointOpacity)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(point, glowRadius, glowPaint);

          final pointRadius = isSelected ? 6.5 : (isHovered ? 5.5 : 4.5);
          final pointPaint = Paint()
            ..color = color.withValues(alpha: pointOpacity)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(point, pointRadius, pointPaint);

          final highlightPaint = Paint()
            ..color = Colors.white.withValues(alpha: 0.8 * pointOpacity)
            ..style = PaintingStyle.fill;
          canvas.drawCircle(point, 2, highlightPaint);

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
  bool shouldRepaint(covariant SplineChartPainter oldDelegate) {
    if (oldDelegate.animationProgress != animationProgress) return true;
    if (oldDelegate.lineWidth != lineWidth) return true;
    if (oldDelegate.showArea != showArea) return true;
    if (oldDelegate.showPoints != showPoints) return true;
    if (oldDelegate.selectedPoint != selectedPoint) return true;
    if (oldDelegate.hoveredPoint != hoveredPoint) return true;

    return super.shouldRepaint(oldDelegate);
  }
}
