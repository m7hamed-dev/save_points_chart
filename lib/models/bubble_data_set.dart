import 'package:flutter/material.dart';
import 'package:save_points_chart/models/bubble_data_point.dart';

/// Represents a collection of bubble data points.
///
/// Similar to [ChartDataSet] but specifically for bubble charts.
/// Contains multiple bubble points that share a color.
///
/// ## Example
/// ```dart
/// BubbleDataSet(
///   color: Colors.blue,
///   dataPoints: [
///     BubbleDataPoint(x: 10, y: 20, size: 50, label: 'Region A'),
///     BubbleDataPoint(x: 15, y: 25, size: 60, label: 'Region B'),
///   ],
/// )
/// ```
///
/// See also:
/// - [ChartDataSet] for standard two-dimensional data sets
/// - [BubbleDataPoint] for individual bubble points
class BubbleDataSet {
  /// The color used to render the bubbles in this data set.
  ///
  /// Applied to all bubbles in this set. Use distinct colors for each
  /// data set to improve readability.
  final Color color;

  /// The list of bubble data points in this data set.
  ///
  /// Each point represents one bubble on the chart.
  /// Labels are stored in each [BubbleDataPoint.label].
  final List<BubbleDataPoint> dataPoints;

  /// Creates a bubble data set.
  ///
  /// [color] is required for rendering.
  /// [dataPoints] is required and must not be empty.
  ///
  /// Throws an [AssertionError] if [dataPoints] is empty.
  BubbleDataSet({required this.color, required this.dataPoints})
      : assert(
          dataPoints.isNotEmpty,
          'BubbleDataSet dataPoints must not be empty',
        );

  /// Creates a copy of this bubble data set with the given fields replaced.
  ///
  /// Returns a new [BubbleDataSet] with the same values as this one,
  /// except for the fields that are explicitly provided.
  BubbleDataSet copyWith({Color? color, List<BubbleDataPoint>? dataPoints}) {
    return BubbleDataSet(
      color: color ?? this.color,
      dataPoints: dataPoints ?? this.dataPoints,
    );
  }

  @override
  String toString() => 'BubbleDataSet(color: $color, dataPoints: $dataPoints)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BubbleDataSet &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          dataPoints == other.dataPoints;

  @override
  int get hashCode => Object.hash(color, dataPoints);
}
