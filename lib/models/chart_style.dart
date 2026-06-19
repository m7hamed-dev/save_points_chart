/// Visual design language applied to the chart drawing itself.
///
/// Controls how series are painted, independent of the color `ChartTheme`.
enum ChartStyle {
  /// Gradient fills, gradient strokes, and soft glow for depth (default).
  gradient,

  /// Solid flat fills and crisp strokes with no gradients or glow.
  flat,

  /// Frosted, translucent fills with a light highlight — glassmorphism.
  glass,
}
