import 'package:save_points_chart/charts/line_chart/line_chart_renderer.dart';

/// Area chart — line chart with fill enabled.
class AreaChartRenderer extends LineChartRenderer {
  const AreaChartRenderer({super.mode}) : super(fillArea: true);
}
