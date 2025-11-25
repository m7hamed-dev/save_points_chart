import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/painters/line_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';

/// Modern area chart with gradient fills
class AreaChartWidget extends StatefulWidget {
  final List<ChartDataSet> dataSets;
  final ChartTheme? theme;
  final double lineWidth;
  final bool showPoints;
  final bool showGrid;
  final bool showAxis;
  final bool showLabel;
  final String? title;
  final String? subtitle;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final ChartPointCallback? onPointTap;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

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
    final effectiveTheme = widget.theme ?? ChartTheme.fromMaterialTheme(Theme.of(context));
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
                  behavior: HitTestBehavior.translucent, // Allow taps even when overlay is present
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
                            20.0,
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
