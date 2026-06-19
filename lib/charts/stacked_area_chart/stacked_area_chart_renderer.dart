import 'dart:ui';

import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/core/utils/bezier.dart';
import 'package:save_points_chart/core/utils/series_paint.dart';
import 'package:save_points_chart/models/chart_point.dart';
import 'package:save_points_chart/models/chart_series.dart';
import 'package:save_points_chart/models/viewport.dart';

/// Stacked area chart — multiple series summed per category on the X axis.
class StackedAreaChartRenderer extends ChartRenderer {
  const StackedAreaChartRenderer({this.smooth = true});

  final bool smooth;

  @override
  void draw(Canvas canvas, Size size, ChartContext context) {
    final categories = stackedAreaCategories(context.config.series);
    if (categories.isEmpty) return;

    final bezier = BezierPathBuilder(tension: context.config.curveTension);
    final anim = context.animationValue;
    final art = SeriesPaint(context.config.style);
    final seriesCount = context.config.series.length;

    for (var s = seriesCount - 1; s >= 0; s--) {
      final series = context.config.series[s];
      final color = series.style.color ?? context.theme.seriesColor(s);
      final topPoints = <ChartPoint>[];
      final bottomPoints = <ChartPoint>[];

      for (final x in categories) {
        final bottom = _stackValueAt(context.config.series, categories, x, s);
        final top = _stackValueAt(context.config.series, categories, x, s + 1);
        final baseY = context.viewport.minY;
        topPoints.add(ChartPoint(x: x, y: baseY + (top - baseY) * anim));
        bottomPoints.add(ChartPoint(x: x, y: baseY + (bottom - baseY) * anim));
      }

      final topPath = bezier.buildFromPoints(
        topPoints,
        context.transformer,
        smooth: smooth && topPoints.length >= 3,
      );
      final bottomPath = bezier.buildFromPoints(
        bottomPoints.reversed.toList(),
        context.transformer,
        smooth: smooth && bottomPoints.length >= 3,
      );

      final areaPath = Path.from(topPath)
        ..addPath(bottomPath, Offset.zero)
        ..close();

      canvas.drawPath(
        areaPath,
        art.bandFill(
          context.bounds.rect,
          series.style.fillColor ?? color,
          opacity: series.style.opacity,
        ),
      );

      canvas.drawPath(
        topPath,
        art.stroke(
          context.bounds.rect,
          color,
          strokeWidth: series.style.strokeWidth,
        ),
      );
    }
  }

  @override
  List<HitRegion> hitRegions(ChartContext context) {
    final regions = <HitRegion>[];
    final categories = stackedAreaCategories(context.config.series);

    for (var c = 0; c < categories.length; c++) {
      final x = categories[c];
      for (var s = 0; s < context.config.series.length; s++) {
        final series = context.config.series[s];
        final point = series.points.where((p) => p.x == x).firstOrNull;
        if (point == null) continue;

        final bottom = _stackValueAt(context.config.series, categories, x, s);
        final top = _stackValueAt(context.config.series, categories, x, s + 1);
        final midY = (bottom + top) / 2;
        final center = context.transformer.dataToCanvas(x, midY);
        final halfW = context.bounds.width / categories.length / 2;

        regions.add(
          HitRegion(
            bounds: Rect.fromCenter(
              center: center,
              width: halfW,
              height:
                  (top - bottom) /
                  context.viewport.height *
                  context.bounds.height,
            ),
            seriesId: series.id,
            pointIndex: c,
            dataX: x,
            dataY: point.y,
            label: point.label ?? series.name,
          ),
        );
      }
    }
    return regions;
  }

  /// Sorted unique X values across all series.
  static List<double> stackedAreaCategories(List<ChartSeries> series) {
    final set = <double>{};
    for (final s in series) {
      for (final p in s.points) {
        set.add(p.x);
      }
    }
    return set.toList()..sort();
  }

  /// Cumulative Y up to [seriesLimit] (exclusive) at [x].
  static double _stackValueAt(
    List<ChartSeries> series,
    List<double> categories,
    double x,
    int seriesLimit,
  ) {
    var sum = 0.0;
    for (var i = 0; i < seriesLimit && i < series.length; i++) {
      final point = series[i].points.where((p) => p.x == x).firstOrNull;
      if (point != null) sum += point.y;
    }
    return sum;
  }

  /// Viewport with Y max = highest stacked total.
  static ChartViewport stackedAreaViewport(
    List<ChartSeries> series, {
    double padding = 0.05,
  }) {
    final categories = stackedAreaCategories(series);
    final xs = categories;
    final ys = <double>[0];
    for (final x in categories) {
      ys.add(_stackValueAt(series, categories, x, series.length));
    }
    return ChartViewport.fromPoints(xs, ys, padding: padding);
  }
}

extension _FirstOrNull<E> on Iterable<E> {
  E? get firstOrNull {
    final it = iterator;
    if (!it.moveNext()) return null;
    return it.current;
  }
}
