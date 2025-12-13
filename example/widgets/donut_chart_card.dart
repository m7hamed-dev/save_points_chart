import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_chart.dart';

class DonutChartCard extends StatelessWidget {
  const DonutChartCard({super.key, required this.theme});

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
              'Donut Chart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            DonutChartWidget(
              data: const [
                PieData(
                  label: 'Product A',
                  value: 40,
                  color: Color(0xFF6366F1),
                ),
                PieData(
                  label: 'Product B',
                  value: 30,
                  color: Color(0xFF10B981),
                ),
                PieData(
                  label: 'Product C',
                  value: 30,
                  color: Color(0xFFEC4899),
                ),
              ],
              theme: theme,
              title: 'Product Sales',
              onSegmentTap: (segment, index, position) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Tapped: ${segment.label} - Value: ${segment.value}',
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
