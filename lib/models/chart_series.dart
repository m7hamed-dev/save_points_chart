import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_point.dart';

/// Style configuration for a data series.
@immutable
class SeriesStyle {
  const SeriesStyle({
    this.color,
    this.strokeWidth = 2.0,
    this.fillColor,
    this.gradient,
    this.showMarkers = false,
    this.markerRadius = 4.0,
    this.opacity = 1.0,
  });

  final Color? color;
  final double strokeWidth;
  final Color? fillColor;
  final Gradient? gradient;
  final bool showMarkers;
  final double markerRadius;
  final double opacity;

  SeriesStyle copyWith({
    Color? color,
    double? strokeWidth,
    Color? fillColor,
    Gradient? gradient,
    bool? showMarkers,
    double? markerRadius,
    double? opacity,
  }) {
    return SeriesStyle(
      color: color ?? this.color,
      strokeWidth: strokeWidth ?? this.strokeWidth,
      fillColor: fillColor ?? this.fillColor,
      gradient: gradient ?? this.gradient,
      showMarkers: showMarkers ?? this.showMarkers,
      markerRadius: markerRadius ?? this.markerRadius,
      opacity: opacity ?? this.opacity,
    );
  }
}

/// A named collection of [ChartPoint]s with optional styling.
@immutable
class ChartSeries {
  const ChartSeries({
    required this.id,
    required this.name,
    required this.points,
    this.style = const SeriesStyle(),
  });

  final String id;
  final String name;
  final List<ChartPoint> points;
  final SeriesStyle style;

  ChartSeries copyWith({
    String? id,
    String? name,
    List<ChartPoint>? points,
    SeriesStyle? style,
  }) {
    return ChartSeries(
      id: id ?? this.id,
      name: name ?? this.name,
      points: points ?? this.points,
      style: style ?? this.style,
    );
  }
}
