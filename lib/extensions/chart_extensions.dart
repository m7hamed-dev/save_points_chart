import 'package:save_points_chart/charts/bubble_chart/bubble_chart_renderer.dart';
import 'package:save_points_chart/models/chart_point.dart';
import 'package:save_points_chart/models/chart_series.dart';

/// Convenience extensions for building chart data.
extension ChartPointListExtension on List<ChartPoint> {
  ChartSeries toSeries({
    required String id,
    required String name,
    SeriesStyle style = const SeriesStyle(),
  }) {
    return ChartSeries(id: id, name: name, points: this, style: style);
  }
}

extension NumericSeriesExtension on Iterable<num> {
  List<ChartPoint> toChartPoints({double startX = 0, double step = 1}) {
    return toList()
        .asMap()
        .entries
        .map((e) => ChartPoint(x: startX + e.key * step, y: e.value.toDouble()))
        .toList();
  }
}

/// Builds bubble chart points with size in metadata.
extension BubblePointExtension on Iterable<(num x, num y, num size)> {
  List<ChartPoint> toBubblePoints({String sizeKey = kBubbleSizeKey}) {
    return map(
      (t) => ChartPoint(
        x: t.$1.toDouble(),
        y: t.$2.toDouble(),
        metadata: {sizeKey: t.$3.toDouble()},
      ),
    ).toList();
  }
}
