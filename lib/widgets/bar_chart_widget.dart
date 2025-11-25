import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/painters/bar_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';

/// Modern bar chart with gradient fills and rounded corners
class BarChartWidget extends StatefulWidget {
  final List<ChartDataSet> dataSets;
  final ChartTheme? theme;
  final double barWidth;
  final double borderRadius;
  final bool showGrid;
  final bool showAxis;
  final bool showLabel;
  final String? title;
  final String? subtitle;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final bool isGrouped;
  final BarCallback? onBarTap;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  const BarChartWidget({
    super.key,
    required this.dataSets,
    this.theme,
    this.barWidth = 20.0,
    this.borderRadius = 8.0,
    this.showGrid = true,
    this.showAxis = true,
    this.showLabel = true,
    this.title,
    this.subtitle,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.isGrouped = false,
    this.onBarTap,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  });

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ChartInteractionResult? _selectedBar;

  // Cache bounds to avoid recalculation
  Map<String, double>? _cachedBounds;
  List<ChartDataSet>? _cachedDataSets;

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
                  onTapDown: widget.onBarTap != null
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

                          // Calculate chart bounds (with caching)
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

                          final result = ChartInteractionHelper.findBar(
                            chartPosition,
                            widget.dataSets,
                            chartSize,
                            bounds['minX']! * 0.95,
                            bounds['maxX']! * 1.05,
                            0.0,
                            bounds['maxY']! * 1.2,
                            widget.barWidth,
                          );

                          if (result != null && result.isHit) {
                            // Clear previous selection first
                            setState(() {
                              _selectedBar = null;
                            });
                            
                            // Set new selection
                            setState(() {
                              _selectedBar = result;
                            });
                            
                            // Get global position for context menu
                            final RenderBox? renderBox =
                                context.findRenderObject() as RenderBox?;
                            final globalPosition = renderBox != null
                                ? renderBox.localToGlobal(details.localPosition)
                                : details.localPosition;
                            
                            // Small delay to ensure overlay is removed before showing new menu
                            Future.microtask(() {
                              widget.onBarTap?.call(
                                result.point!,
                                result.datasetIndex!,
                                result.elementIndex!,
                                globalPosition,
                              );
                            });
                          } else {
                            // Clear selection if tap is outside any bar
                            setState(() {
                              _selectedBar = null;
                            });
                          }
                        }
                      : null,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: 300,
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, 300),
                      painter: BarChartPainter(
                        theme: effectiveTheme,
                        dataSets: widget.dataSets,
                        barWidth: widget.barWidth,
                        borderRadius: widget.borderRadius,
                        showGrid: widget.showGrid,
                        showAxis: widget.showAxis,
                        showLabel: widget.showLabel,
                        isGrouped: widget.isGrouped,
                        animationProgress: _animation.value,
                        selectedBar: _selectedBar,
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
