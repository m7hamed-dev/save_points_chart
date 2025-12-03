import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_chart.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Save Points Chart Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark(useMaterial3: true),
      home: const ChartExamplePage(),
    );
  }
}

class ChartExamplePage extends StatefulWidget {
  const ChartExamplePage({super.key});

  @override
  State<ChartExamplePage> createState() => _ChartExamplePageState();
}

class _ChartExamplePageState extends State<ChartExamplePage> {
  bool _isDarkMode = false;

  @override
  Widget build(BuildContext context) {
    final theme = _isDarkMode ? ChartTheme.dark() : ChartTheme.light();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Save Points Chart Examples'),
        actions: [
          IconButton(
            icon: Icon(_isDarkMode ? Icons.light_mode : Icons.dark_mode),
            onPressed: () {
              setState(() {
                _isDarkMode = !_isDarkMode;
              });
            },
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Line Chart Example
          Card(
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
                        label: 'Sales',
                        color: const Color(0xFF6366F1),
                        dataPoints: [
                          const ChartDataPoint(x: 0, y: 20, label: 'Jan'),
                          const ChartDataPoint(x: 1, y: 35, label: 'Feb'),
                          const ChartDataPoint(x: 2, y: 28, label: 'Mar'),
                          const ChartDataPoint(x: 3, y: 45, label: 'Apr'),
                          const ChartDataPoint(x: 4, y: 50, label: 'May'),
                          const ChartDataPoint(x: 5, y: 42, label: 'Jun'),
                        ],
                      ),
                      ChartDataSet(
                        label: 'Revenue',
                        color: const Color(0xFF10B981),
                        dataPoints: [
                          const ChartDataPoint(x: 0, y: 15, label: 'Jan'),
                          const ChartDataPoint(x: 1, y: 30, label: 'Feb'),
                          const ChartDataPoint(x: 2, y: 25, label: 'Mar'),
                          const ChartDataPoint(x: 3, y: 40, label: 'Apr'),
                          const ChartDataPoint(x: 4, y: 45, label: 'May'),
                          const ChartDataPoint(x: 5, y: 38, label: 'Jun'),
                        ],
                      ),
                    ],
                    theme: theme,
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
          ),

          const SizedBox(height: 16),

          // Area Chart Example
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Area Chart',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  AreaChartWidget(
                    dataSets: [
                      ChartDataSet(
                        label: 'Users',
                        color: const Color(0xFF8B5CF6),
                        dataPoints: [
                          const ChartDataPoint(x: 0, y: 100, label: 'Week 1'),
                          const ChartDataPoint(x: 1, y: 150, label: 'Week 2'),
                          const ChartDataPoint(x: 2, y: 120, label: 'Week 3'),
                          const ChartDataPoint(x: 3, y: 180, label: 'Week 4'),
                          const ChartDataPoint(x: 4, y: 200, label: 'Week 5'),
                        ],
                      ),
                    ],
                    theme: theme,
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
          ),

          const SizedBox(height: 16),

          // Bar Chart Example
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Bar Chart',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 8),
                  BarChartWidget(
                    dataSets: [
                      ChartDataSet(
                        label: 'Quarterly Sales',
                        color: const Color(0xFFEC4899),
                        dataPoints: [
                          const ChartDataPoint(x: 0, y: 80, label: 'Q1'),
                          const ChartDataPoint(x: 1, y: 95, label: 'Q2'),
                          const ChartDataPoint(x: 2, y: 70, label: 'Q3'),
                          const ChartDataPoint(x: 3, y: 110, label: 'Q4'),
                        ],
                      ),
                    ],
                    theme: theme,
                    title: 'Quarterly Performance',
                    onBarTap: (point, datasetIndex, pointIndex, position) {
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
          ),

          const SizedBox(height: 16),

          // Pie Chart Example
          Card(
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
          ),

          const SizedBox(height: 16),

          // Donut Chart Example
          Card(
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
          ),
        ],
      ),
    );
  }
}
