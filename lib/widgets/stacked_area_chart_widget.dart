import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/painters/stacked_area_chart_painter.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';

/// Stacked area chart widget for visualizing cumulative multi-series trends.
class StackedAreaChartWidget extends StatefulWidget {
  /// Individual series to stack. Each dataset should share the same X domain.
  final List<ChartDataSet> dataSets;

  /// Optional theme override. Falls back to Material theme.
  final ChartTheme? theme;

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

  /// Container visual options.
  final bool useGlassmorphism;
  final bool useNeumorphism;

  /// Tap callback on a stacked point (top of the layer).
  final ChartPointCallback? onPointTap;

  /// Loading/error handling.
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  const StackedAreaChartWidget({
    super.key,
    required this.dataSets,
    this.theme,
    this.lineWidth = 3.0,
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

    final cumulativeDataSets = _buildCumulativeDataSets(widget.dataSets);

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
                            _cachedCumulativeData =
                                List.from(cumulativeDataSets);
                          }

                          final chartSize = Size(
                            constraints.maxWidth - 70,
                            240,
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
                                ? renderBox.localToGlobal(details.localPosition)
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
                    height: 300,
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, 300),
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
    );
  }

  List<ChartDataSet> _buildCumulativeDataSets(List<ChartDataSet> sets) {
    if (sets.isEmpty) return [];

    final int maxLength =
        sets.map((s) => s.dataPoints.length).reduce((a, b) => math.max(a, b));

    final List<ChartDataSet> cumulative = [];
    final List<double> running = List.filled(maxLength, 0.0);

    for (int i = 0; i < sets.length; i++) {
      final dataSet = sets[i];
      final List<ChartDataPoint> points = [];

      for (int j = 0; j < dataSet.dataPoints.length; j++) {
        final p = dataSet.dataPoints[j];
        final sum = running[j] + p.y;
        running[j] = sum;
        points.add(ChartDataPoint(x: p.x, y: sum, label: p.label));
      }

      cumulative.add(ChartDataSet(
        label: dataSet.label,
        dataPoints: points,
        color: dataSet.color,
      ),);
    }

    return cumulative;
  }
}

