import 'dart:ui';

import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/core/engine/chart_renderer.dart';
import 'package:save_points_chart/core/interactions/hit_test_result.dart'
    show ChartHitResult;

/// Canvas-based hit testing — never uses widget trees.
class HitTestEngine {
  const HitTestEngine();

  ChartHitResult? test(
    Offset position,
    ChartContext context,
    List<ChartRenderer> renderers, {
    double tolerance = 12,
  }) {
    ChartHitResult? closest;

    for (final renderer in renderers) {
      for (final region in renderer.hitRegions(context)) {
        final expanded = region.bounds.inflate(tolerance);
        if (!expanded.contains(position)) continue;

        final center = region.bounds.center;
        final distance = (position - center).distance;

        if (closest == null || distance < closest.distance) {
          closest = ChartHitResult(region: region, distance: distance);
        }
      }
    }

    return closest;
  }
}
