import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/theme/charts_config.dart';
import 'package:save_points_chart/painters/bubble_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';
import 'package:save_points_chart/widgets/chart_empty_state.dart';

/// A modern bubble chart widget for visualizing three-dimensional data.
///
/// This widget displays data points as bubbles where x, y represent position
/// and size represents a third dimension. Perfect for visualizing relationships
/// between three variables (e.g., sales, profit, and market share).
///
/// ## Features
/// - Multiple data series support with distinct colors
/// - Interactive bubble tapping with haptic feedback ([onBubbleTap])
/// - Hover support for desktop/web platforms ([onBubbleHover])
/// - Background tap handling ([onChartTap])
/// - Customizable bubble size range ([minBubbleSize], [maxBubbleSize])
/// - Smooth entrance animations
/// - Full theme support (light/dark mode)
/// - Glassmorphism and neumorphism effects
/// - Optimized rendering with bounds caching
///
/// ## Example
/// ```dart
/// BubbleChartWidget(
///   dataSets: [
///     BubbleDataSet(
///       label: 'Products',
///       color: Colors.blue,
///       dataPoints: [
///         BubbleDataPoint(x: 10, y: 20, size: 50),
///         BubbleDataPoint(x: 15, y: 30, size: 75),
///       ],
///     ),
///   ],
///   theme: ChartTheme.light(),
///   minBubbleSize: 5.0,
///   maxBubbleSize: 30.0,
///   onBubbleTap: (point, datasetIndex, pointIndex, position) {
///     print('Tapped bubble: ${point.y}');
///   },
///   onBubbleHover: (point, datasetIndex, pointIndex) {
///     if (point != null) {
///       showTooltip('Bubble: ${point.y}');
///     }
///   },
///   onChartTap: (position) {
///     // Handle background tap
///   },
/// )
/// ```
///
/// ## Performance Tips
/// - Bounds are automatically cached to avoid recalculation
/// - Use [RepaintBoundary] around multiple charts
/// - Consider data point limits for very large datasets
///
/// See also:
/// - `ScatterChartWidget` for two-dimensional scatter plots (import from save_points_chart)
/// - `BubbleDataSet` for bubble data structure (import from models)
class BubbleChartWidget extends StatefulWidget {
  final List<BubbleDataSet> dataSets;
  final ChartTheme? theme;
  final double minBubbleSize;
  final double maxBubbleSize;
  final bool showGrid;
  final bool showAxis;
  final bool showLabel;
  final String? title;
  final String? subtitle;
  final Widget? header;
  final Widget? footer;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final BubbleTapCallback? onBubbleTap;
  final BubbleHoverCallback? onBubbleHover;
  final ChartTapCallback? onChartTap;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final List<BoxShadow>? boxShadow;
  final ChartsConfig? config;

  /// Creates a bubble chart widget.
  ///
  /// [dataSets] must not be empty. Each dataset must contain at least one
  /// bubble data point. [theme] is optional and will be inferred from the
  /// Material theme if not provided.
  ///
  /// [minBubbleSize] and [maxBubbleSize] control the visual size range of
  /// bubbles. The actual bubble sizes will be scaled proportionally within
  /// this range based on the data values.
  ///
  /// Throws an [AssertionError] if:
  /// - [dataSets] is empty
  /// - [minBubbleSize] is not positive
  /// - [maxBubbleSize] is not greater than [minBubbleSize]
  ///
  /// ## Example
  /// ```dart
  /// BubbleChartWidget(
  ///   dataSets: myBubbleDataSets,
  ///   minBubbleSize: 5.0,
  ///   maxBubbleSize: 30.0,
  ///   onBubbleTap: handleBubbleTap,
  ///   onChartTap: (position) {
  ///     // Handle background tap
  ///   },
  /// )
  /// ```
  BubbleChartWidget({
    super.key,
    required this.dataSets,
    this.theme,
    this.minBubbleSize = 5.0,
    this.maxBubbleSize = 30.0,
    this.showGrid = true,
    this.showAxis = true,
    this.showLabel = true,
    this.title,
    this.subtitle,
    this.header,
    this.footer,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.onBubbleTap,
    this.onBubbleHover,
    this.onChartTap,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.height,
    this.padding,
    this.margin,
    this.boxShadow,
    this.config,
  })  : assert(minBubbleSize > 0, 'Min bubble size must be positive'),
        assert(
          minBubbleSize.isFinite,
          'Min bubble size must be finite',
        ),
        assert(maxBubbleSize > minBubbleSize, 'Max must be greater than min'),
        assert(
          maxBubbleSize.isFinite,
          'Max bubble size must be finite',
        );

  @override
  State<BubbleChartWidget> createState() => _BubbleChartWidgetState();
}

class _BubbleChartWidgetState extends State<BubbleChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ChartInteractionResult? _selectedBubble;
  ChartInteractionResult? _hoveredBubble;

  Map<String, double>? _cachedBounds;
  List<BubbleDataSet>? _cachedDataSets;

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
    double minY = double.infinity;
    double maxY = double.negativeInfinity;

    for (final dataSet in widget.dataSets) {
      for (final point in dataSet.dataPoints) {
        // BubbleDataSet still uses dataPoints (plural)
        if (point.x < minX) minX = point.x;
        if (point.x > maxX) maxX = point.x;
        if (point.y < minY) minY = point.y;
        if (point.y > maxY) maxY = point.y;
      }
    }

    final xRange = maxX - minX;
    final yRange = maxY - minY;
    _cachedBounds = {
      'minX': minX - xRange * 0.1,
      'maxX': maxX + xRange * 0.1,
      'minY': minY - yRange * 0.1,
      'maxY': maxY + yRange * 0.1,
    };
    _cachedDataSets = List.from(widget.dataSets);

    return _cachedBounds!;
  }

  void _handleHover(Offset position, Size chartSize) {
    if (widget.onBubbleHover == null) return;

    final bounds = _calculateBounds();
    final chartPosition = Offset(
      position.dx - 50.0,
      position.dy - 20.0,
    );

    // Convert bubble datasets to regular datasets for interaction helper
    // Each bubble point becomes a separate ChartDataSet
    final regularDataSets = <ChartDataSet>[];
    for (final bubbleDataSet in widget.dataSets) {
      for (final point in bubbleDataSet.dataPoints) {
        regularDataSets.add(
          ChartDataSet(
            color: bubbleDataSet.color,
            dataPoint:
                ChartDataPoint(x: point.x, y: point.y, label: point.label),
          ),
        );
      }
    }

    final result = ChartInteractionHelper.findNearestPoint(
      chartPosition,
      regularDataSets,
      chartSize,
      bounds['minX']!,
      bounds['maxX']!,
      bounds['minY']!,
      bounds['maxY']!,
      ChartInteractionConstants.hoverRadius * 3,
    );

    if (result != null && result.isHit) {
      if (_hoveredBubble?.elementIndex != result.elementIndex ||
          _hoveredBubble?.datasetIndex != result.datasetIndex) {
        setState(() {
          _hoveredBubble = result;
        });
        widget.onBubbleHover?.call(
          result.point,
          result.datasetIndex,
          result.elementIndex,
        );
      }
    } else {
      if (_hoveredBubble != null) {
        setState(() {
          _hoveredBubble = null;
        });
        widget.onBubbleHover?.call(null, null, null);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = widget.config?.theme ??
        widget.theme ??
        ChartTheme.fromMaterialTheme(Theme.of(context));
    final effectiveEmptyWidget = widget.config?.emptyWidget ??
        ChartEmptyState(
          theme: effectiveTheme,
          message: widget.config?.emptyMessage ?? 'No data available',
        );
    final hasData = widget.dataSets.isNotEmpty &&
        widget.dataSets.every((ds) => ds.dataPoints.isNotEmpty);
    if (!hasData) {
      Widget container = ChartContainer(
        theme: effectiveTheme,
        title: widget.title,
        subtitle: widget.subtitle,
        header: widget.header,
        footer: widget.footer,
        useGlassmorphism: widget.config?.useGlassmorphism ?? widget.useGlassmorphism,
        useNeumorphism: widget.config?.useNeumorphism ?? widget.useNeumorphism,
        isLoading: widget.isLoading,
        isError: widget.isError,
        errorMessage: widget.config?.errorMessage ?? widget.errorMessage,
        errorWidget: widget.config?.errorWidget,
        padding: widget.padding,
        boxShadow: widget.config?.boxShadow ?? widget.boxShadow,
        child: effectiveEmptyWidget,
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
      useGlassmorphism: widget.config?.useGlassmorphism ?? widget.useGlassmorphism,
      useNeumorphism: widget.config?.useNeumorphism ?? widget.useNeumorphism,
      isLoading: widget.isLoading,
      isError: widget.isError,
      errorMessage: widget.config?.errorMessage ?? widget.errorMessage,
      errorWidget: widget.config?.errorWidget,
      padding: widget.padding,
      boxShadow: widget.config?.boxShadow ?? widget.boxShadow,
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
                  onHover: widget.onBubbleHover != null
                      ? (event) {
                          _handleHover(event.localPosition, chartSize);
                        }
                      : null,
                  onExit: widget.onBubbleHover != null
                      ? (_) {
                          setState(() {
                            _hoveredBubble = null;
                          });
                          widget.onBubbleHover?.call(null, null, null);
                        }
                      : null,
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: widget.onBubbleTap != null
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

                            // Convert bubble datasets to regular datasets
                            // Each bubble point becomes a separate ChartDataSet
                            final regularDataSets = <ChartDataSet>[];
                            for (final bubbleDataSet in widget.dataSets) {
                              for (final point in bubbleDataSet.dataPoints) {
                                regularDataSets.add(
                                  ChartDataSet(
                                    color: bubbleDataSet.color,
                                    dataPoint: ChartDataPoint(
                                      x: point.x,
                                      y: point.y,
                                      label: point.label,
                                    ),
                                  ),
                                );
                              }
                            }

                            final result =
                                ChartInteractionHelper.findNearestPoint(
                              chartPosition,
                              regularDataSets,
                              chartSize,
                              bounds['minX']!,
                              bounds['maxX']!,
                              bounds['minY']!,
                              bounds['maxY']!,
                              ChartInteractionConstants.tapRadius * 3,
                            );

                            if (result != null && result.isHit) {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedBubble = result;
                              });
                              Future.microtask(() {
                                widget.onBubbleTap?.call(
                                  result.point!,
                                  result.datasetIndex!,
                                  result.elementIndex!,
                                  globalPosition,
                                );
                              });
                            } else {
                              setState(() {
                                _selectedBubble = null;
                              });
                              // Call onChartTap if no bubble was hit
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
                        size:
                            Size(constraints.maxWidth, widget.height ?? 300.0),
                        painter: BubbleChartPainter(
                          theme: effectiveTheme,
                          bubbleDataSets: widget.dataSets,
                          minBubbleSize: widget.minBubbleSize,
                          maxBubbleSize: widget.maxBubbleSize,
                          showGrid: widget.showGrid,
                          showAxis: widget.showAxis,
                          showLabel: widget.showLabel,
                          animationProgress: _animation.value,
                          selectedBubble: _selectedBubble,
                          hoveredBubble: _hoveredBubble,
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

    if (widget.margin != null) {
      container = Padding(
        padding: widget.margin!,
        child: container,
      );
    }

    return container;
  }
}
