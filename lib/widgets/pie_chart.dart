import 'package:flutter/material.dart';
import 'package:save_points_chart/charts/pie_chart/pie_chart_renderer.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/widgets/chart_widget.dart';

/// Pie or donut chart widget.
class PieChart extends StatelessWidget {
  const PieChart({
    super.key,
    required this.config,
    this.isDonut = false,
    this.explodedIndex,
    this.theme,
  });

  final ChartConfig config;
  final bool isDonut;
  final int? explodedIndex;
  final ChartTheme? theme;

  @override
  Widget build(BuildContext context) {
    return ChartWidget(
      config: config,
      theme: theme,
      enableZoomPan: false,
      enableCrosshair: false,
      renderers: [
        PieChartRenderer(isDonut: isDonut, explodedIndex: explodedIndex),
      ],
    );
  }
}
