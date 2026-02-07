import 'package:save_points_chart/models/chart_data_point.dart';

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
/// - [BubbleDataSet] for collections of bubble data points (import from models)
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
  /// [label] is optional.
  /// [showValue] defaults to true to display the value on the chart.
  ///
  /// Throws an [AssertionError] if [size] is not positive or not finite.
  const BubbleDataPoint({
    required super.x,
    required super.y,
    required this.size,
    super.label,
    super.showValue,
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
    bool? showValue,
  }) {
    return BubbleDataPoint(
      x: x ?? this.x,
      y: y ?? this.y,
      size: size ?? this.size,
      label: label ?? this.label,
      showValue: showValue ?? this.showValue,
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
