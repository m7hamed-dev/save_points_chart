import 'package:flutter/material.dart';
import '../models/chart_data.dart';
import '../models/chart_interaction.dart';
import '../theme/chart_theme.dart';
import '../painters/line_chart_painter.dart';
import '../utils/chart_interaction_helper.dart';
import 'chart_container.dart';

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
  final ChartTheme theme;
  final double lineWidth;
  final bool showArea;
  final bool showPoints;
  final bool showGrid;
  final bool showAxis;
  final bool showLabel;
  final String? title;
  final String? subtitle;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final ChartPointCallback? onPointTap;
  final ChartPointHoverCallback? onPointHover;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  /// Creates a line chart widget.
  ///
  /// [dataSets] must not be empty. Each dataset must contain at least one
  /// data point. [theme] is required for styling.
  ///
  /// The [lineWidth] defaults to 3.0 pixels. Set [showArea] to true to fill
  /// the area under the line with a gradient. Use [onPointTap] to handle
  /// user interactions with data points.
  LineChartWidget({
    super.key,
    required this.dataSets,
    required this.theme,
    this.lineWidth = 3.0,
    this.showArea = true,
    this.showPoints = true,
    this.showGrid = true,
    this.showAxis = true,
    this.showLabel = true,
    this.title,
    this.subtitle,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.onPointTap,
    this.onPointHover,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  }) : assert(dataSets.isNotEmpty, 'LineChartWidget requires at least one data set'),
       assert(lineWidth > 0, 'Line width must be positive'),
       assert(!isLoading || !isError, 'Cannot be both loading and in error state');

  @override
  State<LineChartWidget> createState() => _LineChartWidgetState();
}

class _LineChartWidgetState extends State<LineChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ChartInteractionResult? _selectedPoint;
  ChartInteractionResult? _hoveredPoint;

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

  /// Calculate chart bounds from data sets
  Map<String, double> _calculateBounds() {
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

    return {
      'minX': minX,
      'maxX': maxX,
      'maxY': maxY,
    };
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
      30.0, // hover radius (larger than tap)
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
    return ChartContainer(
      theme: widget.theme,
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
                final chartSize = Size(
                  constraints.maxWidth - 70,
                  240,
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
                    behavior: HitTestBehavior.opaque,
                    onTapDown: widget.onPointTap != null
                        ? (details) {
                            // Use localPosition directly (relative to SizedBox)
                            // Account for padding
                            const leftPadding = 50.0;
                            const topPadding = 20.0;
                            final chartPosition = Offset(
                              details.localPosition.dx - leftPadding,
                              details.localPosition.dy - topPadding,
                            );
                            
                            // Calculate chart bounds
                            final bounds = _calculateBounds();
                            
                            final result = ChartInteractionHelper.findNearestPoint(
                              chartPosition,
                              widget.dataSets,
                              chartSize,
                              bounds['minX']!,
                              bounds['maxX']!,
                              0.0,
                              bounds['maxY']! * 1.15,
                              20.0, // tap radius
                            );
                            
                            if (result != null && result.isHit) {
                              setState(() {
                                _selectedPoint = result;
                              });
                              widget.onPointTap?.call(
                                result.point!,
                                result.datasetIndex!,
                                result.elementIndex!,
                              );
                            }
                          }
                        : null,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: 300,
                      child: CustomPaint(
                        size: Size(constraints.maxWidth, 300),
                        painter: LineChartPainter(
                          theme: widget.theme,
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
