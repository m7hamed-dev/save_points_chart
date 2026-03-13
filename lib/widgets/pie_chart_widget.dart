import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/painters/pie_chart_painter.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/theme/charts_config.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';
import 'package:save_points_chart/widgets/chart_empty_state.dart';
import 'package:save_points_chart/widgets/show_empty_or_widget.dart';

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
  /// [.vertical] = Column (chart top, legend below).
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

class _PieChartWidgetState extends State<PieChartWidget> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  ChartInteractionResult? _selectedSegment;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(duration: const Duration(milliseconds: 1500), vsync: this);
    _animation = CurvedAnimation(parent: _controller, curve: Curves.easeOutQuart);
    _controller.forward();
  }

  void _handleTap(TapDownDetails details, double size) {
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

      // Compute a stable anchor point near the tapped segment, not the raw tap.
      final renderBox = context.findRenderObject() as RenderBox?;
      final localTap = details.localPosition;
      final chartSize = Size(size, widget.height ?? 250.0);
      final center = Offset(chartSize.width / 2, chartSize.height / 2);

      // Direction from center to tap; fallback to straight up if zero.
      var direction = localTap - center;
      if (direction.distance == 0) {
        direction = const Offset(0, -1);
      }
      final radius = chartSize.shortestSide / 2 - 20;
      final normalized = direction / direction.distance;
      final anchorLocal = center + normalized * (radius * 0.7);

      final globalPosition = renderBox != null ? renderBox.localToGlobal(anchorLocal) : anchorLocal;

      // Small delay to ensure overlay is removed before showing new menu
      Future.microtask(() {
        widget.onSegmentTap?.call(result.segment!, result.elementIndex!, globalPosition);
      });
    } else {
      // Clear selection if tap is outside any segment
      setState(() {
        _selectedSegment = null;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = widget.config?.theme ?? ChartTheme.fromMaterialTheme(Theme.of(context));
    final effectiveEmptyWidget =
        widget.config?.emptyWidget ??
        ChartEmptyState(theme: effectiveTheme, message: widget.config?.emptyMessage ?? 'No data available');
    final effectiveEmptyNoValuesWidget =
        widget.config?.emptyWidget ??
        ChartEmptyState(theme: effectiveTheme, message: widget.config?.emptyMessage ?? 'No values to display');

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

    final Widget content = widget.legendLayout == .vertical
        ? Column(
            mainAxisSize: .min,
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
              Expanded(flex: 3, child: _pieChart(effectiveTheme)),
              if (widget.showLegend && effectiveTheme.showLegend)
                Expanded(flex: 2, child: _data(effectiveTheme, total)),
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
      mainAxisAlignment: .center,
      crossAxisAlignment: .start,
      children: widget.data.map((item) {
        return Padding(
          padding: const .symmetric(vertical: 4.0),
          child: Row(
            children: [
              Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(color: item.color, shape: BoxShape.circle),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: ShowEmptyOrWidget(
                  showWidget: item.showLabel,
                  widget: Text(
                    item.label,
                    style: TextStyle(color: effectiveTheme.textColor, fontSize: 12),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),
              ShowEmptyOrWidget(
                showWidget: item.showValue,
                widget: Text(
                  '${((item.value / total) * 100).toStringAsFixed(1)}%',
                  style: TextStyle(
                    color: effectiveTheme.textColor.withValues(alpha: 0.7),
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                  ),
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
              // Ensure we have a valid width constraint
              // If maxWidth is unbounded or zero, use a default size
              // Minimum size of 100 to prevent negative radius in painter (radius = min(width, height) / 2 - 20)
              final maxWidth = constraints.maxWidth.isFinite && constraints.maxWidth > 0 ? constraints.maxWidth : 250.0;
              final width = math.min(maxWidth, 250.0).clamp(100.0, 250.0);
              final height = (widget.height ?? 250.0).clamp(100.0, double.infinity);
              final chartSize = Size(width, height);
              return GestureDetector(
                behavior: HitTestBehavior.translucent, // Allow taps even when overlay is present
                onTapDown: widget.onSegmentTap != null ? (details) => _handleTap(details, chartSize.width) : null,
                onSecondaryTapDown: widget.onSegmentTap != null
                    ? (details) => _handleTap(details, chartSize.width)
                    : null,
                child: SizedBox(
                  width: chartSize.width,
                  height: chartSize.height,
                  child: CustomPaint(
                    size: chartSize,
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
