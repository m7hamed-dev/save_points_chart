import 'dart:math' as math;
import 'dart:ui';

import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/core/utils/rounded_bar.dart';

/// OHLC candlestick chart renderer.
class CandlestickChartRenderer extends ChartRenderer {
  const CandlestickChartRenderer();

  @override
  void draw(Canvas canvas, Size size, ChartContext context) {
    if (context.config.series.isEmpty) return;
    final series = context.config.series.first;

    final candleWidth =
        context.bounds.width / math.max(series.points.length, 1) * 0.6;

    for (var i = 0; i < series.points.length; i++) {
      final p = series.points[i];
      final open = (p.metadata['open'] as num?)?.toDouble() ?? p.y;
      final high = (p.metadata['high'] as num?)?.toDouble() ?? p.y;
      final low = (p.metadata['low'] as num?)?.toDouble() ?? p.y;
      final close = (p.metadata['close'] as num?)?.toDouble() ?? p.y;

      final x = context.transformer.dataToCanvasX(p.x);
      final bullish = close >= open;
      const bullColor = Color(0xFF43A047);
      const bearColor = Color(0xFFE53935);
      final color = bullish ? bullColor : bearColor;

      final highY = context.transformer.dataToCanvasY(high);
      final lowY = context.transformer.dataToCanvasY(low);
      final openY = context.transformer.dataToCanvasY(open);
      final closeY = context.transformer.dataToCanvasY(close);

      canvas.drawLine(
        Offset(x, highY),
        Offset(x, lowY),
        context.paintCache.get(key: 'wick', color: color, strokeWidth: 1.5),
      );

      final bodyTop = bullish ? closeY : openY;
      final bodyBottom = bullish ? openY : closeY;
      final bodyRect = Rect.fromCenter(
        center: Offset(x, (bodyTop + bodyBottom) / 2),
        width: candleWidth,
        height: (bodyBottom - bodyTop).abs().clamp(1, double.infinity),
      );
      drawRoundedBar(
        canvas,
        bodyRect,
        radius: context.config.barBorderRadius,
        paint: context.paintCache.fill('body-$i', color),
      );
    }
  }

  @override
  List<HitRegion> hitRegions(ChartContext context) {
    final regions = <HitRegion>[];
    if (context.config.series.isEmpty) return regions;
    final series = context.config.series.first;
    final candleWidth =
        context.bounds.width / math.max(series.points.length, 1) * 0.6;

    for (var i = 0; i < series.points.length; i++) {
      final p = series.points[i];
      final open = (p.metadata['open'] as num?)?.toDouble() ?? p.y;
      final high = (p.metadata['high'] as num?)?.toDouble() ?? p.y;
      final low = (p.metadata['low'] as num?)?.toDouble() ?? p.y;
      final close = (p.metadata['close'] as num?)?.toDouble() ?? p.y;
      final x = context.transformer.dataToCanvasX(p.x);
      final highY = context.transformer.dataToCanvasY(high);
      final lowY = context.transformer.dataToCanvasY(low);
      regions.add(
        HitRegion(
          bounds: Rect.fromCenter(
            center: Offset(x, (highY + lowY) / 2),
            width: candleWidth + 4,
            height: (lowY - highY).abs() + 4,
          ),
          seriesId: series.id,
          pointIndex: i,
          dataX: p.x,
          dataY: close,
          label: p.label ?? 'O:$open H:$high L:$low C:$close',
        ),
      );
    }
    return regions;
  }
}
