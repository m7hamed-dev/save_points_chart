import 'package:flutter/material.dart';
import 'package:save_points_chart/charts/radar_chart/radar_chart_renderer.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/widgets/chart_widget.dart';
import 'package:save_points_chart/widgets/chart_widget_controller.dart';

/// Radar chart widget.
class RadarChart extends StatelessWidget {
  const RadarChart({super.key, required this.config,
    this.controller, this.theme});

  final ChartConfig config;
  final ChartWidgetController? controller;
  final ChartTheme? theme;

  @override
  Widget build(BuildContext context) {
    return ChartWidget(
      config: config,
      controller: controller,
      theme: theme,
      enableZoomPan: false,
      renderers: const [RadarChartRenderer()],
    );
  }
}
