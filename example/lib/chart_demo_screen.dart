import 'package:flutter/material.dart';
import 'package:save_points_chart_example/sample_data.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/providers/theme_provider.dart';
import 'package:save_points_chart_example/data_test_screen.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/theme/charts_config.dart';
import 'package:save_points_chart/widgets/area_chart_widget.dart';
import 'package:save_points_chart/widgets/bar_chart_widget.dart';
import 'package:save_points_chart/widgets/bubble_chart_widget.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';
import 'package:save_points_chart/widgets/chart_legend_scope.dart';
import 'package:save_points_chart/widgets/chart_pan_zoom_scope.dart';
import 'package:save_points_chart/widgets/donut_chart_widget.dart';
import 'package:save_points_chart/widgets/funnel_chart_widget.dart';
import 'package:save_points_chart/widgets/gauge_chart_widget.dart';
import 'package:save_points_chart/widgets/line_chart_widget.dart';
import 'package:save_points_chart/widgets/pie_chart_widget.dart';
import 'package:save_points_chart/widgets/pyramid_chart_widget.dart';
import 'package:save_points_chart/widgets/radar_chart_widget.dart';
import 'package:save_points_chart/widgets/radial_chart_widget.dart';
import 'package:save_points_chart/widgets/scatter_chart_widget.dart';
import 'package:save_points_chart/widgets/sparkline_chart_widget.dart';
import 'package:save_points_chart/widgets/spline_chart_widget.dart';
import 'package:save_points_chart/widgets/stacked_column_chart_widget.dart';
import 'package:save_points_chart/widgets/step_line_chart_widget.dart';

/// Breakpoint above which the demo switches from a drawer to a side rail.
const double _kWideLayoutBreakpoint = 900.0;

/// Stylistic mode applied to the demo charts from the app bar menu.
enum _StyleMode {
  defaultStyle('Default'),
  glassmorphism('Glassmorphism'),
  neumorphism('Neumorphism');

  const _StyleMode(this.label);
  final String label;
}

/// Declarative description of one chart in the demo.
class _ChartTab {
  const _ChartTab({required this.label, required this.icon, required this.builder});

  final String label;
  final IconData icon;
  final Widget Function(ChartTheme theme, ChartsConfig config) builder;
}

class ChartDemoScreen extends StatefulWidget {
  const ChartDemoScreen({super.key});

  @override
  State<ChartDemoScreen> createState() => _ChartDemoScreenState();
}

class _ChartDemoScreenState extends State<ChartDemoScreen> {
  int _selectedIndex = 0;
  _StyleMode _styleMode = _StyleMode.defaultStyle;
  bool _isLoading = false;
  bool _isError = false;

  bool get _useGlassmorphism => _styleMode == _StyleMode.glassmorphism;
  bool get _useNeumorphism => _styleMode == _StyleMode.neumorphism;

  late final List<_ChartTab> _tabs = [
    _ChartTab(label: 'Line Chart', icon: Icons.show_chart, builder: _buildLineChart),
    _ChartTab(label: 'Bar Chart', icon: Icons.bar_chart, builder: _buildBarChart),
    _ChartTab(label: 'Area Chart', icon: Icons.area_chart, builder: _buildAreaChart),
    _ChartTab(label: 'Pie Chart', icon: Icons.pie_chart, builder: _buildPieChart),
    _ChartTab(label: 'Donut Chart', icon: Icons.donut_large, builder: _buildDonutChart),
    _ChartTab(label: 'Radial Chart', icon: Icons.radar, builder: _buildRadialChart),
    _ChartTab(label: 'Sparkline', icon: Icons.trending_up, builder: _buildSparklineChart),
    _ChartTab(label: 'Scatter Chart', icon: Icons.scatter_plot, builder: _buildScatterChart),
    _ChartTab(label: 'Bubble Chart', icon: Icons.bubble_chart, builder: _buildBubbleChart),
    _ChartTab(label: 'Radar Chart', icon: Icons.polyline, builder: _buildRadarChart),
    _ChartTab(label: 'Gauge Chart', icon: Icons.speed, builder: _buildGaugeChart),
    _ChartTab(label: 'Spline Chart', icon: Icons.timeline, builder: _buildSplineChart),
    _ChartTab(label: 'Step Line', icon: Icons.stacked_line_chart, builder: _buildStepLineChart),
    _ChartTab(label: 'Stacked Column', icon: Icons.view_column, builder: _buildStackedColumnChart),
    _ChartTab(label: 'Pyramid Chart', icon: Icons.change_history, builder: _buildPyramidChart),
    _ChartTab(label: 'Funnel Chart', icon: Icons.filter_alt, builder: _buildFunnelChart),
    _ChartTab(label: 'Data Test', icon: Icons.science, builder: _buildDataTest),
  ];

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final chartTheme = themeProvider.chartTheme;
    final chartsConfig = ChartsConfig(
      theme: chartTheme,
      useGlassmorphism: _useGlassmorphism,
      useNeumorphism: _useNeumorphism,
      errorMessage: _isError ? 'Unable to load chart data. Please try again.' : null,
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth >= _kWideLayoutBreakpoint;
        final body = _tabs[_selectedIndex].builder(chartTheme, chartsConfig);

        return Scaffold(
          appBar: AppBar(
            title: const Text('Modern Charts'),
            actions: [
              IconButton(
                icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
                onPressed: themeProvider.toggleTheme,
                tooltip: 'Toggle Theme',
              ),
              PopupMenuButton<_StyleMode>(
                icon: const Icon(Icons.more_vert),
                tooltip: 'Chart style',
                onSelected: (mode) => setState(() => _styleMode = mode),
                itemBuilder: (context) => [
                  for (final mode in _StyleMode.values)
                    PopupMenuItem<_StyleMode>(
                      value: mode,
                      child: Row(
                        children: [
                          Icon(mode == _styleMode ? Icons.check_box : Icons.check_box_outline_blank),
                          const SizedBox(width: 8),
                          Text(mode.label),
                        ],
                      ),
                    ),
                ],
              ),
            ],
          ),
          drawer: isWide ? null : _Drawer(tabs: _tabs, selectedIndex: _selectedIndex, onTap: _onTabSelected),
          body: isWide
              ? Row(
                  children: [
                    _SideRail(tabs: _tabs, selectedIndex: _selectedIndex, onTap: _onTabSelected),
                    const VerticalDivider(width: 1),
                    Expanded(child: body),
                  ],
                )
              : body,
        );
      },
    );
  }

  void _onTabSelected(int index) {
    setState(() => _selectedIndex = index);
  }

  // ── Shared handlers ─────────────────────────────────────────────────────

  void _showPointMenu({
    required ChartDataPoint point,
    required int datasetIndex,
    required int elementIndex,
    required Offset position,
    required ChartTheme theme,
    required String datasetLabel,
    String? userLabel,
    String exportMessage = 'Exporting data point…',
    String shareMessage = 'Sharing data point…',
    String? detailExtra,
  }) {
    ChartContextMenuHelper.show(
      context,
      point: point,
      segment: null,
      position: position,
      datasetIndex: datasetIndex,
      elementIndex: elementIndex,
      datasetLabel: datasetLabel,
      theme: theme,
      useGlassmorphism: _useGlassmorphism,
      useNeumorphism: _useNeumorphism,
      onViewDetails: () => _showDetailsDialog(
        context,
        point: point,
        datasetLabel: detailExtra != null ? '$datasetLabel – $detailExtra' : datasetLabel,
        userLabel: userLabel,
      ),
      onExport: () => _showSnack(exportMessage),
      onShare: () => _showSnack(shareMessage),
    );
  }

  void _showSegmentMenu({
    required PieData segment,
    required int segmentIndex,
    required Offset position,
    required ChartTheme theme,
    Color? backgroundColor,
    bool backgroundBlur = false,
  }) {
    ChartContextMenuHelper.show(
      context,
      point: null,
      segment: segment,
      position: position,
      elementIndex: segmentIndex,
      theme: theme,
      backgroundColor: backgroundColor,
      backgroundBlur: backgroundBlur,
      useGlassmorphism: _useGlassmorphism,
      useNeumorphism: _useNeumorphism,
      onViewDetails: () => _showDetailsDialog(context, segment: segment),
      onExport: () => _showSnack('Exporting ${segment.label} data…'),
      onShare: () => _showSnack('Sharing ${segment.label} data…'),
    );
  }

  void _showDetailsDialog(
    BuildContext context, {
    ChartDataPoint? point,
    PieData? segment,
    String? datasetLabel,
    String? userLabel,
  }) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(point != null ? 'Point Details' : 'Segment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (point != null) ...[
              if (userLabel != null)
                Text('Label: $userLabel', style: const TextStyle(fontWeight: FontWeight.bold)),
              if (datasetLabel != null) Text('Dataset: $datasetLabel'),
              const SizedBox(height: 8),
              Text('X Value: ${point.x.toStringAsFixed(2)}'),
              Text('Y Value: ${point.y.toStringAsFixed(2)}'),
            ] else if (segment != null) ...[
              Text('Label: ${segment.label}', style: const TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Text('Value: ${segment.value.toStringAsFixed(2)}'),
              Text('Color: ${segment.color}'),
            ],
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Chart builders ──────────────────────────────────────────────────────

  Widget _scroll({required List<Widget> children}) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: children,
      ),
    );
  }

  Widget _buildLineChart(ChartTheme theme, ChartsConfig config) {
    final lineDataSets = SampleData.generateMultiLineData();
    final usersDataSets = SampleData.generateUsersData();

    return _scroll(
      children: [
        // Showcase: legend toggle + pan/zoom composed together.
        ChartLegendScope(
          dataSets: lineDataSets,
          seriesLabelFor: (color, group) =>
              color == const Color(0xFF6366F1) ? 'Sales' : 'Revenue',
          builder: (context, visible) => ChartPanZoomScope(
            maxScale: 6,
            panAxis: PanAxis.horizontal,
            showControls: true,
            child: LineChartWidget(
              dataSets: visible,
              config: config,
              title: 'Sales & Revenue Trend',
              subtitle: 'Tap a legend to hide a series · pinch to zoom',
              isLoading: _isLoading,
              isError: _isError,
              onPointTap: (point, datasetIndex, pointIndex, position) {
                if (datasetIndex < 0 || datasetIndex >= visible.length) return;
                _showPointMenu(
                  point: point,
                  datasetIndex: datasetIndex,
                  elementIndex: pointIndex,
                  position: position,
                  theme: theme,
                  datasetLabel: visible[datasetIndex].dataPoint.label ?? '',
                );
              },
            ),
          ),
        ),
        const SizedBox(height: 24),
        _StateControls(
          isLoading: _isLoading,
          isError: _isError,
          onToggleLoading: () => setState(() {
            _isLoading = !_isLoading;
            _isError = false;
          }),
          onToggleError: () => setState(() {
            _isError = !_isError;
            _isLoading = false;
          }),
        ),
        const SizedBox(height: 24),
        LineChartWidget(
          config: config,
          title: 'Temperature Over Time',
          subtitle: 'Without grid lines',
          dataSets: SampleData.generateLineData(count: 8, maxY: 40)
              .map((point) => ChartDataSet(color: const Color(0xFFEC4899), dataPoint: point))
              .toList(),
        ),
        const SizedBox(height: 24),
        LineChartWidget(
          dataSets: usersDataSets,
          config: config,
          title: 'Users by Name',
          subtitle: 'User data visualization – Tap on points!',
          onPointTap: (point, datasetIndex, pointIndex, position) {
            if (datasetIndex < 0 || datasetIndex >= usersDataSets.length) return;
            final userLabel = point.label ?? 'User ${point.x.toInt() + 1}';
            _showPointMenu(
              point: point,
              datasetIndex: datasetIndex,
              elementIndex: pointIndex,
              position: position,
              theme: theme,
              datasetLabel: usersDataSets[datasetIndex].dataPoint.label ?? '',
              userLabel: userLabel,
              exportMessage: 'Exporting $userLabel data…',
              shareMessage: 'Sharing $userLabel data…',
            );
          },
        ),
      ],
    );
  }

  Widget _buildBarChart(ChartTheme theme, ChartsConfig config) {
    final barDataSets = SampleData.generateBarData();
    final usersDataSets = SampleData.generateUsersData();
    final multiLineDataSets = SampleData.generateMultiLineData();

    return _scroll(
      children: [
        BarChartWidget(
          barRounded: false,
          dataSets: barDataSets,
          config: config,
          title: 'Monthly Sales',
          subtitle: 'Quarterly breakdown – Tap on bars!',
          onBarTap: (point, datasetIndex, barIndex, position) {
            if (datasetIndex < 0 || datasetIndex >= barDataSets.length) return;
            _showPointMenu(
              point: point,
              datasetIndex: datasetIndex,
              elementIndex: barIndex,
              position: position,
              theme: theme,
              datasetLabel: barDataSets[datasetIndex].dataPoint.label ?? '',
              exportMessage: 'Exporting bar data…',
              shareMessage: 'Sharing bar data…',
            );
          },
        ),
        const SizedBox(height: 24),
        BarChartWidget(
          barRounded: false,
          dataSets: multiLineDataSets,
          config: config,
          title: 'Grouped Bar Chart',
          subtitle: 'Multiple datasets comparison',
          isGrouped: true,
        ),
        const SizedBox(height: 24),
        BarChartWidget(
          barRounded: false,
          dataSets: usersDataSets,
          config: config,
          title: 'Users by Name',
          subtitle: 'User data visualization – Tap on bars!',
          onBarTap: (point, datasetIndex, barIndex, position) {
            if (datasetIndex < 0 || datasetIndex >= usersDataSets.length) return;
            final userLabel = point.label ?? 'User ${point.x.toInt() + 1}';
            _showPointMenu(
              point: point,
              datasetIndex: datasetIndex,
              elementIndex: barIndex,
              position: position,
              theme: theme,
              datasetLabel: usersDataSets[datasetIndex].dataPoint.label ?? '',
              userLabel: userLabel,
              exportMessage: 'Exporting $userLabel data…',
              shareMessage: 'Sharing $userLabel data…',
            );
          },
        ),
      ],
    );
  }

  Widget _buildAreaChart(ChartTheme theme, ChartsConfig config) {
    final areaDataSets = SampleData.generateMultiLineData();
    final usersDataSets = SampleData.generateUsersData();

    return _scroll(
      children: [
        AreaChartWidget(
          dataSets: areaDataSets,
          config: config,
          title: 'Revenue Area Chart',
          subtitle: 'Filled area visualization – Tap on points!',
          onPointTap: (point, datasetIndex, pointIndex, position) {
            if (datasetIndex < 0 || datasetIndex >= areaDataSets.length) return;
            _showPointMenu(
              point: point,
              datasetIndex: datasetIndex,
              elementIndex: pointIndex,
              position: position,
              theme: theme,
              datasetLabel: areaDataSets[datasetIndex].dataPoint.label ?? '',
            );
          },
        ),
        const SizedBox(height: 24),
        AreaChartWidget(
          dataSets: SampleData.generateLineData(count: 15)
              .map((point) => ChartDataSet(color: const Color(0xFF10B981), dataPoint: point))
              .toList(),
          config: config,
          title: 'Growth Metrics',
          subtitle: 'Single dataset area chart',
        ),
        const SizedBox(height: 24),
        AreaChartWidget(
          dataSets: usersDataSets,
          config: config,
          title: 'Users Growth Trend',
          subtitle: 'User data as area chart – Tap on points!',
          onPointTap: (point, datasetIndex, pointIndex, position) {
            if (datasetIndex < 0 || datasetIndex >= usersDataSets.length) return;
            final userLabel = point.label ?? 'User ${point.x.toInt() + 1}';
            _showPointMenu(
              point: point,
              datasetIndex: datasetIndex,
              elementIndex: pointIndex,
              position: position,
              theme: theme,
              datasetLabel: usersDataSets[datasetIndex].dataPoint.label ?? '',
              userLabel: userLabel,
              exportMessage: 'Exporting $userLabel data…',
              shareMessage: 'Sharing $userLabel data…',
            );
          },
        ),
      ],
    );
  }

  Widget _buildPieChart(ChartTheme theme, ChartsConfig config) {
    final pieData = SampleData.generatePieData();
    return _scroll(
      children: [
        PieChartWidget(
          data: pieData,
          config: config,
          title: 'Device Distribution',
          subtitle: 'User devices breakdown – Tap on segments!',
          onSegmentTap: (segment, segmentIndex, position) => _showSegmentMenu(
            segment: segment,
            segmentIndex: segmentIndex,
            position: position,
            theme: theme,
            backgroundColor: pieData[segmentIndex].color,
            backgroundBlur: true,
          ),
        ),
        const SizedBox(height: 24),
        PieChartWidget(
          data: pieData,
          legendLayout: Axis.vertical,
          config: config,
          title: 'Device Distribution',
          subtitle: 'Vertical legend – Tap on segments!',
          onSegmentTap: (segment, segmentIndex, position) => _showSegmentMenu(
            segment: segment,
            segmentIndex: segmentIndex,
            position: position,
            theme: theme,
            backgroundColor: pieData[segmentIndex].color,
          ),
        ),
      ],
    );
  }

  Widget _buildDonutChart(ChartTheme theme, ChartsConfig config) {
    final pieData = SampleData.generatePieData();
    return _scroll(
      children: [
        DonutChartWidget(
          data: pieData,
          config: config,
          title: 'Sales Distribution',
          subtitle: 'Donut chart with center value – Tap on segments!',
          onSegmentTap: (segment, segmentIndex, position) =>
              _showSegmentMenu(segment: segment, segmentIndex: segmentIndex, position: position, theme: theme),
        ),
        const SizedBox(height: 24),
        DonutChartWidget(
          data: pieData,
          config: config,
          legendLayout: Axis.vertical,
          title: 'Sales Distribution',
          subtitle: 'Vertical legend – Tap on segments!',
          onSegmentTap: (segment, segmentIndex, position) =>
              _showSegmentMenu(segment: segment, segmentIndex: segmentIndex, position: position, theme: theme),
        ),
        const SizedBox(height: 24),
        DonutChartWidget(
          config: config,
          legendLayout: Axis.vertical,
          title: 'Sales Distribution',
          subtitle: 'With custom circle size',
          data: SampleData.generatePieData(showValue: false, showLabel: false, circleSize: 80.0),
        ),
      ],
    );
  }

  Widget _buildRadialChart(ChartTheme theme, ChartsConfig config) {
    final radialDataSets = SampleData.generateRadialData();
    return _scroll(
      children: [
        RadialChartWidget(
          dataSets: radialDataSets,
          config: config,
          title: 'Performance Metrics',
          subtitle: 'Multi-dimensional analysis – Tap on points!',
          onPointTap: (point, datasetIndex, pointIndex, position) {
            if (datasetIndex < 0 || datasetIndex >= radialDataSets.length) return;
            _showPointMenu(
              point: point,
              datasetIndex: datasetIndex,
              elementIndex: pointIndex,
              position: position,
              theme: theme,
              datasetLabel: radialDataSets[datasetIndex].dataPoint.label ?? '',
              exportMessage: 'Exporting radial data point…',
              shareMessage: 'Sharing radial data point…',
            );
          },
        ),
      ],
    );
  }

  Widget _buildSparklineChart(ChartTheme theme, ChartsConfig config) {
    final sparklineDataSets = SampleData.generateSparklineData();
    final positiveTrend = List.generate(
      15,
      (i) => ChartDataSet(
        color: const Color(0xFF10B981),
        dataPoint: ChartDataPoint(x: i.toDouble(), y: 50 + i * 2, label: 'Point ${i + 1}'),
      ),
    );
    final negativeTrend = List.generate(
      15,
      (i) => ChartDataSet(
        color: const Color(0xFFEF4444),
        dataPoint: ChartDataPoint(x: i.toDouble(), y: 100 - i * 2),
      ),
    );

    void onTap(List<ChartDataSet> sets, ChartDataPoint point, int di, int pi, Offset pos, {String? suffix}) {
      if (di < 0 || di >= sets.length) return;
      _showPointMenu(
        point: point,
        datasetIndex: di,
        elementIndex: pi,
        position: pos,
        theme: theme,
        datasetLabel: sets[di].dataPoint.label ?? '',
        exportMessage: suffix != null ? 'Exporting $suffix data…' : 'Exporting sparkline data point…',
        shareMessage: suffix != null ? 'Sharing $suffix data…' : 'Sharing sparkline data point…',
      );
    }

    return _scroll(
      children: [
        SparklineChartWidget(
          dataSets: sparklineDataSets,
          config: config,
          title: 'Trend Analysis',
          subtitle: 'Compact sparkline visualization – Tap on points!',
          onPointTap: (p, di, pi, pos) => onTap(sparklineDataSets, p, di, pi, pos),
        ),
        const SizedBox(height: 24),
        Row(
          children: [
            Expanded(
              child: SparklineChartWidget(
                dataSets: positiveTrend,
                config: config,
                title: 'Positive Trend',
                onPointTap: (p, di, pi, pos) => onTap(positiveTrend, p, di, pi, pos, suffix: 'positive trend'),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SparklineChartWidget(
                dataSets: negativeTrend,
                config: config,
                title: 'Negative Trend',
                onPointTap: (p, di, pi, pos) => onTap(negativeTrend, p, di, pi, pos, suffix: 'negative trend'),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildScatterChart(ChartTheme theme, ChartsConfig config) {
    final scatterDataSets = SampleData.generateScatterData();
    return _scroll(
      children: [
        ScatterChartWidget(
          dataSets: scatterDataSets,
          config: config,
          title: 'Product Correlation',
          subtitle: 'Scatter plot showing relationship – Tap on points!',
          onPointTap: (point, datasetIndex, pointIndex, position) {
            if (datasetIndex < 0 || datasetIndex >= scatterDataSets.length) return;
            _showPointMenu(
              point: point,
              datasetIndex: datasetIndex,
              elementIndex: pointIndex,
              position: position,
              theme: theme,
              datasetLabel: scatterDataSets[datasetIndex].dataPoint.label ?? '',
            );
          },
        ),
      ],
    );
  }

  Widget _buildBubbleChart(ChartTheme theme, ChartsConfig config) {
    final bubbleDataSets = SampleData.generateBubbleData();
    return _scroll(
      children: [
        BubbleChartWidget(
          dataSets: bubbleDataSets,
          config: config,
          title: 'Regional Performance',
          subtitle: 'Bubble chart with size dimension – Tap on bubbles!',
          onBubbleTap: (point, datasetIndex, pointIndex, position) {
            if (datasetIndex < 0 || datasetIndex >= bubbleDataSets.length) return;
            final dataSet = bubbleDataSets[datasetIndex];
            if (pointIndex < 0 || pointIndex >= dataSet.dataPoints.length) return;
            final bubblePoint = dataSet.dataPoints[pointIndex];
            _showPointMenu(
              point: point,
              datasetIndex: datasetIndex,
              elementIndex: pointIndex,
              position: position,
              theme: theme,
              datasetLabel: bubblePoint.label ?? '',
              detailExtra: 'Size: ${bubblePoint.size.toStringAsFixed(1)}',
            );
          },
        ),
      ],
    );
  }

  Widget _buildRadarChart(ChartTheme theme, ChartsConfig config) {
    final radarDataSets = SampleData.generateRadarData();
    return _scroll(
      children: [
        RadarChartWidget(
          dataSets: radarDataSets,
          config: config,
          title: 'Team Performance Comparison',
          subtitle: 'Multi-dimensional radar chart – Tap on points!',
          onPointTap: (point, datasetIndex, pointIndex, position) {
            if (datasetIndex < 0 || datasetIndex >= radarDataSets.length) return;
            final dataSet = radarDataSets[datasetIndex];
            if (pointIndex < 0 || pointIndex >= dataSet.dataPoints.length) return;
            _showPointMenu(
              point: point,
              datasetIndex: datasetIndex,
              elementIndex: pointIndex,
              position: position,
              theme: theme,
              datasetLabel: dataSet.dataPoints[pointIndex].label,
            );
          },
        ),
      ],
    );
  }

  Widget _buildGaugeChart(ChartTheme theme, ChartsConfig config) {
    const gauges = [
      (value: 75.0, title: 'Performance Score', subtitle: 'Current performance metric – Tap on chart!', label: 'Score'),
      (value: 85.0, title: 'Customer Satisfaction', subtitle: 'Customer satisfaction rating – Tap on chart!', label: 'Satisfaction'),
      (value: 60.0, title: 'Sales Target', subtitle: 'Progress towards sales goal – Tap on chart!', label: 'Progress'),
    ];
    return _scroll(
      children: [
        for (final g in gauges) ...[
          GaugeChartWidget(
            value: g.value,
            config: config,
            title: g.title,
            subtitle: g.subtitle,
            centerLabel: g.label,
            unit: '%',
            onChartTap: () => _showDetailsDialog(
              context,
              point: ChartDataPoint(x: 0, y: g.value, label: g.title),
              datasetLabel: g.title,
            ),
          ),
          const SizedBox(height: 24),
        ],
      ],
    );
  }

  Widget _buildSplineChart(ChartTheme theme, ChartsConfig config) {
    final splineDataSets = SampleData.generateMultiLineData();
    return _scroll(
      children: [
        SplineChartWidget(
          dataSets: splineDataSets,
          config: config,
          title: 'Smooth Spline Chart',
          subtitle: 'Spline curves with smooth bezier interpolation – Tap on points!',
          onPointTap: (point, datasetIndex, pointIndex, position) {
            if (datasetIndex < 0 || datasetIndex >= splineDataSets.length) return;
            _showPointMenu(
              point: point,
              datasetIndex: datasetIndex,
              elementIndex: pointIndex,
              position: position,
              theme: theme,
              datasetLabel: splineDataSets[datasetIndex].dataPoint.label ?? '',
            );
          },
        ),
      ],
    );
  }

  Widget _buildStepLineChart(ChartTheme theme, ChartsConfig config) {
    final stepLineDataSets = SampleData.generateMultiLineData();
    return _scroll(
      children: [
        StepLineChartWidget(
          dataSets: stepLineDataSets,
          config: config,
          title: 'Step Line Chart',
          subtitle: 'Step function visualization – Tap on points!',
          onPointTap: (point, datasetIndex, pointIndex, position) {
            if (datasetIndex < 0 || datasetIndex >= stepLineDataSets.length) return;
            _showPointMenu(
              point: point,
              datasetIndex: datasetIndex,
              elementIndex: pointIndex,
              position: position,
              theme: theme,
              datasetLabel: stepLineDataSets[datasetIndex].dataPoint.label ?? '',
            );
          },
        ),
      ],
    );
  }

  Widget _buildStackedColumnChart(ChartTheme theme, ChartsConfig config) {
    final stackedBarDataSets = SampleData.generateBarData();
    return _scroll(
      children: [
        StackedColumnChartWidget(
          dataSets: stackedBarDataSets,
          config: config,
          title: 'Stacked Column Chart',
          subtitle: 'Multiple datasets stacked vertically – Tap on bars!',
          onBarTap: (point, datasetIndex, barIndex, position) {
            if (datasetIndex < 0 || datasetIndex >= stackedBarDataSets.length) return;
            _showPointMenu(
              point: point,
              datasetIndex: datasetIndex,
              elementIndex: barIndex,
              position: position,
              theme: theme,
              datasetLabel: stackedBarDataSets[datasetIndex].dataPoint.label ?? '',
            );
          },
        ),
      ],
    );
  }

  Widget _buildPyramidChart(ChartTheme theme, ChartsConfig config) {
    return _scroll(
      children: [
        PyramidChartWidget(
          data: SampleData.generatePieData(),
          config: config,
          title: 'Pyramid Chart',
          subtitle: 'Hierarchical data visualization – Tap on segments!',
          onSegmentTap: (segment, segmentIndex, position) =>
              _showSegmentMenu(segment: segment, segmentIndex: segmentIndex, position: position, theme: theme),
        ),
      ],
    );
  }

  Widget _buildFunnelChart(ChartTheme theme, ChartsConfig config) {
    return _scroll(
      children: [
        FunnelChartWidget(
          data: SampleData.generatePieData(),
          config: config,
          title: 'Funnel Chart',
          subtitle: 'Sales funnel and conversion tracking – Tap on segments!',
          onSegmentTap: (segment, segmentIndex, position) =>
              _showSegmentMenu(segment: segment, segmentIndex: segmentIndex, position: position, theme: theme),
        ),
      ],
    );
  }

  Widget _buildDataTest(ChartTheme theme, ChartsConfig config) {
    return DataTestScreen(theme: theme);
  }
}

// ── Navigation widgets ────────────────────────────────────────────────────

class _Drawer extends StatelessWidget {
  const _Drawer({required this.tabs, required this.selectedIndex, required this.onTap});

  final List<_ChartTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          const _DrawerHeader(),
          for (var i = 0; i < tabs.length; i++) ...[
            if (tabs[i].label == 'Data Test') const Divider(),
            _DrawerItem(
              icon: tabs[i].icon,
              title: tabs[i].label,
              isSelected: selectedIndex == i,
              onTap: () {
                onTap(i);
                Navigator.of(context).pop();
              },
            ),
          ],
        ],
      ),
    );
  }
}

class _DrawerHeader extends StatelessWidget {
  const _DrawerHeader();

  @override
  Widget build(BuildContext context) {
    return DrawerHeader(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF6366F1), Color(0xFF8B5CF6), Color(0xFFEC4899)],
          stops: [0.0, 0.5, 1.0],
        ),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFF6366F1).withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: Colors.white.withValues(alpha: 0.3), width: 1.5),
            ),
            child: const Icon(Icons.show_chart, size: 32, color: Colors.white),
          ),
          const SizedBox(height: 12),
          const Text(
            'Modern Charts',
            style: TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
              shadows: [Shadow(color: Colors.black26, offset: Offset(0, 2), blurRadius: 4)],
            ),
          ),
          const SizedBox(height: 2),
          Text(
            '17+ Chart Types',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 12,
              fontWeight: FontWeight.w500,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  const _DrawerItem({
    required this.icon,
    required this.title,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6) : Colors.transparent,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected ? theme.colorScheme.primary.withValues(alpha: 0.15) : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected ? theme.colorScheme.primary : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
            color: isSelected ? theme.colorScheme.onPrimaryContainer : theme.colorScheme.onSurface,
          ),
        ),
        selected: isSelected,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        onTap: onTap,
      ),
    );
  }
}

class _SideRail extends StatelessWidget {
  const _SideRail({required this.tabs, required this.selectedIndex, required this.onTap});

  final List<_ChartTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 260,
      child: Column(
        children: [
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
              itemCount: tabs.length,
              itemBuilder: (context, i) => _DrawerItem(
                icon: tabs[i].icon,
                title: tabs[i].label,
                isSelected: selectedIndex == i,
                onTap: () => onTap(i),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StateControls extends StatelessWidget {
  const _StateControls({
    required this.isLoading,
    required this.isError,
    required this.onToggleLoading,
    required this.onToggleError,
  });

  final bool isLoading;
  final bool isError;
  final VoidCallback onToggleLoading;
  final VoidCallback onToggleError;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ElevatedButton.icon(
          onPressed: onToggleLoading,
          icon: Icon(isLoading ? Icons.stop : Icons.refresh),
          label: Text(isLoading ? 'Stop Loading' : 'Show Loading'),
        ),
        const SizedBox(width: 8),
        ElevatedButton.icon(
          onPressed: onToggleError,
          icon: Icon(isError ? Icons.check_circle : Icons.error_outline),
          label: Text(isError ? 'Hide Error' : 'Show Error'),
        ),
      ],
    );
  }
}
