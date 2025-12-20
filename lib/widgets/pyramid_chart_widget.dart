import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/painters/pyramid_chart_painter.dart';
import 'package:save_points_chart/widgets/chart_container.dart';

/// A pyramid chart widget displaying hierarchical data in a pyramid shape.
///
/// Each segment represents a category, with the largest at the bottom
/// and smallest at the top, creating a pyramid visualization.
class PyramidChartWidget extends StatefulWidget {
  final List<PieData> data;
  final ChartTheme? theme;
  final String? title;
  final String? subtitle;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  PyramidChartWidget({
    super.key,
    required this.data,
    this.theme,
    this.title,
    this.subtitle,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  }) : assert(
          data.isNotEmpty,
          'PyramidChartWidget requires at least one data segment',
        );

  @override
  State<PyramidChartWidget> createState() => _PyramidChartWidgetState();
}

class _PyramidChartWidgetState extends State<PyramidChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

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
                    painter: PyramidChartPainter(
                      theme: effectiveTheme,
                      data: widget.data,
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

