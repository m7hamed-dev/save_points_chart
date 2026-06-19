import 'package:flutter/material.dart';
import 'package:save_points_chart/charts/candlestick_chart/candlestick_chart_renderer.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/widgets/chart_widget.dart';

/// Candlestick chart widget.
class CandlestickChart extends StatelessWidget {
  const CandlestickChart({super.key, required this.config,
    this.theme});

  final ChartConfig config;
  final ChartTheme? theme;

  @override
  Widget build(BuildContext context) {
    return ChartWidget(
      config: config,
      theme: theme,
      renderers: const [CandlestickChartRenderer()],
    );
  }
}
