import 'package:flutter/material.dart';

/// Theme-aware chart styling configuration
class ChartTheme {
  final Color backgroundColor;
  final Color textColor;
  final Color gridColor;
  final Color axisColor;
  final List<Color> gradientColors;
  final double shadowElevation;
  final double borderRadius;
  final bool showGrid;
  final bool showAxis;
  final bool showLegend;
  final bool showTooltip;

  const ChartTheme({
    required this.backgroundColor,
    required this.textColor,
    required this.gridColor,
    required this.axisColor,
    required this.gradientColors,
    this.shadowElevation = 4.0,
    this.borderRadius = 16.0,
    this.showGrid = true,
    this.showAxis = true,
    this.showLegend = true,
    this.showTooltip = true,
  });

  /// Create light theme with enhanced colors
  factory ChartTheme.light() {
    return const ChartTheme(
      backgroundColor: Color(0xFFFFFFFF),
      textColor: Color(0xFF111827),
      gridColor: Color(0xFFE5E7EB),
      axisColor: Color(0xFF6B7280),
      gradientColors: [
        Color(0xFF6366F1), // Indigo
        Color(0xFF8B5CF6), // Purple
        Color(0xFFEC4899), // Pink
        Color(0xFF10B981), // Emerald
        Color(0xFFF59E0B), // Amber
      ],
      shadowElevation: 6.0,
      borderRadius: 20.0,
    );
  }

  /// Create dark theme with enhanced colors
  factory ChartTheme.dark() {
    return const ChartTheme(
      backgroundColor: Color(0xFF1F2937),
      textColor: Color(0xFFF9FAFB),
      gridColor: Color(0xFF374151),
      axisColor: Color(0xFF9CA3AF),
      gradientColors: [
        Color(0xFF818CF8), // Light Indigo
        Color(0xFFA78BFA), // Light Purple
        Color(0xFFF472B6), // Light Pink
        Color(0xFF34D399), // Light Emerald
        Color(0xFFFBBF24), // Light Amber
      ],
      shadowElevation: 12.0,
      borderRadius: 20.0,
    );
  }

  /// Create from Material Theme
  factory ChartTheme.fromMaterialTheme(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark ? ChartTheme.dark() : ChartTheme.light();
  }

  /// Copy with method for customization
  ChartTheme copyWith({
    Color? backgroundColor,
    Color? textColor,
    Color? gridColor,
    Color? axisColor,
    List<Color>? gradientColors,
    double? shadowElevation,
    double? borderRadius,
    bool? showGrid,
    bool? showAxis,
    bool? showLegend,
    bool? showTooltip,
  }) {
    return ChartTheme(
      backgroundColor: backgroundColor ?? this.backgroundColor,
      textColor: textColor ?? this.textColor,
      gridColor: gridColor ?? this.gridColor,
      axisColor: axisColor ?? this.axisColor,
      gradientColors: gradientColors ?? this.gradientColors,
      shadowElevation: shadowElevation ?? this.shadowElevation,
      borderRadius: borderRadius ?? this.borderRadius,
      showGrid: showGrid ?? this.showGrid,
      showAxis: showAxis ?? this.showAxis,
      showLegend: showLegend ?? this.showLegend,
      showTooltip: showTooltip ?? this.showTooltip,
    );
  }
}
