import 'dart:ui';

import 'package:flutter/material.dart' show EdgeInsets;
import 'package:save_points_chart/core/chrome/chart_chrome.dart';
import 'package:save_points_chart/core/coordinates/chart_bounds.dart';
import 'package:save_points_chart/core/coordinates/coordinate_transformer.dart';
import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/core/engine/render_pipeline.dart';
import 'package:save_points_chart/core/interactions/hit_test_result.dart';
import 'package:save_points_chart/core/layers/axis_layer.dart';
import 'package:save_points_chart/core/layers/background_layer.dart';
import 'package:save_points_chart/core/layers/chart_layer.dart';
import 'package:save_points_chart/core/layers/chrome_layer.dart';
import 'package:save_points_chart/core/layers/grid_layer.dart';
import 'package:save_points_chart/core/layers/interaction_layer.dart';
import 'package:save_points_chart/core/layers/layer_stack.dart';
import 'package:save_points_chart/core/layers/overlay_layer.dart';
import 'package:save_points_chart/core/layers/series_layer.dart';
import 'package:save_points_chart/core/scaling/zoom_pan_controller.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/core/utils/paint_cache.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/models/viewport.dart';

/// Central chart engine — builds context and drives the render pipeline.
class ChartEngine {
  ChartEngine({
    required this.config,
    required this.renderers,
    ChartTheme? theme,
    ZoomPanController? zoomPan,
    List<ChartLayer>? extraLayers,
  }) : theme = theme ?? config.theme ?? ChartTheme.light(),
       zoomPan = zoomPan ?? ZoomPanController() {
    _layerStack = LayerStack(
      layers: [
        const BackgroundLayer(),
        const GridLayer(),
        const AxisLayer(),
        SeriesLayer(renderers: renderers),
        const InteractionLayer(),
        const ChromeLayer(),
        ...?extraLayers,
        const OverlayLayer(),
      ],
    );
    _pipeline = RenderPipeline(layerStack: _layerStack);
  }

  final ChartConfig config;
  final List<ChartRenderer> renderers;
  final ChartTheme theme;
  final ZoomPanController zoomPan;

  late final LayerStack _layerStack;
  late final RenderPipeline _pipeline;
  final PaintCache _paintCache = PaintCache();

  LayerStack get layerStack => _layerStack;
  RenderPipeline get pipeline => _pipeline;

  ChartContext buildContext(
    Size size, {
    double animationValue = 1.0,
    ChartHitResult? hoveredHit,
    ChartHitResult? selectedHit,
    Offset? crosshairPosition,
  }) {
    final bounds = ChartBounds.fromSize(size, margins: _plotMargins());
    final viewport = _resolveViewport();

    return ChartContext(
      config: config,
      theme: theme,
      bounds: bounds,
      viewport: viewport,
      transformer: CoordinateTransformer(viewport: viewport, bounds: bounds),
      paintCache: _paintCache,
      animationValue: animationValue,
      hoveredHit: hoveredHit,
      selectedHit: selectedHit,
      crosshairPosition: crosshairPosition,
      zoomPan: zoomPan,
    );
  }

  EdgeInsets _plotMargins() {
    final base = theme.padding;
    final top = base.top + ChartChrome.headerReservedHeight(config);
    final bottom = base.bottom + ChartChrome.legendReservedHeight(config);
    final left = base.left + ChartChrome.legendReservedLeft(config);
    final right = base.right + ChartChrome.legendReservedRight(config);

    final xTitle = config.xAxisTitle;
    final yTitle = config.yAxisTitle;
    var bottomWithAxis = bottom;
    var leftWithAxis = left;
    if (xTitle != null && xTitle.isNotEmpty) {
      bottomWithAxis += 20;
    }
    if (yTitle != null && yTitle.isNotEmpty) {
      leftWithAxis += 20;
    }
    return EdgeInsets.fromLTRB(leftWithAxis, top, right, bottomWithAxis);
  }

  ChartViewport _resolveViewport() {
    if (config.viewport != null) {
      zoomPan.setViewport(config.viewport!);
      return zoomPan.viewport;
    }
    final allX = <double>[];
    final allY = <double>[];
    for (final series in config.series) {
      for (final point in series.points) {
        allX.add(point.x);
        allY.add(point.y);
      }
    }
    final computed = ChartViewport.fromPoints(allX, allY);
    zoomPan.setViewport(computed);
    return zoomPan.viewport;
  }

  void paint(Canvas canvas, Size size, ChartContext context) {
    _pipeline.paint(canvas, size, context);
  }

  void markSeriesDirty(ChartContext context) {
    _pipeline.markDirty(context.bounds.rect);
  }
}
