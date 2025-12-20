import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_chart.dart';

class PyramidChartCard extends StatelessWidget {
  const PyramidChartCard({super.key, required this.theme});

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
              'Pyramid Chart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            PyramidChartWidget(
              data: SampleData.generatePieData(),
              theme: theme,
              title: 'Pyramid Chart',
              subtitle: 'Tap on segments to see details',
              onSegmentTap: (segment, segmentIndex, position) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Tapped: ${segment.label} - Value: ${segment.value.toStringAsFixed(1)}',
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

