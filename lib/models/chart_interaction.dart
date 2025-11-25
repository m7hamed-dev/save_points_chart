import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';

/// Constants for chart interaction
class ChartInteractionConstants {
  /// Standard tap radius for detecting point taps (in pixels)
  static const double tapRadius = 20.0;
  
  /// Hover radius for detecting point hovers (larger than tap for better UX)
  static const double hoverRadius = 30.0;
  
  /// Long press duration threshold (in milliseconds)
  static const int longPressDuration = 500;
}

/// Callback for chart point interactions
/// [position] is the global tap position for showing context menus
typedef ChartPointCallback = void Function(
  ChartDataPoint point,
  int datasetIndex,
  int pointIndex,
  Offset position,
);

/// Callback for pie chart segment interactions
/// [position] is the global tap position for showing context menus
typedef PieSegmentCallback = void Function(
  PieData segment,
  int segmentIndex,
  Offset position,
);

/// Callback for bar chart interactions
/// [position] is the global tap position for showing context menus
typedef BarCallback = void Function(
  ChartDataPoint point,
  int datasetIndex,
  int barIndex,
  Offset position,
);

/// Callback for mouse hover events on chart points
/// Called when mouse enters a point area
typedef ChartPointHoverCallback = void Function(
  ChartDataPoint? point,
  int? datasetIndex,
  int? pointIndex,
);

/// Callback for mouse hover events on pie segments
/// Called when mouse enters a segment area
typedef PieSegmentHoverCallback = void Function(
  PieData? segment,
  int? segmentIndex,
);

/// Callback for mouse hover events on bars
/// Called when mouse enters a bar area
typedef BarHoverCallback = void Function(
  ChartDataPoint? point,
  int? datasetIndex,
  int? barIndex,
);

/// Result of a chart interaction
class ChartInteractionResult {
  final ChartDataPoint? point;
  final PieData? segment;
  final int? datasetIndex;
  final int? elementIndex;
  final bool isHit;

  const ChartInteractionResult({
    this.point,
    this.segment,
    this.datasetIndex,
    this.elementIndex,
    this.isHit = false,
  });

  const ChartInteractionResult.none()
      : point = null,
        segment = null,
        datasetIndex = null,
        elementIndex = null,
        isHit = false;
}
