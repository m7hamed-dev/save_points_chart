import 'package:flutter/material.dart';
import 'package:save_points_chart/charts/gauge_chart/gauge_chart_renderer.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/widgets/chart_widget.dart';

/// Gauge chart widget.
class GaugeChart extends StatelessWidget {
  const GaugeChart({
    super.key,
    required this.config,
    this.min = 0,
    this.max = 100,
    this.theme,
  });

  final ChartConfig config;
  final double min;
  final double max;
  final ChartTheme? theme;

  @override
  Widget build(BuildContext context) {
    return ChartWidget(
      config: config.copyWith(showGrid: false, showAxis: false),
      theme: theme,
      enableZoomPan: false,
      enableCrosshair: false,
      renderers: [GaugeChartRenderer(min: min, max: max)],
    );
  }
}
