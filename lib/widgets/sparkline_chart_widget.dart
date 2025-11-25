import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/painters/line_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';

/// Compact sparkline chart for inline data visualization
class SparklineChartWidget extends StatefulWidget {
  final ChartDataSet dataSet;
  final ChartTheme? theme;
  final double lineWidth;
  final bool showArea;
  final bool showLabel;
  final Color? positiveColor;
  final Color? negativeColor;
  final String? title;
  final String? subtitle;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final ChartPointCallback? onPointTap;

  const SparklineChartWidget({
    super.key,
    required this.dataSet,
    this.theme,
    this.lineWidth = 2.0,
    this.showArea = true,
    this.showLabel = false,
    this.positiveColor,
    this.negativeColor,
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
  State<SparklineChartWidget> createState() => _SparklineChartWidgetState();
}

class _SparklineChartWidgetState extends State<SparklineChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ChartInteractionResult? _selectedPoint;

  // Cache bounds to avoid recalculation
  Map<String, double>? _cachedBounds;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 800),
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
    // Determine if trend is positive or negative
    final firstValue = widget.dataSet.dataPoints.first.y;
    final lastValue = widget.dataSet.dataPoints.last.y;
    final isPositive = lastValue >= firstValue;
    final lineColor = isPositive
        ? (widget.positiveColor ?? const Color(0xFF10B981))
        : (widget.negativeColor ?? const Color(0xFFEF4444));

    // Create a modified dataset with the determined color
    final modifiedDataSet = ChartDataSet(
      label: widget.dataSet.label,
      color: lineColor,
      dataPoints: widget.dataSet.dataPoints,
    );

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
      padding: const EdgeInsets.all(12.0),
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                final chartSize = Size(constraints.maxWidth, 100);

                // Calculate bounds for tap detection (with caching)
                Map<String, double> bounds;
                if (_cachedBounds != null) {
                  bounds = _cachedBounds!;
                } else {
                  double minX = double.infinity;
                  double maxX = double.negativeInfinity;
                  double maxY = double.negativeInfinity;

                  for (final point in widget.dataSet.dataPoints) {
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
                }

                return GestureDetector(
                  behavior: HitTestBehavior
                      .translucent, // Allow taps even when overlay is present
                  onTapDown: widget.onPointTap != null
                      ? (details) {
                          // Hide any existing context menu first to prevent blocking
                          ChartContextMenuHelper.hide();

                          final result =
                              ChartInteractionHelper.findNearestPoint(
                            details.localPosition,
                            [modifiedDataSet],
                            chartSize,
                            bounds['minX']!,
                            bounds['maxX']!,
                            0.0,
                            bounds['maxY']! * 1.15,
                            20.0, // tap radius
                          );

                          if (result != null && result.isHit) {
                            // Clear previous selection first
                            setState(() {
                              _selectedPoint = null;
                            });

                            // Set new selection
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
                    height: 100,
                    child: CustomPaint(
                      size: chartSize,
                      painter: LineChartPainter(
                        theme: effectiveTheme.copyWith(
                            showGrid: false, showAxis: false),
                        dataSets: [modifiedDataSet],
                        lineWidth: widget.lineWidth,
                        showArea: widget.showArea,
                        showPoints: false,
                        showGrid: false,
                        showAxis: false,
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
