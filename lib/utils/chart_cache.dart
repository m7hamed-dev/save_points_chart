import 'dart:ui' as ui;
import 'package:flutter/material.dart';

/// Performance cache for chart rendering
class ChartCache {
  // Cache for Paint objects
  static final Map<String, Paint> _paintCache = {};

  // Cache for TextPainters
  static final Map<String, TextPainter> _textPainterCache = {};

  // Cache for Paths
  static final Map<String, Path> _pathCache = {};

  // Cache for Shaders
  static final Map<String, ui.Shader> _shaderCache = {};

  /// Get or create a Paint object
  static Paint getPaint({
    required Color color,
    double? strokeWidth,
    PaintingStyle? style,
    StrokeCap? strokeCap,
    StrokeJoin? strokeJoin,
    MaskFilter? maskFilter,
  }) {
    final key =
        'paint_${color.toARGB32()}_${strokeWidth}_${style}_${strokeCap}_${strokeJoin}_$maskFilter';

    if (_paintCache.containsKey(key)) {
      final paint = _paintCache[key]!;
      // Update properties if needed
      paint.color = color;
      if (strokeWidth != null) paint.strokeWidth = strokeWidth;
      if (style != null) paint.style = style;
      if (strokeCap != null) paint.strokeCap = strokeCap;
      if (strokeJoin != null) paint.strokeJoin = strokeJoin;
      if (maskFilter != null) paint.maskFilter = maskFilter;
      return paint;
    }

    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth ?? 1.0
      ..style = style ?? PaintingStyle.stroke
      ..strokeCap = strokeCap ?? StrokeCap.butt
      ..strokeJoin = strokeJoin ?? StrokeJoin.miter;
    if (maskFilter != null) paint.maskFilter = maskFilter;

    _paintCache[key] = paint;
    return paint;
  }

  /// Get or create a TextPainter
  static TextPainter getTextPainter({
    required String text,
    required TextStyle style,
  }) {
    final key = 'text_${text}_${style.hashCode}';

    if (_textPainterCache.containsKey(key)) {
      final painter = _textPainterCache[key]!;
      painter.text = TextSpan(text: text, style: style);
      painter.layout();
      return painter;
    }

    final painter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    painter.layout();

    _textPainterCache[key] = painter;
    return painter;
  }

  /// Clear all caches (call when memory is low)
  static void clearCache() {
    _paintCache.clear();
    _textPainterCache.clear();
    _pathCache.clear();
    _shaderCache.clear();
  }

  /// Clear specific cache type
  static void clearPathCache() => _pathCache.clear();
  static void clearShaderCache() => _shaderCache.clear();
}
