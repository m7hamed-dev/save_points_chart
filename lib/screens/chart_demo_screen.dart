import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/theme_provider.dart';
import '../theme/chart_theme.dart';
import '../widgets/line_chart_widget.dart';
import '../widgets/bar_chart_widget.dart';
import '../widgets/area_chart_widget.dart';
import '../widgets/pie_chart_widget.dart';
import '../widgets/donut_chart_widget.dart';
import '../widgets/radial_chart_widget.dart';
import '../widgets/sparkline_chart_widget.dart';
import '../models/chart_data.dart';
import '../data/sample_data.dart';

class ChartDemoScreen extends StatefulWidget {
  const ChartDemoScreen({super.key});

  @override
  State<ChartDemoScreen> createState() => _ChartDemoScreenState();
}

class _ChartDemoScreenState extends State<ChartDemoScreen> {
  int _selectedIndex = 0;
  bool _useGlassmorphism = false;
  bool _useNeumorphism = false;
  bool _isLoading = false;
  bool _isError = false;

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final chartTheme = themeProvider.chartTheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Modern Charts'),
        actions: [
          IconButton(
            icon: Icon(
              themeProvider.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => themeProvider.toggleTheme(),
            tooltip: 'Toggle Theme',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.more_vert),
            onSelected: (value) {
              setState(() {
                if (value == 'glassmorphism') {
                  _useGlassmorphism = !_useGlassmorphism;
                  _useNeumorphism = false;
                } else if (value == 'neumorphism') {
                  _useNeumorphism = !_useNeumorphism;
                  _useGlassmorphism = false;
                } else {
                  _useGlassmorphism = false;
                  _useNeumorphism = false;
                }
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'glassmorphism',
                child: Row(
                  children: [
                    Icon(
                      _useGlassmorphism
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                    const SizedBox(width: 8),
                    const Text('Glassmorphism'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'neumorphism',
                child: Row(
                  children: [
                    Icon(
                      _useNeumorphism
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                    const SizedBox(width: 8),
                    const Text('Neumorphism'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'default',
                child: Row(
                  children: [
                    Icon(
                      (!_useGlassmorphism && !_useNeumorphism)
                          ? Icons.check_box
                          : Icons.check_box_outline_blank,
                    ),
                    const SizedBox(width: 8),
                    const Text('Default'),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _selectedIndex,
            onDestinationSelected: (index) {
              setState(() {
                _selectedIndex = index;
              });
            },
            labelType: NavigationRailLabelType.all,
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.show_chart),
                selectedIcon: Icon(Icons.show_chart),
                label: Text('Line'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.bar_chart),
                selectedIcon: Icon(Icons.bar_chart),
                label: Text('Bar'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.area_chart),
                selectedIcon: Icon(Icons.area_chart),
                label: Text('Area'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.pie_chart),
                selectedIcon: Icon(Icons.pie_chart),
                label: Text('Pie'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.donut_large),
                selectedIcon: Icon(Icons.donut_large),
                label: Text('Donut'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.radar),
                selectedIcon: Icon(Icons.radar),
                label: Text('Radial'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.trending_up),
                selectedIcon: Icon(Icons.trending_up),
                label: Text('Sparkline'),
              ),
            ],
          ),
          const VerticalDivider(thickness: 1, width: 1),
          Expanded(child: _buildChartContent(chartTheme)),
        ],
      ),
    );
  }

  Widget _buildChartContent(ChartTheme chartTheme) {
    switch (_selectedIndex) {
      case 0:
        return _buildLineChart(chartTheme);
      case 1:
        return _buildBarChart(chartTheme);
      case 2:
        return _buildAreaChart(chartTheme);
      case 3:
        return _buildPieChart(chartTheme);
      case 4:
        return _buildDonutChart(chartTheme);
      case 5:
        return _buildRadialChart(chartTheme);
      case 6:
        return _buildSparklineChart(chartTheme);
      default:
        return _buildLineChart(chartTheme);
    }
  }

  Widget _buildLineChart(ChartTheme chartTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LineChartWidget(
            dataSets: SampleData.generateMultiLineData(),
            theme: chartTheme,
            title: 'Sales & Revenue Trend',
            subtitle: 'Last 12 months performance - Hover or tap on points!',
            showLabel: true,
            useGlassmorphism: _useGlassmorphism,
            useNeumorphism: _useNeumorphism,
            isLoading: _isLoading,
            isError: _isError,
            errorMessage: _isError
                ? 'Unable to load chart data. Please try again.'
                : null,
            onPointTap: (point, datasetIndex, pointIndex) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tapped point: X=${point.x.toStringAsFixed(1)}, Y=${point.y.toStringAsFixed(1)}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
            onPointHover: (point, datasetIndex, pointIndex) {
              // Hover effect is automatically shown on the chart
              // Points will highlight when you hover over them
              if (point != null) {
                // Optional: You can add custom tooltip or other UI feedback here
              }
            },
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isLoading = !_isLoading;
                    _isError = false;
                  });
                },
                icon: Icon(_isLoading ? Icons.stop : Icons.refresh),
                label: Text(_isLoading ? 'Stop Loading' : 'Show Loading'),
              ),
              const SizedBox(width: 8),
              ElevatedButton.icon(
                onPressed: () {
                  setState(() {
                    _isError = !_isError;
                    _isLoading = false;
                  });
                },
                icon: Icon(_isError ? Icons.check_circle : Icons.error_outline),
                label: Text(_isError ? 'Hide Error' : 'Show Error'),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LineChartWidget(
            dataSets: [
              ChartDataSet(
                label: 'Temperature',
                color: const Color(0xFFEC4899),
                dataPoints: SampleData.generateLineData(count: 24, maxY: 40),
              ),
            ],
            theme: chartTheme.copyWith(showGrid: false),
            title: 'Temperature Over Time',
            subtitle: 'Without grid lines',
            useGlassmorphism: _useGlassmorphism,
            useNeumorphism: _useNeumorphism,
          ),
          const SizedBox(height: 24),
          LineChartWidget(
            dataSets: SampleData.generateUsersData(),
            theme: chartTheme,
            title: 'Users by Name (No Labels)',
            subtitle: 'User data without axis labels',
            showLabel: true,
            useGlassmorphism: _useGlassmorphism,
            useNeumorphism: _useNeumorphism,
            onPointTap: (point, datasetIndex, pointIndex) {
              final userLabel = point.label ?? 'User ${point.x.toInt() + 1}';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tapped: $userLabel - Value=${point.y.toStringAsFixed(0)}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          LineChartWidget(
            dataSets: SampleData.generateUsersData(),
            theme: chartTheme,
            title: 'Users by Name',
            subtitle: 'User data visualization - Tap on points!',
            useGlassmorphism: _useGlassmorphism,
            useNeumorphism: _useNeumorphism,
            onPointTap: (point, datasetIndex, pointIndex) {
              final userLabel = point.label ?? 'User ${point.x.toInt() + 1}';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tapped: $userLabel - Value=${point.y.toStringAsFixed(0)}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(ChartTheme chartTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BarChartWidget(
            dataSets: SampleData.generateBarData(),
            theme: chartTheme,
            title: 'Monthly Sales',
            subtitle: 'Quarterly breakdown - Tap on bars!',
            useGlassmorphism: _useGlassmorphism,
            useNeumorphism: _useNeumorphism,
            onBarTap: (point, datasetIndex, barIndex) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tapped bar: Value=${point.y.toStringAsFixed(1)}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          BarChartWidget(
            dataSets: SampleData.generateMultiLineData(),
            theme: chartTheme,
            title: 'Grouped Bar Chart',
            subtitle: 'Multiple datasets comparison',
            isGrouped: true,
            useGlassmorphism: _useGlassmorphism,
            useNeumorphism: _useNeumorphism,
          ),
          const SizedBox(height: 24),
          BarChartWidget(
            dataSets: SampleData.generateUsersData(),
            theme: chartTheme,
            title: 'Users by Name',
            subtitle: 'User data visualization - Tap on bars!',
            useGlassmorphism: _useGlassmorphism,
            useNeumorphism: _useNeumorphism,
            onBarTap: (point, datasetIndex, barIndex) {
              final userLabel = point.label ?? 'User ${point.x.toInt() + 1}';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tapped: $userLabel - Value=${point.y.toStringAsFixed(0)}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAreaChart(ChartTheme chartTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AreaChartWidget(
            dataSets: SampleData.generateMultiLineData(),
            theme: chartTheme,
            title: 'Revenue Area Chart',
            subtitle: 'Filled area visualization - Tap on points!',
            useGlassmorphism: _useGlassmorphism,
            useNeumorphism: _useNeumorphism,
            onPointTap: (point, datasetIndex, pointIndex) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tapped point: X=${point.x.toStringAsFixed(1)}, Y=${point.y.toStringAsFixed(1)}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
          const SizedBox(height: 24),
          AreaChartWidget(
            dataSets: [
              ChartDataSet(
                label: 'Growth',
                color: const Color(0xFF10B981),
                dataPoints: SampleData.generateLineData(count: 15, maxY: 100),
              ),
            ],
            theme: chartTheme,
            title: 'Growth Metrics',
            subtitle: 'Single dataset area chart',
            useGlassmorphism: _useGlassmorphism,
            useNeumorphism: _useNeumorphism,
          ),
          const SizedBox(height: 24),
          AreaChartWidget(
            dataSets: SampleData.generateUsersData(),
            theme: chartTheme,
            title: 'Users Growth Trend',
            subtitle: 'User data as area chart - Tap on points!',
            useGlassmorphism: _useGlassmorphism,
            useNeumorphism: _useNeumorphism,
            onPointTap: (point, datasetIndex, pointIndex) {
              final userLabel = point.label ?? 'User ${point.x.toInt() + 1}';
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tapped: $userLabel - Value=${point.y.toStringAsFixed(0)}',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(ChartTheme chartTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PieChartWidget(
            data: SampleData.generatePieData(),
            theme: chartTheme,
            title: 'Device Distribution',
            subtitle: 'User devices breakdown - Tap on segments!',
            useGlassmorphism: _useGlassmorphism,
            useNeumorphism: _useNeumorphism,
            onSegmentTap: (segment, segmentIndex) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tapped segment: ${segment.label} (${segment.value.toStringAsFixed(1)})',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChart(ChartTheme chartTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          DonutChartWidget(
            data: SampleData.generatePieData(),
            theme: chartTheme,
            title: 'Sales Distribution',
            subtitle: 'Donut chart with center value - Tap on segments!',
            useGlassmorphism: _useGlassmorphism,
            useNeumorphism: _useNeumorphism,
            onSegmentTap: (segment, segmentIndex) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    'Tapped segment: ${segment.label} (${segment.value.toStringAsFixed(1)})',
                  ),
                  duration: const Duration(seconds: 2),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRadialChart(ChartTheme chartTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RadialChartWidget(
            dataSets: SampleData.generateRadialData(),
            theme: chartTheme,
            title: 'Performance Metrics',
            subtitle: 'Multi-dimensional analysis',
            useGlassmorphism: _useGlassmorphism,
            useNeumorphism: _useNeumorphism,
          ),
        ],
      ),
    );
  }

  Widget _buildSparklineChart(ChartTheme chartTheme) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SparklineChartWidget(
            dataSet: SampleData.generateSparklineData(),
            theme: chartTheme,
            title: 'Trend Analysis',
            subtitle: 'Compact sparkline visualization',
            useGlassmorphism: _useGlassmorphism,
            useNeumorphism: _useNeumorphism,
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SparklineChartWidget(
                  dataSet: ChartDataSet(
                    label: 'Positive',
                    color: const Color(0xFF10B981),
                    dataPoints: List.generate(15, (i) {
                      return ChartDataPoint(x: i.toDouble(), y: 50 + i * 2);
                    }),
                  ),
                  theme: chartTheme,
                  title: 'Positive Trend',
                  useGlassmorphism: _useGlassmorphism,
                  useNeumorphism: _useNeumorphism,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SparklineChartWidget(
                  dataSet: ChartDataSet(
                    label: 'Negative',
                    color: const Color(0xFFEF4444),
                    dataPoints: List.generate(15, (i) {
                      return ChartDataPoint(x: i.toDouble(), y: 100 - i * 2);
                    }),
                  ),
                  theme: chartTheme,
                  title: 'Negative Trend',
                  useGlassmorphism: _useGlassmorphism,
                  useNeumorphism: _useNeumorphism,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
