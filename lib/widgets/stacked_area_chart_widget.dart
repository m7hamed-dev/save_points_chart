import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/painters/stacked_area_chart_painter.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/theme/charts_config.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';
import 'package:save_points_chart/widgets/chart_empty_state.dart';

/// Stacked area chart widget for visualizing cumulative multi-series trends.
class StackedAreaChartWidget extends StatefulWidget {
  /// Individual series to stack. Each dataset should share the same X domain.
  final List<ChartDataSet> dataSets;

  /// Width of each series outline.
  final double lineWidth;

  /// Whether to draw grid lines.
  final bool showGrid;

  /// Whether to draw axes.
  final bool showAxis;

  /// Whether to draw axis labels.
  final bool showLabel;

  /// Optional title/subtitle.
  final String? title;
  final String? subtitle;

  /// Optional header widget displayed below subtitle.
  final Widget? header;

  /// Optional footer widget displayed below chart.
  final Widget? footer;

  /// Tap callback on a stacked point (top of the layer).
  final ChartPointCallback? onPointTap;

  /// Loading/error handling.
  final bool isLoading;
  final bool isError;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final ChartsConfig? config;
  final int? xAxisLabelRotation;
  final int? yAxisLabelRotation;

  const StackedAreaChartWidget({
    super.key,
    required this.dataSets,
    this.lineWidth = 3.0,
    this.showGrid = true,
    this.showAxis = true,
    this.showLabel = true,
    this.title,
    this.subtitle,
    this.header,
    this.footer,
    this.onPointTap,
    this.isLoading = false,
    this.isError = false,
    this.height,
    this.padding,
    this.margin,
    this.config,
    this.xAxisLabelRotation,
    this.yAxisLabelRotation,
  }) : assert(dataSets.length > 1, 'Provide at least two datasets to stack.');

  @override
  State<StackedAreaChartWidget> createState() => _StackedAreaChartWidgetState();
}

class _StackedAreaChartWidgetState extends State<StackedAreaChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ChartInteractionResult? _selectedPoint;

  // Cache bounds for interaction lookups
  Map<String, double>? _cachedBounds;
  List<ChartDataSet>? _cachedCumulativeData;

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
    final cumulativeDataSets = _buildCumulativeDataSets(widget.dataSets);

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
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: widget.onPointTap != null
                        ? (details) {
                            ChartContextMenuHelper.hide();

                            const leftPadding = 50.0;
                            const topPadding = 20.0;
                            final chartPosition = Offset(
                              details.localPosition.dx - leftPadding,
                              details.localPosition.dy - topPadding,
                            );

                            if (cumulativeDataSets.isEmpty) return;

                            Map<String, double> bounds;
                            if (_cachedBounds != null &&
                                _cachedCumulativeData != null &&
                                _cachedCumulativeData == cumulativeDataSets) {
                              bounds = _cachedBounds!;
                            } else {
                              double minX = double.infinity;
                              double maxX = double.negativeInfinity;
                              double maxY = double.negativeInfinity;

                              for (final dataSet in cumulativeDataSets) {
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
                              _cachedCumulativeData =
                                  List.from(cumulativeDataSets);
                            }

                            final chartHeight = widget.height ?? 240.0;
                            final chartSize = Size(
                              constraints.maxWidth - 70,
                              chartHeight,
                            );

                            final result =
                                ChartInteractionHelper.findNearestPoint(
                              chartPosition,
                              cumulativeDataSets,
                              chartSize,
                              bounds['minX']!,
                              bounds['maxX']!,
                              0.0,
                              bounds['maxY']! * 1.1,
                              ChartInteractionConstants.tapRadius,
                            );

                            if (result != null && result.isHit) {
                              HapticFeedback.selectionClick();
                              setState(() {
                                _selectedPoint = result;
                              });

                              final renderBox =
                                  context.findRenderObject() as RenderBox?;
                              final globalPosition = renderBox != null
                                  ? renderBox
                                      .localToGlobal(details.localPosition)
                                  : details.localPosition;

                              Future.microtask(() {
                                widget.onPointTap?.call(
                                  result.point!,
                                  result.datasetIndex!,
                                  result.elementIndex!,
                                  globalPosition,
                                );
                              });
                            } else {
                              setState(() {
                                _selectedPoint = null;
                              });
                            }
                          }
                        : null,
                    child: SizedBox(
                      width: constraints.maxWidth,
                      height: widget.height ?? 300.0,
                      child: CustomPaint(
                        size:
                            Size(constraints.maxWidth, widget.height ?? 300.0),
                        painter: StackedAreaChartPainter(
                          theme: effectiveTheme,
                          dataSets: cumulativeDataSets,
                          lineWidth: widget.lineWidth,
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

  List<ChartDataSet> _buildCumulativeDataSets(List<ChartDataSet> sets) {
    if (sets.isEmpty) return [];

    // Group datasets by x coordinate
    final Map<double, List<ChartDataSet>> groupedByX = {};
    for (final dataSet in sets) {
      final x = dataSet.dataPoint.x;
      if (!groupedByX.containsKey(x)) {
        groupedByX[x] = [];
      }
      groupedByX[x]!.add(dataSet);
    }

    // Sort x values
    final sortedXValues = groupedByX.keys.toList()..sort();

    // For each x position, calculate cumulative values by dataset index
    final Map<int, Map<double, double>> cumulativeByIndex = {};

    for (final xValue in sortedXValues) {
      final datasetsAtX = groupedByX[xValue]!;
      // Sort by original index to maintain layer order
      datasetsAtX.sort((a, b) {
        final indexA = sets.indexOf(a);
        final indexB = sets.indexOf(b);
        return indexA.compareTo(indexB);
      });

      double runningSum = 0.0;
      for (int i = 0; i < datasetsAtX.length; i++) {
        final dataSet = datasetsAtX[i];
        final originalIndex = sets.indexOf(dataSet);
        runningSum += dataSet.dataPoint.y;

        if (!cumulativeByIndex.containsKey(originalIndex)) {
          cumulativeByIndex[originalIndex] = {};
        }
        cumulativeByIndex[originalIndex]![xValue] = runningSum;
      }
    }

    // Build cumulative datasets
    final List<ChartDataSet> cumulative = [];
    for (int i = 0; i < sets.length; i++) {
      final originalDataSet = sets[i];
      final cumulativeValues = cumulativeByIndex[i]!;

      // Create a dataset for each x value with cumulative y
      for (final entry in cumulativeValues.entries) {
        cumulative.add(
          ChartDataSet(
            color: originalDataSet.color,
            dataPoint: ChartDataPoint(
              x: entry.key,
              y: entry.value,
              label: originalDataSet.dataPoint.label,
            ),
          ),
        );
      }
    }

    return cumulative;
  }
}
