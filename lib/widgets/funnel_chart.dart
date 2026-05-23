import 'package:flutter/material.dart';
import 'package:save_points_chart/charts/funnel_chart/funnel_chart_renderer.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/widgets/chart_widget.dart';
import 'package:save_points_chart/widgets/chart_widget_controller.dart';

/// Funnel chart widget.
class FunnelChart extends StatelessWidget {
  const FunnelChart({
    super.key,
    required this.config,
    this.controller,
    this.theme,
    this.gap = 4,
    this.labelStages = true,
    this.sortDescending = true,
  });

  final ChartConfig config;
  final ChartWidgetController? controller;
  final ChartTheme? theme;
  final double gap;
  final bool labelStages;
  final bool sortDescending;

  @override
  Widget build(BuildContext context) {
    return ChartWidget(
      config: config,
      controller: controller,
      theme: theme,
      renderers: [
        FunnelChartRenderer(
          gap: gap,
          labelStages: labelStages,
          sortDescending: sortDescending,
        ),
      ],
    );
  }
}
