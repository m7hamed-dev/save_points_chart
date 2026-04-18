import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_chart.dart';
import 'package:save_points_chart_example/chart_demo_screen.dart';
import 'package:save_points_chart_example/widgets/area_chart_card.dart';
import 'package:save_points_chart_example/widgets/bar_chart_card.dart';
import 'package:save_points_chart_example/widgets/bubble_chart_card.dart';
import 'package:save_points_chart_example/widgets/data_test_page.dart';
import 'package:save_points_chart_example/widgets/donut_chart_card.dart';
import 'package:save_points_chart_example/widgets/funnel_chart_card.dart';
import 'package:save_points_chart_example/widgets/gauge_chart_card.dart';
import 'package:save_points_chart_example/widgets/line_chart_card.dart';
import 'package:save_points_chart_example/widgets/pie_chart_card.dart';
import 'package:save_points_chart_example/widgets/pyramid_chart_card.dart';
import 'package:save_points_chart_example/widgets/radar_chart_card.dart';
import 'package:save_points_chart_example/widgets/radial_chart_card.dart';
import 'package:save_points_chart_example/widgets/scatter_chart_card.dart';
import 'package:save_points_chart_example/widgets/sparkline_chart_card.dart';
import 'package:save_points_chart_example/widgets/spline_chart_card.dart';
import 'package:save_points_chart_example/widgets/stacked_area_chart_card.dart';
import 'package:save_points_chart_example/widgets/stacked_column_chart_card.dart';
import 'package:save_points_chart_example/widgets/step_line_chart_card.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ThemeProvider(child: _AppRoot());
  }
}

class _AppRoot extends StatelessWidget {
  const _AppRoot();

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    return MaterialApp(
      title: 'Save Points Chart Example',
      theme: ThemeData(colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple), useMaterial3: true),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple, brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: themeProvider.themeMode,
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
  int _tabIndex = 0;

  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final chartTheme = themeProvider.chartTheme;

    // The rich "Showcase" tab has its own Scaffold and navigation;
    // render it directly without our shell.
    if (_tabIndex == 2) {
      return Stack(
        children: [
          const ChartDemoScreen(),
          Positioned(
            right: 8,
            bottom: 80,
            child: _TabSwitcher(selected: _tabIndex, onChanged: (i) => setState(() => _tabIndex = i)),
          ),
        ],
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Points Chart Examples'),
        actions: [
          IconButton(
            icon: Icon(themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: themeProvider.toggleTheme,
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: switch (_tabIndex) {
        1 => DataTestPage(theme: chartTheme),
        _ => _SampleChartsList(theme: chartTheme),
      },
      bottomNavigationBar: NavigationBar(
        selectedIndex: _tabIndex,
        onDestinationSelected: (i) => setState(() => _tabIndex = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.auto_awesome), label: 'Samples'),
          NavigationDestination(icon: Icon(Icons.science), label: 'Data Test'),
          NavigationDestination(icon: Icon(Icons.dashboard_customize), label: 'Showcase'),
        ],
      ),
    );
  }
}

/// Mini navigation control shown over the Showcase screen so users can return.
class _TabSwitcher extends StatelessWidget {
  const _TabSwitcher({required this.selected, required this.onChanged});

  final int selected;
  final ValueChanged<int> onChanged;

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      color: Theme.of(context).colorScheme.surface,
      borderRadius: BorderRadius.circular(20),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              tooltip: 'Back to Samples',
              icon: const Icon(Icons.auto_awesome),
              isSelected: selected == 0,
              onPressed: () => onChanged(0),
            ),
            IconButton(
              tooltip: 'Data Test',
              icon: const Icon(Icons.science),
              isSelected: selected == 1,
              onPressed: () => onChanged(1),
            ),
            IconButton(
              tooltip: 'Showcase',
              icon: const Icon(Icons.dashboard_customize),
              isSelected: selected == 2,
              onPressed: () => onChanged(2),
            ),
          ],
        ),
      ),
    );
  }
}

class _SampleChartsList extends StatelessWidget {
  const _SampleChartsList({required this.theme});

  final ChartTheme theme;

  @override
  Widget build(BuildContext context) {
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
}
