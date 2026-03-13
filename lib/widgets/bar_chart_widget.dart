import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/theme/charts_config.dart';
import 'package:save_points_chart/painters/bar_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';
import 'package:save_points_chart/widgets/chart_empty_state.dart';
import 'package:save_points_chart/widgets/chart_tooltip_overlay.dart';

/// Modern bar chart with gradient fills and rounded corners
class BarChartWidget extends StatefulWidget {
  final List<ChartDataSet> dataSets;
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
  final bool isGrouped;
  final BarCallback? onBarTap;
  final BarHoverCallback? onBarHover;
  final bool isLoading;
  final bool isError;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final ChartsConfig? config;
  final int? xAxisLabelRotation;
  final int? yAxisLabelRotation;

  const BarChartWidget({
    super.key,
    required this.dataSets,
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
    this.isGrouped = false,
    this.onBarTap,
    this.onBarHover,
    this.isLoading = false,
    this.isError = false,
    this.height,
    this.padding,
    this.margin,
    this.config,
    this.xAxisLabelRotation,
    this.yAxisLabelRotation,
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
  
  // Cache grouped data for painter optimization
  Map<double, List<ChartDataSet>>? _groupedData;
  List<double>? _sortedXValues;

  void _hideTooltip() {
    ChartTooltipOverlay.hide();
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
      curve: Curves.easeOutQuart,
    );
    _controller.forward();
    _updateGroupedData();
  }

  @override
  void didUpdateWidget(BarChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.dataSets != oldWidget.dataSets || 
        widget.isGrouped != oldWidget.isGrouped) {
      _updateGroupedData();
      // Clear bounds cache if data changed
      if (widget.dataSets != oldWidget.dataSets) {
        _cachedBounds = null;
        _cachedDataSets = null;
      }
    }
  }

  void _updateGroupedData() {
    if (!widget.isGrouped) {
      _groupedData = null;
      _sortedXValues = null;
      return;
    }

    final Map<double, List<ChartDataSet>> groupedByX = {};
    for (final dataSet in widget.dataSets) {
      final x = dataSet.dataPoint.x;
      groupedByX.putIfAbsent(x, () => []).add(dataSet);
    }
    
    _groupedData = groupedByX;
    _sortedXValues = groupedByX.keys.toList()..sort();
  }

  Map<String, double> _getOrCalculateBounds() {
    if (_cachedBounds != null &&
        _cachedDataSets != null &&
        _cachedDataSets == widget.dataSets) {
      return _cachedBounds!;
    }

    double minX = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final dataSet in widget.dataSets) {
      final point = dataSet.dataPoint;
      if (point.x < minX) minX = point.x;
      if (point.x > maxX) maxX = point.x;
      if (point.y > maxY) maxY = point.y;
    }

    final bounds = {
      'minX': minX,
      'maxX': maxX,
      'maxY': maxY,
    };
    
    _cachedBounds = bounds;
    _cachedDataSets = List.from(widget.dataSets);
    return bounds;
  }

  /// Handle mouse hover events
  void _handleHover(
    Offset position,
    BoxConstraints constraints,
    ChartTheme effectiveTheme,
  ) {
    if (widget.onBarHover == null) return;

    const leftPadding = 50.0;
    const topPadding = 20.0;
    final chartPosition = Offset(
      position.dx - leftPadding,
      position.dy - topPadding,
    );

    if (widget.dataSets.isEmpty) return;

    final bounds = _getOrCalculateBounds();

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

        // Dashboard-style hover tooltip for bars.
        if (effectiveTheme.showTooltip) {
          final RenderBox? renderBox =
              context.findRenderObject() as RenderBox?;
          final global = renderBox != null
              ? renderBox.localToGlobal(position)
              : position;
          final ds = (result.datasetIndex != null &&
                  result.datasetIndex! >= 0 &&
                  result.datasetIndex! < widget.dataSets.length)
              ? widget.dataSets[result.datasetIndex!]
              : null;
          ChartTooltipOverlay.show(
            context,
            globalAnchor: global,
            theme: effectiveTheme,
            point: result.point!,
            color: ds?.color,
            seriesLabel: ds?.dataPoint.label,
          );
        }
      }
    } else {
      if (_hoveredBar != null) {
        setState(() {
          _hoveredBar = null;
        });
        widget.onBarHover?.call(null, null, null);
      }
      _hideTooltip();
    }
  }

  void _handleTap(TapDownDetails details, BoxConstraints constraints) {
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

    final bounds = _getOrCalculateBounds();

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
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
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
      _hideTooltip();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var effectiveTheme =
        widget.config?.theme ?? ChartTheme.fromMaterialTheme(Theme.of(context));
    if (widget.xAxisLabelRotation != null) {
      effectiveTheme = effectiveTheme.copyWith(
          xAxisLabelRotation: widget.xAxisLabelRotation);
    }
    if (widget.yAxisLabelRotation != null) {
      effectiveTheme = effectiveTheme.copyWith(
          yAxisLabelRotation: widget.yAxisLabelRotation);
    }

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
        useGlassmorphism: widget.config?.useGlassmorphism ?? false,
        useNeumorphism: widget.config?.useNeumorphism ?? false,
        isLoading: widget.isLoading,
        isError: widget.isError,
        errorMessage: widget.config?.errorMessage,
        errorWidget: widget.config?.errorWidget,
        padding: widget.padding,
        boxShadow: widget.config?.boxShadow,
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
      useGlassmorphism: widget.config?.useGlassmorphism ?? false,
      useNeumorphism: widget.config?.useNeumorphism ?? false,
      isLoading: widget.isLoading,
      isError: widget.isError,
      errorMessage: widget.config?.errorMessage,
      errorWidget: widget.config?.errorWidget,
      padding: widget.padding,
      boxShadow: widget.config?.boxShadow,
      child: ChartEmptyScope(
        dataSets: widget.dataSets,
        emptyWidget: effectiveEmptyWidget,
        child: RepaintBoundary(
          child: AnimatedBuilder(
            animation: _animation,
            builder: (context, child) {
              return LayoutBuilder(
                builder: (context, constraints) {
                  return MouseRegion(
                    onHover: widget.onBarHover != null
                        ? (event) {
                            _handleHover(
                              event.localPosition,
                              constraints,
                              effectiveTheme,
                            );
                          }
                        : null,
                    onExit: widget.onBarHover != null
                        ? (_) {
                            setState(() {
                              _hoveredBar = null;
                            });
                            widget.onBarHover?.call(null, null, null);
                            _hideTooltip();
                          }
                        : null,
                    child: GestureDetector(
                      behavior: HitTestBehavior
                          .translucent, // Allow taps even when overlay is present
                      onTapDown: widget.onBarTap != null
                          ? (details) => _handleTap(details, constraints)
                          : null,
                      onSecondaryTapDown: widget.onBarTap != null
                          ? (details) => _handleTap(details, constraints)
                          : null,
                      child: SizedBox(
                        width: constraints.maxWidth,
                        height: widget.height ?? 300.0,
                        child: CustomPaint(
                          size: Size(
                              constraints.maxWidth, widget.height ?? 300.0,),
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
                            groupedData: _groupedData,
                            sortedXValues: _sortedXValues,
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
