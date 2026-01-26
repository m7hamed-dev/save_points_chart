import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/painters/line_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';

/// A modern area chart widget with gradient fills and smooth animations.
///
/// This widget displays one or more data series as filled areas with optional
/// points and interactive tooltips. Area charts are useful for showing
/// cumulative values over time and comparing multiple series.
///
/// ## Features
/// - Multiple data series support with distinct colors
/// - Smooth entrance animations with easing curves
/// - Gradient area fills for visual appeal
/// - Interactive point tapping with haptic feedback
/// - Loading and error states with user-friendly messages
/// - Full theme support (light/dark mode)
/// - Glassmorphism and neumorphism effects
/// - Optimized rendering with RepaintBoundary
///
/// ## Example
/// ```dart
/// AreaChartWidget(
///   dataSets: [
///     ChartDataSet(
///       color: Colors.blue,
///       label: 'January',
///       dataPoint: ChartDataPoint(x: 0, y: 100),
///     ),
///     ChartDataSet(
///       color: Colors.blue,
///       label: 'February',
///       dataPoint: ChartDataPoint(x: 1, y: 150),
///     ),
///     ChartDataSet(
///       color: Colors.blue,
///       label: 'March',
///       dataPoint: ChartDataPoint(x: 2, y: 200),
///     ),
///   ],
///   theme: ChartTheme.light(),
///   title: 'Active Users',
///   subtitle: 'Monthly growth',
///   onPointTap: (point, datasetIndex, pointIndex, position) {
///     print('Tapped: ${point.y}');
///     showContextMenu(position);
///   },
/// )
/// ```
///
/// ## Performance Tips
/// - Use [RepaintBoundary] around multiple charts to isolate repaints
/// - Cache data sets when possible to avoid unnecessary rebuilds
/// - Consider using [isLoading] during data fetching
///
/// See also:
/// - `LineChartWidget` for line charts without fills (import from save_points_chart)
/// - `BarChartWidget` for bar charts (import from save_points_chart)
/// - `StackedAreaChartWidget` for stacked area charts (import from save_points_chart)
class AreaChartWidget extends StatefulWidget {
  /// The data sets to display in the chart.
  ///
  /// Must not be empty. Each dataset must contain at least one data point.
  final List<ChartDataSet> dataSets;

  /// The theme to use for styling the chart.
  ///
  /// If null, the theme will be inferred from the current Material theme.
  final ChartTheme? theme;

  /// The width of the line connecting data points.
  ///
  /// Defaults to 3.0 pixels.
  final double lineWidth;

  /// Whether to show data points on the chart.
  ///
  /// Defaults to true.
  final bool showPoints;

  /// Whether to show the grid lines.
  ///
  /// Defaults to true.
  final bool showGrid;

  /// Whether to show the axis lines.
  ///
  /// Defaults to true.
  final bool showAxis;

  /// Whether to show axis labels.
  ///
  /// Defaults to true.
  final bool showLabel;

  /// The title displayed above the chart.
  ///
  /// Optional. If null, no title is shown.
  final String? title;

  /// The subtitle displayed below the title.
  ///
  /// Optional. If null, no subtitle is shown.
  final String? subtitle;

  /// Optional widget displayed below the subtitle and above the chart.
  ///
  /// If null, no header is shown.
  final Widget? header;

  /// Optional widget displayed below the chart.
  ///
  /// If null, no footer is shown.
  final Widget? footer;

  /// Whether to apply glassmorphism effects to the chart container.
  ///
  /// Defaults to false.
  final bool useGlassmorphism;

  /// Whether to apply neumorphism effects to the chart container.
  ///
  /// Defaults to false.
  final bool useNeumorphism;

  /// Callback invoked when a data point is tapped.
  ///
  /// Provides the tapped point, dataset index, point index, and global position.
  /// Optional. If null, tapping is disabled.
  final ChartPointCallback? onPointTap;

  /// Callback invoked when the chart background (empty area) is tapped.
  ///
  /// Provides the global tap position. Only fires when tapping on empty chart area
  /// (not on data points). Optional. If null, background taps are ignored.
  final ChartTapCallback? onChartTap;

  /// Whether the chart is in a loading state.
  ///
  /// When true, a loading indicator is displayed. Defaults to false.
  final bool isLoading;

  /// Whether the chart is in an error state.
  ///
  /// When true, an error message is displayed. Defaults to false.
  final bool isError;

  /// The error message to display when [isError] is true.
  ///
  /// If null, a default error message is shown.
  final String? errorMessage;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final List<BoxShadow>? boxShadow;

  /// Creates an area chart widget.
  ///
  /// [dataSets] must not be empty. Each dataset must contain at least one
  /// data point. [theme] is optional and will be inferred from the Material
  /// theme if not provided.
  ///
  /// The [lineWidth] defaults to 3.0 pixels. Use [onPointTap] to handle
  /// user interactions with data points. The chart will automatically animate
  /// on first build with a smooth entrance animation.
  ///
  /// Throws an [AssertionError] if [dataSets] is empty or any dataset
  /// is empty.
  ///
  /// ## Example
  /// ```dart
  /// AreaChartWidget(
  ///   dataSets: myDataSets,
  ///   title: 'Sales Over Time',
  ///   onPointTap: handlePointTap,
  /// )
  /// ```
  const AreaChartWidget({
    super.key,
    required this.dataSets,
    this.theme,
    this.lineWidth = 3.0,
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
    this.onChartTap,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.height,
    this.padding,
    this.margin,
    this.boxShadow,
  });

  @override
  State<AreaChartWidget> createState() => _AreaChartWidgetState();
}

class _AreaChartWidgetState extends State<AreaChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ChartInteractionResult? _selectedPoint;

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

  @override
  Widget build(BuildContext context) {
    final effectiveTheme =
        widget.theme ?? ChartTheme.fromMaterialTheme(Theme.of(context));
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
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior
                      .translucent, // Allow taps even when overlay is present
                  onTapDown: widget.onPointTap != null
                      ? (details) {
                          // Hide any existing context menu first to prevent blocking
                          ChartContextMenuHelper.hide();

                          // Use localPosition directly (relative to SizedBox)
                          const leftPadding = 50.0;
                          const topPadding = 20.0;
                          final chartPosition = Offset(
                            details.localPosition.dx - leftPadding,
                            details.localPosition.dy - topPadding,
                          );

                          if (widget.dataSets.isEmpty) return;

                          // Use cached bounds if available
                          Map<String, double> bounds;
                          if (_cachedBounds != null &&
                              _cachedDataSets != null &&
                              _cachedDataSets == widget.dataSets) {
                            bounds = _cachedBounds!;
                          } else {
                            double minX = double.infinity;
                            double maxX = double.negativeInfinity;
                            double maxY = double.negativeInfinity;

                            for (final dataSet in widget.dataSets) {
                              final point = dataSet.dataPoint;
                              if (point.x < minX) minX = point.x;
                              if (point.x > maxX) maxX = point.x;
                              if (point.y > maxY) maxY = point.y;
                            }

                            bounds = {
                              'minX': minX,
                              'maxX': maxX,
                              'maxY': maxY,
                            };
                            _cachedBounds = bounds;
                            _cachedDataSets = List.from(widget.dataSets);
                          }

                          final chartHeight = widget.height ?? 240.0;
                          final chartSize = Size(
                            constraints.maxWidth - 70,
                            chartHeight,
                          );

                          // Get global position for context menu and callbacks
                          final RenderBox? renderBox =
                              context.findRenderObject() as RenderBox?;
                          final globalPosition = renderBox != null
                              ? renderBox.localToGlobal(details.localPosition)
                              : details.localPosition;

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
                      size: Size(constraints.maxWidth, widget.height ?? 300.0),
                      painter: LineChartPainter(
                        theme: effectiveTheme,
                        dataSets: widget.dataSets,
                        lineWidth: widget.lineWidth,
                        showPoints: widget.showPoints,
                        showGrid: widget.showGrid,
                        showAxis: widget.showAxis,
                        showLabel: widget.showLabel,
                        animationProgress: _animation.value,
                        selectedPoint: _selectedPoint,
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
