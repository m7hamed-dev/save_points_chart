import 'dart:math' as math;
import 'package:flutter/material.dart';
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

  StackedAreaChartPainter({
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

    // Data is cumulative already, so maxY is simply top layer max.
    for (final dataSet in dataSets) {
      for (final point in dataSet.dataPoints) {
        if (point.x < minX) minX = point.x;
        if (point.x > maxX) maxX = point.x;
        if (point.y > maxY) maxY = point.y;
      }
    }

    if (!minX.isFinite ||
        !maxX.isFinite ||
        !maxY.isFinite ||
        minX == double.infinity) {
      return;
    }

    final minY = 0.0;
    final maxYAdjusted = maxY > 0 ? maxY * 1.1 : 1.0;
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

    // Precompute cumulative paths; dataSets are already cumulative, but
    // we still need previous layer for fill.
    List<Offset>? previousPoints;

    for (int dsIndex = 0; dsIndex < dataSets.length; dsIndex++) {
      final dataSet = dataSets[dsIndex];
      if (dataSet.dataPoints.isEmpty) continue;

      final points = dataSet.dataPoints
          .map((point) => pointToCanvas(
                point,
                chartSize,
                minX - xPadding,
                maxX + xPadding,
                minY,
                maxYAdjusted,
              ),)
          .where((p) => p.dx.isFinite && p.dy.isFinite)
          .toList();

      if (points.isEmpty) continue;

      final totalPoints = points.length;
      final animatedPoints = (totalPoints * animationProgress).ceil();

      // Build upper curve path
      final upperPath = Path();
      upperPath.moveTo(points.first.dx, points.first.dy);

      for (int i = 1; i < animatedPoints && i < points.length; i++) {
        final prevPoint = points[i - 1];
        final currentPoint = points[i];
        final dx = currentPoint.dx - prevPoint.dx;
        if (!dx.isFinite) continue;

        Offset targetPoint = currentPoint;
        if (i == animatedPoints - 1 && animationProgress < 1.0) {
          final partialProgress = (animationProgress * totalPoints) - (i - 1);
          final lerped =
              Offset.lerp(prevPoint, currentPoint, partialProgress) ??
                  currentPoint;
          targetPoint = lerped;
        }

        final cp1 = Offset(prevPoint.dx + dx * curveSmoothness, prevPoint.dy);
        final cp2 = Offset(targetPoint.dx - dx * curveSmoothness, targetPoint.dy);
        upperPath.cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, targetPoint.dx,
            targetPoint.dy,);
      }

      // Build fill path between previous layer and current
      final fillPath = Path();
      final baseline = previousPoints ??
          List.generate(points.length, (i) => Offset(points[i].dx, chartSize.height));

      // Start at first baseline point
      fillPath.moveTo(baseline.first.dx, baseline.first.dy);

      // Upper curve forward
      fillPath.addPath(upperPath, Offset.zero);

      // Baseline backward to close
      for (int i = math.min(animatedPoints, baseline.length) - 1; i >= 0; i--) {
        fillPath.lineTo(baseline[i].dx, baseline[i].dy);
      }
      fillPath.close();

      final color = dataSet.color;
      final areaPaint = Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            color.withValues(alpha: 0.5 * animationProgress),
            color.withValues(alpha: 0.18 * animationProgress),
            color.withValues(alpha: 0.0),
          ],
          stops: const [0.0, 0.6, 1.0],
        ).createShader(Rect.fromLTWH(0, 0, chartSize.width, chartSize.height))
        ..style = PaintingStyle.fill;

      canvas.drawPath(fillPath, areaPaint);

      // Draw outline on top
      final linePaint = Paint()
        ..color = color
        ..strokeWidth = lineWidth
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..strokeJoin = StrokeJoin.round;
      canvas.drawPath(upperPath, linePaint);

      // Points (optional highlight)
      final animatedPts = math.min(animatedPoints, points.length);
      for (int i = 0; i < animatedPts; i++) {
        final point = points[i];
        final isSelected = selectedPoint != null &&
            selectedPoint!.isHit &&
            selectedPoint!.datasetIndex == dsIndex &&
            selectedPoint!.elementIndex == i;
        final isHovered = hoveredPoint != null &&
            hoveredPoint!.isHit &&
            hoveredPoint!.datasetIndex == dsIndex &&
            hoveredPoint!.elementIndex == i;
        final opacity = i < animatedPts - 1 ? 1.0 : animationProgress;
        final radius = isSelected
            ? 6.0
            : isHovered
                ? 5.0
                : 4.0;
        final pointPaint = Paint()
          ..color = color.withValues(alpha: opacity)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(point, radius, pointPaint);

        final borderPaint = Paint()
          ..color = theme.backgroundColor
          ..style = PaintingStyle.stroke
          ..strokeWidth = 1.5;
        canvas.drawCircle(point, radius, borderPaint);
      }

      previousPoints = points;
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

