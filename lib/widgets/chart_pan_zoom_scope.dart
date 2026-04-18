import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// A drop-in wrapper that adds pan and pinch-zoom to any chart widget.
///
/// Built on top of [InteractiveViewer] so it works with every chart painter
/// without modifying them — the entire child is transformed as a rendered
/// bitmap. Optional floating controls let users zoom in/out and reset the
/// view programmatically, and a [TransformationController] can be supplied
/// for full external control.
///
/// ## Simple usage
/// ```dart
/// ChartPanZoomScope(
///   child: LineChartWidget(dataSets: dataSets),
/// )
/// ```
///
/// ## With controls and horizontal-only panning (time-series style)
/// ```dart
/// ChartPanZoomScope(
///   minScale: 1.0,
///   maxScale: 8.0,
///   panAxis: PanAxis.horizontal,
///   showControls: true,
///   child: LineChartWidget(dataSets: dataSets),
/// )
/// ```
///
/// ## With an external controller
/// ```dart
/// final controller = TransformationController();
///
/// ElevatedButton(
///   onPressed: () => controller.value = Matrix4.identity(),
///   child: const Text('Reset'),
/// );
///
/// ChartPanZoomScope(
///   controller: controller,
///   child: myChart,
/// );
/// ```
class ChartPanZoomScope extends StatefulWidget {
  const ChartPanZoomScope({
    super.key,
    required this.child,
    this.minScale = 1.0,
    this.maxScale = 5.0,
    this.panAxis = PanAxis.free,
    this.boundaryMargin = EdgeInsets.zero,
    this.constrained = true,
    this.controller,
    this.showControls = false,
    this.controlsAlignment = Alignment.bottomRight,
    this.controlsPadding = const EdgeInsets.all(8),
    this.zoomStep = 1.5,
    this.hapticFeedback = true,
    this.onInteractionStart,
    this.onInteractionEnd,
  }) : assert(minScale > 0, 'minScale must be > 0'),
       assert(maxScale >= minScale, 'maxScale must be >= minScale'),
       assert(zoomStep > 1.0, 'zoomStep must be > 1.0');

  /// The chart (or any widget) to wrap.
  final Widget child;

  /// Minimum zoom factor. Defaults to 1.0 (no zoom-out below original size).
  final double minScale;

  /// Maximum zoom factor. Defaults to 5.0.
  final double maxScale;

  /// Whether panning is constrained to a single axis. Use
  /// [PanAxis.horizontal] for time-series charts.
  final PanAxis panAxis;

  /// Extra space allowed around the child when zoomed. See
  /// [InteractiveViewer.boundaryMargin].
  final EdgeInsets boundaryMargin;

  /// When true (default), the child stays within the viewport. When false,
  /// the child can be panned outside the viewport bounds.
  final bool constrained;

  /// Optional transformation controller. Provide one to reset, inspect, or
  /// drive the transform from outside this widget.
  final TransformationController? controller;

  /// When true, renders floating zoom-in / zoom-out / reset buttons over the
  /// chart.
  final bool showControls;

  /// Where the floating controls are placed.
  final AlignmentGeometry controlsAlignment;

  /// Padding between the controls and the edge of the chart.
  final EdgeInsetsGeometry controlsPadding;

  /// Factor the current scale is multiplied/divided by when the
  /// zoom-in / zoom-out buttons are pressed. Defaults to 1.5.
  final double zoomStep;

  /// Whether to fire a light haptic impulse when the control buttons are used.
  final bool hapticFeedback;

  /// Invoked when the user begins a pan or pinch gesture.
  final ValueChanged<ScaleStartDetails>? onInteractionStart;

  /// Invoked when the user finishes a pan or pinch gesture.
  final ValueChanged<ScaleEndDetails>? onInteractionEnd;

  @override
  State<ChartPanZoomScope> createState() => _ChartPanZoomScopeState();
}

class _ChartPanZoomScopeState extends State<ChartPanZoomScope> {
  TransformationController? _internal;
  TransformationController get _controller => widget.controller ?? _internal!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internal = TransformationController();
    }
    _controller.addListener(_onTransformChanged);
  }

  @override
  void didUpdateWidget(covariant ChartPanZoomScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _internal)?.removeListener(_onTransformChanged);
      if (widget.controller == null) {
        _internal ??= TransformationController();
      } else {
        _internal?.dispose();
        _internal = null;
      }
      _controller.addListener(_onTransformChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onTransformChanged);
    _internal?.dispose();
    super.dispose();
  }

  void _onTransformChanged() {
    // Rebuild so the "reset" button enabled-state tracks the current transform.
    if (mounted && widget.showControls) setState(() {});
  }

  double get _currentScale => _controller.value.getMaxScaleOnAxis();

  bool get _isIdentity {
    final m = _controller.value;
    return (m.getMaxScaleOnAxis() - 1.0).abs() < 0.001 &&
        m.getTranslation().x.abs() < 0.5 &&
        m.getTranslation().y.abs() < 0.5;
  }

  void _tap() {
    if (widget.hapticFeedback) HapticFeedback.selectionClick();
  }

  void _zoomBy(double factor) {
    _tap();
    final target = (_currentScale * factor).clamp(widget.minScale, widget.maxScale);
    final currentScale = _currentScale;
    if (currentScale == 0) return;
    final scaleDelta = target / currentScale;
    final m = Matrix4.copy(_controller.value)..scaleByDouble(scaleDelta, scaleDelta, scaleDelta, 1);
    _controller.value = m;
  }

  void _reset() {
    _tap();
    _controller.value = Matrix4.identity();
  }

  @override
  Widget build(BuildContext context) {
    final viewer = InteractiveViewer(
      transformationController: _controller,
      minScale: widget.minScale,
      maxScale: widget.maxScale,
      panAxis: widget.panAxis,
      boundaryMargin: widget.boundaryMargin,
      constrained: widget.constrained,
      onInteractionStart: widget.onInteractionStart,
      onInteractionEnd: widget.onInteractionEnd,
      child: widget.child,
    );

    if (!widget.showControls) return viewer;

    return Stack(
      children: [
        viewer,
        Align(
          alignment: widget.controlsAlignment,
          child: Padding(
            padding: widget.controlsPadding,
            child: _ZoomControls(
              onZoomIn: _currentScale < widget.maxScale - 0.001
                  ? () => _zoomBy(widget.zoomStep)
                  : null,
              onZoomOut: _currentScale > widget.minScale + 0.001
                  ? () => _zoomBy(1 / widget.zoomStep)
                  : null,
              onReset: _isIdentity ? null : _reset,
            ),
          ),
        ),
      ],
    );
  }
}

class _ZoomControls extends StatelessWidget {
  const _ZoomControls({this.onZoomIn, this.onZoomOut, this.onReset});

  final VoidCallback? onZoomIn;
  final VoidCallback? onZoomOut;
  final VoidCallback? onReset;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Material(
      color: scheme.surface.withValues(alpha: 0.92),
      elevation: 2,
      borderRadius: BorderRadius.circular(24),
      child: Padding(
        padding: const EdgeInsets.all(2),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Zoom out',
              iconSize: 20,
              icon: const Icon(Icons.zoom_out),
              onPressed: onZoomOut,
            ),
            IconButton(
              tooltip: 'Reset view',
              iconSize: 20,
              icon: const Icon(Icons.crop_free),
              onPressed: onReset,
            ),
            IconButton(
              tooltip: 'Zoom in',
              iconSize: 20,
              icon: const Icon(Icons.zoom_in),
              onPressed: onZoomIn,
            ),
          ],
        ),
      ),
    );
  }
}
