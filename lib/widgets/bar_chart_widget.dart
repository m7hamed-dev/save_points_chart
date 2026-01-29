import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/painters/bar_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';
import 'package:save_points_chart/widgets/chart_empty_state.dart';

/// Modern bar chart with gradient fills and rounded corners
class BarChartWidget extends StatefulWidget {
  final List<ChartDataSet> dataSets;
  final ChartTheme? theme;
  final double barWidth;
  final double borderRadius;
  final bool barRounded;
  final bool showGrid;
  final bool showAxis;
  final bool showLabel;
  final String? title;
  final String? subtitle;
  final Widget? header;
  final Widget? footer;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final bool isGrouped;
  final BarCallback? onBarTap;
  final BarHoverCallback? onBarHover;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final List<BoxShadow>? boxShadow;

  const BarChartWidget({
    super.key,
    required this.dataSets,
    this.theme,
    this.barWidth = 20.0,
    this.borderRadius = 8.0,
    this.barRounded = true,
    this.showGrid = true,
    this.showAxis = true,
    this.showLabel = true,
    this.title,
    this.subtitle,
    this.header,
    this.footer,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.isGrouped = false,
    this.onBarTap,
    this.onBarHover,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.height,
    this.padding,
    this.margin,
    this.boxShadow,
  });

  @override
  State<BarChartWidget> createState() => _BarChartWidgetState();
}

class _BarChartWidgetState extends State<BarChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ChartInteractionResult? _selectedBar;
  ChartInteractionResult? _hoveredBar;

  // Cache bounds to avoid recalculation
  Map<String, double>? _cachedBounds;
  List<ChartDataSet>? _cachedDataSets;

  /// Handle mouse hover events
  void _handleHover(Offset position, BoxConstraints constraints) {
    if (widget.onBarHover == null) return;

    const leftPadding = 50.0;
    const topPadding = 20.0;
    final chartPosition = Offset(
      position.dx - leftPadding,
      position.dy - topPadding,
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
      if (_hoveredBar?.elementIndex != result.elementIndex ||
          _hoveredBar?.datasetIndex != result.datasetIndex) {
        setState(() {
          _hoveredBar = result;
        });
        widget.onBarHover?.call(
          result.point,
          result.datasetIndex,
          result.elementIndex,
        );
      }
    } else {
      if (_hoveredBar != null) {
        setState(() {
          _hoveredBar = null;
        });
        widget.onBarHover?.call(null, null, null);
      }
    }
  }

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
                  return MouseRegion(
                    onHover: widget.onBarHover != null
                        ? (event) {
                            _handleHover(event.localPosition, constraints);
                          }
                        : null,
                    onExit: widget.onBarHover != null
                        ? (_) {
                            setState(() {
                              _hoveredBar = null;
                            });
                            widget.onBarHover?.call(null, null, null);
                          }
                        : null,
                    child: GestureDetector(
                      behavior: HitTestBehavior
                          .translucent, // Allow taps even when overlay is present
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
                                // Provide haptic feedback
                                HapticFeedback.selectionClick();

                                // Set new selection (optimized single setState)
                                setState(() {
                                  _selectedBar = result;
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
                        height: widget.height ?? 300.0,
                        child: CustomPaint(
                          size: Size(
                              constraints.maxWidth, widget.height ?? 300.0),
                          painter: BarChartPainter(
                            theme: effectiveTheme,
                            dataSets: widget.dataSets,
                            barWidth: widget.barWidth,
                            borderRadius: widget.borderRadius,
                            barRounded: widget.barRounded,
                            showGrid: widget.showGrid,
                            showAxis: widget.showAxis,
                            showLabel: widget.showLabel,
                            isGrouped: widget.isGrouped,
                            animationProgress: _animation.value,
                            selectedBar: _selectedBar,
                            hoveredBar: _hoveredBar,
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
