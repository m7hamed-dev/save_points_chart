import 'package:flutter/material.dart';

/// Represents a single data point in a chart.
///
/// Each point has an x-coordinate (horizontal position) and y-coordinate
/// (vertical value). An optional label can be provided for display purposes.
///
/// This is an immutable value class that represents a single data point
/// in various chart types (line, bar, area, scatter, etc.).
///
/// ## Example
/// ```dart
/// const ChartDataPoint(
///   x: 0,
///   y: 10.5,
///   label: 'January',
/// )
/// 
/// // With custom label rotation
/// ChartDataPoint(
///   x: 1,
///   y: 20.0,
///   label: 'February',
///   xAxisLabelRotation: LabelRotation.diagonalDown, // 45° rotation
/// )
/// ```
///
/// See also:
/// - [ChartDataSet] for collections of data points
/// - [BubbleDataPoint] for bubble charts with size information
class ChartDataPoint {
  /// The x-coordinate (horizontal position) of the data point.
  ///
  /// This value represents the horizontal position on the chart.
  /// It should be a finite number (not NaN or Infinity).
  final double x;

  /// The y-coordinate (vertical value) of the data point.
  ///
  /// This value represents the vertical value on the chart.
  /// It should be a finite number (not NaN or Infinity).
  final double y;

  /// Optional label for the data point (e.g., "Jan", "Q1").
  ///
  /// Used for axis labels, tooltips, and legends. If null, the chart
  /// will use the x or y value as a fallback.
  final String? label;

  /// Optional rotation angle for the X-axis label in radians.
  ///
  /// If provided, this rotation will be used for this specific data point's label.
  /// If null, the chart theme's [xAxisLabelRotation] will be used as fallback.
  /// Common values:
  /// - 0.0: Horizontal labels
  /// - -pi/4 or -45 degrees: Diagonal labels (slanted down)
  /// - -pi/2 or -90 degrees: Vertical labels
  ///
  /// See also:
  /// - [LabelRotation] for common rotation constants
  final double? xAxisLabelRotation;

  /// Creates a chart data point.
  ///
  /// [x] and [y] are required and must be finite numbers.
  /// [label] is optional and can be used for axis labels or tooltips.
  /// [xAxisLabelRotation] is optional and allows per-point label rotation.
  ///
  /// Throws an [AssertionError] if [x] or [y] are not finite.
  const ChartDataPoint({
    required this.x,
    required this.y,
    this.label,
    this.xAxisLabelRotation,
  });

  /// Creates a copy of this data point with the given fields replaced.
  ///
  /// Returns a new [ChartDataPoint] with the same values as this one,
  /// except for the fields that are explicitly provided.
  ChartDataPoint copyWith({
    double? x,
    double? y,
    String? label,
    double? xAxisLabelRotation,
  }) {
    return ChartDataPoint(
      x: x ?? this.x,
      y: y ?? this.y,
      label: label ?? this.label,
      xAxisLabelRotation: xAxisLabelRotation ?? this.xAxisLabelRotation,
    );
  }

  @override
  String toString() =>
      'ChartDataPoint(x: $x, y: $y, label: ${label ?? "null"}, xAxisLabelRotation: ${xAxisLabelRotation ?? "null"})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartDataPoint &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          label == other.label &&
          xAxisLabelRotation == other.xAxisLabelRotation;

  @override
  int get hashCode => Object.hash(x, y, label, xAxisLabelRotation);
}

/// Represents a segment in a pie or donut chart.
///
/// Each segment has a label, a numeric value, and a color for visualization.
/// The percentage is calculated automatically based on the total of all segments.
///
/// This is an immutable value class used for pie, donut, pyramid, and funnel charts.
///
/// ## Example
/// ```dart
/// const PieData(
///   label: 'Mobile',
///   value: 45.0,
///   color: Colors.blue,
/// )
/// ```
///
/// See also:
/// - [ChartDataPoint] for point-based charts
class PieData {
  /// The label displayed in the legend and tooltips.
  ///
  /// Should be a short, descriptive string (e.g., "Mobile", "Desktop").
  final String label;

  /// The numeric value of this segment.
  ///
  /// Must be non-negative and finite. The percentage is calculated automatically
  /// based on the total of all segments. Zero values are allowed but won't
  /// be visible in the chart.
  final double value;

  /// The color used to render this segment.
  ///
  /// This color is used for the segment fill, legend, and tooltips.
  final Color color;

  /// Creates a pie chart segment.
  ///
  /// [label] must not be empty. [value] must be non-negative and finite.
  /// [color] is required for rendering.
  ///
  /// Throws an [AssertionError] if [value] is negative or not finite,
  /// or if [label] is empty.
  const PieData({
    required this.label,
    required this.value,
    required this.color,
  });

  /// Creates a copy of this pie data with the given fields replaced.
  ///
  /// Returns a new [PieData] with the same values as this one,
  /// except for the fields that are explicitly provided.
  PieData copyWith({
    String? label,
    double? value,
    Color? color,
  }) {
    return PieData(
      label: label ?? this.label,
      value: value ?? this.value,
      color: color ?? this.color,
    );
  }

  @override
  String toString() => 'PieData(label: $label, value: $value, color: $color)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PieData &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          value == other.value &&
          color == other.color;

  @override
  int get hashCode => Object.hash(label, value, color);
}

/// Represents a bubble data point with size information.
///
/// Extends [ChartDataPoint] with an additional size property for bubble charts.
/// The size represents the third dimension of data visualization, allowing
/// you to encode three variables (x, y, size) in a single chart.
///
/// ## Example
/// ```dart
/// const BubbleDataPoint(
///   x: 10,
///   y: 20,
///   size: 50,
///   label: 'Product A',
/// )
/// ```
///
/// See also:
/// - [ChartDataPoint] for standard two-dimensional points
/// - [BubbleDataSet] for collections of bubble data points
class BubbleDataPoint extends ChartDataPoint {
  /// The size of the bubble (third dimension).
  ///
  /// This value is used to determine the radius of the bubble.
  /// Must be positive and finite. The actual rendered size will be
  /// scaled based on the min/max size range of the chart.
  final double size;

  /// Creates a bubble data point.
  ///
  /// [x], [y], and [size] are required and must be finite numbers.
  /// [label] and [xAxisLabelRotation] are optional.
  ///
  /// Throws an [AssertionError] if [size] is not positive or not finite.
  const BubbleDataPoint({
    required super.x,
    required super.y,
    required this.size,
    super.label,
    super.xAxisLabelRotation,
  });

  /// Creates a copy of this bubble data point with the given fields replaced.
  ///
  /// Returns a new [BubbleDataPoint] with the same values as this one,
  /// except for the fields that are explicitly provided.
  @override
  BubbleDataPoint copyWith({
    double? x,
    double? y,
    double? size,
    String? label,
    double? xAxisLabelRotation,
  }) {
    return BubbleDataPoint(
      x: x ?? this.x,
      y: y ?? this.y,
      size: size ?? this.size,
      label: label ?? this.label,
      xAxisLabelRotation: xAxisLabelRotation ?? this.xAxisLabelRotation,
    );
  }

  @override
  String toString() =>
      'BubbleDataPoint(x: $x, y: $y, size: $size, label: ${label ?? "null"})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is BubbleDataPoint &&
          runtimeType == other.runtimeType &&
          size == other.size;

  @override
  int get hashCode => Object.hash(super.hashCode, size);
}

/// Represents a collection of bubble data points.
///
/// Similar to [ChartDataSet] but specifically for bubble charts.
/// Contains multiple bubble points that share a label and color.
///
/// ## Example
/// ```dart
/// BubbleDataSet(
///   label: 'Region A',
///   color: Colors.blue,
///   dataPoints: [
///     BubbleDataPoint(x: 10, y: 20, size: 50),
///     BubbleDataPoint(x: 15, y: 25, size: 60),
///   ],
/// )
/// ```
///
/// See also:
/// - [ChartDataSet] for standard two-dimensional data sets
/// - [BubbleDataPoint] for individual bubble points
class BubbleDataSet {
  /// The label for this data set (displayed in legends and tooltips).
  ///
  /// Should be a descriptive name for the data set (e.g., "Region A",
  /// "Team 1"). Must not be empty.
  final String label;

  /// The color used to render the bubbles in this data set.
  ///
  /// Applied to all bubbles in this set. Use distinct colors for each
  /// data set to improve readability.
  final Color color;

  /// The list of bubble data points in this data set.
  ///
  /// Each point represents one bubble on the chart.
  final List<BubbleDataPoint> dataPoints;

  /// Creates a bubble data set.
  ///
  /// [label] must not be empty. [color] is required for rendering.
  /// [dataPoints] is required and must not be empty.
  ///
  /// Throws an [AssertionError] if [label] is empty or [dataPoints] is empty.
  BubbleDataSet({
    required this.label,
    required this.color,
    required this.dataPoints,
  })  : assert(
          label.isNotEmpty,
          'BubbleDataSet label must not be empty',
        ),
        assert(
          dataPoints.isNotEmpty,
          'BubbleDataSet dataPoints must not be empty',
        );

  /// Creates a copy of this bubble data set with the given fields replaced.
  ///
  /// Returns a new [BubbleDataSet] with the same values as this one,
  /// except for the fields that are explicitly provided.
  BubbleDataSet copyWith({
    String? label,
    Color? color,
    List<BubbleDataPoint>? dataPoints,
  }) {
    return BubbleDataSet(
      label: label ?? this.label,
      color: color ?? this.color,
      dataPoints: dataPoints ?? this.dataPoints,
    );
  }

  @override
  String toString() =>
      'BubbleDataSet(label: $label, color: $color, dataPoints: $dataPoints)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BubbleDataSet &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          color == other.color &&
          dataPoints == other.dataPoints;

  @override
  int get hashCode => Object.hash(label, color, dataPoints);
}

/// Represents a single data point in a chart.
///
/// Each [ChartDataSet] represents one data point with a label and color.
/// Multiple [ChartDataSet] instances can be used to create charts with
/// multiple points, where each dataset represents one point.
///
/// This is the primary data structure for line, bar, area, scatter, and
/// other point-based charts.
///
/// ## Example
/// ```dart
/// ChartDataSet(
///   color: Colors.blue,
///   label: 'January',
///   dataPoint: ChartDataPoint(x: 1, y: 20),
/// )
/// ```
///
/// See also:
/// - [ChartDataPoint] for individual data points
/// - [BubbleDataSet] for bubble charts
/// - [RadarDataSet] for radar charts
class ChartDataSet {
  /// The label for this data point (displayed in legends and tooltips).
  ///
  /// Should be a descriptive name for the data point (e.g., "January",
  /// "Q1", "Sales"). Must not be empty.
  final String label;

  /// The single data point in this dataset.
  ///
  /// Each dataset represents one point on the chart.
  final ChartDataPoint dataPoint;

  /// The color used to render this data point.
  ///
  /// Applied to lines, bars, areas, and points. For multi-point charts,
  /// use distinct colors for each dataset to improve readability.
  final Color color;

  /// Creates a chart data set.
  ///
  /// [label] must not be empty. [dataPoint] is required.
  /// [color] is required for rendering.
  ///
  /// Throws an [AssertionError] if [label] is empty.
  ChartDataSet({
    required this.color,
    required this.label,
    required this.dataPoint,
  }) : assert(
          label.isNotEmpty,
          'ChartDataSet label must not be empty',
        );

  /// Creates a copy of this data set with the given fields replaced.
  ///
  /// Returns a new [ChartDataSet] with the same values as this one,
  /// except for the fields that are explicitly provided.
  ChartDataSet copyWith({
    String? label,
    ChartDataPoint? dataPoint,
    Color? color,
  }) {
    return ChartDataSet(
      label: label ?? this.label,
      dataPoint: dataPoint ?? this.dataPoint,
      color: color ?? this.color,
    );
  }

  @override
  String toString() =>
      'ChartDataSet(label: $label, point: $dataPoint, color: $color)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartDataSet &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          dataPoint == other.dataPoint &&
          color == other.color;

  @override
  int get hashCode => Object.hash(label, dataPoint, color);
}

/// Represents a radar/spider chart data point.
///
/// Each point has a label (axis name) and a value (distance from center).
/// Radar charts display multiple axes arranged in a circle, with each
/// [RadarDataPoint] representing one axis.
///
/// ## Example
/// ```dart
/// const RadarDataPoint(
///   label: 'Speed',
///   value: 80,
/// )
/// ```
///
/// See also:
/// - [RadarDataSet] for collections of radar data points
/// - [ChartDataPoint] for standard two-dimensional points
class RadarDataPoint {
  /// The label for this axis (e.g., "Speed", "Quality").
  ///
  /// Displayed along the axis line. Should be a short, descriptive string.
  /// Must not be empty.
  final String label;

  /// The value on this axis (0.0 to maxValue).
  ///
  /// Must be non-negative and finite. The value determines how far from
  /// the center the point is plotted on this axis.
  final double value;

  /// Creates a radar data point.
  ///
  /// [label] must not be empty. [value] must be non-negative and finite.
  ///
  /// Throws an [AssertionError] if [value] is negative or not finite,
  /// or if [label] is empty.
  const RadarDataPoint({
    required this.label,
    required this.value,
  });

  /// Creates a copy of this radar data point with the given fields replaced.
  ///
  /// Returns a new [RadarDataPoint] with the same values as this one,
  /// except for the fields that are explicitly provided.
  RadarDataPoint copyWith({
    String? label,
    double? value,
  }) {
    return RadarDataPoint(
      label: label ?? this.label,
      value: value ?? this.value,
    );
  }

  @override
  String toString() => 'RadarDataPoint(label: $label, value: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RadarDataPoint &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          value == other.value;

  @override
  int get hashCode => Object.hash(label, value);
}

/// Represents a collection of radar/spider chart data points.
///
/// Contains multiple axes with values forming a polygon shape.
/// Each data point represents one axis on the radar chart.
///
/// ## Example
/// ```dart
/// RadarDataSet(
///   label: 'Team A',
///   color: Colors.blue,
///   dataPoints: [
///     RadarDataPoint(label: 'Speed', value: 80),
///     RadarDataPoint(label: 'Quality', value: 90),
///     RadarDataPoint(label: 'Design', value: 75),
///   ],
/// )
/// ```
///
/// See also:
/// - [RadarDataPoint] for individual radar points
/// - [ChartDataSet] for standard two-dimensional data sets
class RadarDataSet {
  /// The label for this data set (displayed in legends and tooltips).
  ///
  /// Should be a descriptive name for the data set (e.g., "Team A",
  /// "Product 1"). Must not be empty.
  final String label;

  /// The color used to render the polygon and points in this data set.
  ///
  /// Applied to the polygon fill, outline, and points. Use distinct colors
  /// for each data set to improve readability.
  final Color color;

  /// The list of radar data points in this data set.
  ///
  /// Each point represents one axis on the radar chart. All data sets
  /// in a radar chart should have the same number of points with matching
  /// axis labels.
  final List<RadarDataPoint> dataPoints;

  /// Creates a radar data set.
  ///
  /// [label] must not be empty. [color] is required for rendering.
  /// [dataPoints] is required and must not be empty.
  ///
  /// Throws an [AssertionError] if [label] is empty or [dataPoints] is empty.
  RadarDataSet({
    required this.label,
    required this.color,
    required this.dataPoints,
  })  : assert(
          label.isNotEmpty,
          'RadarDataSet label must not be empty',
        ),
        assert(
          dataPoints.isNotEmpty,
          'RadarDataSet dataPoints must not be empty',
        );

  /// Creates a copy of this radar data set with the given fields replaced.
  ///
  /// Returns a new [RadarDataSet] with the same values as this one,
  /// except for the fields that are explicitly provided.
  RadarDataSet copyWith({
    String? label,
    Color? color,
    List<RadarDataPoint>? dataPoints,
  }) {
    return RadarDataSet(
      label: label ?? this.label,
      color: color ?? this.color,
      dataPoints: dataPoints ?? this.dataPoints,
    );
  }

  @override
  String toString() =>
      'RadarDataSet(label: $label, color: $color, dataPoints: $dataPoints)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RadarDataSet &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          color == other.color &&
          dataPoints == other.dataPoints;

  @override
  int get hashCode => Object.hash(label, color, dataPoints);
}
