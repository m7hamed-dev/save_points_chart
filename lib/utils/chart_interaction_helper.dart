import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';

/// Helper class for detecting chart interactions.
///
/// This class provides static methods to detect taps and hovers on various
/// chart elements such as points, bars, segments, and shapes.
class ChartInteractionHelper {
  /// Find nearest point to tap location (optimized with early exit and squared distance).
  ///
  /// Searches through all data sets to find the point closest to the tap position
  /// within the specified tap radius. Returns null if no point is found.
  ///
  /// Parameters:
  /// - [tapPosition] - The position where the user tapped
  /// - [dataSets] - List of chart data sets to search through
  /// - [chartSize] - Size of the chart area
  /// - [minX], [maxX], [minY], [maxY] - Data bounds for coordinate conversion
  /// - [tapRadius] - Maximum distance from tap position to consider a hit
  ///
  /// Returns a [ChartInteractionResult] if a point is found, null otherwise.
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
  /// Find pie/donut chart segment at tap location.
  ///
  /// Determines which segment of a pie or donut chart contains the tap position
  /// by calculating the angle from the center. Returns null if tap is outside
  /// the chart or in the center hole (for donut charts).
  ///
  /// Parameters:
  /// - [tapPosition] - The position where the user tapped
  /// - [data] - List of pie data segments
  /// - [size] - Size of the chart area
  /// - [center] - Center point of the pie chart
  /// - [radius] - Radius of the pie chart
  /// - [innerRadius] - Inner radius for donut charts (0 for pie charts)
  ///
  /// Returns a [ChartInteractionResult] if a segment is found, null otherwise.
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

  /// Find pyramid segment at tap location
  /// Find pyramid chart segment at tap location.
  ///
  /// Determines which segment of a pyramid chart contains the tap position
  /// by checking if the point is within the trapezoid shape of each segment.
  ///
  /// Parameters:
  /// - [tapPosition] - The position where the user tapped
  /// - [data] - List of pie data segments (used for pyramid data)
  /// - [size] - Size of the chart area
  ///
  /// Returns a [ChartInteractionResult] if a segment is found, null otherwise.
  static ChartInteractionResult? findPyramidSegment(
    Offset tapPosition,
    List<PieData> data,
    Size size,
    double animationProgress,
  ) {
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

    // Sort data by value (largest to smallest for pyramid)
    final sortedData = List<PieData>.from(data)
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = sortedData.fold<double>(0, (sum, item) => sum + item.value);
    if (total <= 0 || !total.isFinite) return null;

    const padding = 40.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;
    final centerX = size.width / 2;

    double cumulativeHeight = 0.0;

    for (int i = 0; i < sortedData.length; i++) {
      final segment = sortedData[i];
      final percentage = segment.value / total;
      final segmentHeight = chartHeight * percentage * animationProgress;

      final baseWidth = chartWidth;
      final topWidth = chartWidth * 0.3;
      final currentY = cumulativeHeight;
      final nextY = cumulativeHeight + segmentHeight;

      final progress = currentY / chartHeight;
      final nextProgress = nextY / chartHeight;
      final currentWidth = baseWidth - (baseWidth - topWidth) * progress;
      final nextWidth = baseWidth - (baseWidth - topWidth) * nextProgress;

      // Check if tap is within trapezoid bounds
      final topLeft = Offset(centerX - currentWidth / 2, padding + currentY);
      final topRight = Offset(centerX + currentWidth / 2, padding + currentY);
      final bottomRight = Offset(centerX + nextWidth / 2, padding + nextY);
      final bottomLeft = Offset(centerX - nextWidth / 2, padding + nextY);

      if (_isPointInTrapezoid(
        tapPosition,
        topLeft,
        topRight,
        bottomRight,
        bottomLeft,
      )) {
        // Find original index in unsorted data
        final originalIndex = data.indexOf(segment);
        return ChartInteractionResult(
          segment: segment,
          elementIndex: originalIndex >= 0 ? originalIndex : i,
          isHit: true,
        );
      }

      cumulativeHeight += segmentHeight;
    }

    return null;
  }

  /// Find funnel segment at tap location
  static ChartInteractionResult? findFunnelSegment(
    Offset tapPosition,
    List<PieData> data,
    Size size,
    double animationProgress,
  ) {
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

    // Sort data by value (largest to smallest for funnel)
    final sortedData = List<PieData>.from(data)
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = sortedData.fold<double>(0, (sum, item) => sum + item.value);
    if (total <= 0 || !total.isFinite) return null;

    const padding = 40.0;
    final chartWidth = size.width - padding * 2;
    final chartHeight = size.height - padding * 2;
    final centerX = size.width / 2;

    double cumulativeHeight = 0.0;

    for (int i = 0; i < sortedData.length; i++) {
      final segment = sortedData[i];
      final percentage = segment.value / total;
      final segmentHeight = chartHeight * percentage * animationProgress;

      final topWidth = chartWidth;
      final bottomWidth = chartWidth * 0.3;
      final currentY = cumulativeHeight;
      final nextY = cumulativeHeight + segmentHeight;

      final progress = currentY / chartHeight;
      final nextProgress = nextY / chartHeight;
      final currentWidth = topWidth - (topWidth - bottomWidth) * progress;
      final nextWidth = topWidth - (topWidth - bottomWidth) * nextProgress;

      // Check if tap is within trapezoid bounds
      final topLeft = Offset(centerX - currentWidth / 2, padding + currentY);
      final topRight = Offset(centerX + currentWidth / 2, padding + currentY);
      final bottomRight = Offset(centerX + nextWidth / 2, padding + nextY);
      final bottomLeft = Offset(centerX - nextWidth / 2, padding + nextY);

      if (_isPointInTrapezoid(
        tapPosition,
        topLeft,
        topRight,
        bottomRight,
        bottomLeft,
      )) {
        // Find original index in unsorted data
        final originalIndex = data.indexOf(segment);
        return ChartInteractionResult(
          segment: segment,
          elementIndex: originalIndex >= 0 ? originalIndex : i,
          isHit: true,
        );
      }

      cumulativeHeight += segmentHeight;
    }

    return null;
  }

  /// Check if a point is inside a trapezoid using cross product method
  static bool _isPointInTrapezoid(
    Offset point,
    Offset topLeft,
    Offset topRight,
    Offset bottomRight,
    Offset bottomLeft,
  ) {
    // Check if point is within vertical bounds
    final minY = math.min(
      math.min(topLeft.dy, topRight.dy),
      math.min(bottomLeft.dy, bottomRight.dy),
    );
    final maxY = math.max(
      math.max(topLeft.dy, topRight.dy),
      math.max(bottomLeft.dy, bottomRight.dy),
    );

    if (point.dy < minY || point.dy > maxY) return false;

    // Calculate left and right edges at this Y position
    final t = (point.dy - topLeft.dy) / (bottomLeft.dy - topLeft.dy);
    if (t.isNaN || !t.isFinite) return false;
    final leftX = topLeft.dx + (bottomLeft.dx - topLeft.dx) * t;

    final t2 = (point.dy - topRight.dy) / (bottomRight.dy - topRight.dy);
    if (t2.isNaN || !t2.isFinite) return false;
    final rightX = topRight.dx + (bottomRight.dx - topRight.dx) * t2;

    // Check if point X is between left and right edges
    return point.dx >= math.min(leftX, rightX) &&
        point.dx <= math.max(leftX, rightX);
  }

  /// Find radar point at tap location
  /// Find radar chart point at tap location.
  ///
  /// Searches through all radar data sets to find the point closest to the tap position
  /// within the specified tap radius. Radar charts have points arranged in a circle.
  ///
  /// Parameters:
  /// - [tapPosition] - The position where the user tapped
  /// - [dataSets] - List of radar data sets to search through
  /// - [size] - Size of the chart area
  /// - [tapRadius] - Maximum distance from tap position to consider a hit
  ///
  /// Returns a [ChartInteractionResult] if a point is found, null otherwise.
  static ChartInteractionResult? findRadarPoint(
    Offset tapPosition,
    List<RadarDataSet> dataSets,
    Size size,
    double maxValue,
    double animationProgress,
  ) {
    if (dataSets.isEmpty) return null;
    if (!size.width.isFinite ||
        !size.height.isFinite ||
        size.width <= 0 ||
        size.height <= 0) {
      return null;
    }
    if (!tapPosition.dx.isFinite || !tapPosition.dy.isFinite) {
      return null;
    }

    final firstDataSet = dataSets.first;
    final numAxes = firstDataSet.dataPoints.length;
    if (numAxes < 3) return null;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 60;
    if (radius <= 0 || !radius.isFinite) return null;

    final tapRadiusSquared = (ChartInteractionConstants.tapRadius *
        ChartInteractionConstants.tapRadius);
    double minDistanceSquared = double.infinity;
    ChartInteractionResult? nearestResult;

    for (int dsIndex = 0; dsIndex < dataSets.length; dsIndex++) {
      final dataSet = dataSets[dsIndex];
      if (dataSet.dataPoints.length != numAxes) continue;

      for (int ptIndex = 0; ptIndex < numAxes; ptIndex++) {
        final radarPoint = dataSet.dataPoints[ptIndex];
        if (!radarPoint.value.isFinite) continue;

        final angle = (2 * math.pi * ptIndex / numAxes) - (math.pi / 2);
        final value = radarPoint.value.clamp(0.0, maxValue);
        final normalizedValue = (value / maxValue) * animationProgress;
        final pointRadius = radius * normalizedValue;

        final point = Offset(
          center.dx + pointRadius * math.cos(angle),
          center.dy + pointRadius * math.sin(angle),
        );

        final dx = tapPosition.dx - point.dx;
        final dy = tapPosition.dy - point.dy;

        if (!dx.isFinite || !dy.isFinite) continue;
        if (dx.abs() > ChartInteractionConstants.tapRadius ||
            dy.abs() > ChartInteractionConstants.tapRadius) {
          continue;
        }

        final distanceSquared = dx * dx + dy * dy;
        if (!distanceSquared.isFinite) continue;

        if (distanceSquared < tapRadiusSquared &&
            distanceSquared < minDistanceSquared) {
          minDistanceSquared = distanceSquared;
          // Convert RadarDataPoint to ChartDataPoint for compatibility
          final chartPoint = ChartDataPoint(
            x: ptIndex.toDouble(),
            y: radarPoint.value,
            label: radarPoint.label,
          );
          nearestResult = ChartInteractionResult(
            point: chartPoint,
            datasetIndex: dsIndex,
            elementIndex: ptIndex,
            isHit: true,
          );
        }
      }
    }

    return nearestResult;
  }
}
