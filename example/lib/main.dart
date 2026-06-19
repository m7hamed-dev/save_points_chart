import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_charts.dart';

void main() => runApp(const ChartsDemoApp());

class ChartsDemoApp extends StatefulWidget {
  const ChartsDemoApp({super.key});

  @override
  State<ChartsDemoApp> createState() => _ChartsDemoAppState();
}

class _ChartsDemoAppState extends State<ChartsDemoApp> {
  var _isDark = true;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'save_points_chart Demo',
      theme: ThemeData.light(useMaterial3: true),
      darkTheme: ThemeData.dark(useMaterial3: true),
      themeMode: _isDark ? ThemeMode.dark : ThemeMode.light,
      home: ChartsDemoPage(
        isDark: _isDark,
        onToggleTheme: () => setState(() => _isDark = !_isDark),
      ),
    );
  }
}

class ChartsDemoPage extends StatefulWidget {
  const ChartsDemoPage({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  final bool isDark;
  final VoidCallback onToggleTheme;

  @override
  State<ChartsDemoPage> createState() => _ChartsDemoPageState();
}

class _ChartsDemoPageState extends State<ChartsDemoPage> {
  var _showAllCharts = true;
  var _chartIndex = 0;

  bool get _isDark => widget.isDark;

  // Chart palette follows the app theme.
  ChartTheme get _chartTheme =>
      _isDark ? ChartTheme.dark() : ChartTheme.light();

  // App chrome colors.
  Color get _bg => _isDark ? const Color(0xFF060D1F) : const Color(0xFFF4F6FB);
  Color get _surface => _isDark ? const Color(0xFF0B1430) : Colors.white;
  Color get _onSurface =>
      _isDark ? Colors.white : const Color(0xFF1A1A1A);
  Color get _onSurfaceMuted =>
      _isDark ? Colors.white70 : const Color(0xFF5B6472);

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
      backgroundColor: _bg,
      drawer: _buildDrawer(context),
      appBar: AppBar(
        title: Text(
          _showAllCharts ? _allChartTitles[_chartIndex] : 'save_points_chart',
          style: TextStyle(color: _onSurface),
        ),
        backgroundColor: _bg,
        foregroundColor: _onSurface,
        actions: [
          IconButton(
            tooltip: _isDark ? 'Switch to light' : 'Switch to dark',
            onPressed: widget.onToggleTheme,
            icon: Icon(_isDark ? Icons.light_mode : Icons.dark_mode),
          ),
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

  Widget _buildDrawer(BuildContext context) {
    final accent = _chartTheme.seriesColor(0);
    return Drawer(
      backgroundColor: _surface,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 16),
              child: Row(
                children: [
                  Icon(Icons.insert_chart_outlined, color: _onSurface),
                  const SizedBox(width: 12),
                  Text(
                    'All charts',
                    style: TextStyle(
                      color: _onSurface,
                      fontSize: 18,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
            Divider(height: 1, color: _onSurfaceMuted.withValues(alpha: 0.3)),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: _allChartTitles.length,
                itemBuilder: (context, i) {
                  final selected = _showAllCharts && i == _chartIndex;
                  return ListTile(
                    selected: selected,
                    selectedTileColor: accent.withValues(alpha: 0.12),
                    leading: Icon(
                      _chartIcon(i),
                      color: selected ? accent : _onSurfaceMuted,
                    ),
                    title: Text(
                      _allChartTitles[i],
                      style: TextStyle(
                        color: selected ? _onSurface : _onSurfaceMuted,
                        fontWeight: selected
                            ? FontWeight.w600
                            : FontWeight.w400,
                      ),
                    ),
                    onTap: () {
                      setState(() {
                        _chartIndex = i;
                        _showAllCharts = true;
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _chartIcon(int index) => switch (index) {
    0 => Icons.show_chart, // Line
    1 => Icons.bar_chart, // Bar
    2 => Icons.pie_chart, // Pie
    3 => Icons.donut_large, // Donut
    4 => Icons.area_chart, // Area
    5 => Icons.scatter_plot, // Scatter
    6 => Icons.radar, // Radar
    7 => Icons.speed, // Gauge
    8 => Icons.timeline, // Sparkline
    9 => Icons.stacked_line_chart, // Stacked
    10 => Icons.waterfall_chart, // Waterfall
    11 => Icons.filter_alt_outlined, // Funnel
    12 => Icons.bubble_chart, // Bubble
    _ => Icons.insert_chart_outlined,
  };

  Widget _buildDashboard() {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Column(
        children: [
          Expanded(
            child: Row(
              children: [
                Expanded(
                  child: BarChart(
                    config: _barOverviewConfig,
                    theme: _chartTheme,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: LineChart(
                    config: _lineTrendConfig,
                    theme: _chartTheme,
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
                  child: PieChart(config: _pieDeviceConfig, theme: _chartTheme),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AreaChart(
                    config: _areaVolumeConfig,
                    theme: _chartTheme,
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
    return Padding(
      padding: const EdgeInsets.all(16),
      child: KeyedSubtree(
        key: ValueKey(_chartIndex),
        child: _buildChartByIndex(_chartIndex),
      ),
    );
  }

  Widget _buildChartByIndex(int index) {
    final theme = _chartTheme;
    return switch (index) {
      0 => LineChart(config: _lineTrendConfig, theme: theme),
      1 => BarChart(config: _barOverviewConfig, theme: theme),
      2 => PieChart(config: _pieDeviceConfig, theme: theme),
      3 => PieChart(config: _pieDeviceConfig, isDonut: true, theme: theme),
      4 => AreaChart(config: _areaVolumeConfig, theme: theme),
      5 => ScatterChart(config: _scatterConfig, theme: theme),
      6 => RadarChart(config: _radarConfig, theme: theme),
      7 => GaugeChart(config: _gaugeConfig, theme: theme),
      8 => SparklineChart(config: _lineTrendConfig, theme: theme),
      9 => StackedAreaChart(config: _stackedConfig, theme: theme),
      10 => WaterfallChart(config: _waterfallConfig, theme: theme),
      11 => FunnelChart(config: _funnelConfig, theme: theme),
      12 => BubbleChart(config: _bubbleConfig, theme: theme),
      _ => LineChart(config: _lineTrendConfig, theme: theme),
    };
  }
}
