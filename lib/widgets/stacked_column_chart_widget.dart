import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/theme/charts_config.dart';
import 'package:save_points_chart/painters/stacked_column_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';
import 'package:save_points_chart/widgets/chart_empty_state.dart';

/// A stacked column chart widget where multiple datasets are stacked vertically.
///
/// Each column is divided into segments representing different data series,
/// with each segment stacked on top of the previous one. This is useful for
/// comparing the composition of different categories while showing the total.
///
/// ## Features
/// - Multiple data series stacked vertically
/// - Customizable bar width and border radius
/// - Interactive bar tapping with visual border highlighting
/// - Gradient fills per segment
/// - Loading and error states
/// - Full theme support
///
/// ## Example
/// ```dart
/// StackedColumnChartWidget(
///   dataSets: [
///     ChartDataSet(
///       label: 'Q1',
///       color: Colors.blue,
///       dataPoints: [
///         ChartDataPoint(x: 0, y: 10),
///         ChartDataPoint(x: 1, y: 20),
///       ],
///     ),
///     ChartDataSet(
///       label: 'Q2',
///       color: Colors.green,
///       dataPoints: [
///         ChartDataPoint(x: 0, y: 15),
///         ChartDataPoint(x: 1, y: 25),
///       ],
///     ),
///   ],
///   theme: ChartTheme.light(),
///   title: 'Quarterly Sales',
///   onBarTap: (point, datasetIndex, barIndex, position) {
///     // Handle bar tap
///   },
/// )
/// ```
class StackedColumnChartWidget extends StatefulWidget {
  final List<ChartDataSet> dataSets;
  final double barWidth;
  final double borderRadius;
  final bool showGrid;
  final bool showAxis;
  final bool showLabel;
  final String? title;
  final String? subtitle;
  final Widget? header;
  final Widget? footer;
  final BarCallback? onBarTap;
  final bool isLoading;
  final bool isError;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final ChartsConfig? config;

  const StackedColumnChartWidget({
    super.key,
    required this.dataSets,
    this.barWidth = 30.0,
    this.borderRadius = 4.0,
    this.showGrid = true,
    this.showAxis = true,
    this.showLabel = true,
    this.title,
    this.subtitle,
    this.header,
    this.footer,
    this.onBarTap,
    this.isLoading = false,
    this.isError = false,
    this.height,
    this.padding,
    this.margin,
    this.config,
  }) : assert(barWidth > 0, 'Bar width must be positive');

  @override
  State<StackedColumnChartWidget> createState() =>
      _StackedColumnChartWidgetState();
}

class _StackedColumnChartWidgetState extends State<StackedColumnChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ChartInteractionResult? _selectedBar;

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
        widget.config?.theme ?? ChartTheme.fromMaterialTheme(Theme.of(context));
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
                  return GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: widget.onBarTap != null
                        ? (details) {
                            ChartContextMenuHelper.hide();

                            const leftPadding = 50.0;
                            const topPadding = 20.0;
                            final chartPosition = Offset(
                              details.localPosition.dx - leftPadding,
                              details.localPosition.dy - topPadding,
                            );

                            if (widget.dataSets.isEmpty) return;

                            double minX = double.infinity;
                            double maxX = double.negativeInfinity;
                            double maxY = double.negativeInfinity;

                            for (final dataSet in widget.dataSets) {
                              final point = dataSet.dataPoint;
                              if (point.x < minX) minX = point.x;
                              if (point.x > maxX) maxX = point.x;
                              if (point.y > maxY) maxY = point.y;
                            }

                            // For stacked, calculate total per x position
                            final Map<double, double> totalsByX = {};
                            for (final dataSet in widget.dataSets) {
                              final point = dataSet.dataPoint;
                              totalsByX[point.x] =
                                  (totalsByX[point.x] ?? 0) + point.y;
                              if (totalsByX[point.x]! > maxY) {
                                maxY = totalsByX[point.x]!;
                              }
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
                              minX * 0.95,
                              maxX * 1.05,
                              0.0,
                              maxY * 1.2,
                              widget.barWidth,
                            );

                            if (result != null && result.isHit) {
                              HapticFeedback.selectionClick();

                              setState(() {
                                _selectedBar = result;
                              });

                              final RenderBox? renderBox =
                                  context.findRenderObject() as RenderBox?;
                              final globalPosition = renderBox != null
                                  ? renderBox
                                      .localToGlobal(details.localPosition)
                                  : details.localPosition;

                              Future.microtask(() {
                                widget.onBarTap?.call(
                                  result.point!,
                                  result.datasetIndex!,
                                  result.elementIndex!,
                                  globalPosition,
                                );
                              });
                            } else {
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
                        size:
                            Size(constraints.maxWidth, widget.height ?? 300.0),
                        painter: StackedColumnChartPainter(
                          theme: effectiveTheme,
                          dataSets: widget.dataSets,
                          barWidth: widget.barWidth,
                          borderRadius: widget.borderRadius,
                          showGrid: widget.showGrid,
                          showAxis: widget.showAxis,
                          showLabel: widget.showLabel,
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
