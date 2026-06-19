import 'package:flutter/material.dart';

/// Paint helpers for the "modern gradient + depth" chart style: gradient
/// strokes/fills, soft glow, and radial highlights shared by all renderers.
///
/// Shaders depend on geometry, so these build fresh [Paint] objects rather
/// than using the `PaintCache` (which keys on solid colors).
class SeriesPaint {
  const SeriesPaint._();

  /// Lighten [color] toward white in HSL space by [amount] (0..1).
  static Color lighten(Color color, [double amount = 0.18]) {
    final hsl = HSLColor.fromColor(color);
    return hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0)).toColor();
  }

  /// Brighter, slightly hue-shifted accent used as a gradient end-stop.
  static Color accent(Color color) {
    final hsl = HSLColor.fromColor(color);
    return hsl
        .withHue((hsl.hue + 12) % 360)
        .withSaturation((hsl.saturation + 0.05).clamp(0.0, 1.0))
        .withLightness((hsl.lightness + 0.12).clamp(0.0, 1.0))
        .toColor();
  }

  /// Stroke paint with a left→right gradient from [color] to its [accent].
  static Paint strokeGradient(
    Rect rect,
    Color color, {
    double strokeWidth = 3,
    double opacity = 1,
  }) {
    return Paint()
      ..shader = LinearGradient(
        colors: [
          color.withValues(alpha: opacity),
          accent(color).withValues(alpha: opacity),
        ],
      ).createShader(rect)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..isAntiAlias = true;
  }

  /// Soft blurred stroke drawn beneath a line/shape for depth.
  static Paint glow(Color color, {double strokeWidth = 6, double blur = 6}) {
    return Paint()
      ..color = color.withValues(alpha: 0.22)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur)
      ..isAntiAlias = true;
  }

  /// Top→bottom area fill fading from [topAlpha] to [bottomAlpha].
  static Paint verticalFill(
    Rect rect,
    Color color, {
    double topAlpha = 0.35,
    double bottomAlpha = 0.0,
  }) {
    return Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: topAlpha),
          color.withValues(alpha: bottomAlpha),
        ],
      ).createShader(rect)
      ..isAntiAlias = true;
  }

  /// Bar fill: bright [accent] at the top → solid [color] at the base.
  static Paint barGradient(Rect rect, Color color, {double opacity = 1}) {
    return Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          accent(color).withValues(alpha: opacity),
          color.withValues(alpha: opacity),
        ],
      ).createShader(rect)
      ..isAntiAlias = true;
  }

  /// Radial fill for slices/bubbles/markers: bright off-center highlight →
  /// solid [color] at the edge.
  static Paint radialFill(Rect rect, Color color, {double opacity = 1}) {
    return Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        colors: [
          lighten(color, 0.26).withValues(alpha: opacity),
          color.withValues(alpha: opacity),
        ],
      ).createShader(rect)
      ..isAntiAlias = true;
  }
}
