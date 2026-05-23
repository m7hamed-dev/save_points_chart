import 'dart:ui';

import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/layers/layer_stack.dart';

/// Orchestrates layered rendering with optional dirty-region support.
class RenderPipeline {
  RenderPipeline({required this.layerStack});

  final LayerStack layerStack;
  Rect? _dirtyRegion;

  void markDirty(Rect region) {
    _dirtyRegion = _dirtyRegion == null
        ? region
        : _dirtyRegion!.expandToInclude(region);
  }

  void clearDirty() => _dirtyRegion = null;

  bool get hasDirtyRegion => _dirtyRegion != null;

  void paint(Canvas canvas, Size size, ChartContext context) {
    if (_dirtyRegion != null) {
      canvas.save();
      canvas.clipRect(_dirtyRegion!);
      layerStack.paint(canvas, size, context);
      canvas.restore();
      _dirtyRegion = null;
    } else {
      layerStack.paint(canvas, size, context);
    }
  }

  void paintStatic(Canvas canvas, Size size, ChartContext context) {
    for (final layer in layerStack.staticLayers) {
      layer.paint(canvas, size, context);
    }
  }

  void paintDynamic(Canvas canvas, Size size, ChartContext context) {
    for (final layer in layerStack.dynamicLayers) {
      layer.paint(canvas, size, context);
    }
  }
}
