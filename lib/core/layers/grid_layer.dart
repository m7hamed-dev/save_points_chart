import 'dart:ui';

import 'package:save_points_chart/core/axis/axis_engine.dart';
import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/layers/chart_layer.dart';

/// Renders grid lines behind series data.
class GridLayer extends ChartLayer {
  const GridLayer({this.tickCount = 5});

  final int tickCount;

  @override
  int get zIndex => 10;

  @override
  bool get isStatic => true;

  @override
  void paint(Canvas canvas, Size size, ChartContext context) {
    if (!context.config.showGrid) return;
    AxisEngine.drawGrid(canvas, context, tickCount: tickCount);
  }
}
