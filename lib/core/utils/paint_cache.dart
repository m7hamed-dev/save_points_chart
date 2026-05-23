import 'package:flutter/material.dart';

/// Caches [Paint] objects to avoid allocations in paint loops.
class PaintCache {
  final Map<String, Paint> _cache = {};

  Paint get({
    required String key,
    required Color color,
    double strokeWidth = 1.0,
    PaintingStyle style = PaintingStyle.stroke,
    StrokeCap strokeCap = StrokeCap.round,
    StrokeJoin strokeJoin = StrokeJoin.round,
    bool isAntiAlias = true,
    double? opacity,
  }) {
    final cacheKey =
        '$key-${color.toARGB32()}-$strokeWidth-$style-$strokeCap-$opacity';
    return _cache.putIfAbsent(cacheKey, () {
      return Paint()
        ..color = opacity != null ? color.withValues(alpha: opacity) : color
        ..strokeWidth = strokeWidth
        ..style = style
        ..strokeCap = strokeCap
        ..strokeJoin = strokeJoin
        ..isAntiAlias = isAntiAlias;
    });
  }

  Paint fill(String key, Color color, {double? opacity}) {
    return get(
      key: key,
      color: color,
      style: PaintingStyle.fill,
      opacity: opacity,
    );
  }

  void clear() => _cache.clear();
}
