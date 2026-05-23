import 'dart:ui';

import 'package:save_points_chart/core/coordinates/chart_bounds.dart';
import 'package:save_points_chart/core/coordinates/coordinate_transformer.dart';
import 'package:save_points_chart/core/interactions/hit_test_result.dart';
import 'package:save_points_chart/core/scaling/zoom_pan_controller.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/core/utils/paint_cache.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/models/viewport.dart';

/// Shared runtime context passed to all renderers and layers.
class ChartContext {
  ChartContext({
    required this.config,
    required this.theme,
    required this.bounds,
    required this.viewport,
    required this.transformer,
    required this.paintCache,
    this.animationValue = 1.0,
    this.hoveredHit,
    this.selectedHit,
    this.crosshairPosition,
    this.zoomPan,
  });

  final ChartConfig config;
  final ChartTheme theme;
  final ChartBounds bounds;
  final ChartViewport viewport;
  final CoordinateTransformer transformer;
  final PaintCache paintCache;
  final double animationValue;
  final ChartHitResult? hoveredHit;
  final ChartHitResult? selectedHit;
  final Offset? crosshairPosition;
  final ZoomPanController? zoomPan;

  ChartContext copyWith({
    ChartConfig? config,
    ChartTheme? theme,
    ChartBounds? bounds,
    ChartViewport? viewport,
    CoordinateTransformer? transformer,
    PaintCache? paintCache,
    double? animationValue,
    ChartHitResult? hoveredHit,
    ChartHitResult? selectedHit,
    Offset? crosshairPosition,
    ZoomPanController? zoomPan,
    bool clearHover = false,
    bool clearSelection = false,
    bool clearCrosshair = false,
  }) {
    return ChartContext(
      config: config ?? this.config,
      theme: theme ?? this.theme,
      bounds: bounds ?? this.bounds,
      viewport: viewport ?? this.viewport,
      transformer: transformer ?? this.transformer,
      paintCache: paintCache ?? this.paintCache,
      animationValue: animationValue ?? this.animationValue,
      hoveredHit: clearHover ? null : (hoveredHit ?? this.hoveredHit),
      selectedHit: clearSelection ? null : (selectedHit ?? this.selectedHit),
      crosshairPosition: clearCrosshair
          ? null
          : (crosshairPosition ?? this.crosshairPosition),
      zoomPan: zoomPan ?? this.zoomPan,
    );
  }
}
