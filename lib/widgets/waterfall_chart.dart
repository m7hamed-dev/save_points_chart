import 'package:flutter/material.dart';
import 'package:save_points_chart/charts/waterfall_chart/waterfall_chart_renderer.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/models/chart_point.dart';
import 'package:save_points_chart/widgets/chart_widget.dart';
import 'package:save_points_chart/widgets/chart_widget_controller.dart';

/// Waterfall chart widget.
class WaterfallChart extends StatelessWidget {
  const WaterfallChart({
    super.key,
    required this.config,
    this.controller,
    this.theme,
    this.valueMode = WaterfallValueMode.delta,
    this.barWidthFactor = 0.55,
    this.connectorLines = true,
  });

  final ChartConfig config;
  final ChartWidgetController? controller;
  final ChartTheme? theme;
  final WaterfallValueMode valueMode;
  final double barWidthFactor;
  final bool connectorLines;

  @override
  Widget build(BuildContext context) {
    final points = config.series.isNotEmpty
        ? config.series.first.points
        : const <ChartPoint>[];
    final resolved = config.copyWith(
      viewport:
          config.viewport ??
          WaterfallChartRenderer.waterfallViewport(points, mode: valueMode),
    );
    return ChartWidget(
      config: resolved,
      controller: controller,
      theme: theme,
      renderers: [
        WaterfallChartRenderer(
          valueMode: valueMode,
          barWidthFactor: barWidthFactor,
          connectorLines: connectorLines,
        ),
      ],
    );
  }
}
