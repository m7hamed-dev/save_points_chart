import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';

/// Helper class for detecting chart interactions.
///
/// This utility class provides optimized static methods to detect taps and
/// hovers on various chart elements such as points, bars, segments, and shapes.
///
/// All methods include comprehensive input validation to prevent NaN and
/// Infinity errors, and use efficient algorithms (e.g., squared distance
/// calculations) for better performance.
///
/// ## Performance
/// - Uses squared distance calculations to avoid expensive sqrt operations
/// - Early exit optimizations for bounds checking
/// - Single-pass algorithms where possible
/// - Comprehensive input validation
/// - Cached calculations where applicable
///
/// ## Example
/// ```dart
/// final result = ChartInteractionHelper.findNearestPoint(
///   tapPosition,
///   dataSets,
///   chartSize,
///   minX, maxX, minY, maxY,
///   ChartInteractionConstants.tapRadius,
/// );
///
/// if (result != null && result.isHit) {
///   print('Tapped: ${result.point!.y}');
/// }
/// ```
///
/// See also:
/// - [ChartInteractionResult] for interaction results
/// - [ChartInteractionConstants] for interaction configuration
class ChartInteractionHelper {
  // Constants for chart calculations
  static const double _defaultPadding = 40.0;
  static const double _defaultRadiusOffset = 20.0;
  static const double _radarRadiusOffset = 60.0;
  static const double _pyramidTopWidthRatio = 0.3;
  static const double _funnelBottomWidthRatio = 0.3;

  // Validation helpers

  /// Validates that a size is finite and positive.
  static bool _isValidSize(Size size) {
    return size.width.isFinite &&
        size.height.isFinite &&
        size.width > 0 &&
        size.height > 0;
  }

  /// Validates that a position is finite.
  static bool _isValidPosition(Offset position) {
    return position.dx.isFinite && position.dy.isFinite;
  }

  /// Validates that bounds are finite and form a valid range.
  static bool _isValidBounds(
    double minX,
    double maxX,
    double minY,
    double maxY,
  ) {
    if (!minX.isFinite || !maxX.isFinite || !minY.isFinite || !maxY.isFinite) {
      return false;
    }
    final xRange = maxX - minX;
    final yRange = maxY - minY;
    return xRange > 0 && yRange > 0 && xRange.isFinite && yRange.isFinite;
  }

  /// Validates that a value is finite and positive.
  static bool _isValidPositiveValue(double value) {
    return value.isFinite && value > 0;
  }

  /// Validates that a point has finite coordinates.
  static bool _isValidPoint(ChartDataPoint point) {
    return point.x.isFinite && point.y.isFinite;
  }

  // Coordinate conversion helpers

  /// Converts a data point to canvas coordinates.
  ///
  /// Returns null if the conversion results in invalid coordinates.
  static Offset? _toCanvasCoordinates(
    ChartDataPoint point,
    Size chartSize,
    double minX,
    double maxX,
    double minY,
    double maxY,
  ) {
    if (!_isValidPoint(point)) return null;

    final xRange = maxX - minX;
    final yRange = maxY - minY;
    if (xRange == 0 || yRange == 0) return null;

    final canvasX = ((point.x - minX) / xRange) * chartSize.width;
    final canvasY =
        chartSize.height - ((point.y - minY) / yRange) * chartSize.height;

    if (!canvasX.isFinite || !canvasY.isFinite) return null;
    return Offset(canvasX, canvasY);
  }

  /// Calculates squared distance between two points (avoids sqrt).
  ///
  /// Returns null if the calculation results in invalid values.
  static double? _squaredDistance(Offset p1, Offset p2) {
    final dx = p1.dx - p2.dx;
    final dy = p1.dy - p2.dy;
    if (!dx.isFinite || !dy.isFinite) return null;
    final distanceSquared = dx * dx + dy * dy;
    return distanceSquared.isFinite ? distanceSquared : null;
  }

  /// Quick bounds check to determine if a point might be within radius.
  ///
  /// Uses Manhattan distance for faster rejection before calculating
  /// Euclidean distance.
  static bool _isWithinQuickBounds(
    Offset tapPosition,
    Offset point,
    double radius,
  ) {
    final dx = (tapPosition.dx - point.dx).abs();
    final dy = (tapPosition.dy - point.dy).abs();
    return dx <= radius && dy <= radius;
  }

  /// Find nearest point to tap location (optimized with early exit and squared distance).
  ///
  /// Searches through all data sets to find the point closest to the tap position
  /// within the specified tap radius. Uses squared distance calculations for
  /// better performance and includes comprehensive input validation.
  ///
  /// ## Algorithm
  /// 1. Validates all inputs (bounds, size, position)
  /// 2. Converts each data point to canvas coordinates
  /// 3. Uses quick bounds check before distance calculation
  /// 4. Calculates squared distance (avoids sqrt)
  /// 5. Returns the nearest point within radius
  ///
  /// ## Performance
  /// - O(n) where n is total number of points across all datasets
  /// - Early exit for points clearly outside radius
  /// - Squared distance avoids expensive sqrt operation
  ///
  /// Parameters:
  /// - [tapPosition] - The position where the user tapped (in chart coordinates)
  /// - [dataSets] - List of chart data sets to search through (must not be empty)
  /// - [chartSize] - Size of the chart area (must be positive and finite)
  /// - [minX], [maxX], [minY], [maxY] - Data bounds for coordinate conversion (must be finite)
  /// - [tapRadius] - Maximum distance from tap position to consider a hit (must be positive)
  ///
  /// Returns a [ChartInteractionResult] if a point is found within [tapRadius],
  /// null otherwise. The result includes the point, dataset index, and element index.
  ///
  /// ## Example
  /// ```dart
  /// final result = ChartInteractionHelper.findNearestPoint(
  ///   Offset(100, 150),
  ///   dataSets,
  ///   Size(400, 300),
  ///   0, 100, 0, 50,
  ///   20.0,
  /// );
  ///
  /// if (result != null && result.isHit) {
  ///   print('Found point: ${result.point!.y}');
  /// }
  /// ```
  ///
  /// Throws no exceptions, but returns null for invalid inputs.
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

    // Validate inputs using helper methods
    if (!_isValidSize(chartSize) ||
        !_isValidPosition(tapPosition) ||
        !_isValidBounds(minX, maxX, minY, maxY) ||
        !_isValidPositiveValue(tapRadius)) {
      return null;
    }

    // Pre-calculate squared radius to avoid repeated multiplication
    final tapRadiusSquared = tapRadius * tapRadius;
    double minDistanceSquared = double.infinity;
    ChartInteractionResult? nearestResult;

    for (int dsIndex = 0; dsIndex < dataSets.length; dsIndex++) {
      final dataSet = dataSets[dsIndex];
      final point = dataSet.dataPoint;

      // Convert to canvas coordinates using helper
      final canvasPoint = _toCanvasCoordinates(
        point,
        chartSize,
        minX,
        maxX,
        minY,
        maxY,
      );
      if (canvasPoint == null) continue;

      // Quick bounds check before distance calculation
      if (!_isWithinQuickBounds(tapPosition, canvasPoint, tapRadius)) {
        continue;
      }

      // Calculate squared distance using helper
      final distanceSquared = _squaredDistance(tapPosition, canvasPoint);
      if (distanceSquared == null) continue;

      // Update nearest result if closer
      if (distanceSquared < tapRadiusSquared &&
          distanceSquared < minDistanceSquared) {
        minDistanceSquared = distanceSquared;
        nearestResult = ChartInteractionResult(
          point: point,
          datasetIndex: dsIndex,
          elementIndex: 0,
          isHit: true,
        );
      }
    }

    return nearestResult;
  }

  /// Find bar at tap location (optimized with early exit).
  ///
  /// Searches through all data sets to find the bar containing the tap position.
  /// Uses efficient bounds checking and coordinate conversion.
  ///
  /// Parameters:
  /// - [tapPosition] - The position where the user tapped
  /// - [dataSets] - List of chart data sets to search through
  /// - [chartSize] - Size of the chart area
  /// - [minX], [maxX], [minY], [maxY] - Data bounds for coordinate conversion
  /// - [barWidth] - Width of each bar in canvas coordinates
  ///
  /// Returns a [ChartInteractionResult] if a bar is found, null otherwise.
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

    // Validate inputs using helper methods
    if (!_isValidSize(chartSize) ||
        !_isValidPosition(tapPosition) ||
        !_isValidBounds(minX, maxX, minY, maxY) ||
        !_isValidPositiveValue(barWidth) ||
        !_isValidPositiveValue(maxY)) {
      return null;
    }

    final xRange = maxX - minX;
    if (xRange == 0 || !xRange.isFinite) return null;

    // Pre-calculate half bar width and cache chart height
    final halfBarWidth = barWidth / 2;
    final chartHeight = chartSize.height;

    for (int dsIndex = 0; dsIndex < dataSets.length; dsIndex++) {
      final dataSet = dataSets[dsIndex];
      final point = dataSet.dataPoint;

      // Validate point values
      if (!_isValidPoint(point)) continue;

      // Calculate bar horizontal position
      final canvasX = ((point.x - minX) / xRange) * chartSize.width;
      if (!canvasX.isFinite) continue;

      // Early exit if tap is clearly to the left or right of bar
      if (tapPosition.dx < canvasX - halfBarWidth ||
          tapPosition.dx > canvasX + halfBarWidth) {
        continue;
      }

      // Calculate bar vertical position
      final barHeight = (point.y / maxY) * chartHeight;
      if (!barHeight.isFinite) continue;

      final barY = chartHeight - barHeight;
      if (!barY.isFinite) continue;

      // Check if tap is within bar vertical bounds
      if (tapPosition.dy >= barY && tapPosition.dy <= chartHeight) {
        return ChartInteractionResult(
          point: point,
          datasetIndex: dsIndex,
          elementIndex: 0,
          isHit: true,
        );
      }
    }

    return null;
  }

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
  /// - [centerSpaceRadius] - Inner radius for donut charts (0 for pie charts)
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
    if (!_isValidSize(size) || !_isValidPosition(tapPosition)) {
      return null;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - _defaultRadiusOffset;

    // Validate radius
    if (!_isValidPositiveValue(radius)) return null;

    // Check if tap is within chart bounds using squared distance
    final distanceSquared = _squaredDistance(tapPosition, center);
    if (distanceSquared == null) return null;

    final centerSpaceRadiusSquared = centerSpaceRadius * centerSpaceRadius;
    final radiusSquared = radius * radius;

    if (distanceSquared < centerSpaceRadiusSquared ||
        distanceSquared > radiusSquared) {
      return null;
    }

    // Calculate total value
    final total = data.fold<double>(0.0, (sum, item) => sum + item.value);
    if (!_isValidPositiveValue(total)) return null;

    // Pre-calculate constants
    const startAngleOffset = -math.pi / 2;
    const twoPi = 2 * math.pi;

    double startAngle = startAngleOffset;

    // Calculate angle from center to tap point
    final dx = tapPosition.dx - center.dx;
    final dy = tapPosition.dy - center.dy;
    final tapAngle = math.atan2(dy, dx);
    // Normalize to 0-2π range
    final normalizedAngle = (tapAngle + twoPi) % twoPi;

    // Pre-calculate value-to-angle conversion factor
    final valueToAngle = twoPi / total;

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final sweepAngle = item.value * valueToAngle;
      final endAngle = startAngle + sweepAngle;

      // Normalize start and end angles
      final normalizedStart = (startAngle + twoPi) % twoPi;
      final normalizedEnd = (endAngle + twoPi) % twoPi;

      // Check if tap angle is within segment
      final isInSegment = normalizedEnd > normalizedStart
          ? normalizedAngle >= normalizedStart &&
              normalizedAngle <= normalizedEnd
          : normalizedAngle >= normalizedStart ||
              normalizedAngle <= normalizedEnd;

      if (isInSegment) {
        return ChartInteractionResult(
          segment: item,
          datasetIndex: 0, // Pie charts have a single dataset
          elementIndex: i,
          isHit: true,
        );
      }

      startAngle = endAngle;
    }

    return null;
  }

  /// Find pyramid chart segment at tap location.
  ///
  /// Determines which segment of a pyramid chart contains the tap position
  /// by checking if the point is within the trapezoid shape of each segment.
  ///
  /// Parameters:
  /// - [tapPosition] - The position where the user tapped
  /// - [data] - List of pie data segments (used for pyramid data)
  /// - [size] - Size of the chart area
  /// - [animationProgress] - Animation progress (0.0 to 1.0)
  ///
  /// Returns a [ChartInteractionResult] if a segment is found, null otherwise.
  static ChartInteractionResult? findPyramidSegment(
    Offset tapPosition,
    List<PieData> data,
    Size size,
    double animationProgress,
  ) {
    if (data.isEmpty) return null;
    if (!_isValidSize(size) || !_isValidPosition(tapPosition)) {
      return null;
    }
    if (!animationProgress.isFinite ||
        animationProgress < 0.0 ||
        animationProgress > 1.0) {
      return null;
    }

    // Sort data by value (largest to smallest for pyramid)
    final sortedData = List<PieData>.from(data)
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = sortedData.fold<double>(0.0, (sum, item) => sum + item.value);
    if (!_isValidPositiveValue(total)) return null;

    final chartWidth = size.width - _defaultPadding * 2;
    final chartHeight = size.height - _defaultPadding * 2;
    final centerX = size.width / 2;

    // Validate chart dimensions after padding
    if (chartWidth <= 0 || chartHeight <= 0) return null;

    final baseWidth = chartWidth;
    final topWidth = chartWidth * _pyramidTopWidthRatio;
    final widthDifference = baseWidth - topWidth;

    double cumulativeHeight = 0.0;

    for (int i = 0; i < sortedData.length; i++) {
      final segment = sortedData[i];
      final percentage = segment.value / total;
      final segmentHeight = chartHeight * percentage * animationProgress;

      final currentY = cumulativeHeight;
      final nextY = cumulativeHeight + segmentHeight;

      final progress = currentY / chartHeight;
      final nextProgress = nextY / chartHeight;
      final currentWidth = baseWidth - widthDifference * progress;
      final nextWidth = baseWidth - widthDifference * nextProgress;

      // Check if tap is within trapezoid bounds
      final topLeft =
          Offset(centerX - currentWidth / 2, _defaultPadding + currentY);
      final topRight =
          Offset(centerX + currentWidth / 2, _defaultPadding + currentY);
      final bottomRight =
          Offset(centerX + nextWidth / 2, _defaultPadding + nextY);
      final bottomLeft =
          Offset(centerX - nextWidth / 2, _defaultPadding + nextY);

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
          datasetIndex: 0, // Pyramid charts have a single dataset
          elementIndex: originalIndex >= 0 ? originalIndex : i,
          isHit: true,
        );
      }

      cumulativeHeight += segmentHeight;
    }

    return null;
  }

  /// Find funnel chart segment at tap location.
  ///
  /// Determines which segment of a funnel chart contains the tap position
  /// by checking if the point is within the trapezoid shape of each segment.
  ///
  /// Parameters:
  /// - [tapPosition] - The position where the user tapped
  /// - [data] - List of pie data segments (used for funnel data)
  /// - [size] - Size of the chart area
  /// - [animationProgress] - Animation progress (0.0 to 1.0)
  ///
  /// Returns a [ChartInteractionResult] if a segment is found, null otherwise.
  static ChartInteractionResult? findFunnelSegment(
    Offset tapPosition,
    List<PieData> data,
    Size size,
    double animationProgress,
  ) {
    if (data.isEmpty) return null;
    if (!_isValidSize(size) || !_isValidPosition(tapPosition)) {
      return null;
    }
    if (!animationProgress.isFinite ||
        animationProgress < 0.0 ||
        animationProgress > 1.0) {
      return null;
    }

    // Sort data by value (largest to smallest for funnel)
    final sortedData = List<PieData>.from(data)
      ..sort((a, b) => b.value.compareTo(a.value));

    final total = sortedData.fold<double>(0.0, (sum, item) => sum + item.value);
    if (!_isValidPositiveValue(total)) return null;

    final chartWidth = size.width - _defaultPadding * 2;
    final chartHeight = size.height - _defaultPadding * 2;
    final centerX = size.width / 2;

    // Validate chart dimensions after padding
    if (chartWidth <= 0 || chartHeight <= 0) return null;

    final topWidth = chartWidth;
    final bottomWidth = chartWidth * _funnelBottomWidthRatio;
    final widthDifference = topWidth - bottomWidth;

    double cumulativeHeight = 0.0;

    for (int i = 0; i < sortedData.length; i++) {
      final segment = sortedData[i];
      final percentage = segment.value / total;
      final segmentHeight = chartHeight * percentage * animationProgress;

      final currentY = cumulativeHeight;
      final nextY = cumulativeHeight + segmentHeight;

      final progress = currentY / chartHeight;
      final nextProgress = nextY / chartHeight;
      final currentWidth = topWidth - widthDifference * progress;
      final nextWidth = topWidth - widthDifference * nextProgress;

      // Check if tap is within trapezoid bounds
      final topLeft =
          Offset(centerX - currentWidth / 2, _defaultPadding + currentY);
      final topRight =
          Offset(centerX + currentWidth / 2, _defaultPadding + currentY);
      final bottomRight =
          Offset(centerX + nextWidth / 2, _defaultPadding + nextY);
      final bottomLeft =
          Offset(centerX - nextWidth / 2, _defaultPadding + nextY);

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
          datasetIndex: 0, // Funnel charts have a single dataset
          elementIndex: originalIndex >= 0 ? originalIndex : i,
          isHit: true,
        );
      }

      cumulativeHeight += segmentHeight;
    }

    return null;
  }

  /// Check if a point is inside a trapezoid using linear interpolation.
  ///
  /// Uses vertical bounds checking and linear interpolation to determine
  /// if a point falls within the trapezoid shape.
  ///
  /// Parameters:
  /// - [point] - The point to check
  /// - [topLeft], [topRight], [bottomRight], [bottomLeft] - Trapezoid vertices
  ///
  /// Returns true if the point is inside the trapezoid, false otherwise.
  static bool _isPointInTrapezoid(
    Offset point,
    Offset topLeft,
    Offset topRight,
    Offset bottomRight,
    Offset bottomLeft,
  ) {
    // Quick vertical bounds check
    final minY = math.min(
      math.min(topLeft.dy, topRight.dy),
      math.min(bottomLeft.dy, bottomRight.dy),
    );
    final maxY = math.max(
      math.max(topLeft.dy, topRight.dy),
      math.max(bottomLeft.dy, bottomRight.dy),
    );

    if (point.dy < minY || point.dy > maxY) return false;

    // Calculate left and right edges at this Y position using linear interpolation
    final leftDy = bottomLeft.dy - topLeft.dy;
    if (leftDy.abs() < 1e-10) {
      // Vertical left edge
      final leftX = topLeft.dx;
      final rightDy = bottomRight.dy - topRight.dy;
      if (rightDy.abs() < 1e-10) {
        // Both edges vertical
        return point.dx >= math.min(leftX, topRight.dx) &&
            point.dx <= math.max(leftX, topRight.dx);
      }
      final t2 = (point.dy - topRight.dy) / rightDy;
      if (!t2.isFinite) return false;
      final rightX = topRight.dx + (bottomRight.dx - topRight.dx) * t2;
      return point.dx >= math.min(leftX, rightX) &&
          point.dx <= math.max(leftX, rightX);
    }

    final t = (point.dy - topLeft.dy) / leftDy;
    if (!t.isFinite) return false;
    final leftX = topLeft.dx + (bottomLeft.dx - topLeft.dx) * t;

    final rightDy = bottomRight.dy - topRight.dy;
    if (rightDy.abs() < 1e-10) {
      // Vertical right edge
      final rightX = topRight.dx;
      return point.dx >= math.min(leftX, rightX) &&
          point.dx <= math.max(leftX, rightX);
    }

    final t2 = (point.dy - topRight.dy) / rightDy;
    if (!t2.isFinite) return false;
    final rightX = topRight.dx + (bottomRight.dx - topRight.dx) * t2;

    // Check if point X is between left and right edges
    return point.dx >= math.min(leftX, rightX) &&
        point.dx <= math.max(leftX, rightX);
  }

  /// Find radar chart point at tap location.
  ///
  /// Searches through all radar data sets to find the point closest to the tap position
  /// within the specified tap radius. Radar charts have points arranged in a circle.
  ///
  /// Parameters:
  /// - [tapPosition] - The position where the user tapped
  /// - [dataSets] - List of radar data sets to search through
  /// - [size] - Size of the chart area
  /// - [maxValue] - Maximum value for scaling radar points
  /// - [animationProgress] - Animation progress value (0.0 to 1.0)
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
    if (!_isValidSize(size) || !_isValidPosition(tapPosition)) {
      return null;
    }
    if (!_isValidPositiveValue(maxValue) ||
        !animationProgress.isFinite ||
        animationProgress < 0.0 ||
        animationProgress > 1.0) {
      return null;
    }

    final firstDataSet = dataSets.first;
    // Note: RadarDataSet has dataPoints property (list), not dataPoint
    // This matches the usage in radar_chart_painter.dart
    final numAxes = firstDataSet.dataPoints.length;
    if (numAxes < 3) return null;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - _radarRadiusOffset;
    if (!_isValidPositiveValue(radius)) return null;

    // Pre-calculate constants
    final tapRadius = ChartInteractionConstants.tapRadius;
    final tapRadiusSquared = tapRadius * tapRadius;
    const piOver2 = math.pi / 2;
    const twoPi = 2 * math.pi;
    final angleStep = twoPi / numAxes;

    double minDistanceSquared = double.infinity;
    ChartInteractionResult? nearestResult;

    for (int dsIndex = 0; dsIndex < dataSets.length; dsIndex++) {
      final dataSet = dataSets[dsIndex];
      if (dataSet.dataPoints.length != numAxes) continue;

      for (int ptIndex = 0; ptIndex < numAxes; ptIndex++) {
        final radarPoint = dataSet.dataPoints[ptIndex];
        if (!radarPoint.value.isFinite) continue;

        // Calculate angle and point position
        final angle = angleStep * ptIndex - piOver2;
        final value = radarPoint.value.clamp(0.0, maxValue);
        final normalizedValue = (value / maxValue) * animationProgress;
        final pointRadius = radius * normalizedValue;

        final point = Offset(
          center.dx + pointRadius * math.cos(angle),
          center.dy + pointRadius * math.sin(angle),
        );

        // Quick bounds check before distance calculation
        if (!_isWithinQuickBounds(tapPosition, point, tapRadius)) {
          continue;
        }

        // Calculate squared distance using helper
        final distanceSquared = _squaredDistance(tapPosition, point);
        if (distanceSquared == null) continue;

        // Update nearest result if closer
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
