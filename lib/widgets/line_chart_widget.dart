import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/save_points_chart.dart'
    show BarChartWidget, AreaChartWidget;
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/painters/line_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';
import 'package:save_points_chart/widgets/chart_empty_state.dart';

/// A modern line chart widget with gradient fills and smooth animations.
///
/// This widget displays one or more data series as connected lines with optional
/// area fills, points, and interactive tooltips.
///
/// ## Features
/// - Multiple data series support
/// - Smooth animations
/// - Gradient area fills
/// - Interactive point tapping
/// - Loading and error states
/// - Full theme support
///
/// ## Example
/// ```dart
/// LineChartWidget(
///   dataSets: [
///     ChartDataSet(
///       color: Colors.blue,
///       label: 'January',
///       dataPoint: ChartDataPoint(x: 1, y: 20),
///     ),
///     ChartDataSet(
///       color: Colors.red,
///       label: 'February',
///       dataPoint: ChartDataPoint(x: 2, y: 30),
///     ),
///   ],
///   theme: ChartTheme.light(),
///   title: 'Sales Trend',
///   onPointTap: (point, datasetIndex, pointIndex) {
///     print('Tapped: ${point.y}');
///   },
/// )
/// ```
///
/// See also:
/// - [BarChartWidget] for bar charts
/// - [AreaChartWidget] for area charts
class LineChartWidget extends StatefulWidget {
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
  final ChartTapCallback? onChartTap;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final List<BoxShadow>? boxShadow;

  /// Creates a line chart widget.
  ///
  /// [dataSets] must not be empty. Each dataset contains one data point.
  /// [theme] is required for styling.
  ///
  /// The [lineWidth] defaults to 3.0 pixels. Set [showArea] to true to fill
  /// the area under the line with a gradient. Use [onPointTap] to handle
  /// user interactions with data points.
  LineChartWidget({
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
    this.onChartTap,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.height,
    this.padding,
    this.margin,
    this.boxShadow,
  })  : assert(lineWidth > 0, 'Line width must be positive'),
        assert(
          !isLoading || !isError,
          'Cannot be both loading and in error state',
        );

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ChartInteractionResult? _selectedPoint;
  ChartInteractionResult? _hoveredPoint;

  // Cache bounds to avoid recalculation
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

  /// Calculate chart bounds from data sets (with caching)
  Map<String, double> _calculateBounds() {
    // Return cached bounds if data hasn't changed
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

  /// Handle mouse hover events
  void _handleHover(Offset position, Size chartSize) {
    if (widget.onPointHover == null) return;

    final bounds = _calculateBounds();
    final chartPosition = Offset(
      position.dx - 50.0, // leftPadding
      position.dy - 20.0, // topPadding
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
                      behavior: HitTestBehavior
                          .translucent, // Allow taps even when overlay is present
                      onTapDown: widget.onPointTap != null
                          ? (details) {
                              // Hide any existing context menu first to prevent blocking
                              ChartContextMenuHelper.hide();

                              // Use localPosition directly (relative to SizedBox)
                              // Account for padding
                              const leftPadding = 50.0;
                              const topPadding = 20.0;
                              final chartPosition = Offset(
                                details.localPosition.dx - leftPadding,
                                details.localPosition.dy - topPadding,
                              );

                              // Get global position for context menu
                              final RenderBox? renderBox =
                                  context.findRenderObject() as RenderBox?;
                              final globalPosition = renderBox != null
                                  ? renderBox
                                      .localToGlobal(details.localPosition)
                                  : details.localPosition;

                              // Calculate chart bounds
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
                                // Provide haptic feedback
                                HapticFeedback.selectionClick();

                                // Set new selection (optimized single setState)
                                setState(() {
                                  _selectedPoint = result;
                                });

                                // Small delay to ensure overlay is removed before showing new menu
                                Future.microtask(() {
                                  widget.onPointTap?.call(
                                    result.point!,
                                    result.datasetIndex!,
                                    result.elementIndex!,
                                    globalPosition,
                                  );
                                });
                              } else {
                                // Clear selection if tap is outside any point
                                setState(() {
                                  _selectedPoint = null;
                                });
                                // Call onChartTap if no point was hit
                                if (widget.onChartTap != null) {
                                  widget.onChartTap!(globalPosition);
                                }
                              }
                            }
                          : null,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: widget.height ?? 300.0,
                        child: CustomPaint(
                          size: Size(
                              constraints.maxWidth, widget.height ?? 300.0),
                          painter: LineChartPainter(
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
