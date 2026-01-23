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
              'Empty data should show a message (widget requires at least one dataset)',
              Container(
                height: 300,
                padding: const EdgeInsets.all(16.0),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.info_outline,
                        size: 48,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Empty Dataset',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'LineChartWidget requires at least one data set.\n'
                        'This is expected behavior to ensure valid chart rendering.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[500],
                        ),
                      ),
                    ],
                  ),
                ),
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
      ChartDataSet(color: Colors.red, label: 'Point 0', dataPoint: const ChartDataPoint(x: 0, y: 10)),
      ChartDataSet(color: Colors.red, label: 'Point 1', dataPoint: const ChartDataPoint(x: 1, y: double.nan)),
      ChartDataSet(color: Colors.red, label: 'Point 2', dataPoint: const ChartDataPoint(x: 2, y: 20)),
      ChartDataSet(color: Colors.red, label: 'Point 3', dataPoint: const ChartDataPoint(x: double.nan, y: 30)),
      ChartDataSet(color: Colors.red, label: 'Point 4', dataPoint: const ChartDataPoint(x: 4, y: 40)),
      ChartDataSet(color: Colors.red, label: 'Point 5', dataPoint: const ChartDataPoint(x: 5, y: double.nan)),
      ChartDataSet(color: Colors.red, label: 'Point 6', dataPoint: const ChartDataPoint(x: 6, y: 50)),
    ];
  }

  List<ChartDataSet> _createInfiniteDataset() {
    return [
      ChartDataSet(color: Colors.orange, label: 'Point 0', dataPoint: const ChartDataPoint(x: 0, y: 10)),
      ChartDataSet(color: Colors.orange, label: 'Point 1', dataPoint: const ChartDataPoint(x: 1, y: double.infinity)),
      ChartDataSet(color: Colors.orange, label: 'Point 2', dataPoint: const ChartDataPoint(x: 2, y: 20)),
      ChartDataSet(color: Colors.orange, label: 'Point 3', dataPoint: const ChartDataPoint(x: double.negativeInfinity, y: 30)),
      ChartDataSet(color: Colors.orange, label: 'Point 4', dataPoint: const ChartDataPoint(x: 4, y: 40)),
      ChartDataSet(color: Colors.orange, label: 'Point 5', dataPoint: const ChartDataPoint(x: 5, y: double.infinity)),
      ChartDataSet(color: Colors.orange, label: 'Point 6', dataPoint: const ChartDataPoint(x: 6, y: 50)),
    ];
  }

  List<ChartDataSet> _createZeroRangeDataset() {
    return [
      ...List.generate(5, (i) => ChartDataSet(
            color: Colors.blue,
            label: 'Point $i',
            dataPoint: ChartDataPoint(x: i.toDouble(), y: 50.0),
          )),
      ...List.generate(5, (i) => ChartDataSet(
            color: Colors.green,
            label: 'Point $i',
            dataPoint: ChartDataPoint(x: 0.0, y: 30.0 + i * 10.0),
          )),
    ];
  }

  List<ChartDataSet> _createSinglePointDataset() {
    return [
      ChartDataSet(
        color: Colors.purple,
        label: 'Single Point',
        dataPoint: const ChartDataPoint(x: 0, y: 50),
      ),
    ];
  }

  List<ChartDataSet> _createMixedDataset() {
    return [
      ChartDataSet(color: Colors.teal, label: 'Point 0', dataPoint: const ChartDataPoint(x: 0, y: 10)),
      ChartDataSet(color: Colors.teal, label: 'Point 1', dataPoint: const ChartDataPoint(x: 1, y: double.nan)),
      ChartDataSet(color: Colors.teal, label: 'Point 2', dataPoint: const ChartDataPoint(x: 2, y: 20)),
      ChartDataSet(color: Colors.teal, label: 'Point 3', dataPoint: const ChartDataPoint(x: 3, y: double.infinity)),
      ChartDataSet(color: Colors.teal, label: 'Point 4', dataPoint: const ChartDataPoint(x: 4, y: 30)),
      ChartDataSet(color: Colors.teal, label: 'Point 5', dataPoint: const ChartDataPoint(x: 5, y: double.negativeInfinity)),
      ChartDataSet(color: Colors.teal, label: 'Point 6', dataPoint: const ChartDataPoint(x: 6, y: 40)),
      ChartDataSet(color: Colors.teal, label: 'Point 7', dataPoint: const ChartDataPoint(x: double.nan, y: 50)),
      ChartDataSet(color: Colors.teal, label: 'Point 8', dataPoint: const ChartDataPoint(x: 8, y: 60)),
      ChartDataSet(color: Colors.teal, label: 'Point 9', dataPoint: const ChartDataPoint(x: 9, y: 70)),
    ];
  }

  List<ChartDataSet> _createNegativeDataset() {
    return List.generate(8, (i) {
      return ChartDataSet(
        color: Colors.indigo,
        label: 'Point $i',
        dataPoint: ChartDataPoint(
          x: i.toDouble(),
          y: 50 + (i - 4) * 10, // Values from 10 to 90, crossing 0
        ),
      );
    });
  }

  List<ChartDataSet> _createLargeValueDataset() {
    return List.generate(6, (i) {
      return ChartDataSet(
        color: Colors.deepOrange,
        label: 'Point $i',
        dataPoint: ChartDataPoint(
          x: i.toDouble(),
          y: 1e10 + i * 1e9, // Very large numbers
        ),
      );
    });
  }
}
