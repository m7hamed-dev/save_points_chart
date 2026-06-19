import 'dart:ui';

import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/core/utils/bezier.dart';
import 'package:save_points_chart/core/utils/series_paint.dart';
import 'package:save_points_chart/models/chart_point.dart';
import 'package:save_points_chart/models/chart_series.dart';

/// Line chart modes.
enum LineChartMode { straight, smooth }

/// Canvas-based line chart renderer.
class LineChartRenderer extends ChartRenderer {
  const LineChartRenderer({
    this.mode = LineChartMode.smooth,
    this.fillArea = false,
  });

  final LineChartMode mode;
  final bool fillArea;

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
        smooth: mode == LineChartMode.smooth,
      );

      if (fillArea && points.isNotEmpty) {
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
          SeriesPaint.verticalFill(
            context.bounds.rect,
            series.style.fillColor ?? color,
            topAlpha: 0.32,
          ),
        );
      }

      // Soft glow beneath the stroke for depth.
      canvas.drawPath(
        path,
        SeriesPaint.glow(
          color,
          strokeWidth: series.style.strokeWidth + 4,
          blur: 5,
        ),
      );

      // Gradient stroke (color → brighter accent).
      canvas.drawPath(
        path,
        SeriesPaint.strokeGradient(
          context.bounds.rect,
          color,
          strokeWidth: series.style.strokeWidth,
          opacity: series.style.opacity,
        ),
      );

      if (series.style.showMarkers) {
        _drawMarkers(canvas, context, points, series, color, s);
      }

      _drawHover(canvas, context, series, points, color);
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

  void _drawMarkers(
    Canvas canvas,
    ChartContext context,
    List<ChartPoint> points,
    ChartSeries series,
    Color color,
    int seriesIndex,
  ) {
    for (final point in points) {
      final pt = context.transformer.dataToCanvas(point.x, point.y);
      final r = series.style.markerRadius;
      if (context.theme.ringMarkers) {
        canvas.drawCircle(
          pt,
          r,
          context.paintCache.fill(
            'marker-fill-$seriesIndex',
            context.theme.markerCenterColor,
          ),
        );
        canvas.drawCircle(
          pt,
          r,
          context.paintCache.get(
            key: 'marker-ring-$seriesIndex',
            color: color,
            strokeWidth: 2,
          ),
        );
      } else {
        canvas.drawCircle(
          pt,
          r,
          context.paintCache.fill('marker-$seriesIndex', color),
        );
      }
    }
  }

  void _drawHover(
    Canvas canvas,
    ChartContext context,
    ChartSeries series,
    List<ChartPoint> points,
    Color color,
  ) {
    final hovered = context.hoveredHit;
    if (hovered == null || hovered.seriesId != series.id) return;
    final idx = hovered.pointIndex;
    if (idx < 0 || idx >= points.length) return;
    final pt = context.transformer.dataToCanvas(points[idx].x, points[idx].y);
    final r = series.style.markerRadius;
    // Soft blurred halo.
    final halo = Paint()
      ..color = color.withValues(alpha: 0.28)
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6)
      ..isAntiAlias = true;
    canvas.drawCircle(pt, r + 7, halo);
    // Outer color ring + light center for a crisp focus point.
    canvas.drawCircle(pt, r + 3, context.paintCache.fill('hover', color));
    canvas.drawCircle(
      pt,
      r,
      context.paintCache.fill('hover-center', context.theme.markerCenterColor),
    );
  }

  @override
  List<HitRegion> hitRegions(ChartContext context) {
    final regions = <HitRegion>[];
    for (final series in context.config.series) {
      for (var i = 0; i < series.points.length; i++) {
        final p = series.points[i];
        final canvas = context.transformer.dataToCanvas(p.x, p.y);
        final r = series.style.markerRadius + 8;
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
