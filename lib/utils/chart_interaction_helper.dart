import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';

/// Helper class for detecting chart interactions
class ChartInteractionHelper {
  /// Find nearest point to tap location (optimized with early exit and squared distance)
  static ChartInteractionResult? findNearestPoint(
    Offset tapPosition,
    List<ChartDataSet> dataSets,
    Size chartSize,
    double minX,
    double maxX,
    double minY,
    double maxY,
    double tapRadius,
  ) {
    // Early exit if no data
    if (dataSets.isEmpty) return null;

    // Validate bounds (check for NaN or Infinity)
    if (!minX.isFinite || !maxX.isFinite || !minY.isFinite || !maxY.isFinite) {
      return null;
    }

    final xRange = maxX - minX;
    final yRange = maxY - minY;
    if (xRange == 0 || yRange == 0 || !xRange.isFinite || !yRange.isFinite) {
      return null;
    }

    // Validate chart size
    if (!chartSize.width.isFinite ||
        !chartSize.height.isFinite ||
        chartSize.width <= 0 ||
        chartSize.height <= 0) {
      return null;
    }

    // Validate tap position
    if (!tapPosition.dx.isFinite || !tapPosition.dy.isFinite) {
      return null;
    }

    // Use squared distance to avoid expensive sqrt calculation
    final tapRadiusSquared = tapRadius * tapRadius;
    double minDistanceSquared = double.infinity;
    ChartInteractionResult? nearestResult;

    for (int dsIndex = 0; dsIndex < dataSets.length; dsIndex++) {
      final dataSet = dataSets[dsIndex];
      if (dataSet.dataPoints.isEmpty) continue;

      for (int ptIndex = 0; ptIndex < dataSet.dataPoints.length; ptIndex++) {
        final point = dataSet.dataPoints[ptIndex];

        // Validate point values
        if (!point.x.isFinite || !point.y.isFinite) continue;

        // Convert to canvas coordinates with NaN protection
        final canvasX = ((point.x - minX) / xRange) * chartSize.width;
        final canvasY =
            chartSize.height - ((point.y - minY) / yRange) * chartSize.height;

        // Validate calculated coordinates
        if (!canvasX.isFinite || !canvasY.isFinite) continue;

        // Quick bounds check before distance calculation
        final dx = tapPosition.dx - canvasX;
        final dy = tapPosition.dy - canvasY;

        // Validate dx and dy
        if (!dx.isFinite || !dy.isFinite) continue;

        // Early exit if point is clearly outside radius
        if (dx.abs() > tapRadius || dy.abs() > tapRadius) continue;

        // Calculate squared distance (faster than distance)
        final distanceSquared = dx * dx + dy * dy;

        // Validate distance
        if (!distanceSquared.isFinite) continue;

        if (distanceSquared < tapRadiusSquared &&
            distanceSquared < minDistanceSquared) {
          minDistanceSquared = distanceSquared;
          nearestResult = ChartInteractionResult(
            point: point,
            datasetIndex: dsIndex,
            elementIndex: ptIndex,
            isHit: true,
          );
        }
      }
    }

    return nearestResult;
  }

  /// Find bar at tap location (optimized with early exit)
  static ChartInteractionResult? findBar(
    Offset tapPosition,
    List<ChartDataSet> dataSets,
    Size chartSize,
    double minX,
    double maxX,
    double minY,
    double maxY,
    double barWidth,
  ) {
    // Early exit if no data
    if (dataSets.isEmpty) return null;

    // Validate bounds (check for NaN or Infinity)
    if (!minX.isFinite || !maxX.isFinite || !minY.isFinite || !maxY.isFinite) {
      return null;
    }

    // Validate chart size
    if (!chartSize.width.isFinite ||
        !chartSize.height.isFinite ||
        chartSize.width <= 0 ||
        chartSize.height <= 0) {
      return null;
    }

    // Validate tap position
    if (!tapPosition.dx.isFinite || !tapPosition.dy.isFinite) {
      return null;
    }

    // Validate bar width
    if (!barWidth.isFinite || barWidth <= 0) return null;

    final xRange = maxX - minX;
    if (xRange == 0 || !xRange.isFinite) return null;

    // Pre-calculate half bar width
    final halfBarWidth = barWidth / 2;

    for (int dsIndex = 0; dsIndex < dataSets.length; dsIndex++) {
      final dataSet = dataSets[dsIndex];
      if (dataSet.dataPoints.isEmpty) continue;

      for (int barIndex = 0; barIndex < dataSet.dataPoints.length; barIndex++) {
        final point = dataSet.dataPoints[barIndex];

        // Validate point values
        if (!point.x.isFinite || !point.y.isFinite) continue;

        // Calculate bar position with NaN protection
        final canvasX = ((point.x - minX) / xRange) * chartSize.width;

        // Validate calculated position
        if (!canvasX.isFinite) continue;

        // Early exit if tap is clearly to the left or right of bar
        if (tapPosition.dx < canvasX - halfBarWidth ||
            tapPosition.dx > canvasX + halfBarWidth) {
          continue;
        }

        // Validate maxY before division
        if (maxY <= 0 || !maxY.isFinite) continue;

        final barHeight = (point.y / maxY) * chartSize.height;
        if (!barHeight.isFinite) continue;

        final barY = chartSize.height - barHeight;
        if (!barY.isFinite) continue;

        // Check if tap is within bar vertical bounds
        if (tapPosition.dy >= barY && tapPosition.dy <= chartSize.height) {
          return ChartInteractionResult(
            point: point,
            datasetIndex: dsIndex,
            elementIndex: barIndex,
            isHit: true,
          );
        }
      }
    }

    return null;
  }

  /// Find pie segment at tap location
  static ChartInteractionResult? findPieSegment(
    Offset tapPosition,
    List<PieData> data,
    Size size,
    double centerSpaceRadius,
  ) {
    // Validate inputs
    if (data.isEmpty) return null;
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= 0) {
      return null;
    }
    if (!tapPosition.dx.isFinite || !tapPosition.dy.isFinite) {
      return null;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

    // Validate radius
    if (radius <= 0 || !radius.isFinite) return null;

    // Check if tap is within chart bounds
    final distanceFromCenter = (tapPosition - center).distance;
    if (!distanceFromCenter.isFinite) return null;
    if (distanceFromCenter < centerSpaceRadius || distanceFromCenter > radius) {
      return null;
    }

    final total = data.map((d) => d.value).reduce((a, b) => a + b);
    if (total <= 0 || !total.isFinite) return null;

    double startAngle = -math.pi / 2;

    // Calculate angle from center to tap point
    final dx = tapPosition.dx - center.dx;
    final dy = tapPosition.dy - center.dy;
    final tapAngle = math.atan2(dy, dx);
    // Normalize to 0-2π range starting from top
    final normalizedAngle =
        (tapAngle + math.pi / 2 + 2 * math.pi) % (2 * math.pi);

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final sweepAngle = (item.value / total) * 2 * math.pi;
      final endAngle = startAngle + sweepAngle;

      // Normalize start and end angles
      final normalizedStart = (startAngle + 2 * math.pi) % (2 * math.pi);
      final normalizedEnd = (endAngle + 2 * math.pi) % (2 * math.pi);

      // Check if tap angle is within segment
      bool isInSegment = false;
      if (normalizedEnd > normalizedStart) {
        isInSegment = normalizedAngle >= normalizedStart &&
            normalizedAngle <= normalizedEnd;
      } else {
        // Segment wraps around
        isInSegment = normalizedAngle >= normalizedStart ||
            normalizedAngle <= normalizedEnd;
      }

      if (isInSegment) {
        return ChartInteractionResult(
          segment: item,
          elementIndex: i,
          isHit: true,
        );
      }

      startAngle = endAngle;
    }

    return null;
  }
}
