import 'package:flutter/material.dart';
import 'package:save_points_chart/charts/line_chart/line_chart_renderer.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/widgets/chart_widget.dart';

/// Line chart widget.
class LineChart extends StatelessWidget {
  const LineChart({
    super.key,
    required this.config,
    this.mode = LineChartMode.smooth,
    this.theme,
    this.fillArea = false,
  });

  final ChartConfig config;
  final LineChartMode mode;
  final ChartTheme? theme;
  final bool fillArea;

  @override
  Widget build(BuildContext context) {
    return ChartWidget(
      config: config,
      theme: theme,
      renderers: [LineChartRenderer(mode: mode, fillArea: fillArea)],
    );
  }
}
