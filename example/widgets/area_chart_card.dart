import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_chart.dart';

class AreaChartCard extends StatelessWidget {
  const AreaChartCard({super.key, required this.theme});

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
              'Area Chart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            // const SizedBox(height: 8),
            AreaChartWidget(
              dataSets: const [
                ChartDataSet(
                  color: Color(0xFF8B5CF6),
                  dataPoint: ChartDataPoint(x: 0, y: 100, label: 'Week 1'),
                ),
                ChartDataSet(
                  color: Color(0xFF8B5CF6),
                  dataPoint: ChartDataPoint(x: 1, y: 150, label: 'Week 2'),
                ),
                ChartDataSet(
                  color: Color(0xFF8B5CF6),
                  dataPoint: ChartDataPoint(x: 2, y: 120, label: 'Week 3'),
                ),
                ChartDataSet(
                  color: Color(0xFF8B5CF6),
                  dataPoint: ChartDataPoint(x: 3, y: 180, label: 'Week 4'),
                ),
                ChartDataSet(
                  color: Color(0xFF8B5CF6),
                  dataPoint: ChartDataPoint(x: 4, y: 200, label: 'Week 5'),
                ),
              ],
              config: ChartsConfig(theme: theme),
              title: 'Active Users',
              subtitle: 'Weekly growth',
              onPointTap: (point, datasetIndex, pointIndex, position) {
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
