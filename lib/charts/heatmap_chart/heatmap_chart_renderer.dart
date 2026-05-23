import 'dart:ui';

import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/core/utils/rounded_bar.dart';

/// Canvas-based heatmap renderer.
class HeatmapChartRenderer extends ChartRenderer {
  const HeatmapChartRenderer();

  @override
  void draw(Canvas canvas, Size size, ChartContext context) {
    final series = context.config.series.firstOrNull;
    if (series == null || series.points.isEmpty) return;

    final xs = series.points.map((p) => p.x).toSet().toList()..sort();
    final ys = series.points.map((p) => p.y).toSet().toList()..sort();
    final values = <String, double>{};
    var minVal = double.infinity;
    var maxVal = double.negativeInfinity;

    for (final p in series.points) {
      final key = '${p.x}_${p.y}';
      final v = (p.metadata['value'] as num?)?.toDouble() ?? p.y;
      values[key] = v;
      if (v < minVal) minVal = v;
      if (v > maxVal) maxVal = v;
    }

    final cellW = context.bounds.width / xs.length;
    final cellH = context.bounds.height / ys.length;
    final radius = context.config.barBorderRadius;

    for (final p in series.points) {
      final xi = xs.indexOf(p.x);
      final yi = ys.indexOf(p.y);
      final v = values['${p.x}_${p.y}'] ?? 0;
      final t = maxVal > minVal ? (v - minVal) / (maxVal - minVal) : 0.5;
      final color = Color.lerp(
        const Color(0xFF1565C0),
        const Color(0xFFE53935),
        t,
      )!;

      final rect = Rect.fromLTWH(
        context.bounds.left + xi * cellW,
        context.bounds.top + yi * cellH,
        cellW,
        cellH,
      ).deflate(1);

      drawRoundedBar(
        canvas,
        rect,
        radius: radius,
        paint: context.paintCache.fill('heat-${p.x}-${p.y}', color),
      );
    }
  }

  @override
  List<HitRegion> hitRegions(ChartContext context) {
    final regions = <HitRegion>[];
    final series = context.config.series.firstOrNull;
    if (series == null || series.points.isEmpty) return regions;

    final xs = series.points.map((p) => p.x).toSet().toList()..sort();
    final ys = series.points.map((p) => p.y).toSet().toList()..sort();
    final cellW = context.bounds.width / xs.length;
    final cellH = context.bounds.height / ys.length;

    for (var i = 0; i < series.points.length; i++) {
      final p = series.points[i];
      final xi = xs.indexOf(p.x);
      final yi = ys.indexOf(p.y);
      final value = (p.metadata['value'] as num?)?.toDouble() ?? p.y;
      final rect = Rect.fromLTWH(
        context.bounds.left + xi * cellW,
        context.bounds.top + yi * cellH,
        cellW,
        cellH,
      ).deflate(1);
      regions.add(
        HitRegion(
          bounds: rect,
          seriesId: series.id,
          pointIndex: i,
          dataX: p.x,
          dataY: p.y,
          label: p.label ?? '($xi, $yi): ${value.toStringAsFixed(1)}',
        ),
      );
    }
    return regions;
  }
}

extension _FirstOrNullHeat<T> on List<T> {
  T? get firstOrNull => isEmpty ? null : first;
}
