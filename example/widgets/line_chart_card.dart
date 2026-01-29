import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_chart.dart';

class LineChartCard extends StatelessWidget {
  const LineChartCard({super.key, required this.theme});

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
              'Line Chart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            LineChartWidget(
              dataSets: [
                ChartDataSet(
                  color: const Color(0xFF6366F1),
                  dataPoint: const ChartDataPoint(x: 0, y: 20, label: 'Jan'),
                ),
                ChartDataSet(
                  color: const Color(0xFF6366F1),
                  dataPoint: const ChartDataPoint(x: 1, y: 35, label: 'Feb'),
                ),
                ChartDataSet(
                  color: const Color(0xFF6366F1),
                  dataPoint: const ChartDataPoint(x: 2, y: 28, label: 'Mar'),
                ),
                ChartDataSet(
                  color: const Color(0xFF6366F1),
                  dataPoint: const ChartDataPoint(x: 3, y: 45, label: 'Apr'),
                ),
                ChartDataSet(
                  color: const Color(0xFF6366F1),
                  dataPoint: const ChartDataPoint(x: 4, y: 50, label: 'May'),
                ),
                ChartDataSet(
                  color: const Color(0xFF6366F1),
                  dataPoint: const ChartDataPoint(x: 5, y: 42, label: 'Jun'),
                ),
                ChartDataSet(
                  color: const Color(0xFF10B981),
                  dataPoint: const ChartDataPoint(x: 0, y: 15, label: 'Jan'),
                ),
                ChartDataSet(
                  color: const Color(0xFF10B981),
                  dataPoint: const ChartDataPoint(x: 1, y: 30, label: 'Feb'),
                ),
                ChartDataSet(
                  color: const Color(0xFF10B981),
                  dataPoint: const ChartDataPoint(x: 2, y: 25, label: 'Mar'),
                ),
                ChartDataSet(
                  color: const Color(0xFF10B981),
                  dataPoint: const ChartDataPoint(x: 3, y: 40, label: 'Apr'),
                ),
                ChartDataSet(
                  color: const Color(0xFF10B981),
                  dataPoint: const ChartDataPoint(x: 4, y: 45, label: 'May'),
                ),
                ChartDataSet(
                  color: const Color(0xFF10B981),
                  dataPoint: const ChartDataPoint(x: 5, y: 38, label: 'Jun'),
                ),
              ],
              config: ChartsConfig(theme: theme),
              title: 'Monthly Sales & Revenue',
              subtitle: 'Last 6 months',
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
