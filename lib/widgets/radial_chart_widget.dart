import 'package:flutter/material.dart';
import '../models/chart_data.dart';
import '../theme/chart_theme.dart';
import '../painters/radial_chart_painter.dart';
import 'chart_container.dart';

/// Modern radial/radar chart
class RadialChartWidget extends StatefulWidget {
  final List<ChartDataSet> dataSets;
  final ChartTheme theme;
  final double lineWidth;
  final bool showPoints;
  final bool showGrid;
  final bool showLabel;
  final String? title;
  final String? subtitle;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  const RadialChartWidget({
    super.key,
    required this.dataSets,
    required this.theme,
    this.lineWidth = 3.0,
    this.showPoints = true,
    this.showGrid = true,
    this.showLabel = true,
    this.title,
    this.subtitle,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  });

  @override
  State<RadialChartWidget> createState() => _RadialChartWidgetState();
}

class _RadialChartWidgetState extends State<RadialChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
              return SizedBox(
                width: constraints.maxWidth,
                height: 300,
                child: CustomPaint(
                  size: Size(constraints.maxWidth, 300),
                  painter: RadialChartPainter(
                    theme: widget.theme,
                    dataSets: widget.dataSets,
                    lineWidth: widget.lineWidth,
                    showPoints: widget.showPoints,
                    showGrid: widget.showGrid,
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
