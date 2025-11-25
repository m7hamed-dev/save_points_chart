import 'package:flutter/material.dart';

/// Performance utility functions for charts
class PerformanceUtils {
  /// Efficiently calculate min/max in a single pass
  static ({double min, double max}) calculateBounds(List<double> values) {
    if (values.isEmpty) return (min: 0.0, max: 0.0);

    double min = double.infinity;
    double max = double.negativeInfinity;

    for (final value in values) {
      if (value < min) min = value;
      if (value > max) max = value;
    }

    return (min: min, max: max);
  }

  /// Pre-calculate step values for loops
  static List<double> preCalculateSteps(double start, double end, int count) {
    final step = (end - start) / count;
    return List.generate(count + 1, (i) => start + step * i);
  }

  /// Efficient string formatting for axis labels
  static String formatAxisValue(double value) {
    if (value % 1 == 0) {
      return value.toInt().toString();
    } else if (value.abs() < 0.01) {
      return value.toStringAsExponential(1);
    } else {
      return value.toStringAsFixed(1);
    }
  }

  /// Batch canvas operations for better performance
  static void drawLinesBatch(
    Canvas canvas,
    List<({Offset start, Offset end})> lines,
    Paint paint,
  ) {
    final path = Path();
    for (final line in lines) {
      path.moveTo(line.start.dx, line.start.dy);
      path.lineTo(line.end.dx, line.end.dy);
    }
    canvas.drawPath(path, paint);
  }
}
