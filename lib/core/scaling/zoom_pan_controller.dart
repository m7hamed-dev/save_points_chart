import 'package:save_points_chart/models/viewport.dart';

/// Manages zoom and pan state for chart viewports.
class ZoomPanController {
  ZoomPanController({ChartViewport? initialViewport})
    : _viewport =
          initialViewport ??
          const ChartViewport(minX: 0, maxX: 10, minY: 0, maxY: 10);

  ChartViewport _viewport;
  double _scale = 1.0;

  ChartViewport get viewport => _viewport;
  double get scale => _scale;

  void setViewport(ChartViewport viewport) {
    _viewport = viewport;
  }

  void zoom(double factor, {double centerX = 0.5, double centerY = 0.5}) {
    _scale *= factor;
    _viewport = _viewport.zoom(factor, centerX: centerX, centerY: centerY);
  }

  void pan(double dx, double dy) {
    _viewport = _viewport.pan(dx, dy);
  }

  void reset(ChartViewport viewport) {
    _viewport = viewport;
    _scale = 1.0;
  }
}
