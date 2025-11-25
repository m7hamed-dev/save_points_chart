import 'package:flutter/material.dart';
import '../models/chart_data.dart';
import '../theme/chart_theme.dart';
import '../painters/line_chart_painter.dart';
import 'chart_container.dart';

/// Compact sparkline chart for inline data visualization
class SparklineChartWidget extends StatefulWidget {
  final ChartDataSet dataSet;
  final ChartTheme theme;
  final double lineWidth;
  final bool showArea;
  final bool showLabel;
  final Color? positiveColor;
  final Color? negativeColor;
  final String? title;
  final String? subtitle;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  const SparklineChartWidget({
    super.key,
    required this.dataSet,
    required this.theme,
    this.lineWidth = 2.0,
    this.showArea = true,
    this.showLabel = false,
    this.positiveColor,
    this.negativeColor,
    this.title,
    this.subtitle,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  });

  @override
  State<SparklineChartWidget> createState() => _SparklineChartWidgetState();
}

class _SparklineChartWidgetState extends State<SparklineChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
    // Determine if trend is positive or negative
    final firstValue = widget.dataSet.dataPoints.first.y;
    final lastValue = widget.dataSet.dataPoints.last.y;
    final isPositive = lastValue >= firstValue;
    final lineColor = isPositive
        ? (widget.positiveColor ?? const Color(0xFF10B981))
        : (widget.negativeColor ?? const Color(0xFFEF4444));

    // Create a modified dataset with the determined color
    final modifiedDataSet = ChartDataSet(
      label: widget.dataSet.label,
      color: lineColor,
      dataPoints: widget.dataSet.dataPoints,
    );

    return ChartContainer(
      theme: widget.theme,
      title: widget.title,
      subtitle: widget.subtitle,
      useGlassmorphism: widget.useGlassmorphism,
      useNeumorphism: widget.useNeumorphism,
      isLoading: widget.isLoading,
      isError: widget.isError,
      errorMessage: widget.errorMessage,
      padding: const EdgeInsets.all(12.0),
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return LayoutBuilder(
            builder: (context, constraints) {
              return SizedBox(
                width: constraints.maxWidth,
                height: 100,
                child: CustomPaint(
                  size: Size(constraints.maxWidth, 100),
                  painter: LineChartPainter(
                    theme: widget.theme.copyWith(showGrid: false, showAxis: false),
                    dataSets: [modifiedDataSet],
                    lineWidth: widget.lineWidth,
                    showArea: widget.showArea,
                    showPoints: false,
                    showGrid: false,
                    showAxis: false,
                    showLabel: widget.showLabel,
                    animationProgress: _animation.value,
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
