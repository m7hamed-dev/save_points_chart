import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/painters/radial_chart_painter.dart';
import 'package:save_points_chart/widgets/chart_container.dart';

/// Modern radial/radar chart
class RadialChartWidget extends StatefulWidget {
  final List<ChartDataSet> dataSets;
  final ChartTheme theme;
  final double lineWidth;
  final bool showPoints;
  final bool showGrid;
  final bool showLabel;
  final String? title;
  final String? subtitle;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final ChartPointCallback? onPointTap;

  const RadialChartWidget({
    super.key,
    required this.dataSets,
    required this.theme,
    this.lineWidth = 3.0,
    this.showPoints = true,
    this.showGrid = true,
    this.showLabel = true,
    this.title,
    this.subtitle,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.onPointTap,
  });

  @override
  State<RadialChartWidget> createState() => _RadialChartWidgetState();
}

class _RadialChartWidgetState extends State<RadialChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1200),
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
                final chartSize = Size(constraints.maxWidth, 300);
                return GestureDetector(
                  behavior: HitTestBehavior.opaque,
                  onTapDown: widget.onPointTap != null
                      ? (details) {
                          final result = _findNearestRadialPoint(
                            details.localPosition,
                            chartSize,
                          );

                          if (result != null && result.isHit) {
                            // Get global position for context menu
                            final RenderBox? renderBox =
                                context.findRenderObject() as RenderBox?;
                            final globalPosition = renderBox != null
                                ? renderBox.localToGlobal(details.localPosition)
                                : details.localPosition;
                            widget.onPointTap?.call(
                              result.point!,
                              result.datasetIndex!,
                              result.elementIndex!,
                              globalPosition,
                            );
                          }
                        }
                      : null,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: 300,
                    child: CustomPaint(
                      size: chartSize,
                      painter: RadialChartPainter(
                        theme: widget.theme,
                        dataSets: widget.dataSets,
                        lineWidth: widget.lineWidth,
                        showPoints: widget.showPoints,
                        showGrid: widget.showGrid,
                        showLabel: widget.showLabel,
                        animationProgress: _animation.value,
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

  ChartInteractionResult? _findNearestRadialPoint(
      Offset tapPosition, Size chartSize,) {
    if (widget.dataSets.isEmpty || widget.dataSets.first.dataPoints.isEmpty) {
      return null;
    }
    
    // Validate inputs
    if (!chartSize.width.isFinite || !chartSize.height.isFinite ||
        chartSize.width <= 0 || chartSize.height <= 0) {
      return null;
    }
    if (!tapPosition.dx.isFinite || !tapPosition.dy.isFinite) {
      return null;
    }

    final center = Offset(chartSize.width / 2, chartSize.height / 2);
    final radius = math.min(chartSize.width, chartSize.height) / 2 - 40;
    
    // Validate radius
    if (radius <= 0 || !radius.isFinite) return null;
    
    final dataSet = widget.dataSets.first;
    final points = dataSet.dataPoints;
    final maxValue = points.map((p) => p.y).reduce(math.max) * 1.2;
    
    // Validate maxValue
    if (maxValue <= 0 || !maxValue.isFinite || points.isEmpty) return null;
    
    final angleStep = 2 * math.pi / points.length;

    // Use squared distance to avoid expensive sqrt
    const tapRadius = 25.0;
    final tapRadiusSquared = tapRadius * tapRadius;
    double minDistanceSquared = double.infinity;
    ChartInteractionResult? nearestResult;

    for (int i = 0; i < points.length; i++) {
      // Validate point values
      if (!points[i].x.isFinite || !points[i].y.isFinite) continue;
      
      final angle = i * angleStep - math.pi / 2;
      final valueRadius = radius * (points[i].y / maxValue);
      
      // Validate valueRadius
      if (!valueRadius.isFinite || valueRadius < 0) continue;
      
      final pointX = center.dx + math.cos(angle) * valueRadius;
      final pointY = center.dy + math.sin(angle) * valueRadius;
      
      // Validate calculated positions
      if (!pointX.isFinite || !pointY.isFinite) continue;

      // Quick bounds check before distance calculation
      final dx = tapPosition.dx - pointX;
      final dy = tapPosition.dy - pointY;
      
      // Validate dx and dy
      if (!dx.isFinite || !dy.isFinite) continue;

      // Early exit if point is clearly outside radius
      if (dx.abs() > tapRadius || dy.abs() > tapRadius) continue;

      // Calculate squared distance (faster than distance)
      final distanceSquared = dx * dx + dy * dy;
      
      // Validate distance
      if (!distanceSquared.isFinite) continue;

      if (distanceSquared < tapRadiusSquared &&
          distanceSquared < minDistanceSquared) {
        minDistanceSquared = distanceSquared;
        nearestResult = ChartInteractionResult(
          point: points[i],
          datasetIndex: 0,
          elementIndex: i,
          isHit: true,
        );
      }
    }

    return nearestResult;
  }
}
