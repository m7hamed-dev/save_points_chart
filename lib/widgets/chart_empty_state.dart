import 'package:flutter/material.dart';
import 'package:save_points_chart/theme/chart_theme.dart';

/// Shared empty-state content for all chart widgets.
///
/// Displays a centered message with theme-consistent styling when a chart
/// has no data or all values are zero. Use inside a ChartContainer for
/// consistent layout and styling across chart types.
///
/// ## Example
/// ```dart
/// ChartContainer(
///   theme: effectiveTheme,
///   title: widget.title,
///   child: ChartEmptyState(
///     theme: effectiveTheme,
///     message: 'No data available',
///   ),
/// )
/// ```
class ChartEmptyState extends StatelessWidget {
  /// Theme used for text color. Required so the message matches chart theme.
  final ChartTheme theme;

  /// Message to display. Defaults to 'No data available'.
  final String message;

  const ChartEmptyState({super.key, required this.theme, this.message = 'No data available'});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Text(message, style: TextStyle(color: theme.textColor.withValues(alpha: 0.5), fontSize: 14)),
    );
  }
}
