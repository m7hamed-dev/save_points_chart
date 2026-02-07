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

/// Callback for chart point tap interactions.
///
/// Invoked when a user taps on a data point in point-based charts.
///
/// **Supported Charts:**
/// - Line charts (`LineChartWidget`)
/// - Area charts (`AreaChartWidget`)
/// - Scatter charts (`ScatterChartWidget`)
/// - Bubble charts (`BubbleChartWidget`) - use `onBubbleTap`
/// - Stacked area charts (`StackedAreaChartWidget`)
/// - Step line charts (`StepLineChartWidget`)
/// - Spline charts (`SplineChartWidget`)
/// - Sparkline charts (`SparklineChartWidget`)
///
/// **Parameters:**
/// - [point] - The tapped data point (never null)
/// - [datasetIndex] - The index of the dataset containing this point (never null)
/// - [pointIndex] - The index of the point within its dataset (never null)
/// - [position] - The global tap position (useful for showing context menus)
///
/// **Usage Notes:**
/// - This callback is nullable - if null, tap interactions are disabled
/// - Haptic feedback is automatically provided on mobile platforms
/// - The tap detection uses [ChartInteractionConstants.tapRadius] for hit detection
///
/// ## Example
/// ```dart
/// onPointTap: (point, datasetIndex, pointIndex, position) {
///   print('Tapped point: ${point.y} at ($datasetIndex, $pointIndex)');
///   showContextMenu(position);
/// }
/// ```
///
/// See also:
/// - `ChartPointHoverCallback` for hover events (desktop/web only)
/// - `onBubbleTap` for bubble chart-specific tap handling
/// - `ChartInteractionConstants` for interaction configuration
typedef ChartPointCallback =
    void Function(
      ChartDataPoint point,
      int datasetIndex,
      int pointIndex,
      Offset position,
    );

/// Callback for pie chart segment tap interactions.
///
/// Invoked when a user taps on a segment in pie/donut charts.
///
/// **Supported Charts:**
/// - Pie charts (`PieChartWidget`)
/// - Donut charts (`DonutChartWidget`)
/// - Pyramid charts (`PyramidChartWidget`)
/// - Funnel charts (`FunnelChartWidget`)
///
/// **Parameters:**
/// - [segment] - The tapped pie segment (never null)
/// - [segmentIndex] - The index of the segment in the data list (never null)
/// - [position] - The global tap position (useful for showing context menus)
///
/// **Usage Notes:**
/// - This callback is nullable - if null, tap interactions are disabled
/// - Haptic feedback is automatically provided on mobile platforms
///
/// ## Example
/// ```dart
/// onSegmentTap: (segment, segmentIndex, position) {
///   print('Tapped segment: ${segment.label} (${segment.value})');
/// }
/// ```
///
/// See also:
/// - [PieSegmentHoverCallback] for hover events (desktop/web only)
typedef PieSegmentCallback =
    void Function(PieData segment, int segmentIndex, Offset position);

/// Callback for bar chart tap interactions.
///
/// Invoked when a user taps on a bar in a bar chart.
///
/// **Supported Charts:**
/// - Bar charts (`BarChartWidget`)
/// - Stacked column charts (`StackedColumnChartWidget`)
///
/// **Parameters:**
/// - [point] - The data point represented by this bar (never null)
/// - [datasetIndex] - The index of the dataset containing this bar (never null)
/// - [barIndex] - The index of the bar within its dataset (never null)
/// - [position] - The global tap position (useful for showing context menus)
///
/// **Usage Notes:**
/// - This callback is nullable - if null, tap interactions are disabled
/// - Haptic feedback is automatically provided on mobile platforms
///
/// ## Example
/// ```dart
/// onBarTap: (point, datasetIndex, barIndex, position) {
///   print('Tapped bar: ${point.y}');
/// }
/// ```
///
/// See also:
/// - [BarHoverCallback] for hover events (desktop/web only)
typedef BarCallback =
    void Function(
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
/// **Supported Charts:**
/// - Line charts (`LineChartWidget`)
/// - Area charts (`AreaChartWidget`)
/// - Scatter charts (`ScatterChartWidget`)
/// - Bubble charts (`BubbleChartWidget`) - use `onBubbleHover`
/// - Stacked area charts (`StackedAreaChartWidget`)
/// - Step line charts (`StepLineChartWidget`)
/// - Spline charts (`SplineChartWidget`)
///
/// **Parameters:**
/// - [point] - The hovered data point, or null if mouse exited
/// - [datasetIndex] - The dataset index, or null if mouse exited
/// - [pointIndex] - The point index, or null if mouse exited
///
/// **Usage Notes:**
/// - This callback is nullable - if null, hover interactions are disabled
/// - **Platform Support:** Desktop and web only (mouse hover not available on mobile)
/// - The hover detection uses [ChartInteractionConstants.hoverRadius] for hit detection
/// - All parameters are nullable - check for null to detect mouse exit
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
///
/// See also:
/// - `ChartPointCallback` for tap events (all platforms)
/// - `onBubbleHover` for bubble chart-specific hover handling
/// - `ChartInteractionConstants` for interaction configuration
typedef ChartPointHoverCallback =
    void Function(ChartDataPoint? point, int? datasetIndex, int? pointIndex);

/// Callback for mouse hover events on pie chart segments.
///
/// Invoked when the mouse enters or exits a segment area in pie/donut charts.
/// When the mouse exits, all parameters will be null.
///
/// **Supported Charts:**
/// - Pie charts (`PieChartWidget`)
/// - Donut charts (`DonutChartWidget`)
/// - Pyramid charts (`PyramidChartWidget`)
/// - Funnel charts (`FunnelChartWidget`)
///
/// **Parameters:**
/// - [segment] - The hovered segment, or null if mouse exited
/// - [segmentIndex] - The segment index, or null if mouse exited
///
/// **Usage Notes:**
/// - This callback is nullable - if null, hover interactions are disabled
/// - **Platform Support:** Desktop and web only (mouse hover not available on mobile)
/// - All parameters are nullable - check for null to detect mouse exit
///
/// ## Example
/// ```dart
/// onSegmentHover: (segment, segmentIndex) {
///   if (segment != null) {
///     showTooltip('${segment.label}: ${segment.value}');
///   }
/// }
/// ```
///
/// See also:
/// - [PieSegmentCallback] for tap events (all platforms)
typedef PieSegmentHoverCallback =
    void Function(PieData? segment, int? segmentIndex);

/// Callback for mouse hover events on bars.
///
/// Invoked when the mouse enters or exits a bar area in bar charts.
/// When the mouse exits, all parameters will be null.
///
/// **Supported Charts:**
/// - Bar charts (`BarChartWidget`)
/// - Stacked column charts (`StackedColumnChartWidget`)
///
/// **Parameters:**
/// - [point] - The data point for the hovered bar, or null if mouse exited
/// - [datasetIndex] - The dataset index, or null if mouse exited
/// - [barIndex] - The bar index, or null if mouse exited
///
/// **Usage Notes:**
/// - This callback is nullable - if null, hover interactions are disabled
/// - **Platform Support:** Desktop and web only (mouse hover not available on mobile)
/// - All parameters are nullable - check for null to detect mouse exit
///
/// ## Example
/// ```dart
/// onBarHover: (point, datasetIndex, barIndex) {
///   if (point != null) {
///     highlightBar(barIndex);
///   }
/// }
/// ```
///
/// See also:
/// - [BarCallback] for tap events (all platforms)
typedef BarHoverCallback =
    void Function(ChartDataPoint? point, int? datasetIndex, int? barIndex);

/// Callback for bubble chart tap interactions.
///
/// Invoked when a user taps on a bubble in a bubble chart.
///
/// **Supported Charts:**
/// - Bubble charts (`BubbleChartWidget`)
///
/// **Parameters:**
/// - `point` - The tapped bubble data point (never null)
/// - `datasetIndex` - The index of the dataset containing this bubble (never null)
/// - `pointIndex` - The index of the bubble within its dataset (never null)
/// - `position` - The global tap position (useful for showing context menus)
///
/// **Usage Notes:**
/// - This callback is nullable - if null, tap interactions are disabled
/// - Haptic feedback is automatically provided on mobile platforms
/// - The tap detection uses [ChartInteractionConstants.tapRadius] * 3 for hit detection
///   (larger radius due to bubble size variability)
///
/// ## Example
/// ```dart
/// onBubbleTap: (point, datasetIndex, pointIndex, position) {
///   print('Tapped bubble: ${point.y} with size ${(point as BubbleDataPoint).size}');
///   showContextMenu(position);
/// }
/// ```
///
/// See also:
/// - `onBubbleHover` for hover events (desktop/web only)
/// - `ChartPointCallback` for other point-based charts
/// - `ChartInteractionConstants` for interaction configuration
typedef BubbleTapCallback = ChartPointCallback;

/// Callback for bubble chart hover interactions.
///
/// Invoked when the mouse enters or exits a bubble area in bubble charts.
/// When the mouse exits, all parameters will be null.
///
/// **Supported Charts:**
/// - Bubble charts (`BubbleChartWidget`)
///
/// **Parameters:**
/// - `point` - The hovered bubble data point, or null if mouse exited
/// - `datasetIndex` - The dataset index, or null if mouse exited
/// - `pointIndex` - The point index, or null if mouse exited
///
/// **Usage Notes:**
/// - This callback is nullable - if null, hover interactions are disabled
/// - **Platform Support:** Desktop and web only (mouse hover not available on mobile)
/// - The hover detection uses [ChartInteractionConstants.hoverRadius] * 3 for hit detection
///   (larger radius due to bubble size variability)
/// - All parameters are nullable - check for null to detect mouse exit
///
/// ## Example
/// ```dart
/// onBubbleHover: (point, datasetIndex, pointIndex) {
///   if (point != null) {
///     final bubble = point as BubbleDataPoint;
///     showTooltip('Value: ${bubble.y}, Size: ${bubble.size}');
///   } else {
///     hideTooltip();
///   }
/// }
/// ```
///
/// See also:
/// - `onBubbleTap` for tap events (all platforms)
/// - `ChartPointHoverCallback` for other point-based charts
/// - `ChartInteractionConstants` for interaction configuration
typedef BubbleHoverCallback = ChartPointHoverCallback;

/// Callback for chart background/empty area tap interactions.
///
/// Invoked when a user taps on an empty area of the chart (not on any data element).
/// Useful for deselecting items, closing menus, or resetting chart state.
///
/// **Supported Charts:**
/// - All chart types support this callback
///
/// **Parameters:**
/// - [position] - The global tap position where the user tapped
///
/// **Usage Notes:**
/// - This callback is nullable - if null, background taps are ignored
/// - Only fires when tapping on empty chart area (not on data points, bars, segments, etc.)
/// - Useful for implementing "tap to deselect" or "tap to close menu" behavior
///
/// ## Example
/// ```dart
/// onChartTap: (position) {
///   // Deselect all items
///   setState(() {
///     selectedItem = null;
///   });
///   // Close any open menus
///   ChartContextMenuHelper.hide();
/// }
/// ```
///
/// See also:
/// - [ChartPointCallback] for point tap events
/// - [PieSegmentCallback] for segment tap events
/// - [BarCallback] for bar tap events
typedef ChartTapCallback = void Function(Offset position);

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
/// - `ChartInteractionHelper` for finding interactions (import from utils)
/// - `ChartInteractionConstants` for interaction configuration
class ChartInteractionResult {
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
  }) : assert(
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
  int get hashCode =>
      Object.hash(point, segment, datasetIndex, elementIndex, isHit);
}
