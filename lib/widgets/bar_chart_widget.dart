import 'package:flutter/material.dart';
import '../models/chart_data.dart';
import '../models/chart_interaction.dart';
import '../theme/chart_theme.dart';
import '../painters/bar_chart_painter.dart';
import '../utils/chart_interaction_helper.dart';
import 'chart_container.dart';

/// Modern bar chart with gradient fills and rounded corners
class BarChartWidget extends StatefulWidget {
  final List<ChartDataSet> dataSets;
  final ChartTheme theme;
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
    required this.theme,
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
    return ChartContainer(
      theme: widget.theme,
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
                  behavior: HitTestBehavior.opaque,
                  onTapDown: widget.onBarTap != null
                      ? (details) {
                          // Use localPosition directly (relative to SizedBox)
                          const leftPadding = 50.0;
                          const topPadding = 20.0;
                          final chartPosition = Offset(
                            details.localPosition.dx - leftPadding,
                            details.localPosition.dy - topPadding,
                          );
                          
                          // Calculate chart bounds
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
                            setState(() {
                              _selectedBar = result;
                            });
                            widget.onBarTap?.call(
                              result.point!,
                              result.datasetIndex!,
                              result.elementIndex!,
                            );
                          }
                        }
                      : null,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: 300,
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, 300),
                      painter: BarChartPainter(
                        theme: widget.theme,
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
