import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_chart.dart';
import 'package:save_points_chart/data/sample_data.dart';

class SparklineChartCard extends StatelessWidget {
  const SparklineChartCard({super.key, required this.theme});

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
              'Sparkline Chart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SparklineChartWidget(
              dataSets: SampleData.generateSparklineData(),
              config: ChartsConfig(theme: theme),
              title: 'Trend Analysis',
              subtitle: 'Tap on points to see details',
              onPointTap: (point, datasetIndex, pointIndex, position) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Tapped: ${point.label ?? 'Point'} - Value: ${point.y.toStringAsFixed(1)}',
                    ),
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
