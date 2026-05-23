import 'dart:ui';

import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/core/utils/rounded_bar.dart';

/// Timeline / Gantt-style chart renderer.
class TimelineChartRenderer extends ChartRenderer {
  const TimelineChartRenderer({this.rowHeight = 28});

  final double rowHeight;

  @override
  void draw(Canvas canvas, Size size, ChartContext context) {
    final radius = context.config.barBorderRadius;
    for (var s = 0; s < context.config.series.length; s++) {
      final series = context.config.series[s];
      final color = series.style.color ?? context.theme.seriesColor(s);
      final rowTop = context.bounds.top + s * rowHeight;

      for (final point in series.points) {
        final start = (point.metadata['start'] as num?)?.toDouble() ?? point.x;
        final end = (point.metadata['end'] as num?)?.toDouble() ?? point.y;

        final x1 = context.transformer.dataToCanvasX(start);
        final x2 = context.transformer.dataToCanvasX(end);
        final rect = Rect.fromLTRB(x1, rowTop + 4, x2, rowTop + rowHeight - 4);

        drawRoundedBar(
          canvas,
          rect,
          radius: radius,
          paint: context.paintCache.fill('timeline-$s', color),
        );

        if (point.label != null) {
          final builder = ParagraphBuilder(ParagraphStyle(fontSize: 10))
            ..pushStyle(context.theme.axisTextStyle.getTextStyle())
            ..addText(point.label!);
          final paragraph = builder.build()
            ..layout(ParagraphConstraints(width: rect.width));
          canvas.drawParagraph(paragraph, Offset(rect.left + 4, rect.top + 4));
        }
      }
    }
  }

  @override
  List<HitRegion> hitRegions(ChartContext context) {
    final regions = <HitRegion>[];
    for (var s = 0; s < context.config.series.length; s++) {
      final series = context.config.series[s];
      final rowTop = context.bounds.top + s * rowHeight;
      for (var i = 0; i < series.points.length; i++) {
        final point = series.points[i];
        final start = (point.metadata['start'] as num?)?.toDouble() ?? point.x;
        final end = (point.metadata['end'] as num?)?.toDouble() ?? point.y;
        final x1 = context.transformer.dataToCanvasX(start);
        final x2 = context.transformer.dataToCanvasX(end);
        final rect = Rect.fromLTRB(x1, rowTop + 4, x2, rowTop + rowHeight - 4);
        regions.add(
          HitRegion(
            bounds: rect,
            seriesId: series.id,
            pointIndex: i,
            dataX: start,
            dataY: end,
            label: point.label ?? series.name,
          ),
        );
      }
    }
    return regions;
  }
}
