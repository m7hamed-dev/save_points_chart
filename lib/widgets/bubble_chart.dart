import 'package:flutter/material.dart';
import 'package:save_points_chart/charts/bubble_chart/bubble_chart_renderer.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/models/chart_data.dart' show ChartPoint;
import 'package:save_points_chart/models/chart_point.dart' show ChartPoint;
import 'package:save_points_chart/widgets/chart_widget.dart';
import 'package:save_points_chart/widgets/chart_widget_controller.dart';

/// Bubble chart widget — point size from [ChartPoint.metadata] `size`.
class BubbleChart extends StatelessWidget {
  const BubbleChart({
    super.key,
    required this.config,
    this.controller,
    this.theme,
    this.minRadius = 4,
    this.maxRadius = 24,
    this.sizeKey = kBubbleSizeKey,
  });

  final ChartConfig config;
  final ChartWidgetController? controller;
  final ChartTheme? theme;
  final double minRadius;
  final double maxRadius;
  final String sizeKey;

  @override
  Widget build(BuildContext context) {
    return ChartWidget(
      config: config,
      controller: controller,
      theme: theme,
      renderers: [
        BubbleChartRenderer(
          minRadius: minRadius,
          maxRadius: maxRadius,
          sizeKey: sizeKey,
        ),
      ],
    );
  }
}
