import 'dart:ui';

import 'package:save_points_chart/core/chrome/chart_chrome.dart';
import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/layers/chart_layer.dart';

/// Renders title and legend chrome above series data.
class ChromeLayer extends ChartLayer {
  const ChromeLayer();

  @override
  int get zIndex => 90;

  @override
  void paint(Canvas canvas, Size size, ChartContext context) {
    ChartChrome.drawTitle(canvas, size, context);
    ChartChrome.drawSubtitle(canvas, size, context);
    ChartChrome.drawLegend(canvas, size, context);
  }
}
