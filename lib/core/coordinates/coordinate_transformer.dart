import 'dart:ui';

import 'package:save_points_chart/core/coordinates/chart_bounds.dart';
import 'package:save_points_chart/models/viewport.dart';

/// Transforms between data space and canvas space.
class CoordinateTransformer {
  CoordinateTransformer({required this.viewport, required this.bounds});

  final ChartViewport viewport;
  final ChartBounds bounds;

  double dataToCanvasX(double dataX) {
    final t = (dataX - viewport.minX) / viewport.width;
    return bounds.left + t * bounds.width;
  }

  double dataToCanvasY(double dataY) {
    final t = (dataY - viewport.minY) / viewport.height;
    return bounds.bottom - t * bounds.height;
  }

  double canvasToDataX(double canvasX) {
    final t = (canvasX - bounds.left) / bounds.width;
    return viewport.minX + t * viewport.width;
  }

  double canvasToDataY(double canvasY) {
    final t = (bounds.bottom - canvasY) / bounds.height;
    return viewport.minY + t * viewport.height;
  }

  Offset dataToCanvas(double x, double y) {
    return Offset(dataToCanvasX(x), dataToCanvasY(y));
  }

  Offset canvasToData(Offset canvas) {
    return Offset(canvasToDataX(canvas.dx), canvasToDataY(canvas.dy));
  }

  CoordinateTransformer copyWith({
    ChartViewport? viewport,
    ChartBounds? bounds,
  }) {
    return CoordinateTransformer(
      viewport: viewport ?? this.viewport,
      bounds: bounds ?? this.bounds,
    );
  }
}
