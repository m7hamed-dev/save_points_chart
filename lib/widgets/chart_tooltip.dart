import 'package:flutter/material.dart';
import 'package:save_points_chart/theme/chart_theme.dart';

class ChartTooltip extends StatelessWidget {
  const ChartTooltip({
    super.key,
    required this.theme,
    required this.title,
    required this.value,
    this.subtitle,
    this.color,
  });

  final ChartTheme theme;
  final String title;
  final String value;
  final String? subtitle;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final titleStyle =
        theme.tooltipStyle ??
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: Colors.white, letterSpacing: -0.1);
    final subtitleStyle = titleStyle.copyWith(
      fontSize: 11,
      fontWeight: FontWeight.w500,
      color: titleStyle.color?.withValues(alpha: 0.75),
      letterSpacing: 0,
    );
    final valueStyle = titleStyle.copyWith(fontSize: 14, fontWeight: FontWeight.w700, letterSpacing: -0.2);

    return Container(
      constraints: const BoxConstraints(minWidth: 140, maxWidth: 240),
      padding: const .symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.tooltipBackgroundColor,
        borderRadius: const .all(.circular(12)),
        border: .all(color: theme.tooltipBorderColor),
        boxShadow: theme.tooltipShadow,
      ),
      child: DefaultTextStyle(
        style: titleStyle,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                if (color != null)
                  Container(
                    width: 8,
                    height: 8,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                      boxShadow: [BoxShadow(color: color!.withValues(alpha: 0.35), blurRadius: 10, spreadRadius: 1)],
                    ),
                  ),
                Expanded(child: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis)),
              ],
            ),
            if (subtitle != null) ...[
              const SizedBox(height: 3),
              Text(subtitle!, style: subtitleStyle, maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
            const SizedBox(height: 8),
            Text(value, style: valueStyle),
          ],
        ),
      ),
    );
  }
}
