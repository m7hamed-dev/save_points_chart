import 'package:flutter/gestures.dart';
import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_engine.dart';
import 'package:save_points_chart/core/interactions/hit_test_engine.dart';
import 'package:save_points_chart/core/interactions/hit_test_result.dart';
import 'package:save_points_chart/core/scaling/zoom_pan_controller.dart';

/// Handles pointer interactions: hover, tap, drag, zoom, pan.
class GestureEngine {
  GestureEngine({
    this.hitTestEngine = const HitTestEngine(),
    this.onHover,
    this.onTap,
    this.onSelection,
    this.onZoom,
    this.onPan,
    this.enableCrosshair = true,
    this.enableZoomPan = true,
  });

  final HitTestEngine hitTestEngine;
  final void Function(ChartHitResult? hit, Offset position)? onHover;
  final void Function(ChartHitResult? hit, Offset position)? onTap;
  final void Function(ChartHitResult hit)? onSelection;
  final void Function(double scale, Offset focal)? onZoom;
  final void Function(double dx, double dy)? onPan;
  final bool enableCrosshair;
  final bool enableZoomPan;

  double _lastScale = 1.0;

  ChartHitResult? handleHover(
    Offset position,
    ChartEngine engine,
    ChartContext context,
  ) {
    final hit = hitTestEngine.test(position, context, engine.renderers);
    onHover?.call(hit, position);
    return hit;
  }

  void handleTap(Offset position, ChartEngine engine, ChartContext context) {
    final hit = hitTestEngine.test(position, context, engine.renderers);
    onTap?.call(hit, position);
    if (hit != null) onSelection?.call(hit);
  }

  Offset? crosshairForHover(Offset position, ChartContext context) {
    if (!enableCrosshair) return null;
    if (!context.bounds.rect.contains(position)) return null;
    return position;
  }

  void handleScaleStart() {
    _lastScale = 1.0;
  }

  void handleScaleUpdate(
    ScaleUpdateDetails details,
    ZoomPanController zoomPan,
    ChartContext context,
  ) {
    if (!enableZoomPan) return;

    final scaleDelta = details.scale / _lastScale;
    _lastScale = details.scale;

    if ((scaleDelta - 1.0).abs() > 0.01) {
      final focal = details.localFocalPoint;
      final bounds = context.bounds.rect;
      final cx = (focal.dx - bounds.left) / bounds.width;
      final cy = (bounds.bottom - focal.dy) / bounds.height;
      zoomPan.zoom(
        scaleDelta,
        centerX: cx.clamp(0.0, 1.0),
        centerY: cy.clamp(0.0, 1.0),
      );
      onZoom?.call(scaleDelta, focal);
    }

    if (details.focalPointDelta != Offset.zero) {
      final dx =
          -details.focalPointDelta.dx /
          context.bounds.width *
          context.viewport.width;
      final dy =
          details.focalPointDelta.dy /
          context.bounds.height *
          context.viewport.height;
      zoomPan.pan(dx, dy);
      onPan?.call(dx, dy);
    }
  }

  void handlePanUpdate(
    DragUpdateDetails details,
    ZoomPanController zoomPan,
    ChartContext context,
  ) {
    if (!enableZoomPan) return;
    final dx =
        -details.delta.dx / context.bounds.width * context.viewport.width;
    final dy =
        details.delta.dy / context.bounds.height * context.viewport.height;
    zoomPan.pan(dx, dy);
    onPan?.call(dx, dy);
  }
}
