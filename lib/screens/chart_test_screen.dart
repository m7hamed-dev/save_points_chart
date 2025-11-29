import 'package:flutter/material.dart';
import 'package:save_points_chart/providers/theme_provider.dart';
import 'package:save_points_chart/widgets/line_chart_widget.dart';
import 'package:save_points_chart/widgets/bar_chart_widget.dart';
import 'package:save_points_chart/widgets/area_chart_widget.dart';
import 'package:save_points_chart/models/chart_data.dart';

/// Test screen to verify NaN and edge case handling
class ChartTestScreen extends StatefulWidget {
  const ChartTestScreen({super.key});

  @override
  State<ChartTestScreen> createState() => _ChartTestScreenState();
}

class _ChartTestScreenState extends State<ChartTestScreen> {
  @override
  Widget build(BuildContext context) {
    final themeProvider = ThemeProvider.of(context);
    final chartTheme = themeProvider.chartTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chart NaN & Edge Cases Test'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildTestSection(
              'Test 1: NaN Values in Data Points',
              'Data with NaN values should be filtered out',
              LineChartWidget(
                dataSets: _createNaNDataset(),
                theme: chartTheme,
                title: 'NaN Values Test',
                subtitle: 'Should handle NaN gracefully',
              ),
            ),
            const SizedBox(height: 24),
            _buildTestSection(
              'Test 2: Infinite Values',
              'Data with infinite values should be filtered out',
              LineChartWidget(
                dataSets: _createInfiniteDataset(),
                theme: chartTheme,
                title: 'Infinite Values Test',
                subtitle: 'Should handle Infinity gracefully',
              ),
            ),
            const SizedBox(height: 24),
            _buildTestSection(
              'Test 3: Zero Range (All Same Values)',
              'When all X or Y values are the same',
              LineChartWidget(
                dataSets: _createZeroRangeDataset(),
                theme: chartTheme,
                title: 'Zero Range Test',
                subtitle: 'Should handle zero range gracefully',
              ),
            ),
            const SizedBox(height: 24),
            _buildTestSection(
              'Test 4: Empty Dataset',
              'Empty data should not crash',
              LineChartWidget(
                dataSets: [],
                theme: chartTheme,
                title: 'Empty Dataset Test',
                subtitle: 'Should handle empty data gracefully',
              ),
            ),
            const SizedBox(height: 24),
            _buildTestSection(
              'Test 5: Single Point',
              'Dataset with only one point',
              LineChartWidget(
                dataSets: _createSinglePointDataset(),
                theme: chartTheme,
                title: 'Single Point Test',
                subtitle: 'Should handle single point',
              ),
            ),
            const SizedBox(height: 24),
            _buildTestSection(
              'Test 6: Mixed Valid and Invalid',
              'Mix of valid, NaN, and infinite values',
              LineChartWidget(
                dataSets: _createMixedDataset(),
                theme: chartTheme,
                title: 'Mixed Values Test',
                subtitle: 'Should filter invalid and show valid',
              ),
            ),
            const SizedBox(height: 24),
            _buildTestSection(
              'Test 7: Negative Values',
              'Data with negative values',
              LineChartWidget(
                dataSets: _createNegativeDataset(),
                theme: chartTheme,
                title: 'Negative Values Test',
                subtitle: 'Should handle negative values',
              ),
            ),
            const SizedBox(height: 24),
            _buildTestSection(
              'Test 8: Very Large Values',
              'Data with very large numbers',
              LineChartWidget(
                dataSets: _createLargeValueDataset(),
                theme: chartTheme,
                title: 'Large Values Test',
                subtitle: 'Should handle large values',
              ),
            ),
            const SizedBox(height: 24),
            _buildTestSection(
              'Test 9: Bar Chart with NaN',
              'Bar chart with invalid values',
              BarChartWidget(
                dataSets: _createNaNDataset(),
                theme: chartTheme,
                title: 'Bar Chart NaN Test',
                subtitle: 'Should handle NaN in bar chart',
              ),
            ),
            const SizedBox(height: 24),
            _buildTestSection(
              'Test 10: Area Chart with Edge Cases',
              'Area chart with various edge cases',
              AreaChartWidget(
                dataSets: _createMixedDataset(),
                theme: chartTheme,
                title: 'Area Chart Edge Cases',
                subtitle: 'Should handle all edge cases',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTestSection(String title, String description, Widget chart) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              height: 300,
              child: chart,
            ),
          ],
        ),
      ),
    );
  }

  List<ChartDataSet> _createNaNDataset() {
    return [
      ChartDataSet(
        label: 'Data with NaN',
        color: Colors.red,
        dataPoints: [
          ChartDataPoint(x: 0, y: 10),
          ChartDataPoint(x: 1, y: double.nan),
          ChartDataPoint(x: 2, y: 20),
          ChartDataPoint(x: double.nan, y: 30),
          ChartDataPoint(x: 4, y: 40),
          ChartDataPoint(x: 5, y: double.nan),
          ChartDataPoint(x: 6, y: 50),
        ],
      ),
    ];
  }

  List<ChartDataSet> _createInfiniteDataset() {
    return [
      ChartDataSet(
        label: 'Data with Infinity',
        color: Colors.orange,
        dataPoints: [
          ChartDataPoint(x: 0, y: 10),
          ChartDataPoint(x: 1, y: double.infinity),
          ChartDataPoint(x: 2, y: 20),
          ChartDataPoint(x: double.negativeInfinity, y: 30),
          ChartDataPoint(x: 4, y: 40),
          ChartDataPoint(x: 5, y: double.infinity),
          ChartDataPoint(x: 6, y: 50),
        ],
      ),
    ];
  }

  List<ChartDataSet> _createZeroRangeDataset() {
    return [
      ChartDataSet(
        label: 'Zero Range (Same Values)',
        color: Colors.blue,
        dataPoints: List.generate(5, (i) {
          return ChartDataPoint(x: i.toDouble(), y: 50.0);
        }),
      ),
      ChartDataSet(
        label: 'Zero X Range',
        color: Colors.green,
        dataPoints: List.generate(5, (i) {
          return ChartDataPoint(x: 0.0, y: 30.0 + i * 10.0);
        }),
      ),
    ];
  }

  List<ChartDataSet> _createSinglePointDataset() {
    return [
      ChartDataSet(
        label: 'Single Point',
        color: Colors.purple,
        dataPoints: [
          ChartDataPoint(x: 0, y: 50),
        ],
      ),
    ];
  }

  List<ChartDataSet> _createMixedDataset() {
    return [
      ChartDataSet(
        label: 'Mixed Valid/Invalid',
        color: Colors.teal,
        dataPoints: [
          ChartDataPoint(x: 0, y: 10),
          ChartDataPoint(x: 1, y: double.nan),
          ChartDataPoint(x: 2, y: 20),
          ChartDataPoint(x: 3, y: double.infinity),
          ChartDataPoint(x: 4, y: 30),
          ChartDataPoint(x: 5, y: double.negativeInfinity),
          ChartDataPoint(x: 6, y: 40),
          ChartDataPoint(x: double.nan, y: 50),
          ChartDataPoint(x: 8, y: 60),
          ChartDataPoint(x: 9, y: 70),
        ],
      ),
    ];
  }

  List<ChartDataSet> _createNegativeDataset() {
    return [
      ChartDataSet(
        label: 'Negative Values',
        color: Colors.indigo,
        dataPoints: List.generate(8, (i) {
          return ChartDataPoint(
            x: i.toDouble(),
            y: 50 + (i - 4) * 10, // Values from 10 to 90, crossing 0
          );
        }),
      ),
    ];
  }

  List<ChartDataSet> _createLargeValueDataset() {
    return [
      ChartDataSet(
        label: 'Very Large Values',
        color: Colors.deepOrange,
        dataPoints: List.generate(6, (i) {
          return ChartDataPoint(
            x: i.toDouble(),
            y: 1e10 + i * 1e9, // Very large numbers
          );
        }),
      ),
    ];
  }
}
