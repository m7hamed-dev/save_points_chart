import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../models/chart_data.dart';
import '../models/chart_interaction.dart';
import '../theme/chart_theme.dart';
import '../painters/pie_chart_painter.dart';
import '../utils/chart_interaction_helper.dart';
import 'chart_container.dart';

/// Modern pie chart with gradient sections and animations
class PieChartWidget extends StatefulWidget {
  final List<PieData> data;
  final ChartTheme theme;
  final double borderWidth;
  final bool showLegend;
  final bool showLabel;
  final String? title;
  final String? subtitle;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final PieSegmentCallback? onSegmentTap;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  const PieChartWidget({
    super.key,
    required this.data,
    required this.theme,
    this.borderWidth = 2.0,
    this.showLegend = true,
    this.showLabel = true,
    this.title,
    this.subtitle,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.onSegmentTap,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  });

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
    final total = widget.data.map((d) => d.value).reduce((a, b) => a + b);

    Widget content = Row(
      children: [
        Expanded(
          flex: 2,
          child: RepaintBoundary(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return LayoutBuilder(
                  builder: (context, constraints) {
                    final size = math.min(constraints.maxWidth, 250.0).toDouble();
                    return GestureDetector(
                      behavior: HitTestBehavior.opaque,
                      onTapDown: widget.onSegmentTap != null
                          ? (details) {
                              // Use localPosition directly (relative to SizedBox)
                              final result = ChartInteractionHelper.findPieSegment(
                                details.localPosition,
                                widget.data,
                                Size(size, 250),
                                0.0,
                              );
                              
                              if (result != null && result.isHit) {
                                setState(() {
                                  _selectedSegment = result;
                                });
                                // Get global position for context menu
                                final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
                                final globalPosition = renderBox != null
                                    ? renderBox.localToGlobal(details.localPosition)
                                    : details.localPosition;
                                widget.onSegmentTap?.call(
                                  result.segment!,
                                  result.elementIndex!,
                                  globalPosition,
                                );
                              }
                            }
                          : null,
                      child: SizedBox(
                        width: size,
                        height: 250,
                        child: CustomPaint(
                          size: Size(size, 250),
                          painter: PieChartPainter(
                            data: widget.data,
                            theme: widget.theme,
                            centerSpaceRadius: 0,
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
          ),
        ),
        if (widget.showLegend && widget.theme.showLegend)
          Expanded(
            flex: 1,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
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
                            color: widget.theme.textColor,
                            fontSize: 12,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        '${((item.value / total) * 100).toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: widget.theme.textColor.withOpacity(0.7),
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
      ],
    );

    return ChartContainer(
      theme: widget.theme,
      title: widget.title,
      subtitle: widget.subtitle,
      useGlassmorphism: widget.useGlassmorphism,
      useNeumorphism: widget.useNeumorphism,
      isLoading: widget.isLoading,
      isError: widget.isError,
      errorMessage: widget.errorMessage,
      child: content,
    );
  }
}
