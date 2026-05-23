import 'package:flutter/foundation.dart';

/// Defines the visible data-space region for a chart.
@immutable
class ChartViewport {
  const ChartViewport({
    required this.minX,
    required this.maxX,
    required this.minY,
    required this.maxY,
  });

  final double minX;
  final double maxX;
  final double minY;
  final double maxY;

  double get width => maxX - minX;
  double get height => maxY - minY;

  static ChartViewport fromPoints(
    Iterable<double> xs,
    Iterable<double> ys, {
    double padding = 0.05,
  }) {
    var minX = double.infinity;
    var maxX = double.negativeInfinity;
    var minY = double.infinity;
    var maxY = double.negativeInfinity;

    for (final x in xs) {
      if (x < minX) minX = x;
      if (x > maxX) maxX = x;
    }
    for (final y in ys) {
      if (y < minY) minY = y;
      if (y > maxY) maxY = y;
    }

    if (minX == double.infinity) {
      return const ChartViewport(minX: 0, maxX: 1, minY: 0, maxY: 1);
    }

    final xPad = (maxX - minX) * padding;
    final yPad = (maxY - minY) * padding;
    return ChartViewport(
      minX: minX - xPad,
      maxX: maxX + xPad,
      minY: minY - yPad,
      maxY: maxY + yPad,
    );
  }

  ChartViewport zoom(
    double factor, {
    double centerX = 0.5,
    double centerY = 0.5,
  }) {
    final cx = minX + width * centerX;
    final cy = minY + height * centerY;
    final newWidth = width / factor;
    final newHeight = height / factor;
    return ChartViewport(
      minX: cx - newWidth * centerX,
      maxX: cx + newWidth * (1 - centerX),
      minY: cy - newHeight * centerY,
      maxY: cy + newHeight * (1 - centerY),
    );
  }

  ChartViewport pan(double dx, double dy) {
    return ChartViewport(
      minX: minX + dx,
      maxX: maxX + dx,
      minY: minY + dy,
      maxY: maxY + dy,
    );
  }

  ChartViewport copyWith({
    double? minX,
    double? maxX,
    double? minY,
    double? maxY,
  }) {
    return ChartViewport(
      minX: minX ?? this.minX,
      maxX: maxX ?? this.maxX,
      minY: minY ?? this.minY,
      maxY: maxY ?? this.maxY,
    );
  }
}
