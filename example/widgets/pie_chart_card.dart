import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_chart.dart';

class PieChartCard extends StatelessWidget {
  const PieChartCard({super.key, required this.theme});

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
              'Pie Chart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            PieChartWidget(
              data: const [
                PieData(
                  label: 'Mobile',
                  value: 35,
                  color: Color(0xFF6366F1),
                ),
                PieData(
                  label: 'Desktop',
                  value: 25,
                  color: Color(0xFF8B5CF6),
                ),
                PieData(
                  label: 'Tablet',
                  value: 20,
                  color: Color(0xFFEC4899),
                ),
                PieData(
                  label: 'Other',
                  value: 20,
                  color: Color(0xFF10B981),
                ),
              ],
              theme: theme,
              title: 'Device Distribution',
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

