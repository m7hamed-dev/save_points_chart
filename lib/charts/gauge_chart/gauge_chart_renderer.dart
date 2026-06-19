import 'dart:math' as math;
import 'dart:ui';

import 'package:save_points_chart/core/axis/axis_engine.dart';
import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/core/utils/series_paint.dart';

/// Semi-circular gauge chart renderer.
class GaugeChartRenderer extends ChartRenderer {
  const GaugeChartRenderer({
    this.min = 0,
    this.max = 100,
    this.startAngle = math.pi,
    this.sweepAngle = math.pi,
    this.showGrid = true,
    this.showAxis = true,
  });

  final double min;
  final double max;
  final double startAngle;
  final double sweepAngle;
  final bool showGrid;
  final bool showAxis;

  @override
  void draw(Canvas canvas, Size size, ChartContext context) {
    final value =
        context.config.series.isNotEmpty &&
            context.config.series.first.points.isNotEmpty
        ? context.config.series.first.points.first.y
        : 0.0;

    final t =
        ((value - min) / (max - min)).clamp(0.0, 1.0) * context.animationValue;

    final radius = math.min(context.bounds.width, context.bounds.height) * 0.42;
    final center = Offset(
      context.bounds.center.dx,
      context.bounds.center.dy + context.bounds.height * 0.22,
    );

    if (showGrid) {
      final gridPaint = context.paintCache.get(
        key: 'gauge-grid',
        color: context.theme.gridColor,
        strokeWidth: context.theme.gridStrokeWidth,
      );
      for (var i = 1; i <= 4; i++) {
        final angle = startAngle + sweepAngle * i / 4;
        final inner =
            center +
            Offset(
              math.cos(angle) * radius * 0.7,
              math.sin(angle) * radius * 0.7,
            );
        final outer =
            center + Offset(math.cos(angle) * radius, math.sin(angle) * radius);
        canvas.drawLine(inner, outer, gridPaint);
      }
    }

    final arcRect = Rect.fromCircle(center: center, radius: radius);
    final color = context.theme.seriesColor(0);

    final trackPaint = context.paintCache.get(
      key: 'gauge-track',
      color: context.theme.gridColor,
      strokeWidth: 14,
    );
    canvas.drawArc(arcRect, startAngle, sweepAngle, false, trackPaint);

    if (t > 0) {
      // Glow underlay.
      canvas.drawArc(
        arcRect,
        startAngle,
        sweepAngle * t,
        false,
        SeriesPaint.glow(color, strokeWidth: 18, blur: 7),
      );
      // Gradient value arc (color → brighter accent) with rounded ends.
      final valuePaint = Paint()
        ..shader = Gradient.sweep(
          center,
          [color, SeriesPaint.accent(color)],
          null,
          TileMode.clamp,
          startAngle,
          startAngle + sweepAngle,
        )
        ..strokeWidth = 14
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round
        ..isAntiAlias = true;
      canvas.drawArc(arcRect, startAngle, sweepAngle * t, false, valuePaint);
    }

    if (showAxis) {
      _drawMinMaxLabels(canvas, context, center, radius);
    }

    final builder =
        ParagraphBuilder(
            ParagraphStyle(
              textAlign: TextAlign.center,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          )
          ..pushStyle(context.theme.axisTextStyle.getTextStyle())
          ..addText((value * context.animationValue).toStringAsFixed(0));

    final paragraph = builder.build()
      ..layout(const ParagraphConstraints(width: 120));
    canvas.drawParagraph(
      paragraph,
      center - Offset(paragraph.maxIntrinsicWidth / 2, radius * 0.5),
    );

    AxisEngine.drawAxisTitles(canvas, context);
  }

  void _drawMinMaxLabels(
    Canvas canvas,
    ChartContext context,
    Offset center,
    double radius,
  ) {
    final style = context.theme.axisTextStyle;
    for (final entry in [(min, startAngle), (max, startAngle + sweepAngle)]) {
      final label = entry.$1.toStringAsFixed(0);
      final angle = entry.$2;
      final pos =
          center +
          Offset(
            math.cos(angle) * (radius + 16),
            math.sin(angle) * (radius + 16),
          );
      final builder =
          ParagraphBuilder(ParagraphStyle(textAlign: TextAlign.center))
            ..pushStyle(style.getTextStyle())
            ..addText(label);
      final paragraph = builder.build()
        ..layout(const ParagraphConstraints(width: 40));
      canvas.drawParagraph(
        paragraph,
        pos - Offset(paragraph.maxIntrinsicWidth / 2, paragraph.height / 2),
      );
    }
  }

  @override
  List<HitRegion> hitRegions(ChartContext context) {
    final radius = math.min(context.bounds.width, context.bounds.height) * 0.42;
    final center = Offset(
      context.bounds.center.dx,
      context.bounds.center.dy + context.bounds.height * 0.22,
    );
    final series = context.config.series.isNotEmpty
        ? context.config.series.first
        : null;
    final value = series != null && series.points.isNotEmpty
        ? series.points.first.y
        : 0.0;
    return [
      HitRegion(
        bounds: Rect.fromCircle(center: center, radius: radius + 20),
        seriesId: series?.id ?? 'gauge',
        pointIndex: 0,
        dataY: value,
        label: series?.name ?? 'Value',
      ),
    ];
  }
}
