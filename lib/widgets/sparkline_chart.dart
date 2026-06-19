import 'package:flutter/material.dart';
import 'package:save_points_chart/charts/sparkline_chart/sparkline_chart_renderer.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/widgets/chart_widget.dart';

/// Compact sparkline chart with full engine features (grid, axes, tooltips).
class SparklineChart extends StatelessWidget {
  const SparklineChart({
    super.key,
    required this.config,
    this.theme,
    this.showEndDot = true,
    this.fill = true,
  });

  final ChartConfig config;
  final ChartTheme? theme;
  final bool showEndDot;
  final bool fill;

  @override
  Widget build(BuildContext context) {
    return ChartWidget(
      config: config,
      theme: theme,
      enableZoomPan: false,
      enableCrosshair: false,
      renderers: [SparklineChartRenderer(showEndDot: showEndDot, fill: fill)],
    );
  }
}
