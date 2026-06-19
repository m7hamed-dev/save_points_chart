import 'package:flutter/material.dart';
import 'package:save_points_chart/charts/stacked_area_chart/stacked_area_chart_renderer.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/widgets/chart_widget.dart';

/// Stacked area chart widget.
class StackedAreaChart extends StatelessWidget {
  const StackedAreaChart({
    super.key,
    required this.config,
    this.theme,
    this.smooth = true,
  });

  final ChartConfig config;
  final ChartTheme? theme;
  final bool smooth;

  @override
  Widget build(BuildContext context) {
    final resolved = config.copyWith(
      viewport:
          config.viewport ??
          StackedAreaChartRenderer.stackedAreaViewport(config.series),
    );
    return ChartWidget(
      config: resolved,
      theme: theme,
      renderers: [StackedAreaChartRenderer(smooth: smooth)],
    );
  }
}
