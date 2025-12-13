import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';

/// Sample data generators for demonstration
class SampleData {
  static List<ChartDataPoint> generateLineData({
    int count = 10,
    double minY = 0,
    double maxY = 100,
  }) {
    return List.generate(count, (index) {
      return ChartDataPoint(
        x: index.toDouble(),
        y: minY + (maxY - minY) * (0.5 + 0.5 * (index % 3 == 0 ? 1.2 : 0.8)),
        label: 'Day ${index + 1}',
      );
    });
  }

  static List<ChartDataSet> generateMultiLineData() {
    return [
      ChartDataSet(
        label: 'Sales',
        color: const Color(0xFF6366F1),
        dataPoints: List.generate(12, (index) {
          return ChartDataPoint(
            x: index.toDouble(),
            y: 20 + (index * 5) + (index % 3) * 10,
            label: 'M${index + 1}',
          );
        }),
      ),
      ChartDataSet(
        label: 'Revenue',
        color: const Color(0xFF10B981),
        dataPoints: List.generate(12, (index) {
          return ChartDataPoint(
            x: index.toDouble(),
            y: 30 + (index * 3) + (index % 2) * 15,
            label: 'M${index + 1}',
          );
        }),
      ),
    ];
  }

  static List<ChartDataSet> generateBarData() {
    return [
      ChartDataSet(
        label: 'Monthly Sales',
        color: const Color(0xFF8B5CF6),
        dataPoints: List.generate(8, (index) {
          return ChartDataPoint(
            x: index.toDouble(),
            y: 50 + (index * 10) + (index % 3) * 20,
            label: 'Q${index + 1}',
          );
        }),
      ),
    ];
  }

  static List<PieData> generatePieData() {
    return [
      const PieData(label: 'Mobile', value: 35, color: Color(0xFF6366F1)),
      const PieData(label: 'Desktop', value: 25, color: Color(0xFF8B5CF6)),
      const PieData(label: 'Tablet', value: 20, color: Color(0xFFEC4899)),
      const PieData(label: 'Other', value: 20, color: Color(0xFF10B981)),
    ];
  }

  static List<ChartDataSet> generateRadialData() {
    return [
      ChartDataSet(
        label: 'Performance',
        color: const Color(0xFF6366F1),
        dataPoints: [
          const ChartDataPoint(x: 0, y: 80, label: 'Speed'),
          const ChartDataPoint(x: 1, y: 90, label: 'Quality'),
          const ChartDataPoint(x: 2, y: 70, label: 'Design'),
          const ChartDataPoint(x: 3, y: 85, label: 'Support'),
          const ChartDataPoint(x: 4, y: 75, label: 'Features'),
          const ChartDataPoint(x: 5, y: 95, label: 'Value'),
        ],
      ),
    ];
  }

  static ChartDataSet generateSparklineData() {
    return ChartDataSet(
      label: 'Trend',
      color: const Color(0xFF10B981),
      dataPoints: List.generate(20, (index) {
        return ChartDataPoint(
          x: index.toDouble(),
          y: 50 + (index % 5) * 10 + (index % 3 == 0 ? 15 : -5),
        );
      }),
    );
  }

  static List<ChartDataSet> generateUsersData() {
    final data = [
      const ChartDataPoint(x: 0, y: 100, label: 'mohamed'),
      const ChartDataPoint(x: 1, y: 200, label: 'ahmed'),
      const ChartDataPoint(x: 2, y: 300, label: 'ali'),
      const ChartDataPoint(x: 3, y: 400, label: 'omar'),
      const ChartDataPoint(x: 4, y: 500, label: 'khalid'),
    ];
    return [
      ChartDataSet(
        label: 'Users',
        color: const Color(0xFF6366F1),
        dataPoints: data,
      ),
    ];
  }

  static List<ChartDataSet> generateScatterData() {
    return [
      ChartDataSet(
        label: 'Product A',
        color: const Color(0xFF6366F1),
        dataPoints: List.generate(20, (index) {
          return ChartDataPoint(
            x: 10 + (index * 5) + (index % 3) * 2,
            y: 20 + (index * 3) + (index % 4) * 5,
            label: 'P${index + 1}',
          );
        }),
      ),
      ChartDataSet(
        label: 'Product B',
        color: const Color(0xFF10B981),
        dataPoints: List.generate(20, (index) {
          return ChartDataPoint(
            x: 15 + (index * 4) + (index % 2) * 3,
            y: 25 + (index * 4) + (index % 3) * 4,
            label: 'P${index + 1}',
          );
        }),
      ),
    ];
  }

  static List<BubbleDataSet> generateBubbleData() {
    return [
      BubbleDataSet(
        label: 'Region A',
        color: const Color(0xFF6366F1),
        dataPoints: List.generate(15, (index) {
          return BubbleDataPoint(
            x: 10 + (index * 8),
            y: 20 + (index * 6),
            size: 20 + (index % 5) * 10,
            label: 'R${index + 1}',
          );
        }),
      ),
      BubbleDataSet(
        label: 'Region B',
        color: const Color(0xFFEC4899),
        dataPoints: List.generate(15, (index) {
          return BubbleDataPoint(
            x: 15 + (index * 7),
            y: 25 + (index * 5),
            size: 25 + (index % 4) * 12,
            label: 'R${index + 1}',
          );
        }),
      ),
    ];
  }

  static List<RadarDataSet> generateRadarData() {
    return [
      RadarDataSet(
        label: 'Team A',
        color: const Color(0xFF6366F1),
        dataPoints: const [
          RadarDataPoint(label: 'Speed', value: 85),
          RadarDataPoint(label: 'Quality', value: 90),
          RadarDataPoint(label: 'Design', value: 75),
          RadarDataPoint(label: 'Support', value: 80),
          RadarDataPoint(label: 'Features', value: 70),
          RadarDataPoint(label: 'Value', value: 95),
        ],
      ),
      RadarDataSet(
        label: 'Team B',
        color: const Color(0xFF10B981),
        dataPoints: const [
          RadarDataPoint(label: 'Speed', value: 70),
          RadarDataPoint(label: 'Quality', value: 85),
          RadarDataPoint(label: 'Design', value: 90),
          RadarDataPoint(label: 'Support', value: 75),
          RadarDataPoint(label: 'Features', value: 85),
          RadarDataPoint(label: 'Value', value: 80),
        ],
      ),
    ];
  }
}
