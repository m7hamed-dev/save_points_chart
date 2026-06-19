import 'dart:math' as math;
import 'dart:ui';

import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/core/utils/rounded_bar.dart';
import 'package:save_points_chart/core/utils/series_paint.dart';
import 'package:save_points_chart/models/chart_series.dart';

enum BarChartOrientation { vertical, horizontal }

enum BarChartLayout { grouped, stacked }

/// Canvas-based bar chart renderer.
class BarChartRenderer extends ChartRenderer {
  const BarChartRenderer({
    this.orientation = BarChartOrientation.vertical,
    this.layout = BarChartLayout.grouped,
  });

  final BarChartOrientation orientation;
  final BarChartLayout layout;

  @override
  void draw(Canvas canvas, Size size, ChartContext context) {
    final series = context.config.series;
    if (series.isEmpty) return;

    final anim = context.animationValue;
    final categories = _categories(series);
    final barCount = series.length;
    final groupWidth = context.bounds.width / math.max(categories.length, 1);
    final barWidth = groupWidth / (barCount + 1);

    for (var c = 0; c < categories.length; c++) {
      var stackBase = context.viewport.minY;

      for (var s = 0; s < series.length; s++) {
        final ser = series[s];
        final point = ser.points.where((p) => p.x == categories[c]).firstOrNull;
        if (point == null) continue;

        final color = ser.style.color ?? context.theme.seriesColor(s);
        final value = point.y * anim;
        final rect = _barRect(
          context,
          categoryIndex: c,
          seriesIndex: s,
          barCount: barCount,
          barWidth: barWidth,
          groupWidth: groupWidth,
          value: value,
          stackBase: stackBase,
        );

        if (layout == BarChartLayout.stacked) {
          stackBase += value;
        }

        final selected =
            context.selectedHit?.seriesId == ser.id &&
            context.selectedHit?.pointIndex == c;
        final paint = SeriesPaint.barGradient(
          rect,
          color,
          opacity: selected ? 0.78 : ser.style.opacity,
        );
        final baseY = context.transformer.dataToCanvasY(context.viewport.minY);
        drawVerticalBar(
          canvas,
          rect,
          radius: context.config.barBorderRadius,
          paint: paint,
          baseY: baseY,
        );
      }
    }
  }

  List<double> _categories(List<ChartSeries> series) {
    final set = <double>{};
    for (final s in series) {
      for (final p in s.points) {
        set.add(p.x);
      }
    }
    final list = set.toList()..sort();
    return list;
  }

  Rect _barRect(
    ChartContext context, {
    required int categoryIndex,
    required int seriesIndex,
    required int barCount,
    required double barWidth,
    required double groupWidth,
    required double value,
    required double stackBase,
  }) {
    final bounds = context.bounds;
    final baseY = context.transformer.dataToCanvasY(
      layout == BarChartLayout.stacked ? stackBase : context.viewport.minY,
    );
    final topY = context.transformer.dataToCanvasY(
      layout == BarChartLayout.stacked ? stackBase + value : value,
    );

    final groupLeft =
        bounds.left + categoryIndex * groupWidth + groupWidth * 0.1;
    final left = groupLeft + seriesIndex * barWidth;

    if (orientation == BarChartOrientation.vertical) {
      return Rect.fromLTRB(left, topY, left + barWidth * 0.8, baseY);
    }
    final x1 = context.transformer.dataToCanvasX(stackBase);
    final x2 = context.transformer.dataToCanvasX(
      layout == BarChartLayout.stacked ? stackBase + value : value,
    );
    final y = bounds.top + categoryIndex * (bounds.height / barCount);
    return Rect.fromLTRB(x1, y, x2, y + barWidth * 0.8);
  }

  @override
  List<HitRegion> hitRegions(ChartContext context) {
    final regions = <HitRegion>[];
    final categories = _categories(context.config.series);
    final barCount = context.config.series.length;
    final groupWidth = context.bounds.width / math.max(categories.length, 1);
    final barWidth = groupWidth / (barCount + 1);

    for (var c = 0; c < categories.length; c++) {
      var stackBase = context.viewport.minY;
      for (var s = 0; s < context.config.series.length; s++) {
        final ser = context.config.series[s];
        final point = ser.points.where((p) => p.x == categories[c]).firstOrNull;
        if (point == null) continue;
        final value = point.y;
        final rect = _barRect(
          context,
          categoryIndex: c,
          seriesIndex: s,
          barCount: barCount,
          barWidth: barWidth,
          groupWidth: groupWidth,
          value: value,
          stackBase: stackBase,
        );
        if (layout == BarChartLayout.stacked) stackBase += value;
        regions.add(
          HitRegion(
            bounds: rect,
            seriesId: ser.id,
            pointIndex: c,
            dataX: point.x,
            dataY: point.y,
            label: point.label ?? ser.name,
          ),
        );
      }
    }
    return regions;
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
