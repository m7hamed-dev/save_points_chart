import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_chart.dart';
import 'widgets/area_chart_card.dart';
import 'widgets/bar_chart_card.dart';
import 'widgets/bubble_chart_card.dart';
import 'widgets/data_test_page.dart';
import 'widgets/donut_chart_card.dart';
import 'widgets/funnel_chart_card.dart';
import 'widgets/gauge_chart_card.dart';
import 'widgets/line_chart_card.dart';
import 'widgets/pie_chart_card.dart';
import 'widgets/pyramid_chart_card.dart';
import 'widgets/radar_chart_card.dart';
import 'widgets/radial_chart_card.dart';
import 'widgets/scatter_chart_card.dart';
import 'widgets/sparkline_chart_card.dart';
import 'widgets/spline_chart_card.dart';
import 'widgets/stacked_area_chart_card.dart';
import 'widgets/stacked_column_chart_card.dart';
import 'widgets/step_line_chart_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Save Points Chart Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const ChartExamplePage(),
    );
  }
}

class ChartExamplePage extends StatefulWidget {
  const ChartExamplePage({super.key});

  @override
  State<ChartExamplePage> createState() => _ChartExamplePageState();
}

class _ChartExamplePageState extends State<ChartExamplePage> {
  bool _isDarkMode = false;
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkMode ? ChartTheme.dark() : ChartTheme.light();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Points Chart Examples'),
        actions: [_iconChangeTheme()],
      ),
      body: _tabIndex == 0 ? _sampleCharts(theme) : DataTestPage(theme: theme),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.auto_awesome),
            label: 'Samples',
          ),
          NavigationDestination(icon: Icon(Icons.science), label: 'Data Test'),
        ],
      ),
    );
  }

  Widget _sampleCharts(ChartTheme theme) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        LineChartCard(theme: theme),
        const SizedBox(height: 16),
        AreaChartCard(theme: theme),
        const SizedBox(height: 16),
        StackedAreaChartCard(theme: theme),
        const SizedBox(height: 16),
        BarChartCard(theme: theme),
        const SizedBox(height: 16),
        StackedColumnChartCard(theme: theme),
        const SizedBox(height: 16),
        PieChartCard(theme: theme),
        const SizedBox(height: 16),
        DonutChartCard(theme: theme),
        const SizedBox(height: 16),
        PyramidChartCard(theme: theme),
        const SizedBox(height: 16),
        FunnelChartCard(theme: theme),
        const SizedBox(height: 16),
        RadialChartCard(theme: theme),
        const SizedBox(height: 16),
        SparklineChartCard(theme: theme),
        const SizedBox(height: 16),
        ScatterChartCard(theme: theme),
        const SizedBox(height: 16),
        BubbleChartCard(theme: theme),
        const SizedBox(height: 16),
        RadarChartCard(theme: theme),
        const SizedBox(height: 16),
        GaugeChartCard(theme: theme),
        const SizedBox(height: 16),
        SplineChartCard(theme: theme),
        const SizedBox(height: 16),
        StepLineChartCard(theme: theme),
      ],
    );
  }

  IconButton _iconChangeTheme() {
    return IconButton(
      icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
      onPressed: () {
        setState(() {
          _isDarkMode = !_isDarkMode;
        });
      },
    );
  }
}
