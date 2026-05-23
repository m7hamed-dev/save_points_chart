import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/core/gestures/gesture_engine.dart';
import 'package:save_points_chart/core/layers/chart_layer.dart';
import 'package:save_points_chart/core/tooltip/tooltip_controller.dart';

/// Registry for external chart plugins.
class PluginRegistry {
  final List<ChartRenderer> _renderers = [];
  final List<ChartLayer> _layers = [];
  final List<GestureEngine> _gestures = [];
  final List<TooltipController> _tooltips = [];

  List<ChartRenderer> get renderers => List.unmodifiable(_renderers);
  List<ChartLayer> get layers => List.unmodifiable(_layers);

  void registerRenderer(ChartRenderer renderer) => _renderers.add(renderer);

  void registerLayer(ChartLayer layer) => _layers.add(layer);

  void registerGesture(GestureEngine gesture) => _gestures.add(gesture);

  void registerTooltip(TooltipController tooltip) => _tooltips.add(tooltip);

  void clear() {
    _renderers.clear();
    _layers.clear();
    _gestures.clear();
    _tooltips.clear();
  }
}
