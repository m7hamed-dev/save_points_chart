import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_chart/core/utils/bezier.dart';

/// Samples the y-values along a [Path] at a fixed resolution.
List<double> _sampleYs(Path path, {int steps = 200}) {
  final ys = <double>[];
  for (final metric in path.computeMetrics()) {
    for (var i = 0; i <= steps; i++) {
      final pos = metric.getTangentForOffset(metric.length * i / steps)?.position;
      if (pos != null) ys.add(pos.dy);
    }
  }
  return ys;
}

void main() {
  final builder = BezierPathBuilder();

  test('monotone curve does not overshoot a peak or flat sections', () {
    // A spike between two flat plateaus at y=10, peaking at y=40.
    final points = const [
      Offset(0, 10),
      Offset(1, 10),
      Offset(2, 40),
      Offset(3, 10),
      Offset(4, 10),
    ];

    final ys = _sampleYs(builder.buildMonotonePath(points));

    // No sampled point may exceed the data range [10, 40] (allow tiny epsilon).
    expect(ys.reduce((a, b) => a < b ? a : b), greaterThanOrEqualTo(10 - 0.01));
    expect(ys.reduce((a, b) => a > b ? a : b), lessThanOrEqualTo(40 + 0.01));
  });

  test('monotone curve preserves monotonic data', () {
    final points = const [
      Offset(0, 0),
      Offset(1, 5),
      Offset(2, 20),
      Offset(3, 30),
      Offset(4, 50),
    ];

    final ys = _sampleYs(builder.buildMonotonePath(points));

    for (var i = 1; i < ys.length; i++) {
      // Strictly non-decreasing within a small tolerance.
      expect(ys[i], greaterThanOrEqualTo(ys[i - 1] - 0.01));
    }
  });

  test('falls back gracefully for fewer than three points', () {
    final path = builder.buildMonotonePath(const [Offset(0, 0), Offset(1, 1)]);
    expect(path.computeMetrics().isNotEmpty, isTrue);
  });
}
