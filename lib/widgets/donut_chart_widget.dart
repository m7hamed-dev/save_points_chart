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
import 'package:save_points_chart/utils/format_utils.dart';

/// Modern donut chart with gradient sections and interactive features.
class DonutChartWidget extends StatefulWidget {
  const DonutChartWidget({
    super.key,
    required this.data,
    this.borderWidth = 2.0,
    this.centerSpaceRadius = 70.0,
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
  
  // State
  ChartInteractionResult? _selectedSegment;
  double _totalValue = 0;

  @override
  void initState() {
    super.initState();
    _calculateTotal();
    _controller = AnimationController(
      duration: widget.config?.animationDuration ?? const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutQuart,
    );
    _controller.forward();
  }

  @override
  void didUpdateWidget(DonutChartWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.data != oldWidget.data) {
      _calculateTotal();
      if (!_controller.isAnimating) {
        _controller.reset();
        _controller.forward();
      }
    }
  }

  void _calculateTotal() {
    if (widget.data.isEmpty) {
      _totalValue = 0;
      return;
    }
    _totalValue = widget.data.fold(0.0, (sum, item) => sum + item.value);
  }

  void _handleTap(TapDownDetails details, Size size, BuildContext context) {
    ChartContextMenuHelper.hide();
    final result = ChartInteractionHelper.findPieSegment(
      details.localPosition,
      widget.data,
      size,
      widget.centerSpaceRadius,
    );

    if (result != null && result.isHit) {
      HapticFeedback.selectionClick();
      setState(() => _selectedSegment = result);
      
      final RenderBox? renderBox = context.findRenderObject() as RenderBox?;
      final globalPosition = renderBox != null
          ? renderBox.localToGlobal(details.localPosition)
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

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = widget.config?.theme ?? 
        ChartTheme.fromMaterialTheme(Theme.of(context));

    // 1. Handle Empty/Loading/Error States
    if (widget.data.isEmpty || _totalValue == 0) {
      return _buildEmptyState(effectiveTheme);
    }

    // 2. Build Content
    final Widget content = LayoutBuilder(
      builder: (context, constraints) {
        final isVertical = widget.legendLayout == Axis.vertical;
        
        // Determine chart size based on constraints
        final availableWidth = constraints.maxWidth;
        // If vertical, chart can take full width. If horizontal, it shares space.
        // We also cap the size to ensure it doesn't get too massive.
        final chartSize = widget.height ?? 
            (isVertical 
                ? math.min(availableWidth, 300.0) 
                : math.min(availableWidth * 0.6, 300.0));

        final chartSection = _buildChartSection(
          chartSize, 
          effectiveTheme,
        );
        
        final legendSection = widget.showLegend && effectiveTheme.showLegend
            ? _buildLegend(effectiveTheme)
            : const SizedBox.shrink();

        if (isVertical) {
          return Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              chartSection,
              const SizedBox(height: 24),
              legendSection,
            ],
          );
        } else {
          return Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Chart takes up space but stays centered
              Flexible(
                flex: 3, 
                child: Center(child: chartSection),
              ),
              const SizedBox(width: 16),
              // Legend takes remaining space
              Flexible(
                flex: 2, 
                child: legendSection,
              ),
            ],
          );
        }
      },
    );

    // 3. Wrap in Container
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

  Widget _buildEmptyState(ChartTheme theme) {
    final message = widget.data.isEmpty 
        ? (widget.config?.emptyMessage ?? 'No data available')
        : (widget.config?.emptyMessage ?? 'No values to display');
        
    Widget container = ChartContainer(
      theme: theme,
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
      child: widget.config?.emptyWidget ?? ChartEmptyState(
        theme: theme,
        message: message,
      ),
    );

    if (widget.margin != null) {
      container = Padding(padding: widget.margin!, child: container);
    }
    return container;
  }

  Widget _buildChartSection(double size, ChartTheme theme) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Interactive Chart Layer
          RepaintBoundary(
            child: AnimatedBuilder(
              animation: _animation,
              builder: (context, child) {
                return GestureDetector(
                  behavior: HitTestBehavior.translucent,
                  onTapDown: widget.onSegmentTap != null 
                      ? (details) => _handleTap(details, Size(size, size), context)
                      : null,
                  child: CustomPaint(
                    size: Size(size, size),
                    painter: PieChartPainter(
                      data: widget.data,
                      theme: theme,
                      centerSpaceRadius: widget.centerSpaceRadius,
                      borderWidth: widget.borderWidth,
                      showLabel: widget.showLabel,
                      animationProgress: _animation.value,
                      selectedSegment: _selectedSegment,
                    ),
                  ),
                );
              },
            ),
          ),
          // Center Info Layer
          _buildCenterInfo(theme),
        ],
      ),
    );
  }

  Widget _buildCenterInfo(ChartTheme theme) {
    // If a segment is selected, show its info, otherwise show Total
    final isSegmentSelected = _selectedSegment != null && _selectedSegment!.isHit;
    final label = isSegmentSelected 
        ? _selectedSegment!.segment!.label 
        : 'Total';
    final value = isSegmentSelected 
        ? _selectedSegment!.segment!.value 
        : _totalValue;

    return IgnorePointer(
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        child: Column(
          key: ValueKey(label), // Triggers animation when label changes
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              label,
              style: TextStyle(
                color: theme.textColor.withValues(alpha: 0.6),
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 4),
            Text(
              ChartFormatUtils.formatValue(value),
              style: TextStyle(
                color: theme.textColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLegend(ChartTheme theme) {
    return Wrap(
      spacing: 16,
      runSpacing: 8,
      children: widget.data.map((item) {
        final percentage = ((item.value / _totalValue) * 100).toStringAsFixed(1);
        final isSelected = _selectedSegment?.segment == item;
        
        return AnimatedOpacity(
          duration: const Duration(milliseconds: 200),
          opacity: _selectedSegment == null || isSelected ? 1.0 : 0.3,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: item.color,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: theme.textColor.withValues(alpha: 0.1),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              Flexible(
                child: Text(
                  item.label,
                  style: TextStyle(
                    color: theme.textColor,
                    fontSize: 12,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                  ),
                ),
              ),
              const SizedBox(width: 4),
              Text(
                '$percentage%',
                style: TextStyle(
                  color: theme.textColor.withValues(alpha: 0.6),
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}
