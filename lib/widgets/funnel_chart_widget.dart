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
class FunnelChartWidget extends StatefulWidget {
  final List<PieData> data;
  final ChartTheme? theme;
  final String? title;
  final String? subtitle;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final PieSegmentCallback? onSegmentTap;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  FunnelChartWidget({
    super.key,
    required this.data,
    this.theme,
    this.title,
    this.subtitle,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.onSegmentTap,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
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
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: widget.onSegmentTap != null
                      ? (details) {
                          ChartContextMenuHelper.hide();

                          final result =
                              ChartInteractionHelper.findFunnelSegment(
                            details.localPosition,
                            widget.data,
                            Size(constraints.maxWidth, 300),
                            _animation.value,
                          );

                          if (result != null && result.isHit) {
                            HapticFeedback.selectionClick();

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
                          }
                        }
                      : null,
                  child: SizedBox(
                    width: constraints.maxWidth,
                    height: 300,
                    child: CustomPaint(
                      size: Size(constraints.maxWidth, 300),
                      painter: FunnelChartPainter(
                        theme: effectiveTheme,
                        data: widget.data,
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
  }
}
