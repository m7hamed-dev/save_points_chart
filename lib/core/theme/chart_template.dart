import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/models/chart_series.dart';
import 'package:save_points_chart/models/chart_template_style.dart';

/// Applies the shared dashboard design system to [ChartConfig] instances.
class ChartTemplate {
  const ChartTemplate._();

  static ChartTheme dashboardTheme() => ChartTheme.dashboard();

  /// Resolves theme + chrome defaults for the active template.
  static ChartConfig resolve(ChartConfig config, {ChartTheme? theme}) {
    if (config.template == ChartTemplateStyle.plain) {
      return config.copyWith(theme: theme ?? config.theme);
    }

    final resolvedTheme = theme ?? config.theme ?? dashboardTheme();
    final series = _enhanceSeries(config.series, resolvedTheme);
    final pieLike = _isPieLike(config);

    return config.copyWith(
      theme: resolvedTheme,
      series: series,
      showGrid: pieLike ? false : config.showGrid,
      showAxis: pieLike ? false : config.showAxis,
      showBorder: true,
      showLegend: config.showLegend || _shouldShowLegend(config),
      barBorderRadius: config.barBorderRadius < 4 ? 6 : config.barBorderRadius,
    );
  }

  static bool _isPieLike(ChartConfig config) {
    if (config.series.length != 1) return false;
    final points = config.series.first.points;
    return points.length >= 2 &&
        points.every((p) => p.label != null && p.label!.isNotEmpty);
  }

  static List<ChartSeries> _enhanceSeries(
    List<ChartSeries> series,
    ChartTheme theme,
  ) {
    return [
      for (var i = 0; i < series.length; i++)
        series[i].copyWith(
          style: series[i].style.copyWith(
            // Pie/donut: color per slice (point index), not one series color.
            color: _isSliceSeries(series[i])
                ? series[i].style.color
                : (series[i].style.color ?? theme.seriesColor(i)),
            showMarkers:
                series[i].style.showMarkers || series[i].points.length <= 12,
            markerRadius: series[i].style.markerRadius < 4
                ? 5.0
                : series[i].style.markerRadius,
            fillColor: _isSliceSeries(series[i])
                ? series[i].style.fillColor
                : (series[i].style.fillColor ??
                      theme.seriesColor(i).withValues(alpha: 0.25)),
          ),
        ),
    ];
  }

  /// Single series with labeled points (pie, donut) — colors use point index.
  static bool _isSliceSeries(ChartSeries series) {
    return series.points.length >= 2 &&
        series.points.every((p) => p.label != null && p.label!.isNotEmpty);
  }

  static bool _shouldShowLegend(ChartConfig config) {
    if (config.series.isEmpty) return false;
    final first = config.series.first;
    if (first.points.length > 1 &&
        first.points.any((p) => p.label != null && p.label!.isNotEmpty)) {
      return true;
    }
    return config.series.length > 1;
  }
}
