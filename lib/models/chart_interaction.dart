import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';

/// Constants for chart interaction behavior.
///
/// These constants define the interaction zones and timing for various
/// chart interactions. Adjust these values to fine-tune the user experience.
///
/// ## Example
/// ```dart
/// // Use custom tap radius
/// final result = ChartInteractionHelper.findNearestPoint(
///   tapPosition,
///   dataSets,
///   chartSize,
///   minX, maxX, minY, maxY,
///   ChartInteractionConstants.tapRadius * 1.5, // 50% larger
/// );
/// ```
class ChartInteractionConstants {
  /// Standard tap radius for detecting point taps (in pixels).
  ///
  /// The maximum distance from a tap position to a data point to be
  /// considered a hit. Larger values make it easier to tap points,
  /// but may cause false positives.
  ///
  /// Default: 20.0 pixels
  static const double tapRadius = 20.0;

  /// Hover radius for detecting point hovers (larger than tap for better UX).
  ///
  /// The maximum distance from a hover position to a data point to trigger
  /// hover effects. Should be larger than [tapRadius] to provide better
  /// visual feedback before the user taps.
  ///
  /// Default: 30.0 pixels
  static const double hoverRadius = 30.0;

  /// Long press duration threshold (in milliseconds).
  ///
  /// The minimum duration a press must be held to trigger a long press event.
  /// Used for context menus and advanced interactions.
  ///
  /// Default: 500 milliseconds
  static const int longPressDuration = 500;
}

/// Callback for chart point interactions.
///
/// Invoked when a user taps on a data point in line, area, scatter, or
/// similar point-based charts.
///
/// Parameters:
/// - [point] - The tapped data point
/// - [datasetIndex] - The index of the dataset containing this point
/// - [pointIndex] - The index of the point within its dataset
/// - [position] - The global tap position (useful for showing context menus)
///
/// ## Example
/// ```dart
/// onPointTap: (point, datasetIndex, pointIndex, position) {
///   print('Tapped point: ${point.y} at ($datasetIndex, $pointIndex)');
///   showContextMenu(position);
/// }
/// ```
typedef ChartPointCallback = void Function(
  ChartDataPoint point,
  int datasetIndex,
  int pointIndex,
  Offset position,
);

/// Callback for pie chart segment interactions.
///
/// Invoked when a user taps on a segment in a pie or donut chart.
///
/// Parameters:
/// - [segment] - The tapped pie segment
/// - [segmentIndex] - The index of the segment in the data list
/// - [position] - The global tap position (useful for showing context menus)
///
/// ## Example
/// ```dart
/// onSegmentTap: (segment, segmentIndex, position) {
///   print('Tapped segment: ${segment.label} (${segment.value})');
/// }
/// ```
typedef PieSegmentCallback = void Function(
  PieData segment,
  int segmentIndex,
  Offset position,
);

/// Callback for bar chart interactions.
///
/// Invoked when a user taps on a bar in a bar chart.
///
/// Parameters:
/// - [point] - The data point represented by this bar
/// - [datasetIndex] - The index of the dataset containing this bar
/// - [barIndex] - The index of the bar within its dataset
/// - [position] - The global tap position (useful for showing context menus)
///
/// ## Example
/// ```dart
/// onBarTap: (point, datasetIndex, barIndex, position) {
///   print('Tapped bar: ${point.y}');
/// }
/// ```
typedef BarCallback = void Function(
  ChartDataPoint point,
  int datasetIndex,
  int barIndex,
  Offset position,
);

/// Callback for mouse hover events on chart points.
///
/// Invoked when the mouse enters or exits a point area in point-based charts.
/// When the mouse exits, all parameters will be null.
///
/// Parameters:
/// - [point] - The hovered data point, or null if mouse exited
/// - [datasetIndex] - The dataset index, or null if mouse exited
/// - [pointIndex] - The point index, or null if mouse exited
///
/// ## Example
/// ```dart
/// onPointHover: (point, datasetIndex, pointIndex) {
///   if (point != null) {
///     showTooltip('Value: ${point.y}');
///   } else {
///     hideTooltip();
///   }
/// }
/// ```
typedef ChartPointHoverCallback = void Function(
  ChartDataPoint? point,
  int? datasetIndex,
  int? pointIndex,
);

/// Callback for mouse hover events on pie segments.
///
/// Invoked when the mouse enters or exits a segment area in pie/donut charts.
/// When the mouse exits, all parameters will be null.
///
/// Parameters:
/// - [segment] - The hovered segment, or null if mouse exited
/// - [segmentIndex] - The segment index, or null if mouse exited
///
/// ## Example
/// ```dart
/// onSegmentHover: (segment, segmentIndex) {
///   if (segment != null) {
///     showTooltip('${segment.label}: ${segment.value}');
///   }
/// }
/// ```
typedef PieSegmentHoverCallback = void Function(
  PieData? segment,
  int? segmentIndex,
);

/// Callback for mouse hover events on bars.
///
/// Invoked when the mouse enters or exits a bar area in bar charts.
/// When the mouse exits, all parameters will be null.
///
/// Parameters:
/// - [point] - The data point for the hovered bar, or null if mouse exited
/// - [datasetIndex] - The dataset index, or null if mouse exited
/// - [barIndex] - The bar index, or null if mouse exited
///
/// ## Example
/// ```dart
/// onBarHover: (point, datasetIndex, barIndex) {
///   if (point != null) {
///     highlightBar(barIndex);
///   }
/// }
/// ```
typedef BarHoverCallback = void Function(
  ChartDataPoint? point,
  int? datasetIndex,
  int? barIndex,
);

/// Result of a chart interaction.
///
/// This immutable class represents the result of detecting a tap or hover
/// on a chart element. It contains information about which element was
/// interacted with and its position.
///
/// Use [isHit] to check if an interaction was successful. If [isHit] is true,
/// then either [point] (for point-based charts) or [segment] (for pie charts)
/// will be non-null, along with the corresponding indices.
///
/// ## Example
/// ```dart
/// final result = ChartInteractionHelper.findNearestPoint(...);
/// if (result != null && result.isHit) {
///   print('Hit point: ${result.point!.y} at index ${result.elementIndex}');
/// }
/// ```
///
/// See also:
/// - [ChartInteractionHelper] for finding interactions (import from utils)
/// - [ChartInteractionConstants] for interaction configuration
class ChartInteractionResult {
  /// The data point that was interacted with, if applicable.
  ///
  /// Non-null for point-based charts (line, bar, area, scatter, etc.)
  /// when [isHit] is true. Null for pie/donut charts or when no hit occurred.
  final ChartDataPoint? point;

  /// The pie segment that was interacted with, if applicable.
  ///
  /// Non-null for pie/donut/pyramid/funnel charts when [isHit] is true.
  /// Null for point-based charts or when no hit occurred.
  final PieData? segment;

  /// The index of the dataset containing the interacted element.
  ///
  /// Non-null when [isHit] is true and the chart has multiple datasets.
  /// Always 0 for single-dataset charts.
  final int? datasetIndex;

  /// The index of the element within its dataset or data list.
  ///
  /// For point-based charts, this is the point index.
  /// For pie charts, this is the segment index.
  /// Non-null when [isHit] is true.
  final int? elementIndex;

  /// Whether an interaction was successfully detected.
  ///
  /// True if a chart element was found at the interaction position,
  /// false otherwise. When false, all other fields will be null.
  final bool isHit;

  /// Creates a chart interaction result.
  ///
  /// [isHit] defaults to false. Set to true when an element is found.
  /// Either [point] or [segment] should be provided (not both).
  const ChartInteractionResult({
    this.point,
    this.segment,
    this.datasetIndex,
    this.elementIndex,
    this.isHit = false,
  })  : assert(
          point == null || segment == null,
          'Cannot have both point and segment',
        ),
        assert(
          !isHit || (point != null || segment != null),
          'isHit true requires point or segment',
        ),
        assert(
          !isHit || datasetIndex != null,
          'isHit true requires datasetIndex',
        ),
        assert(
          !isHit || elementIndex != null,
          'isHit true requires elementIndex',
        );

  /// Creates a result representing no interaction.
  ///
  /// All fields will be null and [isHit] will be false.
  const ChartInteractionResult.none()
      : point = null,
        segment = null,
        datasetIndex = null,
        elementIndex = null,
        isHit = false;

  /// Creates a copy of this result with the given fields replaced.
  ///
  /// Returns a new [ChartInteractionResult] with the same values as this one,
  /// except for the fields that are explicitly provided.
  ChartInteractionResult copyWith({
    ChartDataPoint? point,
    PieData? segment,
    int? datasetIndex,
    int? elementIndex,
    bool? isHit,
  }) {
    return ChartInteractionResult(
      point: point ?? this.point,
      segment: segment ?? this.segment,
      datasetIndex: datasetIndex ?? this.datasetIndex,
      elementIndex: elementIndex ?? this.elementIndex,
      isHit: isHit ?? this.isHit,
    );
  }

  @override
  String toString() {
    if (!isHit) return 'ChartInteractionResult.none()';
    if (point != null) {
      return 'ChartInteractionResult(point: $point, datasetIndex: $datasetIndex, elementIndex: $elementIndex)';
    }
    return 'ChartInteractionResult(segment: $segment, elementIndex: $elementIndex)';
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartInteractionResult &&
          runtimeType == other.runtimeType &&
          point == other.point &&
          segment == other.segment &&
          datasetIndex == other.datasetIndex &&
          elementIndex == other.elementIndex &&
          isHit == other.isHit;

  @override
  int get hashCode => Object.hash(
        point,
        segment,
        datasetIndex,
        elementIndex,
        isHit,
      );
}
