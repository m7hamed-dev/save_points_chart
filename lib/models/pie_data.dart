import 'package:flutter/material.dart';

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
//  - [ChartDataPoint] for point-based charts
class PieData {
  /// Creates a pie chart segment.
  ///
  /// [label] must not be empty. [value] must be non-negative and finite.
  /// [color] is required for rendering.
  /// [showValue] defaults to true to display the value on the chart.
  ///
  /// Throws an [AssertionError] if [value] is negative or not finite,
  /// or if [label] is empty.
  const PieData({
    required this.label,
    this.value = 0.0,
    required this.color,
    this.showValue = true,
    this.showLabel = true,
    this.width = 16.0,
    this.height = 16.0,
  });

  /// The label displayed in the legend and tooltips.
  ///
  /// Should be a short, descriptive string (e.g., "Mobile", "Desktop").
  final String label;
  final bool? showLabel;

  /// The numeric value of this segment.
  ///
  /// Must be non-negative and finite. The percentage is calculated automatically
  /// based on the total of all segments. Zero values are allowed but won't
  /// be visible in the chart.
  final double value;

  /// width and height
  final double? width, height;

  /// The color used to render this segment.
  ///
  /// This color is used for the segment fill, legend, and tooltips.
  final Color color;

  /// Whether to show the value for this segment.
  ///
  /// When true (default), the value will be displayed on the chart.
  /// When false, the value will be hidden.
  final bool showValue;

  /// Creates a copy of this pie data with the given fields replaced.
  ///
  /// Returns a new [PieData] with the same values as this one,
  /// except for the fields that are explicitly provided.
  PieData copyWith({
    String? label,
    double? value,
    Color? color,
    bool? showValue,
  }) {
    return PieData(
      label: label ?? this.label,
      value: value ?? this.value,
      color: color ?? this.color,
      showValue: showValue ?? this.showValue,
    );
  }

  @override
  String toString() =>
      'PieData(label: $label, value: $value, color: $color, showValue: $showValue)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PieData &&
          runtimeType == other.runtimeType &&
          label == other.label &&
          value == other.value &&
          color == other.color &&
          showValue == other.showValue;

  @override
  int get hashCode => Object.hash(label, value, color, showValue);
}
