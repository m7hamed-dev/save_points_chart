import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/painters/gauge_chart_painter.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';

/// A modern gauge chart widget for displaying a single metric value.
///
/// This widget displays a value on a semi-circular or circular gauge,
/// useful for KPIs, progress indicators, and single-value metrics.
///
/// ## Features
/// - Customizable value range
/// - Smooth animations
/// - Customizable segments
/// - Full theme support
///
/// ## Example
/// ```dart
/// GaugeChartWidget(
///   value: 75,
///   minValue: 0,
///   maxValue: 100,
///   theme: ChartTheme.light(),
///   title: 'Performance',
/// )
/// ```
class GaugeChartWidget extends StatefulWidget {
  /// The current value to display on the gauge.
  final double value;

  /// The minimum value of the gauge.
  final double minValue;

  /// The maximum value of the gauge.
  final double maxValue;

  /// The number of segments/divisions on the gauge.
  final int segments;

  /// The start angle in degrees (0 is right, positive is clockwise).
  final double startAngleDegrees;

  /// The sweep angle in degrees (how much of the circle to use).
  final double sweepAngleDegrees;

  final ChartTheme? theme;
  final bool showGrid;
  final bool showAxis;
  final bool showLabel;
  final String? title;
  final String? subtitle;
  final Widget? header;
  final Widget? footer;
  final String? centerLabel;
  final String? unit;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final VoidCallback? onChartTap;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;
  final double? height;
  final EdgeInsets? padding;
  final EdgeInsets? margin;
  final List<BoxShadow>? boxShadow;

  const GaugeChartWidget({
    super.key,
    required this.value,
    this.minValue = 0.0,
    this.maxValue = 100.0,
    this.segments = 5,
    this.startAngleDegrees = 180.0,
    this.sweepAngleDegrees = 180.0,
    this.theme,
    this.showGrid = true,
    this.showAxis = true,
    this.showLabel = true,
    this.title,
    this.subtitle,
    this.header,
    this.footer,
    this.centerLabel,
    this.unit,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.onChartTap,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
    this.height,
    this.padding,
    this.margin,
    this.boxShadow,
  })  : assert(maxValue > minValue, 'Max value must be greater than min value'),
        assert(segments > 0, 'Segments must be positive');

  @override
  State<GaugeChartWidget> createState() => _GaugeChartWidgetState();
}

class _GaugeChartWidgetState extends State<GaugeChartWidget>
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
      child: RepaintBoundary(
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return LayoutBuilder(
              builder: (context, constraints) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: widget.onChartTap != null
                      ? (details) {
                          ChartContextMenuHelper.hide();
                          HapticFeedback.selectionClick();

                          final RenderBox? renderBox =
                              context.findRenderObject() as RenderBox?;
                          final globalPosition = renderBox != null
                              ? renderBox.localToGlobal(details.localPosition)
                              : details.localPosition;

                          // Create a ChartDataPoint for gauge value
                          final gaugePoint = ChartDataPoint(
                            x: 0,
                            y: widget.value,
                            label: widget.centerLabel ?? 'Value',
                          );

                          // Show context menu with gauge details
                          ChartContextMenuHelper.show(
                            context,
                            point: gaugePoint,
                            segment: null,
                            position: globalPosition,
                            datasetIndex: 0,
                            elementIndex: 0,
                            datasetLabel: widget.title ?? 'Gauge',
                            theme: effectiveTheme,
                            useGlassmorphism: widget.useGlassmorphism,
                            useNeumorphism: widget.useNeumorphism,
                            onViewDetails: () {
                              widget.onChartTap?.call();
                            },
                          );
                        }
                      : null,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: widget.height ?? 300.0,
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, widget.height ?? 300.0),
                      painter: GaugeChartPainter(
                        theme: effectiveTheme,
                        value: widget.value,
                        minValue: widget.minValue,
                        maxValue: widget.maxValue,
                        segments: widget.segments,
                        startAngle: widget.startAngleDegrees * 3.14159 / 180,
                        sweepAngle: widget.sweepAngleDegrees * 3.14159 / 180,
                        showGrid: widget.showGrid,
                        showAxis: widget.showAxis,
                        showLabel: widget.showLabel,
                        centerLabel: widget.centerLabel,
                        unit: widget.unit,
                        animationProgress: _animation.value,
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
