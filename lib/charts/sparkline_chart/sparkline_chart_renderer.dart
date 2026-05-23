import 'dart:ui';

import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/core/utils/bezier.dart';
import 'package:save_points_chart/models/chart_point.dart';

/// Compact line chart without axes — ideal for inline KPIs.
class SparklineChartRenderer extends ChartRenderer {
  const SparklineChartRenderer({
    this.showEndDot = true,
    this.fill = true,
    this.strokeWidth = 1.5,
  });

  final bool showEndDot;
  final bool fill;
  final double strokeWidth;

  @override
  void draw(Canvas canvas, Size size, ChartContext context) {
    final bezier = BezierPathBuilder(tension: context.config.curveTension);
    final anim = context.animationValue;

    for (var s = 0; s < context.config.series.length; s++) {
      final series = context.config.series[s];
      if (series.points.isEmpty) continue;

      final color = series.style.color ?? context.theme.seriesColor(s);
      final points = _animatedPoints(series.points, anim, context);

      final path = bezier.buildFromPoints(
        points,
        context.transformer,
        smooth: points.length >= 3,
      );

      if (fill && points.isNotEmpty) {
        final fillPath = Path.from(path);
        final first = context.transformer.dataToCanvas(
          points.first.x,
          points.first.y,
        );
        final last = context.transformer.dataToCanvas(
          points.last.x,
          points.last.y,
        );
        fillPath
          ..lineTo(last.dx, context.bounds.bottom)
          ..lineTo(first.dx, context.bounds.bottom)
          ..close();

        canvas.drawPath(
          fillPath,
          context.paintCache.fill(
            'sparkline-fill-$s',
            (series.style.fillColor ?? color).withValues(alpha: 0.15),
          ),
        );
      }

      canvas.drawPath(
        path,
        context.paintCache.get(
          key: 'sparkline-$s',
          color: color.withValues(alpha: series.style.opacity),
          strokeWidth: series.style.strokeWidth > 0
              ? series.style.strokeWidth
              : strokeWidth,
        ),
      );

      if (showEndDot && points.isNotEmpty) {
        final last = points.last;
        canvas.drawCircle(
          context.transformer.dataToCanvas(last.x, last.y),
          series.style.markerRadius > 0 ? series.style.markerRadius : 3,
          context.paintCache.fill('sparkline-dot-$s', color),
        );
      }
    }
  }

  List<ChartPoint> _animatedPoints(
    List<ChartPoint> points,
    double t,
    ChartContext context,
  ) {
    if (t >= 1.0) return points;
    final baseY = context.viewport.minY;
    return points
        .map(
          (p) =>
              ChartPoint(x: p.x, y: baseY + (p.y - baseY) * t, label: p.label),
        )
        .toList();
  }

  @override
  List<HitRegion> hitRegions(ChartContext context) {
    final regions = <HitRegion>[];
    for (final series in context.config.series) {
      if (series.points.isEmpty) continue;
      final last = series.points.last;
      final canvas = context.transformer.dataToCanvas(last.x, last.y);
      regions.add(
        HitRegion(
          bounds: Rect.fromCircle(center: canvas, radius: 10),
          seriesId: series.id,
          pointIndex: series.points.length - 1,
          dataX: last.x,
          dataY: last.y,
          label: last.label ?? series.name,
        ),
      );
    }
    return regions;
  }
}
