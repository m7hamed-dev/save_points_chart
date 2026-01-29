import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/theme/charts_config.dart';
import 'package:save_points_chart/painters/pie_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';
import 'package:save_points_chart/widgets/chart_empty_state.dart';

/// Modern pie chart with gradient sections and animations
class PieChartWidget extends StatefulWidget {
  const PieChartWidget({
    super.key,
    required this.data,
    this.borderWidth = 2.0,
    this.showLegend = true,
    this.showLabel = true,
    this.legendLayout = Axis.horizontal,
    this.title,
    this.subtitle,
    this.header,
    this.footer,
    this.onSegmentTap,
    this.isLoading = false,
    this.isError = false,
    this.height,
    this.padding,
    this.margin,
    this.config,
  });

  final List<PieData> data;
  final double borderWidth;
  final bool showLegend;
  final bool showLabel;

  /// Layout of chart and legend: [Axis.horizontal] = Row (chart left, legend right),
  /// [Axis.vertical] = Column (chart top, legend below).
  final Axis legendLayout;
  final String? title;
  final String? subtitle;
  final Widget? header;
  final Widget? footer;
  final PieSegmentCallback? onSegmentTap;
  final bool isLoading;
  final bool isError;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final ChartsConfig? config;

  @override
  State<PieChartWidget> createState() => _PieChartWidgetState();
}

class _PieChartWidgetState extends State<PieChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ChartInteractionResult? _selectedSegment;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme =
        widget.config?.theme ?? ChartTheme.fromMaterialTheme(Theme.of(context));
    final effectiveEmptyWidget =
        widget.config?.emptyWidget ??
        ChartEmptyState(
          theme: effectiveTheme,
          message: widget.config?.emptyMessage ?? 'No data available',
        );
    final effectiveEmptyNoValuesWidget =
        widget.config?.emptyWidget ??
        ChartEmptyState(
          theme: effectiveTheme,
          message: widget.config?.emptyMessage ?? 'No values to display',
        );

    // Handle empty data case
    if (widget.data.isEmpty) {
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

    final total = widget.data.map((d) => d.value).reduce((a, b) => a + b);

    // Handle all-zero data: painter would draw nothing and legend would show NaN%
    if (total == 0 || !total.isFinite) {
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
        child: effectiveEmptyNoValuesWidget,
      );
      if (widget.margin != null) {
        container = Padding(padding: widget.margin!, child: container);
      }
      return container;
    }

    final Widget content = widget.legendLayout == Axis.vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _pieChart(effectiveTheme),
              if (widget.showLegend && effectiveTheme.showLegend) ...[
                const SizedBox(height: 16),
                Center(child: _data(effectiveTheme, total)),
              ],
            ],
          )
        : Row(
            children: [
              Expanded(flex: 2, child: _pieChart(effectiveTheme)),
              if (widget.showLegend && effectiveTheme.showLegend)
                Expanded(child: _data(effectiveTheme, total)),
            ],
          );

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
      child: content,
    );

    if (widget.margin != null) {
      container = Padding(padding: widget.margin!, child: container);
    }

    return container;
  }

  Column _data(ChartTheme effectiveTheme, double total) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: .start,
      children: widget.data.map((item) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: effectiveTheme.textColor,
                    fontSize: 12,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              Text(
                '${((item.value / total) * 100).toStringAsFixed(1)}%',
                style: TextStyle(
                  color: effectiveTheme.textColor.withValues(alpha: 0.7),
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }

  RepaintBoundary _pieChart(ChartTheme effectiveTheme) {
    return RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final size = math.min(constraints.maxWidth, 250.0).toDouble();
              return GestureDetector(
                behavior: HitTestBehavior
                    .translucent, // Allow taps even when overlay is present
                onTapDown: widget.onSegmentTap != null
                    ? (details) {
                        // Hide any existing context menu first to prevent blocking
                        ChartContextMenuHelper.hide();

                        // Use localPosition directly (relative to SizedBox)
                        final result = ChartInteractionHelper.findPieSegment(
                          details.localPosition,
                          widget.data,
                          Size(size, widget.height ?? 250.0),
                          0.0,
                        );

                        if (result != null && result.isHit) {
                          // Provide haptic feedback
                          HapticFeedback.selectionClick();

                          // Set new selection (optimized single setState)
                          setState(() {
                            _selectedSegment = result;
                          });

                          // Get global position for context menu
                          final RenderBox? renderBox =
                              context.findRenderObject() as RenderBox?;
                          final globalPosition = renderBox != null
                              ? renderBox.localToGlobal(details.localPosition)
                              : details.localPosition;

                          // Small delay to ensure overlay is removed before showing new menu
                          Future.microtask(() {
                            widget.onSegmentTap?.call(
                              result.segment!,
                              result.elementIndex!,
                              globalPosition,
                            );
                          });
                        } else {
                          // Clear selection if tap is outside any segment
                          setState(() {
                            _selectedSegment = null;
                          });
                        }
                      }
                    : null,
                child: SizedBox(
                  width: size,
                  height: widget.height ?? 250.0,
                  child: CustomPaint(
                    size: Size(size, widget.height ?? 250.0),
                    painter: PieChartPainter(
                      data: widget.data,
                      theme: effectiveTheme,
                      borderWidth: widget.borderWidth,
                      showLabel: widget.showLabel,
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
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
