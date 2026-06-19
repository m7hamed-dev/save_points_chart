import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart' show Colors, FontWeight;
import 'package:save_points_chart/core/axis/axis_engine.dart';
import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/core/utils/series_paint.dart';
import 'package:save_points_chart/models/chart_point.dart';
import 'package:save_points_chart/models/chart_series.dart';

/// Canvas-based pie and donut chart renderer.
class PieChartRenderer extends ChartRenderer {
  const PieChartRenderer({
    this.isDonut = false,
    this.donutRadiusFactor = 0.55,
    this.explodedIndex,
    this.explodeDistance = 12,
  });

  final bool isDonut;
  final double donutRadiusFactor;
  final int? explodedIndex;
  final double explodeDistance;

  @override
  void draw(Canvas canvas, Size size, ChartContext context) {
    final series = context.config.series.isNotEmpty
        ? context.config.series.first
        : null;
    if (series == null || series.points.isEmpty) return;

    final anim = context.animationValue;
    final art = SeriesPaint(context.config.style);
    final total = series.points.fold<double>(0, (s, p) => s + p.y.abs());
    if (total == 0) return;

    final center = context.bounds.center;
    final radius =
        math.min(context.bounds.width, context.bounds.height) / 2 * 0.85;
    final innerRadius = isDonut ? radius * donutRadiusFactor : 0.0;

    if (context.config.showGrid) {
      final gridPaint = context.paintCache.get(
        key: 'pie-grid',
        color: context.theme.gridColor,
        strokeWidth: context.theme.gridStrokeWidth,
      );
      for (var i = 1; i <= 4; i++) {
        canvas.drawCircle(center, radius * i / 4, gridPaint);
      }
    }

    var startAngle = -math.pi / 2;

    for (var i = 0; i < series.points.length; i++) {
      final point = series.points[i];
      final sweep = (point.y.abs() / total) * 2 * math.pi * anim;
      final color = _sliceColor(context, series, point, i);

      var sliceCenter = center;
      if (explodedIndex == i) {
        final mid = startAngle + sweep / 2;
        sliceCenter =
            center +
            Offset(
              math.cos(mid) * explodeDistance,
              math.sin(mid) * explodeDistance,
            );
      }

      final rect = Rect.fromCircle(center: sliceCenter, radius: radius);
      final paint = art.blobFill(rect, color);

      if (isDonut) {
        final path = Path()
          ..addArc(rect, startAngle, sweep)
          ..arcTo(
            Rect.fromCircle(center: sliceCenter, radius: innerRadius),
            startAngle + sweep,
            -sweep,
            false,
          )
          ..close();
        canvas.drawPath(path, paint);
      } else {
        canvas.drawArc(rect, startAngle, sweep, true, paint);
      }

      if (context.hoveredHit?.pointIndex == i) {
        canvas.drawArc(
          rect,
          startAngle,
          sweep,
          true,
          context.paintCache.get(
            key: 'pie-hover',
            color: Colors.white.withValues(alpha: 0.25),
            strokeWidth: 2,
          ),
        );
      }

      startAngle += sweep;
    }

    _drawSliceBorders(
      canvas,
      context,
      center,
      radius,
      innerRadius,
      series.points,
      total,
      anim,
    );

    if (isDonut) {
      _drawCenterLabel(canvas, context, series);
    }

    if (context.config.showAxis) {
      _drawSliceLabels(canvas, context, series, center, radius, total, anim);
    }
    AxisEngine.drawAxisTitles(canvas, context);
  }

  Color _sliceColor(
    ChartContext context,
    ChartSeries series,
    ChartPoint point,
    int index,
  ) {
    final fromMeta = point.metadata['color'];
    if (fromMeta is Color) return fromMeta;
    if (series.points.length > 1) {
      return context.theme.seriesColor(index);
    }
    return series.style.color ?? context.theme.seriesColor(0);
  }

  void _drawSliceBorders(
    Canvas canvas,
    ChartContext context,
    Offset center,
    double radius,
    double innerRadius,
    List<ChartPoint> points,
    double total,
    double anim,
  ) {
    final borderPaint = context.paintCache.get(
      key: 'pie-slice-border',
      color: context.theme.sliceBorderColor,
      strokeWidth: context.theme.sliceBorderWidth,
    );
    var angle = -math.pi / 2;
    for (var i = 0; i < points.length; i++) {
      final sweep = (points[i].y.abs() / total) * 2 * math.pi * anim;
      _drawRadialBorder(
        canvas,
        center,
        radius,
        innerRadius,
        angle,
        borderPaint,
      );
      angle += sweep;
    }
    _drawRadialBorder(canvas, center, radius, innerRadius, angle, borderPaint);
  }

  void _drawRadialBorder(
    Canvas canvas,
    Offset center,
    double radius,
    double innerRadius,
    double angle,
    Paint paint,
  ) {
    final outer =
        center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
    final inner =
        center +
        Offset(math.cos(angle) * innerRadius, math.sin(angle) * innerRadius);
    canvas.drawLine(innerRadius > 0 ? inner : center, outer, paint);
  }

  void _drawSliceLabels(
    Canvas canvas,
    ChartContext context,
    ChartSeries series,
    Offset center,
    double radius,
    double total,
    double anim,
  ) {
    var startAngle = -math.pi / 2;
    for (var i = 0; i < series.points.length; i++) {
      final point = series.points[i];
      final sweep = (point.y.abs() / total) * 2 * math.pi * anim;
      final mid = startAngle + sweep / 2;
      final label = point.label;
      if (label != null && label.isNotEmpty) {
        final pos =
            center +
            Offset(
              math.cos(mid) * (radius + 12),
              math.sin(mid) * (radius + 12),
            );
        final builder =
            ParagraphBuilder(ParagraphStyle(textAlign: TextAlign.center))
              ..pushStyle(context.theme.axisTextStyle.getTextStyle())
              ..addText(label);
        final paragraph = builder.build()
          ..layout(const ParagraphConstraints(width: 80));
        canvas.drawParagraph(
          paragraph,
          pos - Offset(paragraph.maxIntrinsicWidth / 2, paragraph.height / 2),
        );
      }
      startAngle += sweep;
    }
  }

  void _drawCenterLabel(
    Canvas canvas,
    ChartContext context,
    ChartSeries series,
  ) {
    final builder =
        ParagraphBuilder(
            ParagraphStyle(
              textAlign: TextAlign.center,
              fontSize: (context.theme.axisTextStyle.fontSize ?? 11) + 4,
              fontWeight: FontWeight.bold,
            ),
          )
          ..pushStyle(context.theme.axisTextStyle.getTextStyle())
          ..addText(series.name);

    final paragraph = builder.build()
      ..layout(ParagraphConstraints(width: context.bounds.width * 0.4));
    final offset =
        context.bounds.center -
        Offset(paragraph.maxIntrinsicWidth / 2, paragraph.height / 2);
    canvas.drawParagraph(paragraph, offset);
  }

  @override
  List<HitRegion> hitRegions(ChartContext context) {
    final regions = <HitRegion>[];
    if (context.config.series.isEmpty) return regions;
    final series = context.config.series.first;

    final total = series.points.fold<double>(0, (s, p) => s + p.y.abs());
    if (total == 0) return regions;

    final center = context.bounds.center;
    final radius = math.min(context.bounds.width, context.bounds.height) / 2;
    var startAngle = -math.pi / 2;

    for (var i = 0; i < series.points.length; i++) {
      final point = series.points[i];
      final sweep = (point.y.abs() / total) * 2 * math.pi;
      final mid = startAngle + sweep / 2;
      final hitCenter =
          center +
          Offset(math.cos(mid) * radius * 0.6, math.sin(mid) * radius * 0.6);
      regions.add(
        HitRegion(
          bounds: Rect.fromCircle(center: hitCenter, radius: radius * 0.25),
          seriesId: series.id,
          pointIndex: i,
          dataY: point.y,
          dataPercent: total > 0 ? (point.y.abs() / total) * 100 : null,
          label: point.label,
        ),
      );
      startAngle += sweep;
    }
    return regions;
  }
}
