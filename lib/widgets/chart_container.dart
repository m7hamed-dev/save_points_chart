import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:save_points_chart/theme/chart_theme.dart';

/// Modern container wrapper for charts with glassmorphism and neumorphism effects.
///
/// This widget provides a consistent, professional container for all chart types
/// with support for titles, subtitles, loading states, error states, and
/// modern visual effects.
///
/// ## Features
/// - Title and subtitle support
/// - Loading state with spinner and message
/// - Error state with icon and message
/// - Glassmorphism effect (frosted glass appearance)
/// - Neumorphism effect (soft shadow appearance)
/// - Full theme support
/// - Accessibility support with semantic labels
/// - Responsive padding and spacing
///
/// ## Example
/// ```dart
/// ChartContainer(
///   theme: ChartTheme.light(),
///   title: 'Sales Chart',
///   subtitle: 'Monthly revenue',
///   useGlassmorphism: true,
///   isLoading: false,
///   child: MyChartWidget(...),
/// )
/// ```
///
/// See also:
/// - [ChartTheme] for theme configuration
class ChartContainer extends StatelessWidget {
  final Widget child;
  final ChartTheme? theme;
  final EdgeInsets padding;
  final String? title;
  final String? subtitle;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final bool isLoading;
  final bool isError;
  final String? errorMessage;

  /// Creates a chart container.
  ///
  /// [child] is required and should be the chart widget to display.
  /// [theme] is optional and will be inferred from the Material theme if not provided.
  ///
  /// The container supports three visual styles:
  /// - Default: Clean card with subtle shadows
  /// - Glassmorphism: Frosted glass effect with backdrop blur
  /// - Neumorphism: Soft shadow effect with depth
  ///
  /// Only one effect should be enabled at a time. If both [useGlassmorphism]
  /// and [useNeumorphism] are true, neumorphism takes precedence.
  ///
  /// ## Example
  /// ```dart
  /// ChartContainer(
  ///   title: 'Sales',
  ///   subtitle: 'Q1 2024',
  ///   isLoading: isLoading,
  ///   isError: hasError,
  ///   errorMessage: errorMessage,
  ///   child: MyChart(...),
  /// )
  /// ```
  const ChartContainer({
    super.key,
    required this.child,
    this.theme,
    this.padding = const EdgeInsets.all(16.0),
    this.title,
    this.subtitle,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.isLoading = false,
    this.isError = false,
    this.errorMessage,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTheme =
        theme ?? ChartTheme.fromMaterialTheme(Theme.of(context));
    Widget container = Container(
      padding: padding,
      decoration: BoxDecoration(
        color: effectiveTheme.backgroundColor,
        borderRadius: BorderRadius.circular(effectiveTheme.borderRadius),
        border: Border.all(
          color: effectiveTheme.gridColor.withValues(alpha: 0.3),
        ),
        boxShadow: [
          // Soft outer shadow (enhanced)
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: effectiveTheme.shadowElevation * 4,
            offset: Offset(0, effectiveTheme.shadowElevation * 0.6),
            spreadRadius: 1,
          ),
          // Medium shadow for depth
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.06),
            blurRadius: effectiveTheme.shadowElevation * 2,
            offset: Offset(0, effectiveTheme.shadowElevation * 0.3),
            spreadRadius: 0,
          ),
          // Inner highlight (enhanced)
          BoxShadow(
            color: Colors.white.withValues(alpha: 0.15),
            blurRadius: 3,
            offset: const Offset(0, -1),
            spreadRadius: -2,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          if (title != null || subtitle != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (title != null)
                    Text(
                      title!,
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.5,
                        color: effectiveTheme.textColor,
                        height: 1.2,
                      ),
                    ),
                  if (subtitle != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 6.0),
                      child: Text(
                        subtitle!,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w400,
                          letterSpacing: 0.1,
                          color:
                              effectiveTheme.textColor.withValues(alpha: 0.65),
                          height: 1.4,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          if (isLoading)
            Semantics(
              label: 'Chart is loading',
              child: SizedBox(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          effectiveTheme.gradientColors.first,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading chart data...',
                        style: TextStyle(
                          color:
                              effectiveTheme.textColor.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else if (isError)
            Semantics(
              label:
                  'Chart error: ${errorMessage ?? 'Failed to load chart data'}',
              child: SizedBox(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage ?? 'Failed to load chart data',
                        style: TextStyle(
                          color:
                              effectiveTheme.textColor.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            Semantics(
              label: title != null
                  ? 'Chart: $title${subtitle != null ? '. $subtitle' : ''}'
                  : 'Chart visualization',
              child: child,
            ),
        ],
      ),
    );

    if (useGlassmorphism) {
      container = Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(effectiveTheme.borderRadius),
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              effectiveTheme.backgroundColor.withValues(alpha: 0.85),
              effectiveTheme.backgroundColor.withValues(alpha: 0.65),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.25),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 24,
              spreadRadius: -2,
            ),
            BoxShadow(
              color: Colors.white.withValues(alpha: 0.1),
              blurRadius: 8,
              offset: const Offset(-2, -2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(effectiveTheme.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
            child: container,
          ),
        ),
      );
    }

    if (useNeumorphism) {
      final isDark = effectiveTheme.backgroundColor.computeLuminance() < 0.5;
      final shadowColor = isDark
          ? Colors.black.withValues(alpha: 0.6)
          : Colors.grey.shade400;
      final highlightColor = isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.white.withValues(alpha: 0.9);

      container = Container(
        padding: padding,
        decoration: BoxDecoration(
          color: effectiveTheme.backgroundColor,
          borderRadius: BorderRadius.circular(effectiveTheme.borderRadius),
          boxShadow: [
            // Dark shadow (bottom right)
            BoxShadow(
              color: shadowColor,
              blurRadius: 24,
              offset: const Offset(8, 8),
            ),
            // Light highlight (top left)
            BoxShadow(
              color: highlightColor,
              blurRadius: 24,
              offset: const Offset(-8, -8),
            ),
            // Inner shadow for depth
            BoxShadow(
              color: shadowColor.withValues(alpha: 0.3),
              blurRadius: 8,
              offset: const Offset(2, 2),
              spreadRadius: -4,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (title != null || subtitle != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (title != null)
                      Text(
                        title!,
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: effectiveTheme.textColor,
                        ),
                      ),
                    if (subtitle != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 4.0),
                        child: Text(
                          subtitle!,
                          style: TextStyle(
                            fontSize: 14,
                            color:
                                effectiveTheme.textColor.withValues(alpha: 0.7),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            if (isLoading)
              SizedBox(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          effectiveTheme.gradientColors.first,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Loading chart data...',
                        style: TextStyle(
                          color:
                              effectiveTheme.textColor.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            else if (isError)
              SizedBox(
                height: 300,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 48,
                        color: Colors.red.withValues(alpha: 0.7),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        errorMessage ?? 'Failed to load chart data',
                        style: TextStyle(
                          color:
                              effectiveTheme.textColor.withValues(alpha: 0.7),
                          fontSize: 14,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              )
            else
              child,
          ],
        ),
      );
    }

    return container;
  }
}
