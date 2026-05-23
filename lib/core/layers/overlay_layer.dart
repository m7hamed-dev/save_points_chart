import 'dart:ui';

import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/layers/chart_layer.dart';

/// Placeholder for plugin-driven canvas overlays (not tooltips).
class OverlayLayer extends ChartLayer {
  const OverlayLayer({this.customPaint});

  final void Function(Canvas canvas, Size size, ChartContext context)?
  customPaint;

  @override
  int get zIndex => 50;

  @override
  void paint(Canvas canvas, Size size, ChartContext context) {
    customPaint?.call(canvas, size, context);
  }
}
