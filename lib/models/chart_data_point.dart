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
/// ```
///
/// See also:
/// - `ChartDataSet` for collections of data points
/// - `BubbleDataPoint` for bubble charts with size information
class ChartDataPoint {
  /// Creates a chart data point.
  ///
  /// [x] and [y] are required and must be finite numbers or numeric strings.
  /// [label] is optional and can be used for axis labels or tooltips.
  /// [showValue] defaults to true to display the value on the chart.
  ///
  /// Throws an [AssertionError] if [x] or [y] are not finite.
  ChartDataPoint({required dynamic x, required dynamic y, this.label, this.showValue = true})
    : x = _parseValue(x, 'x'),
      y = _parseValue(y, 'y'),
      assert(_parseValue(x, 'x').isFinite, 'ChartDataPoint.x must be a finite number'),
      assert(_parseValue(y, 'y').isFinite, 'ChartDataPoint.y must be a finite number');

  /// Parses a numeric value from either a [num] or a numeric [String].
  ///
  /// Throws [ArgumentError] if the value cannot be interpreted as a number.
  static double _parseValue(dynamic value, String name) {
    if (value is num) return value.toDouble();
    if (value is String) {
      final parsed = double.tryParse(value);
      if (parsed != null) return parsed;
    }
    throw ArgumentError.value(
      value,
      name,
      'ChartDataPoint.$name must be a num or numeric String',
    );
  }

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

  /// Whether to show the value for this data point.
  ///
  /// When true (default), the value will be displayed on the chart.
  /// When false, the value will be hidden.
  final bool showValue;

  /// Creates a copy of this data point with the given fields replaced.
  ///
  /// Returns a new [ChartDataPoint] with the same values as this one,
  /// except for the fields that are explicitly provided.
  ChartDataPoint copyWith({dynamic x, dynamic y, String? label, bool? showValue}) {
    return ChartDataPoint(
      x: x ?? this.x,
      y: y ?? this.y,
      label: label ?? this.label,
      showValue: showValue ?? this.showValue,
    );
  }

  @override
  String toString() => 'ChartDataPoint(x: $x, y: $y, label: ${label ?? "null"}, showValue: $showValue)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartDataPoint &&
          runtimeType == other.runtimeType &&
          x == other.x &&
          y == other.y &&
          label == other.label &&
          showValue == other.showValue;

  @override
  int get hashCode => Object.hash(x, y, label, showValue);
}
