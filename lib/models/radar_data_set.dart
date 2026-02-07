import 'package:flutter/material.dart';
import 'package:save_points_chart/models/radar_data_point.dart';

/// Represents a collection of radar/spider chart data points.
///
/// Contains multiple axes with values forming a polygon shape.
/// Each data point represents one axis on the radar chart.
///
/// ## Example
/// ```dart
/// RadarDataSet(
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
  /// Creates a radar data set.
  ///
  /// [color] is required for rendering.
  /// [dataPoints] is required and must not be empty.
  ///
  /// Throws an [AssertionError] if [dataPoints] is empty.
  RadarDataSet({required this.color, required this.dataPoints})
      : assert(
          dataPoints.isNotEmpty,
          'RadarDataSet dataPoints must not be empty',
        );

  /// The color used to render the polygon and points in this data set.
  ///
  /// Applied to the polygon fill, outline, and points. Use distinct colors
  /// for each data set to improve readability.
  final Color color;

  /// The list of radar data points in this data set.
  ///
  /// Each point represents one axis on the radar chart. All data sets
  /// in a radar chart should have the same number of points with matching
  /// axis labels. Each [RadarDataPoint] has its own label for the axis name.
  final List<RadarDataPoint> dataPoints;

  /// Creates a copy of this radar data set with the given fields replaced.
  ///
  /// Returns a new [RadarDataSet] with the same values as this one,
  /// except for the fields that are explicitly provided.
  RadarDataSet copyWith({Color? color, List<RadarDataPoint>? dataPoints}) {
    return RadarDataSet(
      color: color ?? this.color,
      dataPoints: dataPoints ?? this.dataPoints,
    );
  }

  @override
  String toString() => 'RadarDataSet(color: $color, dataPoints: $dataPoints)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is RadarDataSet &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          dataPoints == other.dataPoints;

  @override
  int get hashCode => Object.hash(color, dataPoints);
}
