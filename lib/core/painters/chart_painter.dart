import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_engine.dart';

/// CustomPainter that delegates to [ChartEngine].
class ChartPainter extends CustomPainter {
  ChartPainter({required this.engine, required this.context});

  final ChartEngine engine;
  final ChartContext context;

  @override
  void paint(Canvas canvas, Size size) {
    engine.paint(canvas, size, context);
  }

  @override
  bool shouldRepaint(ChartPainter oldDelegate) {
    return oldDelegate.context != context;
  }
}
