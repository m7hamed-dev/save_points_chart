import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart' show BubbleDataSet, RadarDataSet;
import 'package:save_points_chart/models/chart_data_point.dart';
import 'package:save_points_chart/save_points_chart.dart' show BubbleDataSet, RadarDataSet;

/// Represents a single data point in a chart.
///
/// Each [ChartDataSet] represents one data point with a color.
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
///   dataPoint: ChartDataPoint(x: 1, y: 20, label: 'January'),
/// )
/// ```
///
/// See also:
/// - [ChartDataPoint] for individual data points
/// - [BubbleDataSet] for bubble charts
/// - [RadarDataSet] for radar charts
class ChartDataSet {
  /// Creates a chart data set.
  ///
  /// [dataPoint] is required.
  /// [color] is required for rendering.
  const ChartDataSet({required this.color, required this.dataPoint});

  /// The single data point in this dataset.
  ///
  /// Each dataset represents one point on the chart.
  // / The label is stored in [dataPoint.label].
  final ChartDataPoint dataPoint;

  /// The color used to render this data point.
  ///
  /// Applied to lines, bars, areas, and points. For multi-point charts,
  /// use distinct colors for each dataset to improve readability.
  final Color color;

  /// Creates a copy of this data set with the given fields replaced.
  ///
  /// Returns a new [ChartDataSet] with the same values as this one,
  /// except for the fields that are explicitly provided.
  ChartDataSet copyWith({ChartDataPoint? dataPoint, Color? color}) {
    return ChartDataSet(dataPoint: dataPoint ?? this.dataPoint, color: color ?? this.color);
  }

  @override
  String toString() => 'ChartDataSet(point: $dataPoint, color: $color)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartDataSet && runtimeType == other.runtimeType && dataPoint == other.dataPoint && color == other.color;

  @override
  int get hashCode => Object.hash(dataPoint, color);

  /// Returns true if [dataSets] is empty or every data point has both x and y
  /// equal to zero (no meaningful data to display).
  ///
  /// Use this to show an empty state widget instead of rendering the chart
  /// when there is no data to display.
  static bool isAllDataPointsEmpty(List<ChartDataSet> dataSets) {
    if (dataSets.isEmpty) return true;
    return dataSets.every((ds) => ds.dataPoint.x == 0 && ds.dataPoint.y == 0);
  }
}

/// Wrapper that shows [emptyWidget] when all data points in [dataSets] have
/// empty x and y (both zero). Otherwise builds [child].
///
/// Use this to display an empty state instead of the chart when there is
/// no meaningful data.
class ChartEmptyScope extends StatelessWidget {
  const ChartEmptyScope({super.key, required this.dataSets, required this.child, this.emptyWidget});

  /// The data sets to check. If empty or all points are (0, 0), [emptyWidget]
  /// is shown.
  final List<ChartDataSet> dataSets;

  /// The chart (or other) content to show when there is data.
  final Widget child;

  /// Widget to show when all data points are empty. Defaults to [SizedBox.shrink].
  final Widget? emptyWidget;

  @override
  Widget build(BuildContext context) {
    if (ChartDataSet.isAllDataPointsEmpty(dataSets)) {
      return emptyWidget ?? const SizedBox.shrink();
    }
    return child;
  }
}
