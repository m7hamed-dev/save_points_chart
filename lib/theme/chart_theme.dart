import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Common label rotation angles in radians for convenience.
///
/// Use these constants when setting label rotation:
/// ```dart
/// ChartTheme.light().copyWith(
///   xAxisLabelRotation: LabelRotation.diagonalDown,
/// )
/// ```
class LabelRotation {
  /// No rotation (horizontal labels)
  static const double none = 0.0;
  
  /// 45 degrees clockwise (slanted down to the right)
  static const double diagonalDown = math.pi / 4;
  
  /// 45 degrees counter-clockwise (slanted up to the right)
  static const double diagonalUp = -math.pi / 4;
  
  /// 90 degrees clockwise (vertical, reading top to bottom)
  static const double vertical = math.pi / 2;
  
  /// 90 degrees counter-clockwise (vertical, reading bottom to top)
  static const double verticalUp = -math.pi / 2;
  
  /// 30 degrees clockwise
  static const double slightDown = math.pi / 6;
  
  /// 30 degrees counter-clockwise
  static const double slightUp = -math.pi / 6;
  
  /// 60 degrees clockwise
  static const double steepDown = math.pi / 3;
  
  /// 60 degrees counter-clockwise
  static const double steepUp = -math.pi / 3;
}

/// Theme-aware chart styling configuration.
///
/// This class provides comprehensive theming for all chart types, including
/// colors, typography, spacing, and visual effects. Themes are designed to
/// work seamlessly with Material Design 3 and support both light and dark modes.
///
/// ## Features
/// - Light and dark theme presets
/// - Automatic theme inference from Material theme
/// - Customizable colors, fonts, and spacing
/// - Copy-with method for easy customization
/// - Professional gradient color palettes
///
/// ## Example
/// ```dart
/// // Use preset theme
/// final theme = ChartTheme.light();
///
/// // Customize theme
/// final customTheme = ChartTheme.light().copyWith(
///   backgroundColor: Colors.grey[100],
///   borderRadius: 24.0,
///   xAxisLabelRotation: LabelRotation.diagonalDown, // Rotate X-axis labels
/// );
///
/// // Infer from Material theme
/// final autoTheme = ChartTheme.fromMaterialTheme(Theme.of(context));
/// ```
///
/// See also:
/// - [ThemeData] for Material theme
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
  
  /// Rotation angle for X-axis labels in radians.
  ///
  /// Defaults to 0.0 (horizontal). Common values:
  /// - 0.0: Horizontal labels
  /// - -pi/4 or -45 degrees: Diagonal labels (slanted down)
  /// - -pi/2 or -90 degrees: Vertical labels
  final double xAxisLabelRotation;
  
  /// Rotation angle for Y-axis labels in radians.
  ///
  /// Defaults to 0.0 (horizontal). Usually kept at 0.0 for Y-axis.
  final double yAxisLabelRotation;

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
    this.xAxisLabelRotation = 0.0,
    this.yAxisLabelRotation = 0.0,
  });

  /// Create light theme with enhanced colors.
  ///
  /// Returns a professionally designed light theme with:
  /// - White background
  /// - Dark text for contrast
  /// - Subtle grid and axis colors
  /// - Vibrant gradient color palette
  /// - Modern rounded corners
  ///
  /// ## Example
  /// ```dart
  /// final theme = ChartTheme.light();
  /// ```
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

  /// Create dark theme with enhanced colors.
  ///
  /// Returns a professionally designed dark theme with:
  /// - Dark background (slate gray)
  /// - Light text for contrast
  /// - Muted grid and axis colors
  /// - Bright gradient color palette
  /// - Modern rounded corners
  ///
  /// ## Example
  /// ```dart
  /// final theme = ChartTheme.dark();
  /// ```
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

  /// Create theme from Material Theme.
  ///
  /// Automatically infers the appropriate chart theme (light or dark) based
  /// on the brightness of the provided Material theme.
  ///
  /// Parameters:
  /// - [theme] - The Material theme to infer from
  ///
  /// Returns [ChartTheme.dark()] if theme brightness is dark,
  /// [ChartTheme.light()] otherwise.
  ///
  /// ## Example
  /// ```dart
  /// final chartTheme = ChartTheme.fromMaterialTheme(Theme.of(context));
  /// ```
  factory ChartTheme.fromMaterialTheme(ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;
    return isDark ? ChartTheme.dark() : ChartTheme.light();
  }

  /// Creates a copy of this theme with the given fields replaced.
  ///
  /// Returns a new [ChartTheme] with the same values as this one,
  /// except for the fields that are explicitly provided. This is useful
  /// for creating variations of a theme.
  ///
  /// Parameters:
  /// - All parameters are optional. Only provided parameters will override
  ///   the current theme values.
  ///
  /// ## Example
  /// ```dart
  /// final customTheme = ChartTheme.light().copyWith(
  ///   backgroundColor: Colors.grey[100],
  ///   borderRadius: 24.0,
  ///   shadowElevation: 8.0,
  /// );
  /// ```
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
    double? xAxisLabelRotation,
    double? yAxisLabelRotation,
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
      xAxisLabelRotation: xAxisLabelRotation ?? this.xAxisLabelRotation,
      yAxisLabelRotation: yAxisLabelRotation ?? this.yAxisLabelRotation,
    );
  }
}
