import 'package:flutter/foundation.dart';

/// A single data point in chart data space.
@immutable
class ChartPoint {
  const ChartPoint({
    required this.x,
    required this.y,
    this.label,
    this.metadata = const {},
  });

  final double x;
  final double y;
  final String? label;
  final Map<String, Object?> metadata;

  ChartPoint copyWith({
    double? x,
    double? y,
    String? label,
    Map<String, Object?>? metadata,
  }) {
    return ChartPoint(
      x: x ?? this.x,
      y: y ?? this.y,
      label: label ?? this.label,
      metadata: metadata ?? this.metadata,
    );
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartPoint &&
          x == other.x &&
          y == other.y &&
          label == other.label;

  @override
  int get hashCode => Object.hash(x, y, label);
}
