import 'package:flutter/foundation.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/models/chart_series.dart';
import 'package:save_points_chart/models/chart_style.dart';
import 'package:save_points_chart/models/chart_template_style.dart';
import 'package:save_points_chart/models/legend_position.dart';
import 'package:save_points_chart/models/viewport.dart';

/// Global configuration for a chart instance.
@immutable
class ChartConfig {
  const ChartConfig({
    this.series = const [],
    this.viewport,
    this.theme,
    this.template = ChartTemplateStyle.dashboard,
    this.style = ChartStyle.gradient,
    this.showGrid = true,
    this.showAxis = true,
    this.xAxisTitle,
    this.yAxisTitle,
    this.title,
    this.subtitle,
    this.showLegend = false,
    this.legendPosition = LegendPosition.bottom,
    this.showBorder = false,
    this.barBorderRadius = 4,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 300),
    this.curveTension = 0.35,
    this.semanticLabel,
  });

  final List<ChartSeries> series;
  final ChartViewport? viewport;
  final ChartTheme? theme;
  final ChartTemplateStyle template;
  final ChartStyle style;
  final bool showGrid;
  final bool showAxis;
  final String? xAxisTitle;
  final String? yAxisTitle;
  final String? title;
  final String? subtitle;
  final bool showLegend;
  final LegendPosition legendPosition;
  final bool showBorder;
  final double barBorderRadius;
  final bool animate;
  final Duration animationDuration;
  final double curveTension;
  final String? semanticLabel;

  ChartConfig copyWith({
    List<ChartSeries>? series,
    ChartViewport? viewport,
    ChartTheme? theme,
    ChartTemplateStyle? template,
    ChartStyle? style,
    bool? showGrid,
    bool? showAxis,
    String? xAxisTitle,
    String? yAxisTitle,
    String? title,
    String? subtitle,
    bool? showLegend,
    LegendPosition? legendPosition,
    bool? showBorder,
    double? barBorderRadius,
    bool? animate,
    Duration? animationDuration,
    double? curveTension,
    String? semanticLabel,
  }) {
    return ChartConfig(
      series: series ?? this.series,
      viewport: viewport ?? this.viewport,
      theme: theme ?? this.theme,
      template: template ?? this.template,
      style: style ?? this.style,
      showGrid: showGrid ?? this.showGrid,
      showAxis: showAxis ?? this.showAxis,
      xAxisTitle: xAxisTitle ?? this.xAxisTitle,
      yAxisTitle: yAxisTitle ?? this.yAxisTitle,
      title: title ?? this.title,
      subtitle: subtitle ?? this.subtitle,
      showLegend: showLegend ?? this.showLegend,
      legendPosition: legendPosition ?? this.legendPosition,
      showBorder: showBorder ?? this.showBorder,
      barBorderRadius: barBorderRadius ?? this.barBorderRadius,
      animate: animate ?? this.animate,
      animationDuration: animationDuration ?? this.animationDuration,
      curveTension: curveTension ?? this.curveTension,
      semanticLabel: semanticLabel ?? this.semanticLabel,
    );
  }
}
