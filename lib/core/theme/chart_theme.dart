import 'package:flutter/material.dart';

/// Visual theme for charts including light, dark, and dashboard presets.
@immutable
class ChartTheme {
  const ChartTheme({
    required this.backgroundColor,
    required this.gridColor,
    required this.axisColor,
    required this.axisTextStyle,
    required this.tooltipBackground,
    required this.tooltipTextStyle,
    required this.crosshairColor,
    required this.selectionColor,
    required this.seriesColors,
    required this.shadow,
    this.titleTextStyle,
    this.subtitleTextStyle,
    this.legendTextStyle,
    this.borderColor = const Color(0x33FFFFFF),
    this.cardBorderRadius = 12,
    this.sliceBorderColor = const Color(0xFFFFFFFF),
    this.sliceBorderWidth = 2,
    this.ringMarkers = false,
    this.markerCenterColor = Colors.white,
    this.gridStrokeWidth = 1.0,
    this.axisStrokeWidth = 1.0,
    this.padding = const EdgeInsets.all(16),
  });

  final Color backgroundColor;
  final Color gridColor;
  final Color axisColor;
  final TextStyle axisTextStyle;
  final Color tooltipBackground;
  final TextStyle tooltipTextStyle;
  final Color crosshairColor;
  final Color selectionColor;
  final List<Color> seriesColors;
  final List<BoxShadow> shadow;
  final TextStyle? titleTextStyle;
  final TextStyle? subtitleTextStyle;
  final TextStyle? legendTextStyle;
  final Color borderColor;
  final double cardBorderRadius;
  final Color sliceBorderColor;
  final double sliceBorderWidth;
  final bool ringMarkers;
  final Color markerCenterColor;
  final double gridStrokeWidth;
  final double axisStrokeWidth;
  final EdgeInsets padding;

  factory ChartTheme.light() {
    return const ChartTheme(
      backgroundColor: Colors.white,
      gridColor: Color(0xFFE0E0E0),
      axisColor: Color(0xFF9E9E9E),
      axisTextStyle: TextStyle(color: Color(0xFF616161), fontSize: 11),
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.2,
      ),
      subtitleTextStyle: TextStyle(
        color: Color(0xFF6B7280),
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
      ),
      legendTextStyle: TextStyle(color: Color(0xFF6B7280), fontSize: 12),
      tooltipBackground: Color(0xFF212121),
      tooltipTextStyle: TextStyle(color: Colors.white, fontSize: 12),
      crosshairColor: Color(0xFF757575),
      selectionColor: Color(0x331976D2),
      borderColor: Color(0xFFE0E0E0),
      seriesColors: [
        Color(0xFF1976D2),
        Color(0xFFE53935),
        Color(0xFF43A047),
        Color(0xFFFB8C00),
        Color(0xFF8E24AA),
        Color(0xFF00ACC1),
      ],
      shadow: [
        BoxShadow(
          color: Color(0x1A000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  factory ChartTheme.dark() {
    return const ChartTheme(
      backgroundColor: Color(0xFF1E1E1E),
      gridColor: Color(0xFF424242),
      axisColor: Color(0xFF757575),
      axisTextStyle: TextStyle(color: Color(0xFFBDBDBD), fontSize: 11),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.2,
      ),
      subtitleTextStyle: TextStyle(
        color: Color(0xFFAAB2C0),
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
      ),
      legendTextStyle: TextStyle(color: Color(0xFFAAB2C0), fontSize: 12),
      tooltipBackground: Color(0xFFEEEEEE),
      tooltipTextStyle: TextStyle(color: Color(0xFF212121), fontSize: 12),
      crosshairColor: Color(0xFF9E9E9E),
      selectionColor: Color(0x3364B5F6),
      seriesColors: [
        Color(0xFF64B5F6),
        Color(0xFFEF5350),
        Color(0xFF66BB6A),
        Color(0xFFFFB74D),
        Color(0xFFBA68C8),
        Color(0xFF4DD0E1),
      ],
      shadow: [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  /// Analytics dashboard preset (navy cards, blue/green/orange series).
  factory ChartTheme.dashboard() {
    return const ChartTheme(
      backgroundColor: Color(0xFF0F1B3C),
      gridColor: Color(0xFF1E3058),
      axisColor: Color(0xFF5C6B8A),
      axisTextStyle: TextStyle(color: Color(0xFF9E9E9E), fontSize: 11),
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.2,
        height: 1.2,
      ),
      subtitleTextStyle: TextStyle(
        color: Color(0xFF8A97B1),
        fontSize: 12,
        fontWeight: FontWeight.w400,
        height: 1.3,
      ),
      legendTextStyle: TextStyle(color: Color(0xFF8A97B1), fontSize: 12),
      tooltipBackground: Color(0xFFEEEEEE),
      tooltipTextStyle: TextStyle(color: Color(0xFF212121), fontSize: 12),
      crosshairColor: Color(0xFF9E9E9E),
      selectionColor: Color(0x3364B5F6),
      ringMarkers: true,
      seriesColors: [
        Color(0xFF2196F3),
        Color(0xFF4CAF50),
        Color(0xFFFF9800),
        Color(0xFFAB47BC),
        Color(0xFF26C6DA),
      ],
      shadow: [
        BoxShadow(
          color: Color(0x33000000),
          blurRadius: 8,
          offset: Offset(0, 2),
        ),
      ],
    );
  }

  Color seriesColor(int index) => seriesColors[index % seriesColors.length];
}
