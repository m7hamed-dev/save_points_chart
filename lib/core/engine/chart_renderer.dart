import 'dart:ui';

import 'package:save_points_chart/core/engine/chart_context.dart';

/// Base contract for all chart renderers.
abstract class ChartRenderer {
  const ChartRenderer();

  void draw(Canvas canvas, Size size, ChartContext context);

  /// Optional hit regions for interaction.
  List<HitRegion> hitRegions(ChartContext context) => const [];
}

/// A hit-testable region in canvas space.
class HitRegion {
  const HitRegion({
    required this.bounds,
    required this.seriesId,
    required this.pointIndex,
    this.dataX,
    this.dataY,
    this.dataPercent,
    this.label,
  });

  final Rect bounds;
  final String seriesId;
  final int pointIndex;
  final double? dataX;
  final double? dataY;
  final double? dataPercent;
  final String? label;

  bool contains(Offset position) => bounds.contains(position);
}
