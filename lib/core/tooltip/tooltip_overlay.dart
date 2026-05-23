import 'package:flutter/material.dart';
import 'package:save_points_chart/core/theme/chart_theme.dart';
import 'package:save_points_chart/core/tooltip/tooltip_controller.dart';
import 'package:save_points_chart/core/tooltip/tooltip_data.dart';

/// Overlay-based tooltip widget — never drawn on canvas.
class TooltipOverlay extends StatelessWidget {
  const TooltipOverlay({
    super.key,
    required this.controller,
    required this.theme,
    required this.chartSize,
  });

  final TooltipController controller;
  final ChartTheme theme;
  final Size chartSize;

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: controller,
      builder: (context, _) {
        if (!controller.visible || controller.data == null) {
          return const SizedBox.shrink();
        }
        return _TooltipBubble(
          data: controller.data!,
          theme: theme,
          chartSize: chartSize,
        );
      },
    );
  }
}

class _TooltipBubble extends StatelessWidget {
  const _TooltipBubble({
    required this.data,
    required this.theme,
    required this.chartSize,
  });

  final TooltipData data;
  final ChartTheme theme;
  final Size chartSize;

  @override
  Widget build(BuildContext context) {
    const padding = 8.0;
    const maxWidth = 200.0;

    var left = data.position.dx + 12;
    var top = data.position.dy - 40;

    if (left + maxWidth > chartSize.width) {
      left = data.position.dx - maxWidth - 12;
    }
    if (top < 0) top = data.position.dy + 12;
    if (top + 80 > chartSize.height) top = chartSize.height - 80;

    return Positioned(
      left: left.clamp(0, chartSize.width - maxWidth),
      top: top.clamp(0, chartSize.height - 80),
      child: Material(
        color: Colors.transparent,
        child: Container(
          constraints: const BoxConstraints(maxWidth: maxWidth),
          padding: const EdgeInsets.all(padding),
          decoration: BoxDecoration(
            color: theme.tooltipBackground,
            borderRadius: BorderRadius.circular(6),
            boxShadow: theme.shadow,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                data.title,
                style: theme.tooltipTextStyle.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              if (data.subtitle != null)
                Text(data.subtitle!, style: theme.tooltipTextStyle),
              ...data.entries.map(
                (e) => Padding(
                  padding: const EdgeInsets.only(top: 2),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (e.color != null)
                        Container(
                          width: 8,
                          height: 8,
                          margin: const EdgeInsets.only(right: 4),
                          decoration: BoxDecoration(
                            color: e.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      Text(
                        '${e.label}: ${e.value}',
                        style: theme.tooltipTextStyle,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
