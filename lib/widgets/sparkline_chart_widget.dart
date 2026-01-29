import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/theme/charts_config.dart';
import 'package:save_points_chart/painters/line_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';
import 'package:save_points_chart/widgets/chart_empty_state.dart';

/// Compact sparkline chart for inline data visualization
class SparklineChartWidget extends StatefulWidget {
  final List<ChartDataSet> dataSets;
  final ChartTheme? theme;
  final double lineWidth;
  final bool showArea;
  final bool showLabel;
  final Color? positiveColor;
  final Color? negativeColor;
  final String? title;
  final String? subtitle;
  final Widget? header;
  final Widget? footer;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final ChartPointCallback? onPointTap;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final List<BoxShadow>? boxShadow;
  final ChartsConfig? config;

  const SparklineChartWidget({
    super.key,
    required this.dataSets,
    this.theme,
    this.lineWidth = 2.0,
    this.showArea = true,
    this.showLabel = false,
    this.positiveColor,
    this.negativeColor,
    this.title,
    this.subtitle,
    this.header,
    this.footer,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.onPointTap,
    this.height,
    this.padding,
    this.margin,
    this.boxShadow,
    this.config,
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
    final effectiveTheme = widget.config?.theme ??
        widget.theme ??
        ChartTheme.fromMaterialTheme(Theme.of(context));
    final effectiveEmptyWidget = widget.config?.emptyWidget ??
        ChartEmptyState(
          theme: effectiveTheme,
          message: widget.config?.emptyMessage ?? 'No data available',
        );
    if (widget.dataSets.isEmpty) {
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
        padding: widget.padding ?? const EdgeInsets.all(12.0),
        boxShadow: widget.config?.boxShadow ?? widget.boxShadow,
        child: effectiveEmptyWidget,
      );
      if (widget.margin != null) {
        container = Padding(padding: widget.margin!, child: container);
      }
      return container;
    }
    // Determine if trend is positive or negative
    final firstValue = widget.dataSets.first.dataPoint.y;
    final lastValue = widget.dataSets.last.dataPoint.y;
    final isPositive = lastValue >= firstValue;
    final lineColor = isPositive
        ? (widget.positiveColor ?? const Color(0xFF10B981))
        : (widget.negativeColor ?? const Color(0xFFEF4444));

    // Create modified datasets with the determined color
    final modifiedDataSets = widget.dataSets.map((ds) {
      return ChartDataSet(
        color: lineColor,
        dataPoint: ds.dataPoint,
      );
    }).toList();

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
      padding: widget.padding ?? const EdgeInsets.all(12.0),
      boxShadow: widget.config?.boxShadow ?? widget.boxShadow,
      child: ChartEmptyScope(
        dataSets: widget.dataSets,
        emptyWidget: effectiveEmptyWidget,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  final chartHeight = widget.height ?? 100.0;
                  final chartSize = Size(constraints.maxWidth, chartHeight);

                  // Calculate bounds for tap detection (with caching)
                  Map<String, double> bounds;
                  if (_cachedBounds != null) {
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
                              modifiedDataSets,
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
                                  ? renderBox
                                      .localToGlobal(details.localPosition)
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
                      height: widget.height ?? 100.0,
                      child: CustomPaint(
                        size: chartSize,
                        painter: LineChartPainter(
                          theme: effectiveTheme.copyWith(
                            showGrid: false,
                            showAxis: false,
                          ),
                          dataSets: modifiedDataSets,
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
