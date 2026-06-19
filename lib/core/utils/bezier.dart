import 'dart:math' as math;
import 'dart:ui';

import 'package:save_points_chart/core/coordinates/coordinate_transformer.dart';
import 'package:save_points_chart/models/chart_point.dart';

/// Cubic Bezier path utilities for smooth line charts.
class BezierPathBuilder {
  BezierPathBuilder({this.tension = 0.35});

  final double tension;

  /// Builds a smooth cubic Bezier path through transformed points.
  Path buildSmoothPath(List<Offset> points, {bool close = false}) {
    final path = Path();
    if (points.isEmpty) return path;
    if (points.length == 1) {
      path.moveTo(points.first.dx, points.first.dy);
      return path;
    }

    path.moveTo(points.first.dx, points.first.dy);

    for (var i = 0; i < points.length - 1; i++) {
      final p0 = i > 0 ? points[i - 1] : points[i];
      final p1 = points[i];
      final p2 = points[i + 1];
      final p3 = i + 2 < points.length ? points[i + 2] : p2;

      final cp1x = p1.dx + (p2.dx - p0.dx) * tension;
      final cp1y = p1.dy + (p2.dy - p0.dy) * tension;
      final cp2x = p2.dx - (p3.dx - p1.dx) * tension;
      final cp2y = p2.dy - (p3.dy - p1.dy) * tension;

      path.cubicTo(cp1x, cp1y, cp2x, cp2y, p2.dx, p2.dy);
    }

    if (close) path.close();
    return path;
  }

  /// Builds a smooth path using **monotone cubic interpolation**
  /// (Fritsch–Carlson). Unlike a cardinal spline, this never overshoots the
  /// data: the curve introduces no false peaks, no dips below a local minimum,
  /// and stays within the value range between points — so a smoothed line
  /// remains a faithful reading of the data.
  ///
  /// Assumes points are ordered by ascending x (true for line/area/sparkline
  /// series). Falls back to the cardinal spline for non-monotonic x.
  Path buildMonotonePath(List<Offset> points, {bool close = false}) {
    final n = points.length;
    if (n < 3) {
      final path = Path();
      if (n == 0) return path;
      path.moveTo(points.first.dx, points.first.dy);
      for (var i = 1; i < n; i++) {
        path.lineTo(points[i].dx, points[i].dy);
      }
      if (close) path.close();
      return path;
    }

    // Secant slopes between consecutive points.
    final dx = List<double>.filled(n - 1, 0);
    final slope = List<double>.filled(n - 1, 0);
    for (var i = 0; i < n - 1; i++) {
      dx[i] = points[i + 1].dx - points[i].dx;
      // Non-increasing x → not a function of x; defer to the cardinal spline.
      if (dx[i] <= 0) return buildSmoothPath(points, close: close);
      slope[i] = (points[i + 1].dy - points[i].dy) / dx[i];
    }

    // Tangents: average of neighbouring secants, clamped to 0 at extrema so
    // the curve can't overshoot a peak or trough.
    final m = List<double>.filled(n, 0);
    m[0] = slope[0];
    m[n - 1] = slope[n - 2];
    for (var i = 1; i < n - 1; i++) {
      m[i] = (slope[i - 1] * slope[i] <= 0)
          ? 0.0
          : (slope[i - 1] + slope[i]) / 2;
    }

    // Fritsch–Carlson: rein in tangents that would break monotonicity.
    for (var i = 0; i < n - 1; i++) {
      if (slope[i] == 0) {
        m[i] = 0;
        m[i + 1] = 0;
        continue;
      }
      final a = m[i] / slope[i];
      final b = m[i + 1] / slope[i];
      final h = a * a + b * b;
      if (h > 9) {
        final t = 3 / math.sqrt(h);
        m[i] = t * a * slope[i];
        m[i + 1] = t * b * slope[i];
      }
    }

    // Emit Hermite segments as cubic Béziers (control points at thirds).
    final path = Path()..moveTo(points.first.dx, points.first.dy);
    for (var i = 0; i < n - 1; i++) {
      final p1 = points[i];
      final p2 = points[i + 1];
      final third = dx[i] / 3;
      path.cubicTo(
        p1.dx + third,
        p1.dy + m[i] * third,
        p2.dx - third,
        p2.dy - m[i + 1] * third,
        p2.dx,
        p2.dy,
      );
    }
    if (close) path.close();
    return path;
  }

  /// Builds path from chart points using a coordinate transformer.
  Path buildFromPoints(
    List<ChartPoint> points,
    CoordinateTransformer transformer, {
    bool smooth = true,
    bool close = false,
  }) {
    final offsets = points
        .map((p) => transformer.dataToCanvas(p.x, p.y))
        .toList();

    if (!smooth || offsets.length < 3) {
      final path = Path();
      if (offsets.isEmpty) return path;
      path.moveTo(offsets.first.dx, offsets.first.dy);
      for (var i = 1; i < offsets.length; i++) {
        path.lineTo(offsets[i].dx, offsets[i].dy);
      }
      if (close) path.close();
      return path;
    }

    return buildMonotonePath(offsets, close: close);
  }
}
