import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/save_points_chart.dart' show LineChartWidget, BarChartWidget;
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/painters/line_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';

/// A modern area chart widget with gradient fills and smooth animations.
///
/// This widget displays one or more data series as filled areas with optional
/// points and interactive tooltips. Area charts are useful for showing
/// cumulative values over time.
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
/// AreaChartWidget(
///   dataSets: [
///     ChartDataSet(
///       label: 'Users',
///       color: Colors.blue,
///       dataPoints: [
///         ChartDataPoint(x: 0, y: 100),
///         ChartDataPoint(x: 1, y: 150),
///       ],
///     ),
///   ],
///   theme: ChartTheme.light(),
///   title: 'Active Users',
///   onPointTap: (point, datasetIndex, pointIndex, position) {
///     print('Tapped: ${point.y}');
///   },
/// )
/// ```
///
/// See also:
/// - [LineChartWidget] for line charts
/// - [BarChartWidget] for bar charts
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

  /// Creates an area chart widget.
  ///
  /// [dataSets] must not be empty. Each dataset must contain at least one
  /// data point. [theme] is optional and will be inferred from the Material
  /// theme if not provided.
  ///
  /// The [lineWidth] defaults to 3.0 pixels. Use [onPointTap] to handle
  /// user interactions with data points.
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
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.onPointTap,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
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
    return ChartContainer(
      theme: effectiveTheme,
      title: widget.title,
      subtitle: widget.subtitle,
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
                              for (final point in dataSet.dataPoints) {
                                if (point.x < minX) minX = point.x;
                                if (point.x > maxX) maxX = point.x;
                                if (point.y > maxY) maxY = point.y;
                              }
                            }

                            bounds = {
                              'minX': minX,
                              'maxX': maxX,
                              'maxY': maxY,
                            };
                            _cachedBounds = bounds;
                            _cachedDataSets = List.from(widget.dataSets);
                          }

                          final chartSize = Size(
                            constraints.maxWidth - 70,
                            240,
                          );

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

                            // Get global position for context menu
                            final RenderBox? renderBox =
                                context.findRenderObject() as RenderBox?;
                            final globalPosition = renderBox != null
                                ? renderBox.localToGlobal(details.localPosition)
                                : details.localPosition;

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
                          }
                        }
                      : null,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: 300,
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, 300),
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
  }
}
