import 'dart:ui';

import 'package:save_points_chart/core/axis/axis_engine.dart';
import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/layers/chart_layer.dart';

/// Renders X and Y axes with labels.
class AxisLayer extends ChartLayer {
  const AxisLayer({this.tickCount = 5});

  final int tickCount;

  @override
  int get zIndex => 20;

  @override
  bool get isStatic => true;

  @override
  void paint(Canvas canvas, Size size, ChartContext context) {
    if (context.config.showAxis) {
      AxisEngine.drawAxes(canvas, context, tickCount: tickCount);
    } else {
      AxisEngine.drawAxisTitles(canvas, context);
    }
  }
}
