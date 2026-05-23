import 'package:flutter/material.dart';
import 'package:save_points_chart/charts/candlestick_chart/candlestick_chart_renderer.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/widgets/chart_widget.dart';
import 'package:save_points_chart/widgets/chart_widget_controller.dart';

/// Candlestick chart widget.
class CandlestickChart extends StatelessWidget {
  const CandlestickChart({super.key, required this.config,
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
      renderers: const [CandlestickChartRenderer()],
    );
  }
}
