import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/painters/pie_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';

/// Modern donut chart with gradient sections
class DonutChartWidget extends StatefulWidget {
  const DonutChartWidget({
    super.key,
    required this.data,
    this.theme,
    this.borderWidth = 2.0,
    this.centerSpaceRadius = 60.0,
    this.showLegend = true,
    this.showLabel = true,
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
  });

  final List<PieData> data;
  final ChartTheme? theme;
  final double borderWidth;
  final double centerSpaceRadius;
  final bool showLegend;
  final bool showLabel;
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
        widget.theme ?? ChartTheme.fromMaterialTheme(Theme.of(context));

    // Handle empty data case
    if (widget.data.isEmpty) {
      Widget container = ChartContainer(
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
        padding: widget.padding,
        boxShadow: widget.boxShadow,
        child: Center(
          child: Text(
            'No data available',
            style: TextStyle(
              color: effectiveTheme.textColor.withValues(alpha: 0.5),
              fontSize: 14,
            ),
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

    final total = widget.data.map((d) => d.value).reduce((a, b) => a + b);

    // Handle all-zero data: painter would draw nothing and legend would show NaN%
    if (total == 0 || !total.isFinite) {
      Widget container = ChartContainer(
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
        padding: widget.padding,
        boxShadow: widget.boxShadow,
        child: Center(
          child: Text(
            'No values to display',
            style: TextStyle(
              color: effectiveTheme.textColor.withValues(alpha: 0.5),
              fontSize: 14,
            ),
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

    final Widget content = Row(
      children: [
        Expanded(
          flex: 2,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final chartSize = widget.height != null
                        ? math
                            .min(constraints.maxWidth, widget.height!)
                            .toDouble()
                        : math.min(constraints.maxWidth, 280.0).toDouble();
                    // Use square size for consistent radius calculation
                    final size = Size(chartSize, chartSize);
                    return Stack(
                      alignment: Alignment.center,
                      children: [
                        GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTapDown: widget.onSegmentTap != null
                              ? (details) {
                                  // Hide any existing context menu first to prevent blocking
                                  ChartContextMenuHelper.hide();

                                  // Use localPosition directly (relative to SizedBox)
                                  final result =
                                      ChartInteractionHelper.findPieSegment(
                                    details.localPosition,
                                    widget.data,
                                    size,
                                    widget.centerSpaceRadius,
                                  );

                                  if (result != null && result.isHit) {
                                    // Provide haptic feedback
                                    HapticFeedback.selectionClick();

                                    // Set new selection (optimized single setState)
                                    setState(() {
                                      _selectedSegment = result;
                                    });

                                    // Get global position for context menu
                                    // Use the GestureDetector's context to find the RenderBox
                                    final RenderBox? renderBox = context
                                        .findRenderObject() as RenderBox?;
                                    final globalPosition = renderBox != null
                                        ? renderBox.localToGlobal(
                                            details.localPosition,
                                          )
                                        : details.globalPosition;

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
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              'Total',
                              style: TextStyle(
                                color: effectiveTheme.textColor
                                    .withValues(alpha: 0.5),
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
          ),
        ),
        if (widget.showLegend && effectiveTheme.showLegend)
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: widget.data.map((item) {
                return ListTile(
                  dense: true,
                  leading: Container(
                    width: 18,
                    height: 18,
                    decoration: BoxDecoration(
                      color: item.color,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.black.withValues(alpha: 0.2),
                        width: 2.0,
                      ),
                    ),
                  ),
                  title: Text(
                    item.label,
                    style: TextStyle(
                      color: effectiveTheme.textColor,
                      fontSize: 12,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  subtitle: Text(
                    '${((item.value / total) * 100).toStringAsFixed(1)}%',
                    style: TextStyle(
                      color: effectiveTheme.textColor.withValues(alpha: 0.7),
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );

    Widget container = ChartContainer(
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
      padding: widget.padding,
      boxShadow: widget.boxShadow,
      child: content,
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
