import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/painters/stacked_column_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';

/// A stacked column chart widget where multiple datasets are stacked vertically.
///
/// Each column is divided into segments representing different data series,
/// with each segment stacked on top of the previous one.
class StackedColumnChartWidget extends StatefulWidget {
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
  final BarCallback? onBarTap;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  StackedColumnChartWidget({
    super.key,
    required this.dataSets,
    this.theme,
    this.barWidth = 30.0,
    this.borderRadius = 4.0,
    this.showGrid = true,
    this.showAxis = true,
    this.showLabel = true,
    this.title,
    this.subtitle,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.onBarTap,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  })  : assert(
          dataSets.isNotEmpty,
          'StackedColumnChartWidget requires at least one data set',
        ),
        assert(barWidth > 0, 'Bar width must be positive');

  @override
  State<StackedColumnChartWidget> createState() =>
      _StackedColumnChartWidgetState();
}

class _StackedColumnChartWidgetState
    extends State<StackedColumnChartWidget> with SingleTickerProviderStateMixin {
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
                            for (final point in dataSet.dataPoints) {
                              if (point.x < minX) minX = point.x;
                              if (point.x > maxX) maxX = point.x;
                              if (point.y > maxY) maxY = point.y;
                            }
                          }

                          // For stacked, calculate total per x position
                          final Map<double, double> totalsByX = {};
                          for (final dataSet in widget.dataSets) {
                            for (final point in dataSet.dataPoints) {
                              totalsByX[point.x] =
                                  (totalsByX[point.x] ?? 0) + point.y;
                              if (totalsByX[point.x]! > maxY) {
                                maxY = totalsByX[point.x]!;
                              }
                            }
                          }

                          final chartSize = Size(
                            constraints.maxWidth - 70,
                            240,
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
                    height: 300,
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, 300),
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
    );
  }
}

