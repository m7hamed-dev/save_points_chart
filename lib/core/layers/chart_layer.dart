import 'dart:ui';

import 'package:save_points_chart/core/engine/chart_context.dart';

/// A single render layer in the chart pipeline.
abstract class ChartLayer {
  const ChartLayer();

  /// Layer z-order — lower renders first.
  int get zIndex;

  void paint(Canvas canvas, Size size, ChartContext context);

  bool get isStatic => true;
}
