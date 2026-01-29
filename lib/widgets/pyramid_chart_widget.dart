import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/theme/charts_config.dart';
import 'package:save_points_chart/painters/pyramid_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';
import 'package:save_points_chart/widgets/chart_empty_state.dart';

/// A pyramid chart widget displaying hierarchical data in a pyramid shape.
///
/// Each segment represents a category, with the largest at the bottom
/// and smallest at the top, creating a pyramid visualization. Useful for
/// displaying hierarchical data such as population distribution or sales funnels.
///
/// ## Features
/// - Hierarchical data visualization
/// - Interactive segment tapping with visual border highlighting
/// - Gradient fills
/// - Smooth animations
/// - Full theme support
///
/// ## Example
/// ```dart
/// PyramidChartWidget(
///   data: [
///     PieData(label: 'Level 1', value: 100, color: Colors.blue),
///     PieData(label: 'Level 2', value: 75, color: Colors.green),
///     PieData(label: 'Level 3', value: 50, color: Colors.orange),
///     PieData(label: 'Level 4', value: 25, color: Colors.red),
///   ],
///   theme: ChartTheme.light(),
///   title: 'Sales Funnel',
///   onSegmentTap: (segment, segmentIndex, position) {
///     // Handle segment tap
///   },
/// )
/// ```
class PyramidChartWidget extends StatefulWidget {
  final List<PieData> data;
  final ChartTheme? theme;
  final String? title;
  final String? subtitle;
  final Widget? header;
  final Widget? footer;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final PieSegmentCallback? onSegmentTap;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final List<BoxShadow>? boxShadow;
  final ChartsConfig? config;

  PyramidChartWidget({
    super.key,
    required this.data,
    this.theme,
    this.title,
    this.subtitle,
    this.header,
    this.footer,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.onSegmentTap,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.height,
    this.padding,
    this.margin,
    this.boxShadow,
    this.config,
  });

  @override
  State<PyramidChartWidget> createState() => _PyramidChartWidgetState();
}

class _PyramidChartWidgetState extends State<PyramidChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ChartInteractionResult? _selectedSegment;

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
    final effectiveTheme = widget.config?.theme ??
        widget.theme ??
        ChartTheme.fromMaterialTheme(Theme.of(context));
    final effectiveEmptyWidget = widget.config?.emptyWidget ??
        ChartEmptyState(
          theme: effectiveTheme,
          message: widget.config?.emptyMessage ?? 'No data available',
        );
    final effectiveEmptyNoValuesWidget = widget.config?.emptyWidget ??
        ChartEmptyState(
          theme: effectiveTheme,
          message: widget.config?.emptyMessage ?? 'No values to display',
        );
    if (widget.data.isEmpty) {
      Widget container = ChartContainer(
        theme: effectiveTheme,
        title: widget.title,
        subtitle: widget.subtitle,
        header: widget.header,
        footer: widget.footer,
        useGlassmorphism: widget.config?.useGlassmorphism ?? widget.useGlassmorphism,
        useNeumorphism: widget.config?.useNeumorphism ?? widget.useNeumorphism,
        isLoading: widget.isLoading,
        isError: widget.isError,
        errorMessage: widget.config?.errorMessage ?? widget.errorMessage,
        errorWidget: widget.config?.errorWidget,
        padding: widget.padding,
        boxShadow: widget.config?.boxShadow ?? widget.boxShadow,
        child: effectiveEmptyWidget,
      );
      if (widget.margin != null) {
        container = Padding(padding: widget.margin!, child: container);
      }
      return container;
    }
    final total = widget.data.map((d) => d.value).reduce((a, b) => a + b);
    if (total == 0 || !total.isFinite) {
      Widget container = ChartContainer(
        theme: effectiveTheme,
        title: widget.title,
        subtitle: widget.subtitle,
        header: widget.header,
        footer: widget.footer,
        useGlassmorphism: widget.config?.useGlassmorphism ?? widget.useGlassmorphism,
        useNeumorphism: widget.config?.useNeumorphism ?? widget.useNeumorphism,
        isLoading: widget.isLoading,
        isError: widget.isError,
        errorMessage: widget.config?.errorMessage ?? widget.errorMessage,
        errorWidget: widget.config?.errorWidget,
        padding: widget.padding,
        boxShadow: widget.config?.boxShadow ?? widget.boxShadow,
        child: effectiveEmptyNoValuesWidget,
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
      useGlassmorphism: widget.config?.useGlassmorphism ?? widget.useGlassmorphism,
      useNeumorphism: widget.config?.useNeumorphism ?? widget.useNeumorphism,
      isLoading: widget.isLoading,
      isError: widget.isError,
      errorMessage: widget.config?.errorMessage ?? widget.errorMessage,
      errorWidget: widget.config?.errorWidget,
      padding: widget.padding,
      boxShadow: widget.config?.boxShadow ?? widget.boxShadow,
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: widget.onSegmentTap != null
                      ? (details) {
                          ChartContextMenuHelper.hide();

                          final result =
                              ChartInteractionHelper.findPyramidSegment(
                            details.localPosition,
                            widget.data,
                            Size(constraints.maxWidth, widget.height ?? 300.0),
                            _animation.value,
                          );

                          if (result != null && result.isHit) {
                            HapticFeedback.selectionClick();

                            setState(() {
                              _selectedSegment = result;
                            });

                            final RenderBox? renderBox =
                                context.findRenderObject() as RenderBox?;
                            final globalPosition = renderBox != null
                                ? renderBox.localToGlobal(details.localPosition)
                                : details.localPosition;

                            Future.microtask(() {
                              widget.onSegmentTap?.call(
                                result.segment!,
                                result.elementIndex!,
                                globalPosition,
                              );
                            });
                          } else {
                            setState(() {
                              _selectedSegment = null;
                            });
                          }
                        }
                      : null,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: widget.height ?? 300.0,
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, widget.height ?? 300.0),
                      painter: PyramidChartPainter(
                        theme: effectiveTheme,
                        data: widget.data,
                        animationProgress: _animation.value,
                        selectedSegment: _selectedSegment,
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

    if (widget.margin != null) {
      container = Padding(
        padding: widget.margin!,
        child: container,
      );
    }

    return container;
  }
}
