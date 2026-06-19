import 'package:flutter/material.dart';
import 'package:save_points_chart/charts/bar_chart/bar_chart_renderer.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/widgets/chart_widget.dart';

/// Bar chart widget.
class BarChart extends StatelessWidget {
  const BarChart({
    super.key,
    required this.config,
    this.orientation = BarChartOrientation.vertical,
    this.layout = BarChartLayout.grouped,
    this.theme,
  });

  final ChartConfig config;
  final BarChartOrientation orientation;
  final BarChartLayout layout;
  final ChartTheme? theme;

  @override
  Widget build(BuildContext context) {
    return ChartWidget(
      config: config,
      theme: theme,
      renderers: [BarChartRenderer(orientation: orientation, layout: layout)],
    );
  }
}
