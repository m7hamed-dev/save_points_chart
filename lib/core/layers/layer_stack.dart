import 'dart:ui';

import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/layers/chart_layer.dart';

/// Ordered stack of render layers.
class LayerStack {
  LayerStack({List<ChartLayer>? layers}) : _layers = layers ?? [];

  final List<ChartLayer> _layers;

  List<ChartLayer> get layers => List.unmodifiable(_layers);

  void add(ChartLayer layer) {
    _layers.add(layer);
    _layers.sort((a, b) => a.zIndex.compareTo(b.zIndex));
  }

  void remove(ChartLayer layer) => _layers.remove(layer);

  void paint(Canvas canvas, Size size, ChartContext context) {
    for (final layer in _layers) {
      layer.paint(canvas, size, context);
    }
  }

  List<ChartLayer> get staticLayers =>
      _layers.where((l) => l.isStatic).toList();

  List<ChartLayer> get dynamicLayers =>
      _layers.where((l) => !l.isStatic).toList();
}
