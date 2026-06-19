import 'dart:ui';

import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/core/utils/series_paint.dart';
import 'package:save_points_chart/models/chart_point.dart';
import 'package:save_points_chart/models/chart_series.dart';

/// Metadata key for bubble radius in data units before scaling.
const String kBubbleSizeKey = 'size';

/// Canvas-based bubble chart — scatter with variable point size.
class BubbleChartRenderer extends ChartRenderer {
  const BubbleChartRenderer({
    this.minRadius = 4,
    this.maxRadius = 24,
    this.sizeKey = kBubbleSizeKey,
  });

  final double minRadius;
  final double maxRadius;
  final String sizeKey;

  @override
  void draw(Canvas canvas, Size size, ChartContext context) {
    final anim = context.animationValue;
    final sizeRange = _globalSizeRange(context.config.series);

    for (var s = 0; s < context.config.series.length; s++) {
      final series = context.config.series[s];
      final color = series.style.color ?? context.theme.seriesColor(s);

      for (final point in series.points) {
        final y =
            context.viewport.minY + (point.y - context.viewport.minY) * anim;
        final offset = context.transformer.dataToCanvas(point.x, y);
        final radius = _radiusFor(point, sizeRange);
        final rect = Rect.fromCircle(center: offset, radius: radius);
        canvas.drawCircle(
          offset,
          radius,
          SeriesPaint.radialFill(
            rect,
            color,
            opacity: series.style.opacity.clamp(0.0, 1.0) * 0.9,
          ),
        );

        if (series.style.strokeWidth > 0) {
          canvas.drawCircle(
            offset,
            radius,
            context.paintCache.get(
              key: 'bubble-stroke-$s',
              color: SeriesPaint.lighten(color, 0.1).withValues(alpha: 0.5),
              strokeWidth: series.style.strokeWidth,
            ),
          );
        }
      }
    }
  }

  (double min, double max) _globalSizeRange(List<ChartSeries> series) {
    var min = double.infinity;
    var max = double.negativeInfinity;
    for (final s in series) {
      for (final p in s.points) {
        final v = _rawSize(p);
        if (v < min) min = v;
        if (v > max) max = v;
      }
    }
    if (min == double.infinity) return (1, 1);
    if (min == max) return (min, min + 1);
    return (min, max);
  }

  double _rawSize(ChartPoint point) {
    final raw = point.metadata[sizeKey];
    if (raw is num) return raw.toDouble();
    return 1;
  }

  double _radiusFor(ChartPoint point, (double min, double max) range) {
    final value = _rawSize(point);
    if (range.$1 == range.$2) {
      return (minRadius + maxRadius) / 2;
    }
    final t = (value - range.$1) / (range.$2 - range.$1);
    return minRadius + t * (maxRadius - minRadius);
  }

  @override
  List<HitRegion> hitRegions(ChartContext context) {
    final regions = <HitRegion>[];
    final sizeRange = _globalSizeRange(context.config.series);

    for (final series in context.config.series) {
      for (var i = 0; i < series.points.length; i++) {
        final p = series.points[i];
        final canvas = context.transformer.dataToCanvas(p.x, p.y);
        final r = _radiusFor(p, sizeRange) + 4;
        regions.add(
          HitRegion(
            bounds: Rect.fromCircle(center: canvas, radius: r),
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
