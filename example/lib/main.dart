import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_charts.dart';

void main() => runApp(const ChartsDemoApp());

class ChartsDemoApp extends StatelessWidget {
  const ChartsDemoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'save_points_chart Demo',
      theme: ThemeData.dark(useMaterial3: true),
      home: const ChartsDemoPage(),
    );
  }
}

class ChartsDemoPage extends StatefulWidget {
  const ChartsDemoPage({super.key});

  @override
  State<ChartsDemoPage> createState() => _ChartsDemoPageState();
}

class _ChartsDemoPageState extends State<ChartsDemoPage> {
  var _showAllCharts = false;
  var _chartIndex = 0;

  static const _allChartTitles = [
    'Line',
    'Bar',
    'Pie',
    'Donut',
    'Area',
    'Scatter',
    'Radar',
    'Gauge',
    'Sparkline',
    'Stacked',
    'Waterfall',
    'Funnel',
    'Bubble',
  ];

  static const _desktopY = [220.0, 260.0, 240.0, 300.0, 320.0];
  static const _mobileY = [140.0, 180.0, 200.0, 210.0, 230.0];

  List<ChartPoint> get _monthPointsDesktop => List.generate(
    5,
    (i) => ChartPoint(x: i.toDouble(), y: _desktopY[i], label: _monthLabel(i)),
  );

  List<ChartPoint> get _monthPointsMobile => List.generate(
    5,
    (i) => ChartPoint(x: i.toDouble(), y: _mobileY[i], label: _monthLabel(i)),
  );

  static String _monthLabel(int i) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May'];
    return months[i];
  }

  ChartSeries get _desktopSeries =>
      ChartSeries(id: 'desktop', name: 'Desktop', points: _monthPointsDesktop);

  ChartSeries get _mobileSeries =>
      ChartSeries(id: 'mobile', name: 'Mobile', points: _monthPointsMobile);

  ChartConfig _cartesianConfig({
    required String title,
    required String subtitle,
    required List<ChartSeries> series,
  }) {
    return ChartConfig(
      title: title,
      subtitle: subtitle,
      xAxisTitle: 'Month',
      yAxisTitle: 'Users',
      series: series,
      semanticLabel: title,
    );
  }

  ChartConfig get _barOverviewConfig => _cartesianConfig(
    title: 'Traffic overview',
    subtitle: 'Desktop vs mobile by month',
    series: [_desktopSeries, _mobileSeries],
  );

  ChartConfig get _lineTrendConfig => _cartesianConfig(
    title: 'Traffic trend',
    subtitle: 'Jan – May · smooth spline',
    series: [_desktopSeries, _mobileSeries],
  );

  ChartConfig get _areaVolumeConfig => _cartesianConfig(
    title: 'Traffic volume',
    subtitle: 'Filled areas · last 5 months',
    series: [_desktopSeries, _mobileSeries],
  );

  ChartConfig get _pieDeviceConfig => ChartConfig(
    title: 'Traffic by device',
    subtitle: 'Share of total sessions',
    series: [
      ChartSeries(
        id: 'devices',
        name: 'Devices',
        points: const [
          ChartPoint(x: 0, y: 60, label: 'Desktop'),
          ChartPoint(x: 1, y: 30, label: 'Mobile'),
          ChartPoint(x: 2, y: 10, label: 'Tablet'),
        ],
      ),
    ],
  );

  ChartConfig get _scatterConfig => _lineTrendConfig;

  ChartConfig get _radarConfig => ChartConfig(
    title: 'Team skills',
    subtitle: 'Radar · six dimensions',
    xAxisTitle: 'Dimension',
    yAxisTitle: 'Score',
    series: [
      ChartSeries(
        id: 'skills',
        name: 'Team',
        points: const [
          ChartPoint(x: 0, y: 80, label: 'Speed'),
          ChartPoint(x: 1, y: 65, label: 'Quality'),
          ChartPoint(x: 2, y: 90, label: 'Design'),
          ChartPoint(x: 3, y: 70, label: 'Support'),
          ChartPoint(x: 4, y: 85, label: 'Delivery'),
          ChartPoint(x: 5, y: 75, label: 'Cost'),
        ],
      ),
    ],
  );

  ChartConfig get _gaugeConfig => ChartConfig(
    title: 'CPU usage',
    subtitle: 'Current utilization',
    yAxisTitle: 'Percent',
    series: [
      ChartSeries(
        id: 'cpu',
        name: 'CPU',
        points: const [ChartPoint(x: 0, y: 72)],
      ),
    ],
  );

  ChartConfig get _waterfallConfig => ChartConfig(
    title: 'P&L waterfall',
    subtitle: 'Step-by-step breakdown',
    xAxisTitle: 'Step',
    yAxisTitle: 'Amount',
    series: [
      ChartSeries(
        id: 'pnl',
        name: 'P&L',
        points: const [
          ChartPoint(
            x: 0,
            y: 100,
            label: 'Start',
            metadata: {kWaterfallTypeKey: 'absolute'},
          ),
          ChartPoint(x: 1, y: 30, label: 'Revenue'),
          ChartPoint(x: 2, y: -15, label: 'Costs'),
          ChartPoint(
            x: 3,
            y: 0,
            label: 'Subtotal',
            metadata: {kWaterfallTypeKey: 'subtotal'},
          ),
          ChartPoint(x: 4, y: 20, label: 'Tax'),
          ChartPoint(
            x: 5,
            y: 135,
            label: 'Total',
            metadata: {kWaterfallTypeKey: 'total'},
          ),
        ],
      ),
    ],
  );

  ChartConfig get _funnelConfig => ChartConfig(
    title: 'Sales funnel',
    subtitle: 'Conversion pipeline',
    yAxisTitle: 'Count',
    series: [
      ChartSeries(
        id: 'funnel',
        name: 'Pipeline',
        points: const [
          ChartPoint(x: 0, y: 1000, label: 'Visitors'),
          ChartPoint(x: 1, y: 600, label: 'Leads'),
          ChartPoint(x: 2, y: 300, label: 'Opportunities'),
          ChartPoint(x: 3, y: 120, label: 'Customers'),
        ],
      ),
    ],
  );

  ChartConfig get _bubbleConfig => ChartConfig(
    title: 'Regional bubbles',
    subtitle: 'Size = volume',
    xAxisTitle: 'X',
    yAxisTitle: 'Y',
    series: [
      ChartSeries(
        id: 'regions',
        name: 'Regions',
        points: [
          (10, 20, 40),
          (25, 35, 80),
          (40, 15, 25),
          (55, 45, 60),
          (70, 30, 50),
        ].toBubblePoints(),
      ),
    ],
  );

  ChartConfig get _stackedConfig => ChartConfig(
    title: 'Stacked products',
    subtitle: 'Product mix over time',
    xAxisTitle: 'Month',
    yAxisTitle: 'Units',
    series: [
      ChartSeries(
        id: 'a',
        name: 'Product A',
        points: [20, 25, 30, 28, 35].toChartPoints(),
      ),
      ChartSeries(
        id: 'b',
        name: 'Product B',
        points: [15, 18, 22, 20, 25].toChartPoints(),
      ),
      ChartSeries(
        id: 'c',
        name: 'Product C',
        points: [10, 12, 15, 14, 18].toChartPoints(),
      ),
    ],
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF060D1F),
      appBar: AppBar(
        title: const Text('save_points_chart'),
        backgroundColor: const Color(0xFF060D1F),
        actions: [
          TextButton.icon(
            onPressed: () => setState(() => _showAllCharts = !_showAllCharts),
            icon: Icon(_showAllCharts ? Icons.dashboard : Icons.view_list),
            label: Text(_showAllCharts ? 'Dashboard' : 'All charts'),
          ),
        ],
      ),
      body: _showAllCharts ? _buildAllCharts() : _buildDashboard(),
    );
  }

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _ExportableChartPanel(
                    config: _barOverviewConfig,
                    builder: (c) =>
                        BarChart(config: _barOverviewConfig, controller: c),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ExportableChartPanel(
                    config: _lineTrendConfig,
                    builder: (c) =>
                        LineChart(config: _lineTrendConfig, controller: c),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: _ExportableChartPanel(
                    config: _pieDeviceConfig,
                    builder: (c) =>
                        PieChart(config: _pieDeviceConfig, controller: c),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _ExportableChartPanel(
                    config: _areaVolumeConfig,
                    builder: (c) =>
                        AreaChart(config: _areaVolumeConfig, controller: c),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAllCharts() {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12),
          child: SegmentedButton<int>(
            segments: List.generate(
              _allChartTitles.length,
              (i) => ButtonSegment(value: i, label: Text(_allChartTitles[i])),
            ),
            selected: {_chartIndex},
            onSelectionChanged: (s) => setState(() => _chartIndex = s.first),
          ),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: _ExportableChartPanel(
              key: ValueKey(_chartIndex),
              config: _configForIndex(_chartIndex),
              builder: (c) => _buildChartByIndex(_chartIndex, c),
            ),
          ),
        ),
      ],
    );
  }

  ChartConfig _configForIndex(int index) => switch (index) {
    0 => _lineTrendConfig,
    1 => _barOverviewConfig,
    2 || 3 => _pieDeviceConfig,
    4 => _areaVolumeConfig,
    5 => _scatterConfig,
    6 => _radarConfig,
    7 => _gaugeConfig,
    8 => _lineTrendConfig,
    9 => _stackedConfig,
    10 => _waterfallConfig,
    11 => _funnelConfig,
    12 => _bubbleConfig,
    _ => _lineTrendConfig,
  };

  Widget _buildChartByIndex(int index, ChartWidgetController controller) {
    return switch (index) {
      0 => LineChart(config: _lineTrendConfig, controller: controller),
      1 => BarChart(config: _barOverviewConfig, controller: controller),
      2 => PieChart(config: _pieDeviceConfig, controller: controller),
      3 => PieChart(
        config: _pieDeviceConfig,
        controller: controller,
        isDonut: true,
      ),
      4 => AreaChart(config: _areaVolumeConfig, controller: controller),
      5 => ScatterChart(config: _scatterConfig, controller: controller),
      6 => RadarChart(config: _radarConfig, controller: controller),
      7 => GaugeChart(config: _gaugeConfig, controller: controller),
      8 => SparklineChart(config: _lineTrendConfig, controller: controller),
      9 => StackedAreaChart(config: _stackedConfig, controller: controller),
      10 => WaterfallChart(config: _waterfallConfig, controller: controller),
      11 => FunnelChart(config: _funnelConfig, controller: controller),
      12 => BubbleChart(config: _bubbleConfig, controller: controller),
      _ => LineChart(config: _lineTrendConfig, controller: controller),
    };
  }
}

class _ExportableChartPanel extends StatefulWidget {
  const _ExportableChartPanel({
    super.key,
    required this.config,
    required this.builder,
  });

  final ChartConfig config;
  final Widget Function(ChartWidgetController controller) builder;

  @override
  State<_ExportableChartPanel> createState() => _ExportableChartPanelState();
}

class _ExportableChartPanelState extends State<_ExportableChartPanel> {
  final _controller = ChartWidgetController();

  @override
  Widget build(BuildContext context) {
    return ChartCard(
      config: widget.config,
      controller: _controller,
      child: widget.builder(_controller),
    );
  }
}
