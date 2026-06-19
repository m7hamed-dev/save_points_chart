import 'dart:ui';

import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/core/utils/series_paint.dart';

/// Canvas-based scatter plot renderer.
class ScatterChartRenderer extends ChartRenderer {
  const ScatterChartRenderer({this.pointRadius = 5});

  final double pointRadius;

  @override
  void draw(Canvas canvas, Size size, ChartContext context) {
    final anim = context.animationValue;
    final art = SeriesPaint(context.config.style);

    for (var s = 0; s < context.config.series.length; s++) {
      final series = context.config.series[s];
      final color = series.style.color ?? context.theme.seriesColor(s);
      final glow = art.glow(color, strokeWidth: 0, blur: 4)
        ..style = PaintingStyle.fill;

      for (final point in series.points) {
        final y =
            context.viewport.minY + (point.y - context.viewport.minY) * anim;
        final offset = context.transformer.dataToCanvas(point.x, y);
        final rect = Rect.fromCircle(center: offset, radius: pointRadius);
        // Soft glow (skipped in flat style) then a style-aware point fill.
        canvas.drawCircle(offset, pointRadius + 2, glow);
        canvas.drawCircle(
          offset,
          pointRadius,
          art.blobFill(rect, color, opacity: series.style.opacity),
        );
      }
    }
  }

  @override
  List<HitRegion> hitRegions(ChartContext context) {
    final regions = <HitRegion>[];
    for (final series in context.config.series) {
      for (var i = 0; i < series.points.length; i++) {
        final p = series.points[i];
        final canvas = context.transformer.dataToCanvas(p.x, p.y);
        regions.add(
          HitRegion(
            bounds: Rect.fromCircle(center: canvas, radius: pointRadius + 6),
            seriesId: series.id,
            pointIndex: i,
            dataX: p.x,
            dataY: p.y,
            label: p.label ?? series.name,
          ),
        );
      }
    }
    return regions;
  }
}
