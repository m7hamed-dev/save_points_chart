import 'package:flutter/material.dart';
import 'package:save_points_chart/core/animations/chart_animation_controller.dart';
import 'package:save_points_chart/core/engine/chart_engine.dart';
import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/core/gestures/gesture_engine.dart';
import 'package:save_points_chart/core/interactions/hit_test_result.dart';
import 'package:save_points_chart/core/painters/chart_painter.dart';
import 'package:save_points_chart/core/theme/chart_template.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/core/tooltip/tooltip_controller.dart';
import 'package:save_points_chart/models/chart_config.dart';

/// Base chart widget — thin UI shell over [ChartEngine].
class ChartWidget extends StatefulWidget {
  const ChartWidget({
    super.key,
    required this.config,
    required this.renderers,
    this.theme,
    this.enableTooltip = true,
    this.enableZoomPan = true,
    this.enableCrosshair = true,
    this.onSelection,
  });

  final ChartConfig config;
  final List<ChartRenderer> renderers;
  final ChartTheme? theme;
  final bool enableTooltip;
  final bool enableZoomPan;
  final bool enableCrosshair;
  final void Function(ChartHitResult hit)? onSelection;

  @override
  State<ChartWidget> createState() => _ChartWidgetState();
}

class _ChartWidgetState extends State<ChartWidget>
    with TickerProviderStateMixin {
  late ChartEngine _engine;
  late GestureEngine _gestures;
  late TooltipController _tooltip;
  ChartAnimationController? _animController;

  ChartHitResult? _hoveredHit;
  ChartHitResult? _selectedHit;
  Offset? _crosshair;
  double _animValue = 1.0;

  @override
  void initState() {
    super.initState();
    _initEngine();
    if (widget.config.animate) {
      _animController = ChartAnimationController(vsync: this)
        ..animation.addListener(() {
          setState(() => _animValue = _animController!.value);
        })
        ..forward();
    }
  }

  ChartConfig get _resolvedConfig =>
      ChartTemplate.resolve(widget.config, theme: widget.theme);

  ChartTheme get _resolvedTheme =>
      widget.theme ?? _resolvedConfig.theme ?? ChartTemplate.dashboardTheme();

  void _initEngine() {
    _engine = ChartEngine(
      config: _resolvedConfig,
      renderers: widget.renderers,
      theme: _resolvedTheme,
    );
    _gestures = GestureEngine(
      enableCrosshair: widget.enableCrosshair,
      enableZoomPan: widget.enableZoomPan,
      onSelection: (hit) {
        setState(() => _selectedHit = hit);
        widget.onSelection?.call(hit);
      },
    );
    _tooltip = TooltipController();
  }

  @override
  void didUpdateWidget(ChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.config != widget.config ||
        oldWidget.renderers != widget.renderers) {
      _initEngine();
      if (widget.config.animate) {
        _animController?.forward(from: 0);
      }
    }
  }

  @override
  void dispose() {
    _animController?.dispose();
    _tooltip.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);
        final chartContext = _engine.buildContext(
          size,
          animationValue: _animValue,
          hoveredHit: _hoveredHit,
          selectedHit: _selectedHit,
          crosshairPosition: _crosshair,
        );

        return Semantics(
          label: widget.config.semanticLabel ?? 'Chart',
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              RepaintBoundary(
                child: MouseRegion(
                  onHover: (e) => _handleHover(e.localPosition, size),
                  onExit: (_) => setState(() {
                    _hoveredHit = null;
                    _crosshair = null;
                    _tooltip.hide();
                  }),
                  child: GestureDetector(
                    onTapDown: (d) => _gestures.handleTap(
                      d.localPosition,
                      _engine,
                      chartContext,
                    ),
                    onScaleStart: (_) => _gestures.handleScaleStart(),
                    onScaleUpdate: (d) {
                      _gestures.handleScaleUpdate(
                        d,
                        _engine.zoomPan,
                        chartContext,
                      );
                      setState(() {});
                    },
                    child: CustomPaint(
                      size: size,
                      painter: ChartPainter(
                        engine: _engine,
                        context: chartContext,
                      ),
                    ),
                  ),
                ),
              ),

              // if (widget.enableTooltip)
              //   TooltipOverlay(
              //     controller: _tooltip,
              //     theme: _engine.theme,
              //     chartSize: size,
              //   ),
            ],
          ),
        );
      },
    );
  }

  void _handleHover(Offset position, Size size) {
    final chartContext = _engine.buildContext(
      size,
      animationValue: _animValue,
      hoveredHit: _hoveredHit,
      selectedHit: _selectedHit,
      crosshairPosition: _crosshair,
    );
    final hit = _gestures.handleHover(position, _engine, chartContext);
    final crosshair = _gestures.crosshairForHover(position, chartContext);
    setState(() {
      _hoveredHit = hit;
      _crosshair = crosshair;
    });
    if (widget.enableTooltip) {
      _tooltip.updateFromHit(hit, position);
    }
  }
}
