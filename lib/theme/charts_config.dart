import 'package:flutter/material.dart';
import 'package:save_points_chart/theme/chart_theme.dart';

/// Optional configuration shared by all chart widgets.
///
/// Use [ChartsConfig] to set theme, visual effects, empty/error UI, and shadows
/// in one place. When passed to a chart, config values override the chart's
/// individual parameters when provided.
///
/// All parameters are optional. Omitted values fall back to the chart's own
/// parameters or defaults.
///
/// ## Example
/// ```dart
/// final config = ChartsConfig(
///   theme: ChartTheme.light(),
///   useGlassmorphism: true,
///   emptyMessage: 'No data yet',
///   errorMessage: 'Something went wrong',
/// );
///
/// LineChartWidget(
///   dataSets: dataSets,
///   config: config,
/// )
/// ```
///
/// See also:
/// - [ChartTheme] for theme configuration
/// - ChartContainer for container styling
class ChartsConfig {
  const ChartsConfig({
    this.useGlassmorphism,
    this.useNeumorphism,
    this.emptyWidget,
    this.emptyMessage,
    this.errorWidget,
    this.errorMessage,
    this.boxShadow,
    this.theme,
  });

  /// Whether to apply glassmorphism (frosted glass) to the chart container.
  final bool? useGlassmorphism;

  /// Whether to apply neumorphism (soft shadow) to the chart container.
  final bool? useNeumorphism;

  /// Custom widget shown when the chart has no data or all values are zero.
  /// If null, charts use ChartEmptyState with [emptyMessage].
  final Widget? emptyWidget;

  /// Message shown in the default empty state when [emptyWidget] is null.
  final String? emptyMessage;

  /// Custom widget shown when the chart is in error state.
  /// If null, charts use the default error UI with [errorMessage].
  final Widget? errorWidget;

  /// Message shown in the default error state when [errorWidget] is null.
  final String? errorMessage;

  /// Custom box shadows for the chart container.
  final List<BoxShadow>? boxShadow;

  /// Theme for colors, typography, and chart styling.
  final ChartTheme? theme;

  /// Creates a copy of this config with the given fields replaced.
  ChartsConfig copyWith({
    bool? useGlassmorphism,
    bool? useNeumorphism,
    Widget? emptyWidget,
    String? emptyMessage,
    Widget? errorWidget,
    String? errorMessage,
    List<BoxShadow>? boxShadow,
    ChartTheme? theme,
  }) {
    return ChartsConfig(
      useGlassmorphism: useGlassmorphism ?? this.useGlassmorphism,
      useNeumorphism: useNeumorphism ?? this.useNeumorphism,
      emptyWidget: emptyWidget ?? this.emptyWidget,
      emptyMessage: emptyMessage ?? this.emptyMessage,
      errorWidget: errorWidget ?? this.errorWidget,
      errorMessage: errorMessage ?? this.errorMessage,
      boxShadow: boxShadow ?? this.boxShadow,
      theme: theme ?? this.theme,
    );
  }
}
