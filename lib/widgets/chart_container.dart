import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:save_points_chart/theme/chart_theme.dart';

/// Modern container wrapper for charts with glassmorphism and neumorphism effects
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
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: effectiveTheme.shadowElevation * 2,
            offset: Offset(0, effectiveTheme.shadowElevation),
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
              effectiveTheme.backgroundColor.withValues(alpha: 0.9),
              effectiveTheme.backgroundColor.withValues(alpha: 0.7),
            ],
          ),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.2),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.1),
              blurRadius: 20,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(effectiveTheme.borderRadius),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: container,
          ),
        ),
      );
    }

    if (useNeumorphism) {
      final isDark = effectiveTheme.backgroundColor.computeLuminance() < 0.5;
      final shadowColor = isDark
          ? Colors.black.withValues(alpha: 0.5)
          : Colors.white.withValues(alpha: 0.8);
      final highlightColor = isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.1);

      container = Container(
        padding: padding,
        decoration: BoxDecoration(
          color: effectiveTheme.backgroundColor,
          borderRadius: BorderRadius.circular(effectiveTheme.borderRadius),
          boxShadow: [
            BoxShadow(
              color: shadowColor,
              blurRadius: 20,
              offset: const Offset(10, 10),
            ),
            BoxShadow(
              color: highlightColor,
              blurRadius: 20,
              offset: const Offset(-10, -10),
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
