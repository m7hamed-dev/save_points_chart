import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_chart.dart';
import 'package:save_points_chart_example/sample_data.dart';

class StepLineChartCard extends StatelessWidget {
  const StepLineChartCard({super.key, required this.theme});

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
              'Step Line Chart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StepLineChartWidget(
              dataSets: SampleData.generateMultiLineData(),
              config: ChartsConfig(theme: theme),
              title: 'Step Line Chart',
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
