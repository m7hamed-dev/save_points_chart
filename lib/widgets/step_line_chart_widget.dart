import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/painters/step_line_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';

/// A step line chart widget that connects points with horizontal and vertical lines.
///
/// Step line charts are useful for displaying data that changes at discrete intervals,
/// such as stock prices or step functions. Each point is connected to the next with
/// a horizontal line followed by a vertical line, creating a step-like appearance.
///
/// ## Features
/// - Multiple data series support
/// - Optional area fill with gradients
/// - Interactive point tapping with visual border highlighting
/// - Mouse hover support
/// - Loading and error states
/// - Full theme support
///
/// ## Example
/// ```dart
/// StepLineChartWidget(
///   dataSets: [
///     ChartDataSet(
///       label: 'Sales',
///       color: Colors.blue,
///       dataPoints: [
///         ChartDataPoint(x: 0, y: 10),
///         ChartDataPoint(x: 1, y: 20),
///         ChartDataPoint(x: 2, y: 15),
///       ],
///     ),
///   ],
///   theme: ChartTheme.light(),
///   title: 'Sales Trend',
///   onPointTap: (point, datasetIndex, pointIndex, position) {
///     // Handle point tap
///   },
/// )
/// ```
class StepLineChartWidget extends StatefulWidget {
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

  StepLineChartWidget({
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
  })  : assert(
          dataSets.isNotEmpty,
          'StepLineChartWidget requires at least one data set',
        ),
        assert(lineWidth > 0, 'Line width must be positive');

  @override
  State<StepLineChartWidget> createState() => _StepLineChartWidgetState();
}

class _StepLineChartWidgetState extends State<StepLineChartWidget>
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
    return ChartContainer(
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
                                ? renderBox.localToGlobal(details.localPosition)
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
                        size: Size(constraints.maxWidth, widget.height ?? 300.0),
                        painter: StepLineChartPainter(
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
    );
  }
}
