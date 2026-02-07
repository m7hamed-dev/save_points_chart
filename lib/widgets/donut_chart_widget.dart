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
import 'package:save_points_chart/widgets/show_empty_or_widget.dart';

/// Modern donut chart with gradient sections
class DonutChartWidget extends StatefulWidget {
  const DonutChartWidget({
    super.key,
    required this.data,
    this.borderWidth = 2.0,
    this.centerSpaceRadius = 60.0,
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
  final double centerSpaceRadius;
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
  State<DonutChartWidget> createState() => _DonutChartWidgetState();
}

class _DonutChartWidgetState extends State<DonutChartWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ChartInteractionResult? _selectedSegment;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 1000),
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

    final Widget chart = RepaintBoundary(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return LayoutBuilder(
            builder: (context, constraints) {
              final chartSize = widget.height != null
                  ? math.min(constraints.maxWidth, widget.height!).toDouble()
                  : math.min(constraints.maxWidth, 280.0).toDouble();
              final size = Size(chartSize, chartSize);
              return Stack(
                alignment: Alignment.center,
                children: [
                  GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTapDown: widget.onSegmentTap != null
                        ? (details) {
                            ChartContextMenuHelper.hide();
                            final result =
                                ChartInteractionHelper.findPieSegment(
                                  details.localPosition,
                                  widget.data,
                                  size,
                                  widget.centerSpaceRadius,
                                );
                            if (result != null && result.isHit) {
                              HapticFeedback.selectionClick();
                              setState(() => _selectedSegment = result);
                              final RenderBox? renderBox =
                                  context.findRenderObject() as RenderBox?;
                              final globalPosition = renderBox != null
                                  ? renderBox.localToGlobal(
                                      details.localPosition,
                                    )
                                  : details.globalPosition;
                              Future.microtask(() {
                                widget.onSegmentTap?.call(
                                  result.segment!,
                                  result.elementIndex!,
                                  globalPosition,
                                );
                              });
                            } else {
                              setState(() => _selectedSegment = null);
                            }
                          }
                        : null,
                    child: SizedBox(
                      width: size.width,
                      height: size.height,
                      child: CustomPaint(
                        size: size,
                        painter: PieChartPainter(
                          data: widget.data,
                          theme: effectiveTheme,
                          centerSpaceRadius: widget.centerSpaceRadius,
                          borderWidth: widget.borderWidth,
                          showLabel: widget.showLabel,
                          animationProgress: _animation.value,
                          selectedSegment: _selectedSegment,
                        ),
                      ),
                    ),
                  ),
                  Column(
                    mainAxisSize: .min,
                    children: [
                      Text(
                        'Total',
                        style: TextStyle(
                          color: effectiveTheme.textColor.withValues(
                            alpha: 0.5,
                          ),
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        total.toStringAsFixed(0),
                        style: TextStyle(
                          color: effectiveTheme.textColor,
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              );
            },
          );
        },
      ),
    );

    final Widget legend = Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: .start,
      children: widget.data.map((item) {
        /// item data: label, color, value, percentage
        final label = item.label;
        final color = item.color;
        final value = item.value;
        final percentage = ((value / total) * 100).toStringAsFixed(1);

        return ListTile(
          dense: true,
          leading: Container(
            width: item.circleSize,
            height: item.circleSize,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.black.withValues(alpha: 0.2),
                width: 2.0,
              ),
            ),
          ),
          title: ShowEmptyOrWidget(
            showWidget: item.showLabel ?? true,
            widget: Text(
              label,
              style: TextStyle(color: effectiveTheme.textColor, fontSize: 12),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          subtitle: ShowEmptyOrWidget(
            showWidget: item.showValue,
            widget: Text(
              '$percentage%',
              style: TextStyle(
                color: effectiveTheme.textColor.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        );
      }).toList(),
    );

    final Widget content = widget.legendLayout == Axis.vertical
        ? Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              chart,
              if (widget.showLegend && effectiveTheme.showLegend) ...[
                const SizedBox(height: 16),
                Center(child: legend),
              ],
            ],
          )
        : Row(
            children: [
              Expanded(flex: 2, child: chart),
              if (widget.showLegend && effectiveTheme.showLegend)
                Expanded(child: legend),
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
}
