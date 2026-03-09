import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_chart.dart';

class BarChartCard extends StatelessWidget {
  const BarChartCard({super.key, required this.theme});

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
              'Bar Chart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BarChartWidget(
              dataSets: [
                ChartDataSet(
                  color: const Color(0xFFEC4899),
                  dataPoint: ChartDataPoint(x: 0, y: 80, label: 'Q1'),
                ),
                ChartDataSet(
                  color: const Color(0xFFEC4899),
                  dataPoint: ChartDataPoint(x: 1, y: 95, label: 'Q2'),
                ),
                ChartDataSet(
                  color: const Color(0xFFEC4899),
                  dataPoint: ChartDataPoint(x: 2, y: 70, label: 'Q3'),
                ),
                ChartDataSet(
                  color: const Color(0xFFEC4899),
                  dataPoint: ChartDataPoint(x: 3, y: 110, label: 'Q4'),
                ),
              ],
              config: ChartsConfig(theme: theme),
              title: 'Quarterly Performance',
              onBarTap: (point, datasetIndex, pointIndex, position) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Tapped: ${point.label ?? 'Point'} - Value: ${point.y.toStringAsFixed(0)}',
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
