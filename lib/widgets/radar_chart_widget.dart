import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/painters/radar_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';

/// A modern radar/spider chart widget for multi-dimensional data visualization.
///
/// This widget displays data across multiple axes arranged in a circle,
/// forming a polygon shape. Useful for comparing multiple metrics.
///
/// ## Features
/// - Multiple data series support
/// - Customizable grid levels
/// - Smooth animations
/// - Full theme support
///
/// ## Example
/// ```dart
/// RadarChartWidget(
///   dataSets: [
///     RadarDataSet(
///       label: 'Performance',
///       color: Colors.blue,
///       dataPoints: [
///         RadarDataPoint(label: 'Speed', value: 80),
///         RadarDataPoint(label: 'Quality', value: 90),
///       ],
///     ),
///   ],
///   theme: ChartTheme.light(),
/// )
/// ```
class RadarChartWidget extends StatefulWidget {
  final List<RadarDataSet> dataSets;
  final ChartTheme? theme;
  final double maxValue;
  final int gridLevels;
  final bool showGrid;
  final bool showAxis;
  final bool showLabel;
  final String? title;
  final String? subtitle;
  final Widget? header;
  final Widget? footer;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final ChartPointCallback? onPointTap;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  RadarChartWidget({
    super.key,
    required this.dataSets,
    this.theme,
    this.maxValue = 100.0,
    this.gridLevels = 5,
    this.showGrid = true,
    this.showAxis = true,
    this.showLabel = true,
    this.title,
    this.subtitle,
    this.header,
    this.footer,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.onPointTap,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  })  : assert(
          dataSets.isNotEmpty,
          'RadarChartWidget requires at least one data set',
        ),
        assert(maxValue > 0, 'Max value must be positive'),
        assert(gridLevels > 0, 'Grid levels must be positive');

  @override
  State<RadarChartWidget> createState() => _RadarChartWidgetState();
}

class _RadarChartWidgetState extends State<RadarChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ChartInteractionResult? _selectedPoint;

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
    return ChartContainer(
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

                          final result = ChartInteractionHelper.findRadarPoint(
                            details.localPosition,
                            widget.dataSets,
                            Size(constraints.maxWidth, 400),
                            widget.maxValue,
                            _animation.value,
                          );

                          if (result != null && result.isHit) {
                            HapticFeedback.selectionClick();

                            setState(() {
                              _selectedPoint = result;
                            });

                            final RenderBox? renderBox =
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
                    height: 400,
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, 400),
                      painter: RadarChartPainter(
                        theme: effectiveTheme,
                        radarDataSets: widget.dataSets,
                        maxValue: widget.maxValue,
                        gridLevels: widget.gridLevels,
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
