/// A modern, high-performance Flutter charting library with full theme support.
///
/// This library provides 12 chart types with Material 3 design, glassmorphism,
/// and neumorphism effects. All charts support light/dark themes and are
/// optimized for performance.
///
/// ## Getting Started
///
/// ```dart
/// import 'package:save_points_chart/save_points_chart.dart';
///
/// LineChartWidget(
///   dataSets: [
///     ChartDataSet(
///       label: 'Sales',
///       color: Colors.blue,
///       dataPoints: [
///         ChartDataPoint(x: 0, y: 10),
///         ChartDataPoint(x: 1, y: 20),
///       ],
///     ),
///   ],
///   theme: ChartTheme.light(),
/// )
/// ```
library;

// Models
export 'models/chart_data.dart';
export 'models/chart_interaction.dart';

// Theme
export 'theme/chart_theme.dart';

// Widgets
export 'widgets/line_chart_widget.dart';
export 'widgets/bar_chart_widget.dart';
export 'widgets/area_chart_widget.dart';
export 'widgets/stacked_area_chart_widget.dart';
export 'widgets/pie_chart_widget.dart';
export 'widgets/donut_chart_widget.dart';
export 'widgets/radial_chart_widget.dart';
export 'widgets/sparkline_chart_widget.dart';
export 'widgets/scatter_chart_widget.dart';
export 'widgets/bubble_chart_widget.dart';
export 'widgets/radar_chart_widget.dart';
export 'widgets/gauge_chart_widget.dart';
export 'widgets/chart_container.dart';
export 'widgets/chart_context_menu.dart';

// Providers
export 'providers/theme_provider.dart';

// Utilities
export 'utils/chart_interaction_helper.dart';
export 'utils/performance_utils.dart';
export 'utils/chart_cache.dart';
