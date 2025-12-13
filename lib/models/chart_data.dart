import 'package:flutter/material.dart';

/// Represents a single data point in a chart.
///
/// Each point has an x-coordinate (horizontal position) and y-coordinate
/// (vertical value). An optional label can be provided for display purposes.
///
/// Example:
/// ```dart
/// ChartDataPoint(
///   x: 0,
///   y: 10.5,
///   label: 'January',
/// )
/// ```
class ChartDataPoint {
  /// The x-coordinate (horizontal position) of the data point.
  final double x;

  /// The y-coordinate (vertical value) of the data point.
  final double y;

  /// Optional label for the data point (e.g., "Jan", "Q1").
  final String? label;

  /// Creates a chart data point.
  ///
  /// [x] and [y] are required. [label] is optional and can be used
  /// for axis labels or tooltips.
  const ChartDataPoint({required this.x, required this.y, this.label});

  @override
  String toString() => 'ChartDataPoint(x: $x, y: $y, label: $label)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartDataPoint &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          label == other.label;

  @override
  int get hashCode => x.hashCode ^ y.hashCode ^ (label?.hashCode ?? 0);
}

/// Represents a segment in a pie or donut chart.
///
/// Each segment has a label, a numeric value, and a color for visualization.
///
/// Example:
/// ```dart
/// PieData(
///   label: 'Mobile',
///   value: 45.0,
///   color: Colors.blue,
/// )
/// ```
class PieData {
  /// The label displayed in the legend and tooltips.
  final String label;

  /// The numeric value of this segment.
  ///
  /// Must be non-negative. The percentage is calculated automatically
  /// based on the total of all segments.
  final double value;

  /// The color used to render this segment.
  final Color color;

  /// Creates a pie chart segment.
  ///
  /// [value] should be non-negative. If negative, it will be treated as 0.
  const PieData({required this.label, required this.value, required this.color})
      : assert(value >= 0, 'PieData value must be non-negative');

  @override
  String toString() => 'PieData(label: $label, value: $value)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PieData &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          value == other.value &&
          color == other.color;

  @override
  int get hashCode => label.hashCode ^ value.hashCode ^ color.hashCode;
}

/// Represents a bubble data point with size information.
///
/// Extends [ChartDataPoint] with an additional size property for bubble charts.
/// The size represents the third dimension of data visualization.
///
/// Example:
/// ```dart
/// BubbleDataPoint(
///   x: 10,
///   y: 20,
///   size: 50,
///   label: 'Product A',
/// )
/// ```
class BubbleDataPoint extends ChartDataPoint {
  /// The size of the bubble (third dimension).
  ///
  /// This value is used to determine the radius of the bubble.
  /// Should be positive. Defaults to 10.0.
  final double size;

  /// Creates a bubble data point.
  ///
  /// [x], [y], and [size] are required. [label] is optional.
  const BubbleDataPoint({
    required super.x,
    required super.y,
    required this.size,
    super.label,
  }) : assert(size > 0, 'Bubble size must be positive');

  @override
  String toString() =>
      'BubbleDataPoint(x: $x, y: $y, size: $size, label: $label)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      super == other &&
          other is BubbleDataPoint &&
          runtimeType == other.runtimeType &&
          size == other.size;

  @override
  int get hashCode => super.hashCode ^ size.hashCode;
}

/// Represents a collection of bubble data points.
///
/// Similar to [ChartDataSet] but specifically for bubble charts.
class BubbleDataSet {
  /// The label for this data series.
  final String label;

  /// The list of bubble data points in this series.
  final List<BubbleDataPoint> dataPoints;

  /// The color used to render this data series.
  final Color color;

  /// Creates a bubble data set.
  BubbleDataSet({
    required this.label,
    required this.dataPoints,
    required this.color,
  }) : assert(
          dataPoints.isNotEmpty,
          'BubbleDataSet must have at least one data point',
        );

  @override
  String toString() =>
      'BubbleDataSet(label: $label, points: ${dataPoints.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BubbleDataSet &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          dataPoints == other.dataPoints &&
          color == other.color;

  @override
  int get hashCode => label.hashCode ^ dataPoints.hashCode ^ color.hashCode;
}

/// Represents a collection of data points that form a single series in a chart.
///
/// Multiple [ChartDataSet] instances can be used to create multi-series charts
/// (e.g., comparing sales vs revenue over time).
///
/// Example:
/// ```dart
/// ChartDataSet(
///   label: 'Sales',
///   color: Colors.blue,
///   dataPoints: [
///     ChartDataPoint(x: 0, y: 10),
///     ChartDataPoint(x: 1, y: 20),
///     ChartDataPoint(x: 2, y: 15),
///   ],
/// )
/// ```
class ChartDataSet {
  /// The label for this data series (displayed in legends and tooltips).
  final String label;

  /// The list of data points in this series.
  ///
  /// Should not be empty. Empty lists may cause rendering issues.
  final List<ChartDataPoint> dataPoints;

  /// The color used to render this data series.
  final Color color;

  /// Creates a chart data set.
  ///
  /// [dataPoints] should not be empty. If empty, the chart may not render correctly.
  ChartDataSet({
    required this.label,
    required this.dataPoints,
    required this.color,
  }) : assert(
          dataPoints.isNotEmpty,
          'ChartDataSet must have at least one data point',
        );

  @override
  String toString() =>
      'ChartDataSet(label: $label, points: ${dataPoints.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartDataSet &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          dataPoints == other.dataPoints &&
          color == other.color;

  @override
  int get hashCode => label.hashCode ^ dataPoints.hashCode ^ color.hashCode;
}

/// Represents a radar/spider chart data point.
///
/// Each point has a label (axis name) and a value (distance from center).
///
/// Example:
/// ```dart
/// RadarDataPoint(
///   label: 'Speed',
///   value: 80,
/// )
/// ```
class RadarDataPoint {
  /// The label for this axis (e.g., "Speed", "Quality").
  final String label;

  /// The value on this axis (0.0 to maxValue).
  final double value;

  /// Creates a radar data point.
  const RadarDataPoint({
    required this.label,
    required this.value,
  }) : assert(value >= 0, 'Radar value must be non-negative');

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
  int get hashCode => label.hashCode ^ value.hashCode;
}

/// Represents a radar/spider chart data set.
///
/// Contains multiple axes with values forming a polygon shape.
class RadarDataSet {
  /// The label for this data series.
  final String label;

  /// The list of radar data points (one per axis).
  final List<RadarDataPoint> dataPoints;

  /// The color used to render this data series.
  final Color color;

  /// Creates a radar data set.
  RadarDataSet({
    required this.label,
    required this.dataPoints,
    required this.color,
  }) : assert(
          dataPoints.isNotEmpty,
          'RadarDataSet must have at least one data point',
        );

  @override
  String toString() =>
      'RadarDataSet(label: $label, points: ${dataPoints.length})';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RadarDataSet &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          dataPoints == other.dataPoints &&
          color == other.color;

  @override
  int get hashCode => label.hashCode ^ dataPoints.hashCode ^ color.hashCode;
}
