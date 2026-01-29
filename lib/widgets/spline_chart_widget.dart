import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/painters/spline_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';
import 'package:save_points_chart/widgets/chart_empty_state.dart';

/// A modern spline chart widget with smooth curves and gradient fills.
///
/// Spline charts are similar to line charts but use smooth bezier curves
/// to connect data points, creating a more fluid visualization.
///
/// ## Features
/// - Multiple data series support
/// - Smooth bezier curves
/// - Gradient area fills
/// - Interactive point tapping
/// - Loading and error states
/// - Full theme support
///
/// ## Example
/// ```dart
/// SplineChartWidget(
///   dataSets: [
///     ChartDataSet(
///       label: 'Sales',
///       color: Colors.blue,
///       dataPoints: [
///         ChartDataPoint(x: 0, y: 10),
///         ChartDataPoint(x: 1, y: 20),
///       ],
///     ),
///   ],
///   theme: ChartTheme.light(),
///   title: 'Sales Trend',
/// )
/// ```
class SplineChartWidget extends StatefulWidget {
  final List<ChartDataSet> dataSets;
  final ChartTheme? theme;
  final double lineWidth;
  final bool showArea;
  final bool showPoints;
  final bool showGrid;
  final bool showAxis;
  final bool showLabel;
  final String? title;
  final String? subtitle;
  final Widget? header;
  final Widget? footer;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final ChartPointCallback? onPointTap;
  final ChartPointHoverCallback? onPointHover;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final List<BoxShadow>? boxShadow;

  SplineChartWidget({
    super.key,
    required this.dataSets,
    this.theme,
    this.lineWidth = 3.0,
    this.showArea = true,
    this.showPoints = true,
    this.showGrid = true,
    this.showAxis = true,
    this.showLabel = true,
    this.title,
    this.subtitle,
    this.header,
    this.footer,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.onPointTap,
    this.onPointHover,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.height,
    this.padding,
    this.margin,
    this.boxShadow,
  }) : assert(lineWidth > 0, 'Line width must be positive');

  @override
  State<SplineChartWidget> createState() => _SplineChartWidgetState();
}

class _SplineChartWidgetState extends State<SplineChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ChartInteractionResult? _selectedPoint;
  ChartInteractionResult? _hoveredPoint;

  Map<String, double>? _cachedBounds;
  List<ChartDataSet>? _cachedDataSets;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Map<String, double> _calculateBounds() {
    if (_cachedBounds != null &&
        _cachedDataSets != null &&
        _cachedDataSets == widget.dataSets) {
      return _cachedBounds!;
    }

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final dataSet in widget.dataSets) {
      final point = dataSet.dataPoint;
      if (point.x < minX) minX = point.x;
      if (point.x > maxX) maxX = point.x;
      if (point.y > maxY) maxY = point.y;
    }

    _cachedBounds = {
      'minX': minX,
      'maxX': maxX,
      'maxY': maxY,
    };
    _cachedDataSets = List.from(widget.dataSets);

    return _cachedBounds!;
  }

  void _handleHover(Offset position, Size chartSize) {
    if (widget.onPointHover == null) return;

    final bounds = _calculateBounds();
    final chartPosition = Offset(
      position.dx - 50.0,
      position.dy - 20.0,
    );

    final result = ChartInteractionHelper.findNearestPoint(
      chartPosition,
      widget.dataSets,
      chartSize,
      bounds['minX']!,
      bounds['maxX']!,
      0.0,
      bounds['maxY']! * 1.15,
      ChartInteractionConstants.hoverRadius,
    );

    if (result != null && result.isHit) {
      if (_hoveredPoint?.elementIndex != result.elementIndex ||
          _hoveredPoint?.datasetIndex != result.datasetIndex) {
        setState(() {
          _hoveredPoint = result;
        });
        widget.onPointHover?.call(
          result.point,
          result.datasetIndex,
          result.elementIndex,
        );
      }
    } else {
      if (_hoveredPoint != null) {
        setState(() {
          _hoveredPoint = null;
        });
        widget.onPointHover?.call(null, null, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme =
        widget.theme ?? ChartTheme.fromMaterialTheme(Theme.of(context));
    if (widget.dataSets.isEmpty) {
      Widget container = ChartContainer(
        theme: effectiveTheme,
        title: widget.title,
        subtitle: widget.subtitle,
        header: widget.header,
        footer: widget.footer,
        useGlassmorphism: widget.useGlassmorphism,
        useNeumorphism: widget.useNeumorphism,
        isLoading: widget.isLoading,
        isError: widget.isError,
        errorMessage: widget.errorMessage,
        padding: widget.padding,
        boxShadow: widget.boxShadow,
        child: ChartEmptyState(theme: effectiveTheme),
      );
      if (widget.margin != null) {
        container = Padding(padding: widget.margin!, child: container);
      }
      return container;
    }
    Widget container = ChartContainer(
      theme: effectiveTheme,
      title: widget.title,
      subtitle: widget.subtitle,
      header: widget.header,
      footer: widget.footer,
      useGlassmorphism: widget.useGlassmorphism,
      useNeumorphism: widget.useNeumorphism,
      isLoading: widget.isLoading,
      isError: widget.isError,
      errorMessage: widget.errorMessage,
      padding: widget.padding,
      boxShadow: widget.boxShadow,
      child: ChartEmptyScope(
        dataSets: widget.dataSets,
        emptyWidget: ChartEmptyState(theme: effectiveTheme),
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final chartHeight = widget.height ?? 240.0;
                  final chartSize = Size(
                    constraints.maxWidth - 70,
                    chartHeight,
                  );

                  return MouseRegion(
                    onHover: widget.onPointHover != null
                        ? (event) {
                            _handleHover(event.localPosition, chartSize);
                          }
                        : null,
                    onExit: widget.onPointHover != null
                        ? (_) {
                            setState(() {
                              _hoveredPoint = null;
                            });
                            widget.onPointHover?.call(null, null, null);
                          }
                        : null,
                    child: GestureDetector(
                      behavior: HitTestBehavior.translucent,
                      onTapDown: widget.onPointTap != null
                          ? (details) {
                              ChartContextMenuHelper.hide();

                              const leftPadding = 50.0;
                              const topPadding = 20.0;
                              final chartPosition = Offset(
                                details.localPosition.dx - leftPadding,
                                details.localPosition.dy - topPadding,
                              );

                              final RenderBox? renderBox =
                                  context.findRenderObject() as RenderBox?;
                              final globalPosition = renderBox != null
                                  ? renderBox
                                      .localToGlobal(details.localPosition)
                                  : details.localPosition;

                              final bounds = _calculateBounds();

                              final result =
                                  ChartInteractionHelper.findNearestPoint(
                                chartPosition,
                                widget.dataSets,
                                chartSize,
                                bounds['minX']!,
                                bounds['maxX']!,
                                0.0,
                                bounds['maxY']! * 1.15,
                                ChartInteractionConstants.tapRadius,
                              );

                              if (result != null && result.isHit) {
                                HapticFeedback.selectionClick();

                                setState(() {
                                  _selectedPoint = result;
                                });

                                Future.microtask(() {
                                  widget.onPointTap?.call(
                                    result.point!,
                                    result.datasetIndex!,
                                    result.elementIndex!,
                                    globalPosition,
                                  );
                                });
                              } else {
                                setState(() {
                                  _selectedPoint = null;
                                });
                              }
                            }
                          : null,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: widget.height ?? 300.0,
                        child: CustomPaint(
                          size: Size(
                              constraints.maxWidth, widget.height ?? 300.0),
                          painter: SplineChartPainter(
                            theme: effectiveTheme,
                            dataSets: widget.dataSets,
                            lineWidth: widget.lineWidth,
                            showArea: widget.showArea,
                            showPoints: widget.showPoints,
                            showGrid: widget.showGrid,
                            showAxis: widget.showAxis,
                            showLabel: widget.showLabel,
                            animationProgress: _animation.value,
                            selectedPoint: _selectedPoint,
                            hoveredPoint: _hoveredPoint,
                          ),
                        ),
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ),
    );

    if (widget.margin != null) {
      container = Padding(
        padding: widget.margin!,
        child: container,
      );
    }

    return container;
  }
}
