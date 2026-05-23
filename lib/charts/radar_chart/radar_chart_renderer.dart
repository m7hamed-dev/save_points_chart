import 'dart:math' as math;
import 'dart:ui';

import 'package:save_points_chart/core/axis/axis_engine.dart';
import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/models/chart_series.dart';

/// Canvas-based radar / spider chart renderer.
class RadarChartRenderer extends ChartRenderer {
  const RadarChartRenderer({this.levels = 5});

  final int levels;

  @override
  void draw(Canvas canvas, Size size, ChartContext context) {
    final series = context.config.series;
    if (series.isEmpty) return;

    final pointCount = series.first.points.length;
    if (pointCount < 3) return;

    final center = context.bounds.center;
    final radius =
        math.min(context.bounds.width, context.bounds.height) / 2 * 0.8;
    final angleStep = 2 * math.pi / pointCount;

    if (context.config.showGrid) {
      _drawWeb(canvas, context, center, radius, pointCount, angleStep);
    }

    for (var s = 0; s < series.length; s++) {
      final ser = series[s];
      final color = ser.style.color ?? context.theme.seriesColor(s);
      final path = Path();
      final maxVal = ser.points.fold<double>(0, (m, p) => math.max(m, p.y));

      for (var i = 0; i < ser.points.length; i++) {
        final norm = maxVal > 0 ? ser.points[i].y / maxVal : 0;
        final r = radius * norm * context.animationValue;
        final angle = -math.pi / 2 + i * angleStep;
        final pt = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();

      canvas.drawPath(
        path,
        context.paintCache.fill('radar-fill-$s', color.withValues(alpha: 0.2)),
      );
      canvas.drawPath(
        path,
        context.paintCache.get(
          key: 'radar-$s',
          color: color,
          strokeWidth: ser.style.strokeWidth,
        ),
      );
    }

    if (context.config.showAxis) {
      _drawSpokeLabels(
        canvas,
        context,
        center,
        radius,
        series.first,
        angleStep,
      );
    }
    AxisEngine.drawAxisTitles(canvas, context);
  }

  void _drawSpokeLabels(
    Canvas canvas,
    ChartContext context,
    Offset center,
    double radius,
    ChartSeries series,
    double angleStep,
  ) {
    for (var i = 0; i < series.points.length; i++) {
      final point = series.points[i];
      final angle = -math.pi / 2 + i * angleStep;
      final label = point.label ?? 'Axis $i';
      final pos =
          center +
          Offset(
            math.cos(angle) * (radius + 14),
            math.sin(angle) * (radius + 14),
          );
      final builder =
          ParagraphBuilder(ParagraphStyle(textAlign: TextAlign.center))
            ..pushStyle(context.theme.axisTextStyle.getTextStyle())
            ..addText(label);
      final paragraph = builder.build()
        ..layout(const ParagraphConstraints(width: 72));
      canvas.drawParagraph(
        paragraph,
        pos - Offset(paragraph.maxIntrinsicWidth / 2, paragraph.height / 2),
      );
    }
  }

  void _drawWeb(
    Canvas canvas,
    ChartContext context,
    Offset center,
    double radius,
    int pointCount,
    double angleStep,
  ) {
    final gridPaint = context.paintCache.get(
      key: 'radar-grid',
      color: context.theme.gridColor,
    );

    for (var level = 1; level <= levels; level++) {
      final r = radius * level / levels;
      final path = Path();
      for (var i = 0; i < pointCount; i++) {
        final angle = -math.pi / 2 + i * angleStep;
        final pt = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
        if (i == 0) {
          path.moveTo(pt.dx, pt.dy);
        } else {
          path.lineTo(pt.dx, pt.dy);
        }
      }
      path.close();
      canvas.drawPath(path, gridPaint);
    }

    for (var i = 0; i < pointCount; i++) {
      final angle = -math.pi / 2 + i * angleStep;
      final end =
          center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
      canvas.drawLine(center, end, gridPaint);
    }
  }

  @override
  List<HitRegion> hitRegions(ChartContext context) {
    final regions = <HitRegion>[];
    final series = context.config.series;
    if (series.isEmpty) return regions;

    final pointCount = series.first.points.length;
    if (pointCount < 3) return regions;

    final center = context.bounds.center;
    final radius =
        math.min(context.bounds.width, context.bounds.height) / 2 * 0.8;
    final angleStep = 2 * math.pi / pointCount;

    for (var s = 0; s < series.length; s++) {
      final ser = series[s];
      final maxVal = ser.points.fold<double>(0, (m, p) => math.max(m, p.y));
      for (var i = 0; i < ser.points.length; i++) {
        final norm = maxVal > 0 ? ser.points[i].y / maxVal : 0;
        final r = radius * norm;
        final angle = -math.pi / 2 + i * angleStep;
        final pt = center + Offset(math.cos(angle) * r, math.sin(angle) * r);
        regions.add(
          HitRegion(
            bounds: Rect.fromCircle(center: pt, radius: 12),
            seriesId: ser.id,
            pointIndex: i,
            dataY: ser.points[i].y,
            label: ser.points[i].label ?? ser.name,
          ),
        );
      }
    }
    return regions;
  }
}
