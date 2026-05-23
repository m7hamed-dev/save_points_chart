import 'package:save_points_chart/core/engine/chart_renderer.dart';

/// Result of a canvas hit test against chart geometry.
class ChartHitResult {
  const ChartHitResult({required this.region, this.distance = 0});

  final HitRegion region;
  final double distance;

  String get seriesId => region.seriesId;
  int get pointIndex => region.pointIndex;
  double? get dataX => region.dataX;
  double? get dataY => region.dataY;
  double? get dataPercent => region.dataPercent;
  String? get label => region.label;
}
