import 'package:save_points_chart/models/chart_point.dart';

/// Linear interpolation utilities for animated chart updates.
class ChartInterpolation {
  const ChartInterpolation._();

  static double lerp(double a, double b, double t) => a + (b - a) * t;

  static ChartPoint lerpPoint(ChartPoint a, ChartPoint b, double t) {
    return ChartPoint(
      x: lerp(a.x, b.x, t),
      y: lerp(a.y, b.y, t),
      label: t < 0.5 ? a.label : b.label,
    );
  }

  static List<ChartPoint> lerpSeries(
    List<ChartPoint> from,
    List<ChartPoint> to,
    double t,
  ) {
    final length = from.length < to.length ? from.length : to.length;
    return List.generate(length, (i) => lerpPoint(from[i], to[i], t));
  }
}
