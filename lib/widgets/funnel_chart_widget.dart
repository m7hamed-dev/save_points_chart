import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/painters/funnel_chart_painter.dart';
import 'package:save_points_chart/utils/chart_interaction_helper.dart';
import 'package:save_points_chart/widgets/chart_container.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';

/// A funnel chart widget displaying data in a funnel shape.
///
/// Similar to pyramid but inverted, with the largest segment at the top
/// and smallest at the bottom, useful for sales funnels and conversion tracking.
/// This visualization helps identify where users drop off in a process.
///
/// ## Features
/// - Sales funnel and conversion tracking
/// - Interactive segment tapping with visual border highlighting
/// - Gradient fills
/// - Smooth animations
/// - Full theme support
///
/// ## Example
/// ```dart
/// FunnelChartWidget(
///   data: [
///     PieData(label: 'Visitors', value: 1000, color: Colors.blue),
///     PieData(label: 'Leads', value: 500, color: Colors.green),
///     PieData(label: 'Qualified', value: 250, color: Colors.orange),
///     PieData(label: 'Customers', value: 100, color: Colors.red),
///   ],
///   theme: ChartTheme.light(),
///   title: 'Sales Funnel',
///   onSegmentTap: (segment, segmentIndex, position) {
///     // Handle segment tap
///   },
/// )
/// ```
class FunnelChartWidget extends StatefulWidget {
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
  final bool shadow;

  FunnelChartWidget({
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
    this.shadow = true,
  }) : assert(
          data.isNotEmpty,
          'FunnelChartWidget requires at least one data segment',
        );

  @override
  State<FunnelChartWidget> createState() => _FunnelChartWidgetState();
}

class _FunnelChartWidgetState extends State<FunnelChartWidget>
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
    if (!widget.shadow) {
      return const SizedBox.shrink();
    }
    
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
                              ChartInteractionHelper.findFunnelSegment(
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
                      painter: FunnelChartPainter(
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
