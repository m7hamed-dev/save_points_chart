import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_chart.dart';

import 'widgets/area_chart_card.dart';
import 'widgets/bar_chart_card.dart';
import 'widgets/donut_chart_card.dart';
import 'widgets/line_chart_card.dart';
import 'widgets/pie_chart_card.dart';

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

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkMode ? ChartTheme.dark() : ChartTheme.light();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Points Chart Examples'),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          LineChartCard(theme: theme),
          const SizedBox(height: 16),
          AreaChartCard(theme: theme),
          const SizedBox(height: 16),
          BarChartCard(theme: theme),
          const SizedBox(height: 16),
          PieChartCard(theme: theme),
          const SizedBox(height: 16),
          DonutChartCard(theme: theme),
        ],
      ),
    );
  }
}
