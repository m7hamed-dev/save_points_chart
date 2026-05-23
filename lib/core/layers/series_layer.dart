import 'dart:ui';

import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/core/layers/chart_layer.dart';

/// Renders chart series via registered renderers.
class SeriesLayer extends ChartLayer {
  const SeriesLayer({required this.renderers});

  final List<ChartRenderer> renderers;

  @override
  int get zIndex => 30;

  @override
  bool get isStatic => false;

  @override
  void paint(Canvas canvas, Size size, ChartContext context) {
    for (final renderer in renderers) {
      renderer.draw(canvas, size, context);
    }
  }
}
