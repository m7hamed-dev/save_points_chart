import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_chart.dart';

class GaugeChartCard extends StatelessWidget {
  const GaugeChartCard({super.key, required this.theme});

  final ChartTheme theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: .start,
          children: [
            const Text(
              'Gauge Chart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            GaugeChartWidget(
              value: 75,
              config: ChartsConfig(theme: theme),
              title: 'Performance Score',
              subtitle: 'Tap on chart to see details',
              centerLabel: 'Score',
              unit: '%',
              onChartTap: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Performance Score: 75%')),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
