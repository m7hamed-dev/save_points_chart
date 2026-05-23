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

    return buildSmoothPath(offsets, close: close);
  }
}
