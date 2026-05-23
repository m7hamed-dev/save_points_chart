import 'dart:math' as math;
import 'dart:ui';

import 'package:save_points_chart/core/axis/axis_engine.dart';
import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/models/chart_point.dart';

/// Canvas-based funnel chart — stage width proportional to value.
class FunnelChartRenderer extends ChartRenderer {
  const FunnelChartRenderer({
    this.gap = 4,
    this.labelStages = true,
    this.sortDescending = true,
  });

  final double gap;
  final bool labelStages;
  final bool sortDescending;

  @override
  void draw(Canvas canvas, Size size, ChartContext context) {
    final series = context.config.series.isNotEmpty
        ? context.config.series.first
        : null;
    if (series == null || series.points.isEmpty) return;

    final stages = _orderedStages(series.points, sortDescending);
    final indexByPoint = {
      for (var i = 0; i < series.points.length; i++) series.points[i]: i,
    };
    final maxValue = stages.fold<double>(0, (m, p) => math.max(m, p.y.abs()));
    if (maxValue == 0) return;

    final anim = context.animationValue;
    final bounds = context.bounds;
    final stageHeight =
        (bounds.height - gap * (stages.length - 1)) / stages.length;
    final maxWidth = bounds.width * 0.9;

    if (context.config.showGrid) {
      final gridPaint = context.paintCache.get(
        key: 'funnel-grid',
        color: context.theme.gridColor,
        strokeWidth: context.theme.gridStrokeWidth,
      );
      for (var g = 0; g <= stages.length; g++) {
        final y = bounds.top + g * (stageHeight + gap);
        canvas.drawLine(
          Offset(bounds.left, y),
          Offset(bounds.right, y),
          gridPaint,
        );
      }
    }

    for (var i = 0; i < stages.length; i++) {
      final point = stages[i];
      final value = point.y.abs() * anim;
      final widthTop = i == 0
          ? maxWidth * (value / maxValue)
          : maxWidth * (stages[i - 1].y.abs() / maxValue);
      final widthBottom = maxWidth * (value / maxValue);

      final top = bounds.top + i * (stageHeight + gap);
      final bottom = top + stageHeight;
      final centerX = bounds.center.dx;

      final path = Path()
        ..moveTo(centerX - widthTop / 2, top)
        ..lineTo(centerX + widthTop / 2, top)
        ..lineTo(centerX + widthBottom / 2, bottom)
        ..lineTo(centerX - widthBottom / 2, bottom)
        ..close();

      final color = series.style.color ?? context.theme.seriesColor(i);
      canvas.drawPath(
        path,
        context.paintCache.fill('funnel-$i', color.withValues(alpha: 0.9)),
      );

      if (context.hoveredHit?.pointIndex == indexByPoint[point]) {
        canvas.drawPath(
          path,
          context.paintCache.get(
            key: 'funnel-hover-$i',
            color: context.theme.crosshairColor,
            strokeWidth: 2,
          ),
        );
      }

      if (labelStages || context.config.showAxis) {
        _drawLabel(canvas, context, point, centerX, top + stageHeight / 2);
      }
    }

    AxisEngine.drawAxisTitles(canvas, context);
  }

  List<ChartPoint> _orderedStages(List<ChartPoint> points, bool descending) {
    final copy = List<ChartPoint>.from(points);
    copy.sort(
      (a, b) => descending
          ? b.y.abs().compareTo(a.y.abs())
          : a.y.abs().compareTo(b.y.abs()),
    );
    return copy;
  }

  void _drawLabel(
    Canvas canvas,
    ChartContext context,
    ChartPoint point,
    double centerX,
    double centerY,
  ) {
    final text = point.label ?? point.y.toStringAsFixed(0);
    final builder =
        ParagraphBuilder(
            ParagraphStyle(
              textAlign: TextAlign.center,
              fontSize: context.theme.axisTextStyle.fontSize ?? 11,
            ),
          )
          ..pushStyle(context.theme.axisTextStyle.getTextStyle())
          ..addText(text);

    final paragraph = builder.build()
      ..layout(ParagraphConstraints(width: context.bounds.width * 0.5));
    canvas.drawParagraph(
      paragraph,
      Offset(
        centerX - paragraph.maxIntrinsicWidth / 2,
        centerY - paragraph.height / 2,
      ),
    );
  }

  @override
  List<HitRegion> hitRegions(ChartContext context) {
    final regions = <HitRegion>[];
    final series = context.config.series.isNotEmpty
        ? context.config.series.first
        : null;
    if (series == null) return regions;

    final stages = _orderedStages(series.points, sortDescending);
    final indexByPoint = {
      for (var i = 0; i < series.points.length; i++) series.points[i]: i,
    };
    final maxValue = stages.fold<double>(0, (m, p) => math.max(m, p.y.abs()));
    if (maxValue == 0) return regions;

    final bounds = context.bounds;
    final stageHeight =
        (bounds.height - gap * (stages.length - 1)) / stages.length;
    final maxWidth = bounds.width * 0.9;

    for (var i = 0; i < stages.length; i++) {
      final point = stages[i];
      final widthTop = i == 0
          ? maxWidth * (stages[i].y.abs() / maxValue)
          : maxWidth * (stages[i - 1].y.abs() / maxValue);
      final widthBottom = maxWidth * (point.y.abs() / maxValue);
      final top = bounds.top + i * (stageHeight + gap);
      final bottom = top + stageHeight;
      final centerX = bounds.center.dx;
      final w = math.max(widthTop, widthBottom);

      regions.add(
        HitRegion(
          bounds: Rect.fromCenter(
            center: Offset(centerX, (top + bottom) / 2),
            width: w,
            height: stageHeight,
          ),
          seriesId: series.id,
          pointIndex: indexByPoint[point] ?? i,
          dataY: point.y,
          label: point.label,
        ),
      );
    }
    return regions;
  }
}
