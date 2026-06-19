import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_style.dart';

/// Style-aware paint factory shared by all renderers. The same call sites
/// (`stroke`, `areaFill`, `barFill`, `blobFill`, `glow`) produce different
/// paints depending on the active [ChartStyle]:
///
/// * [ChartStyle.gradient] — gradient fills/strokes with a soft glow.
/// * [ChartStyle.flat] — solid fills, crisp strokes, no glow.
/// * [ChartStyle.glass] — frosted translucent fills with a light highlight.
///
/// Shaders depend on geometry, so these build fresh [Paint] objects rather
/// than using the `PaintCache` (which keys on solid colors).
class SeriesPaint {
  const SeriesPaint(this.style);

  final ChartStyle style;

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

  Paint _strokeBase(double strokeWidth) => Paint()
    ..strokeWidth = strokeWidth
    ..style = PaintingStyle.stroke
    ..strokeCap = StrokeCap.round
    ..strokeJoin = StrokeJoin.round
    ..isAntiAlias = true;

  /// Line/area/radar outline stroke.
  Paint stroke(
    Rect rect,
    Color color, {
    double strokeWidth = 3,
    double opacity = 1,
  }) {
    final paint = _strokeBase(strokeWidth);
    switch (style) {
      case ChartStyle.gradient:
        paint.shader = LinearGradient(
          colors: [
            color.withValues(alpha: opacity),
            accent(color).withValues(alpha: opacity),
          ],
        ).createShader(rect);
      case ChartStyle.flat:
        paint.color = color.withValues(alpha: opacity);
      case ChartStyle.glass:
        paint.color = lighten(color, 0.08).withValues(alpha: opacity * 0.95);
    }
    return paint;
  }

  /// Soft blurred underlay drawn beneath a line/shape for depth.
  /// Returns an invisible paint for [ChartStyle.flat] (draws nothing).
  Paint glow(Color color, {double strokeWidth = 6, double blur = 6}) {
    if (style == ChartStyle.flat) {
      return Paint()..color = const Color(0x00000000);
    }
    final alpha = style == ChartStyle.glass ? 0.16 : 0.22;
    return Paint()
      ..color = color.withValues(alpha: alpha)
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, blur)
      ..isAntiAlias = true;
  }

  /// Area fill under a line (line / sparkline / stacked area).
  Paint areaFill(Rect rect, Color color, {double opacity = 1}) {
    switch (style) {
      case ChartStyle.gradient:
        return _vertical(rect, color, 0.32 * opacity, 0.0);
      case ChartStyle.flat:
        return Paint()
          ..color = color.withValues(alpha: 0.16 * opacity)
          ..isAntiAlias = true;
      case ChartStyle.glass:
        return _vertical(rect, lighten(color, 0.06), 0.28 * opacity,
            0.12 * opacity);
    }
  }

  /// Filled band fill for stacked areas (more body than a line fill).
  Paint bandFill(Rect rect, Color color, {double opacity = 1}) {
    switch (style) {
      case ChartStyle.gradient:
        return _vertical(rect, color, 0.85 * opacity, 0.45 * opacity);
      case ChartStyle.flat:
        return Paint()
          ..color = color.withValues(alpha: 0.75 * opacity)
          ..isAntiAlias = true;
      case ChartStyle.glass:
        return _vertical(rect, lighten(color, 0.06), 0.5 * opacity,
            0.28 * opacity);
    }
  }

  /// Bar / funnel fill.
  Paint barFill(Rect rect, Color color, {double opacity = 1}) {
    switch (style) {
      case ChartStyle.gradient:
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
      case ChartStyle.flat:
        return Paint()
          ..color = color.withValues(alpha: opacity)
          ..isAntiAlias = true;
      case ChartStyle.glass:
        return Paint()
          ..shader = LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              lighten(color, 0.2).withValues(alpha: 0.6 * opacity),
              color.withValues(alpha: 0.38 * opacity),
            ],
          ).createShader(rect)
          ..isAntiAlias = true;
    }
  }

  /// Slice / bubble / scatter point fill.
  Paint blobFill(Rect rect, Color color, {double opacity = 1}) {
    switch (style) {
      case ChartStyle.gradient:
        return _radial(rect, lighten(color, 0.26), color, opacity, opacity);
      case ChartStyle.flat:
        return Paint()
          ..color = color.withValues(alpha: opacity)
          ..isAntiAlias = true;
      case ChartStyle.glass:
        return _radial(rect, lighten(color, 0.3), color, 0.7 * opacity,
            0.45 * opacity);
    }
  }

  Paint _vertical(Rect rect, Color color, double topAlpha, double bottomAlpha) {
    return Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [
          color.withValues(alpha: topAlpha.clamp(0.0, 1.0)),
          color.withValues(alpha: bottomAlpha.clamp(0.0, 1.0)),
        ],
      ).createShader(rect)
      ..isAntiAlias = true;
  }

  Paint _radial(
    Rect rect,
    Color inner,
    Color outer,
    double innerAlpha,
    double outerAlpha,
  ) {
    return Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        colors: [
          inner.withValues(alpha: innerAlpha.clamp(0.0, 1.0)),
          outer.withValues(alpha: outerAlpha.clamp(0.0, 1.0)),
        ],
      ).createShader(rect)
      ..isAntiAlias = true;
  }
}
