import 'package:flutter/material.dart';
import 'package:save_points_chart/charts/scatter_chart/scatter_chart_renderer.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/widgets/chart_widget.dart';

/// Scatter chart widget.
class ScatterChart extends StatelessWidget {
  const ScatterChart({
    super.key,
    required this.config,
    this.pointRadius = 5,
    this.theme,
  });

  final ChartConfig config;
  final double pointRadius;
  final ChartTheme? theme;

  @override
  Widget build(BuildContext context) {
    return ChartWidget(
      config: config,
      theme: theme,
      renderers: [ScatterChartRenderer(pointRadius: pointRadius)],
    );
  }
}
