import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

/// Common label rotation angles in degrees for convenience.
///
/// Use these constants when setting label rotation:
/// ```dart
/// ChartTheme.light().copyWith(
///   xAxisLabelRotation: LabelRotation.diagonalDown, // 45 degrees
/// )
///
/// // Or use custom degrees:
/// ChartDataPoint(
///   x: 1,
///   y: 20,
///   label: 'January',
///   xAxisLabelRotation: 30, // 30 degrees
/// )
/// ```
class LabelRotation {
  /// No rotation (horizontal labels)
  static const int none = 0;

  /// 45 degrees clockwise (slanted down to the right)
  static const int diagonalDown = 45;

  /// 45 degrees counter-clockwise (slanted up to the right)
  static const int diagonalUp = -45;

  /// 90 degrees clockwise (vertical, reading top to bottom)
  static const int vertical = 90;

  /// 90 degrees counter-clockwise (vertical, reading bottom to top)
  static const int verticalUp = -90;

  /// 30 degrees clockwise
  static const int slightDown = 30;

  /// 30 degrees counter-clockwise
  static const int slightUp = -30;

  /// 60 degrees clockwise
  static const int steepDown = 60;

  /// 60 degrees counter-clockwise
  static const int steepUp = -60;
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
  /// Card/container surface color (inside dashboard card).
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

  /// Subtle border color for the chart card.
  final Color cardBorderColor;

  /// Optional tinted overlay used for hover/selection highlights.
  final Color overlayColor;

  /// Crosshair color (hover line).
  final Color crosshairColor;

  /// Tooltip surface/background color.
  final Color tooltipBackgroundColor;

  /// Tooltip border color.
  final Color tooltipBorderColor;

  /// Tooltip shadow.
  final List<BoxShadow> tooltipShadow;

  /// Grid appearance controls.
  final double gridLineWidth;
  final double gridDashWidth;
  final double gridDashSpace;

  /// Rotation angle for X-axis labels in degrees.
  ///
  /// Defaults to 0 (horizontal). Common values:
  /// - 0: Horizontal labels
  /// - -45: Diagonal labels (slanted down)
  /// - -90: Vertical labels
  ///
  /// See also:
  /// - [LabelRotation] for common rotation constants
  final int xAxisLabelRotation;

  /// Rotation angle for Y-axis labels in degrees.
  ///
  /// Defaults to 0 (horizontal). Usually kept at 0 for Y-axis.
  ///
  /// See also:
  /// - [LabelRotation] for common rotation constants
  final int yAxisLabelRotation;

  /// Text style for axis labels.
  final TextStyle? axisLabelStyle;

  /// Text style for tooltips.
  final TextStyle? tooltipStyle;

  /// Padding around the chart content.
  final EdgeInsets padding;

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
    this.cardBorderColor = const Color(0x00000000),
    this.overlayColor = const Color(0x14000000),
    this.crosshairColor = const Color(0x66000000),
    this.tooltipBackgroundColor = const Color(0xFF111827),
    this.tooltipBorderColor = const Color(0x1FFFFFFF),
    this.tooltipShadow = const [
      BoxShadow(
        color: Color(0x1A000000),
        blurRadius: 18,
        offset: Offset(0, 8),
        spreadRadius: -6,
      ),
      BoxShadow(
        color: Color(0x0F000000),
        blurRadius: 10,
        offset: Offset(0, 4),
        spreadRadius: -6,
      ),
    ],
    this.gridLineWidth = 1.0,
    this.gridDashWidth = 4.0,
    this.gridDashSpace = 4.0,
    this.xAxisLabelRotation = 0,
    this.yAxisLabelRotation = 0,
    this.axisLabelStyle,
    this.tooltipStyle,
    this.padding = const EdgeInsets.fromLTRB(40, 20, 20, 40),
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
      textColor: Color(0xFF1F2937), // Gray 900
      gridColor: Color(0xFFE5E7EB), // Gray 200
      axisColor: Color(0xFF9CA3AF), // Gray 400
      cardBorderColor: Color(0x1A111827), // ~Gray 900 @ 10%
      overlayColor: Color(0x0F111827),
      crosshairColor: Color(0x66111827),
      tooltipBackgroundColor: Color(0xFF0B1220),
      tooltipBorderColor: Color(0x14111827),
      tooltipShadow: [
        BoxShadow(
          color: Color(0x14000000),
          blurRadius: 20,
          offset: Offset(0, 10),
          spreadRadius: -8,
        ),
        BoxShadow(
          color: Color(0x0A000000),
          blurRadius: 10,
          offset: Offset(0, 4),
          spreadRadius: -8,
        ),
      ],
      gradientColors: [
        Color(0xFF6366F1), // Indigo 500
        Color(0xFF8B5CF6), // Violet 500
        Color(0xFFEC4899), // Pink 500
        Color(0xFF10B981), // Emerald 500
        Color(0xFFF59E0B), // Amber 500
      ],
      axisLabelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Color(0xFF6B7280), // Gray 500
      ),
      tooltipStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFFF9FAFB),
        letterSpacing: -0.1,
      ),
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
      backgroundColor: Color(0xFF1F2937), // Gray 800
      textColor: Color(0xFFF9FAFB), // Gray 50
      gridColor: Color(0xFF374151), // Gray 700
      axisColor: Color(0xFF6B7280), // Gray 500
      cardBorderColor: Color(0x1AFFFFFF),
      overlayColor: Color(0x14FFFFFF),
      crosshairColor: Color(0x66FFFFFF),
      tooltipBackgroundColor: Color(0xFF0B1220),
      tooltipBorderColor: Color(0x1AFFFFFF),
      tooltipShadow: [
        BoxShadow(
          color: Color(0x66000000),
          blurRadius: 22,
          offset: Offset(0, 12),
          spreadRadius: -10,
        ),
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 12,
          offset: Offset(0, 6),
          spreadRadius: -10,
        ),
      ],
      gradientColors: [
        Color(0xFF818CF8), // Indigo 400
        Color(0xFFA78BFA), // Violet 400
        Color(0xFFF472B6), // Pink 400
        Color(0xFF34D399), // Emerald 400
        Color(0xFFFBBF24), // Amber 400
      ],
      shadowElevation: 8.0,
      axisLabelStyle: TextStyle(
        fontSize: 11,
        fontWeight: FontWeight.w500,
        color: Color(0xFF9CA3AF), // Gray 400
      ),
      tooltipStyle: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: Color(0xFFF9FAFB),
        letterSpacing: -0.1,
      ),
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
    Color? cardBorderColor,
    Color? overlayColor,
    Color? crosshairColor,
    Color? tooltipBackgroundColor,
    Color? tooltipBorderColor,
    List<BoxShadow>? tooltipShadow,
    double? gridLineWidth,
    double? gridDashWidth,
    double? gridDashSpace,
    int? xAxisLabelRotation,
    int? yAxisLabelRotation,
    TextStyle? axisLabelStyle,
    TextStyle? tooltipStyle,
    EdgeInsets? padding,
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
      cardBorderColor: cardBorderColor ?? this.cardBorderColor,
      overlayColor: overlayColor ?? this.overlayColor,
      crosshairColor: crosshairColor ?? this.crosshairColor,
      tooltipBackgroundColor:
          tooltipBackgroundColor ?? this.tooltipBackgroundColor,
      tooltipBorderColor: tooltipBorderColor ?? this.tooltipBorderColor,
      tooltipShadow: tooltipShadow ?? this.tooltipShadow,
      gridLineWidth: gridLineWidth ?? this.gridLineWidth,
      gridDashWidth: gridDashWidth ?? this.gridDashWidth,
      gridDashSpace: gridDashSpace ?? this.gridDashSpace,
      xAxisLabelRotation: xAxisLabelRotation ?? this.xAxisLabelRotation,
      yAxisLabelRotation: yAxisLabelRotation ?? this.yAxisLabelRotation,
      axisLabelStyle: axisLabelStyle ?? this.axisLabelStyle,
      tooltipStyle: tooltipStyle ?? this.tooltipStyle,
      padding: padding ?? this.padding,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is ChartTheme &&
        other.backgroundColor == backgroundColor &&
        other.textColor == textColor &&
        other.gridColor == gridColor &&
        other.axisColor == axisColor &&
        listEquals(other.gradientColors, gradientColors) &&
        other.shadowElevation == shadowElevation &&
        other.borderRadius == borderRadius &&
        other.showGrid == showGrid &&
        other.showAxis == showAxis &&
        other.showLegend == showLegend &&
        other.showTooltip == showTooltip &&
        other.cardBorderColor == cardBorderColor &&
        other.overlayColor == overlayColor &&
        other.crosshairColor == crosshairColor &&
        other.tooltipBackgroundColor == tooltipBackgroundColor &&
        other.tooltipBorderColor == tooltipBorderColor &&
        listEquals(other.tooltipShadow, tooltipShadow) &&
        other.gridLineWidth == gridLineWidth &&
        other.gridDashWidth == gridDashWidth &&
        other.gridDashSpace == gridDashSpace &&
        other.xAxisLabelRotation == xAxisLabelRotation &&
        other.yAxisLabelRotation == yAxisLabelRotation &&
        other.axisLabelStyle == axisLabelStyle &&
        other.tooltipStyle == tooltipStyle &&
        other.padding == padding;
  }

  @override
  int get hashCode => Object.hashAll([
    backgroundColor,
    textColor,
    gridColor,
    axisColor,
    Object.hashAll(gradientColors),
    shadowElevation,
    borderRadius,
    showGrid,
    showAxis,
    showLegend,
    showTooltip,
    cardBorderColor,
    overlayColor,
    crosshairColor,
    tooltipBackgroundColor,
    tooltipBorderColor,
    Object.hashAll(tooltipShadow),
    gridLineWidth,
    gridDashWidth,
    gridDashSpace,
    xAxisLabelRotation,
    yAxisLabelRotation,
    axisLabelStyle,
    tooltipStyle,
    padding,
  ]);
}
