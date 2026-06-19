import 'dart:ui';

import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/core/utils/rounded_bar.dart';
import 'package:save_points_chart/core/utils/series_paint.dart';
import 'package:save_points_chart/models/chart_point.dart';
import 'package:save_points_chart/models/viewport.dart';

/// How each point's [ChartPoint.y] is interpreted.
enum WaterfallValueMode {
  /// Each [ChartPoint.y] is added to the running total (default).
  delta,

  /// Each [ChartPoint.y] is an absolute bar height from zero.
  absolute,
}

/// Metadata key for waterfall bar type. Values: `delta`, `total`, `subtotal`.
const String kWaterfallTypeKey = 'waterfallType';

/// Canvas-based waterfall chart renderer.
class WaterfallChartRenderer extends ChartRenderer {
  const WaterfallChartRenderer({
    this.valueMode = WaterfallValueMode.delta,
    this.barWidthFactor = 0.55,
    this.connectorLines = true,
  });

  final WaterfallValueMode valueMode;
  final double barWidthFactor;
  final bool connectorLines;

  @override
  void draw(Canvas canvas, Size size, ChartContext context) {
    final series = context.config.series.isNotEmpty
        ? context.config.series.first
        : null;
    if (series == null || series.points.isEmpty) return;

    final segments = _buildSegments(series.points);
    if (segments.isEmpty) return;

    final anim = context.animationValue;
    final color = series.style.color ?? context.theme.seriesColor(0);
    final negColor = context.theme.seriesColor(1);
    final art = SeriesPaint(context.config.style);

    final categoryCount = segments.length;
    final slotWidth = context.bounds.width / categoryCount;

    for (var i = 0; i < segments.length; i++) {
      final seg = segments[i];
      final startY =
          context.viewport.minY + (seg.start - context.viewport.minY) * anim;
      final endY =
          context.viewport.minY + (seg.end - context.viewport.minY) * anim;

      final left = context.bounds.left + i * slotWidth + slotWidth * 0.2;
      final right = left + slotWidth * barWidthFactor;
      final y1 = context.transformer.dataToCanvasY(startY);
      final y2 = context.transformer.dataToCanvasY(endY);

      final (barColor, barOpacity) = switch (seg.kind) {
        _WaterfallKind.total || _WaterfallKind.subtotal => (color, 0.6),
        _WaterfallKind.positive => (color, 1.0),
        _WaterfallKind.negative => (negColor, 0.9),
      };

      final barRect = Rect.fromLTRB(
        left,
        y1 < y2 ? y1 : y2,
        right,
        y1 < y2 ? y2 : y1,
      );
      final paint = art.barFill(barRect, barColor, opacity: barOpacity);
      final baseY = context.transformer.dataToCanvasY(context.viewport.minY);
      drawVerticalBar(
        canvas,
        barRect,
        radius: context.config.barBorderRadius,
        paint: paint,
        baseY: baseY,
      );

      if (connectorLines && i < segments.length - 1) {
        final next = segments[i + 1];
        final nextStartY =
            context.viewport.minY + (next.start - context.viewport.minY) * anim;
        final lineY = context.transformer.dataToCanvasY(endY);
        final nextX =
            context.bounds.left + (i + 1) * slotWidth + slotWidth * 0.2;
        canvas.drawLine(
          Offset(right, lineY),
          Offset(nextX, context.transformer.dataToCanvasY(nextStartY)),
          context.paintCache.get(
            key: 'wf-connector',
            color: context.theme.gridColor.withValues(alpha: 0.6),
          ),
        );
      }
    }
  }

  List<_WaterfallSegment> _buildSegments(List<ChartPoint> points) {
    final segments = <_WaterfallSegment>[];
    var running = 0.0;

    for (final point in points) {
      final type = _parseType(point);
      double start;
      double end;
      _WaterfallKind kind;

      switch (type) {
        case 'total':
        case 'subtotal':
          start = 0;
          end = type == 'subtotal' ? running : point.y;
          if (type == 'total') running = point.y;
          kind = type == 'total'
              ? _WaterfallKind.total
              : _WaterfallKind.subtotal;
        case 'absolute':
          start = 0;
          end = point.y;
          running = point.y;
          kind = point.y >= 0
              ? _WaterfallKind.positive
              : _WaterfallKind.negative;
        default:
          if (valueMode == WaterfallValueMode.absolute) {
            start = 0;
            end = point.y;
            running = point.y;
          } else {
            start = running;
            end = running + point.y;
            running = end;
          }
          kind = point.y >= 0
              ? _WaterfallKind.positive
              : _WaterfallKind.negative;
      }

      segments.add(
        _WaterfallSegment(
          start: start,
          end: end,
          kind: kind,
          label: point.label,
        ),
      );
    }
    return segments;
  }

  String _parseType(ChartPoint point) {
    final raw = point.metadata[kWaterfallTypeKey];
    if (raw is String) return raw.toLowerCase();
    if (valueMode == WaterfallValueMode.absolute) return 'absolute';
    return 'delta';
  }

  @override
  List<HitRegion> hitRegions(ChartContext context) {
    final regions = <HitRegion>[];
    final series = context.config.series.isNotEmpty
        ? context.config.series.first
        : null;
    if (series == null) return regions;

    final segments = _buildSegments(series.points);
    final categoryCount = segments.length;
    final slotWidth = context.bounds.width / categoryCount;

    for (var i = 0; i < segments.length; i++) {
      final seg = segments[i];
      final left = context.bounds.left + i * slotWidth + slotWidth * 0.2;
      final right = left + slotWidth * barWidthFactor;
      final y1 = context.transformer.dataToCanvasY(seg.start);
      final y2 = context.transformer.dataToCanvasY(seg.end);
      regions.add(
        HitRegion(
          bounds: Rect.fromLTRB(
            left,
            y1 < y2 ? y1 : y2,
            right,
            y1 < y2 ? y2 : y1,
          ),
          seriesId: series.id,
          pointIndex: i,
          dataY: seg.end - seg.start,
          label: seg.label,
        ),
      );
    }
    return regions;
  }

  /// Viewport spanning all bar tops and bottoms.
  static ChartViewport waterfallViewport(
    List<ChartPoint> points, {
    WaterfallValueMode mode = WaterfallValueMode.delta,
    double padding = 0.08,
  }) {
    final segments = WaterfallChartRenderer(
      valueMode: mode,
    )._buildSegments(points);
    final ys = <double>[0];
    for (final s in segments) {
      ys.add(s.start);
      ys.add(s.end);
    }
    final xs = List<double>.generate(points.length, (i) => i.toDouble());
    return ChartViewport.fromPoints(xs, ys, padding: padding);
  }
}

enum _WaterfallKind { positive, negative, subtotal, total }

class _WaterfallSegment {
  const _WaterfallSegment({
    required this.start,
    required this.end,
    required this.kind,
    this.label,
  });

  final double start;
  final double end;
  final _WaterfallKind kind;
  final String? label;
}
