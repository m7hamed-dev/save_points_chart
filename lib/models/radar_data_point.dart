import 'package:save_points_chart/models/chart_data.dart' show RadarDataSet, ChartDataPoint;
import 'package:save_points_chart/save_points_chart.dart' show RadarDataSet, ChartDataPoint;

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
  /// Creates a radar data point.
  ///
  /// [label] must not be empty. [value] must be non-negative and finite.
  /// [showValue] defaults to true to display the value on the chart.
  ///
  /// Throws an [AssertionError] if [value] is negative or not finite,
  /// or if [label] is empty.
  const RadarDataPoint({
    required this.label,
    required this.value,
    this.showValue = true,
  });

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

  /// Whether to show the value for this data point.
  ///
  /// When true (default), the value will be displayed on the chart.
  /// When false, the value will be hidden.
  final bool showValue;

  /// Creates a copy of this radar data point with the given fields replaced.
  ///
  /// Returns a new [RadarDataPoint] with the same values as this one,
  /// except for the fields that are explicitly provided.
  RadarDataPoint copyWith({String? label, double? value, bool? showValue}) {
    return RadarDataPoint(
      label: label ?? this.label,
      value: value ?? this.value,
      showValue: showValue ?? this.showValue,
    );
  }

  @override
  String toString() =>
      'RadarDataPoint(label: $label, value: $value, showValue: $showValue)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RadarDataPoint &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          value == other.value &&
          showValue == other.showValue;

  @override
  int get hashCode => Object.hash(label, value, showValue);
}
