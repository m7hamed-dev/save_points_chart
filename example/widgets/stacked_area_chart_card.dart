import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_chart.dart';

class StackedAreaChartCard extends StatelessWidget {
  const StackedAreaChartCard({super.key, required this.theme});

  final ChartTheme theme;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Stacked Area Chart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            StackedAreaChartWidget(
              dataSets: [
                ChartDataSet(
                  label: 'Mobile',
                  color: const Color(0xFF6366F1),
                  dataPoints: const [
                    ChartDataPoint(x: 0, y: 40, label: 'Q1'),
                    ChartDataPoint(x: 1, y: 60, label: 'Q2'),
                    ChartDataPoint(x: 2, y: 55, label: 'Q3'),
                    ChartDataPoint(x: 3, y: 70, label: 'Q4'),
                  ],
                ),
                ChartDataSet(
                  label: 'Web',
                  color: const Color(0xFF10B981),
                  dataPoints: const [
                    ChartDataPoint(x: 0, y: 35, label: 'Q1'),
                    ChartDataPoint(x: 1, y: 40, label: 'Q2'),
                    ChartDataPoint(x: 2, y: 45, label: 'Q3'),
                    ChartDataPoint(x: 3, y: 50, label: 'Q4'),
                  ],
                ),
                ChartDataSet(
                  label: 'Backend',
                  color: const Color(0xFFF59E0B),
                  dataPoints: const [
                    ChartDataPoint(x: 0, y: 25, label: 'Q1'),
                    ChartDataPoint(x: 1, y: 35, label: 'Q2'),
                    ChartDataPoint(x: 2, y: 30, label: 'Q3'),
                    ChartDataPoint(x: 3, y: 40, label: 'Q4'),
                  ],
                ),
              ],
              theme: theme,
              title: 'Stacked Revenue',
              subtitle: 'By platform (quarterly)',
              onPointTap: (point, datasetIndex, pointIndex, position) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      '${point.label ?? 'Point'} • ${widgetLabel(datasetIndex)}: ${point.y.toStringAsFixed(0)}',
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

  String widgetLabel(int datasetIndex) {
    switch (datasetIndex) {
      case 0:
        return 'Mobile';
      case 1:
        return 'Web';
      case 2:
        return 'Backend';
      default:
        return 'Series ${datasetIndex + 1}';
    }
  }
}
