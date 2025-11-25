import 'chart_data.dart';

/// Callback for chart point interactions
typedef ChartPointCallback = void Function(ChartDataPoint point, int datasetIndex, int pointIndex);

/// Callback for pie chart segment interactions
typedef PieSegmentCallback = void Function(PieData segment, int segmentIndex);

/// Callback for bar chart interactions
typedef BarCallback = void Function(ChartDataPoint point, int datasetIndex, int barIndex);

/// Callback for mouse hover events on chart points
/// Called when mouse enters a point area
typedef ChartPointHoverCallback = void Function(ChartDataPoint? point, int? datasetIndex, int? pointIndex);

/// Callback for mouse hover events on pie segments
/// Called when mouse enters a segment area
typedef PieSegmentHoverCallback = void Function(PieData? segment, int? segmentIndex);

/// Callback for mouse hover events on bars
/// Called when mouse enters a bar area
typedef BarHoverCallback = void Function(ChartDataPoint? point, int? datasetIndex, int? barIndex);

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

