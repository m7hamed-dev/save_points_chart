import 'dart:ui';

import 'package:save_points_chart/core/chrome/chart_chrome.dart';
import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/layers/chart_layer.dart';

/// Renders the chart background.
class BackgroundLayer extends ChartLayer {
  const BackgroundLayer();

  @override
  int get zIndex => 0;

  @override
  void paint(Canvas canvas, Size size, ChartContext context) {
    final gradient = context.theme.backgroundGradient;
    final paint = gradient != null
        ? (Paint()..shader = gradient.createShader(Offset.zero & size))
        : context.paintCache.fill('bg', context.theme.backgroundColor);
    if (context.config.showBorder) {
      final rrect = RRect.fromRectAndRadius(
        Offset.zero & size,
        Radius.circular(context.theme.cardBorderRadius),
      );
      canvas.drawRRect(rrect, paint);
      ChartChrome.drawBorder(canvas, size, context);
    } else {
      canvas.drawRect(Offset.zero & size, paint);
    }
  }
}
