import 'package:flutter/material.dart';
import 'package:save_points_chart/charts/area_chart/area_chart_renderer.dart';
import 'package:save_points_chart/charts/line_chart/line_chart_renderer.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/widgets/chart_widget.dart';
import 'package:save_points_chart/widgets/chart_widget_controller.dart';

/// Area chart widget.
class AreaChart extends StatelessWidget {
  const AreaChart({
    super.key,
    required this.config,
    this.controller,
    this.mode = LineChartMode.smooth,
    this.theme,
  });

  final ChartConfig config;
  final ChartWidgetController? controller;
  final LineChartMode mode;
  final ChartTheme? theme;

  @override
  Widget build(BuildContext context) {
    return ChartWidget(
      config: config,
      controller: controller,
      theme: theme,
      renderers: [AreaChartRenderer(mode: mode)],
    );
  }
}
