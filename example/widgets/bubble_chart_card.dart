import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_chart.dart';

class BubbleChartCard extends StatelessWidget {
  const BubbleChartCard({super.key, required this.theme});

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
              'Bubble Chart',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            BubbleChartWidget(
              dataSets: SampleData.generateBubbleData(),
              theme: theme,
              title: 'Regional Performance',
              subtitle: 'Tap on bubbles to see details',
              onBubbleTap: (point, datasetIndex, pointIndex, position) {
                final bubblePoint = SampleData.generateBubbleData()[datasetIndex].dataPoints[pointIndex];
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Tapped: ${point.label ?? 'Bubble'} - Size: ${bubblePoint.size.toStringAsFixed(1)}',
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

