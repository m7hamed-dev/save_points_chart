import 'dart:ui';

import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/layers/chart_layer.dart';

/// Renders crosshair and selection highlights.
class InteractionLayer extends ChartLayer {
  const InteractionLayer();

  @override
  int get zIndex => 40;

  @override
  bool get isStatic => false;

  @override
  void paint(Canvas canvas, Size size, ChartContext context) {
    final crosshair = context.crosshairPosition;
    if (crosshair != null) {
      final paint = context.paintCache.get(
        key: 'crosshair',
        color: context.theme.crosshairColor,
      );
      final bounds = context.bounds;
      canvas.drawLine(
        Offset(crosshair.dx, bounds.top),
        Offset(crosshair.dx, bounds.bottom),
        paint,
      );
      canvas.drawLine(
        Offset(bounds.left, crosshair.dy),
        Offset(bounds.right, crosshair.dy),
        paint,
      );
    }

    final selected = context.selectedHit;
    if (selected != null) {
      final paint = context.paintCache.fill(
        'selection',
        context.theme.selectionColor,
      );
      canvas.drawRect(selected.region.bounds.inflate(4), paint);
    }
  }
}
