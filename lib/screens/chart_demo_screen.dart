import 'package:flutter/material.dart';
import 'package:save_points_chart/main.dart';
import 'package:save_points_chart/providers/theme_provider.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/theme/charts_config.dart';
import 'package:save_points_chart/widgets/line_chart_widget.dart';
import 'package:save_points_chart/widgets/bar_chart_widget.dart';
import 'package:save_points_chart/widgets/area_chart_widget.dart';
import 'package:save_points_chart/widgets/pie_chart_widget.dart';
import 'package:save_points_chart/widgets/donut_chart_widget.dart';
import 'package:save_points_chart/widgets/radial_chart_widget.dart';
import 'package:save_points_chart/widgets/sparkline_chart_widget.dart';
import 'package:save_points_chart/widgets/scatter_chart_widget.dart';
import 'package:save_points_chart/widgets/bubble_chart_widget.dart';
import 'package:save_points_chart/widgets/radar_chart_widget.dart';
import 'package:save_points_chart/widgets/gauge_chart_widget.dart';
import 'package:save_points_chart/widgets/spline_chart_widget.dart';
import 'package:save_points_chart/widgets/step_line_chart_widget.dart';
import 'package:save_points_chart/widgets/stacked_column_chart_widget.dart';
import 'package:save_points_chart/widgets/pyramid_chart_widget.dart';
import 'package:save_points_chart/widgets/funnel_chart_widget.dart';
import 'package:save_points_chart/widgets/chart_context_menu.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/data/sample_data.dart';

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
    final themeProvider = ThemeProvider.of(context);
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
      drawer: _buildDrawer(),
      body: _buildChartContent(
        chartTheme,
        ChartsConfig(
          theme: chartTheme,
          useGlassmorphism: _useGlassmorphism,
          useNeumorphism: _useNeumorphism,
          errorMessage:
              _isError ? 'Unable to load chart data. Please try again.' : null,
        ),
      ),
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: ListView(
        padding: EdgeInsets.zero,
        children: [
          DrawerHeader(
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  Color(0xFF6366F1),
                  Color(0xFF8B5CF6),
                  Color(0xFFEC4899),
                ],
                stops: [0.0, 0.5, 1.0],
              ),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF6366F1).withValues(alpha: 0.3),
                  blurRadius: 20,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.end,
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.3),
                      width: 1.5,
                    ),
                  ),
                  child: const Icon(
                    Icons.show_chart,
                    size: 32,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Modern Charts',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                    shadows: [
                      Shadow(
                        color: Colors.black26,
                        offset: Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  '17+ Chart Types',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.9),
                    fontSize: 12,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
          _buildDrawerItem(
            icon: Icons.show_chart,
            title: 'Line Chart',
            index: 0,
          ),
          _buildDrawerItem(
            icon: Icons.bar_chart,
            title: 'Bar Chart',
            index: 1,
          ),
          _buildDrawerItem(
            icon: Icons.area_chart,
            title: 'Area Chart',
            index: 2,
          ),
          _buildDrawerItem(
            icon: Icons.pie_chart,
            title: 'Pie Chart',
            index: 3,
          ),
          _buildDrawerItem(
            icon: Icons.donut_large,
            title: 'Donut Chart',
            index: 4,
          ),
          _buildDrawerItem(
            icon: Icons.radar,
            title: 'Radial Chart',
            index: 5,
          ),
          _buildDrawerItem(
            icon: Icons.trending_up,
            title: 'Sparkline Chart',
            index: 6,
          ),
          _buildDrawerItem(
            icon: Icons.scatter_plot,
            title: 'Scatter Chart',
            index: 7,
          ),
          _buildDrawerItem(
            icon: Icons.bubble_chart,
            title: 'Bubble Chart',
            index: 8,
          ),
          _buildDrawerItem(
            icon: Icons.polyline,
            title: 'Radar Chart',
            index: 9,
          ),
          _buildDrawerItem(
            icon: Icons.speed,
            title: 'Gauge Chart',
            index: 10,
          ),
          _buildDrawerItem(
            icon: Icons.timeline,
            title: 'Spline Chart',
            index: 11,
          ),
          _buildDrawerItem(
            icon: Icons.show_chart,
            title: 'Step Line Chart',
            index: 12,
          ),
          _buildDrawerItem(
            icon: Icons.view_column,
            title: 'Stacked Column',
            index: 13,
          ),
          _buildDrawerItem(
            icon: Icons.change_history,
            title: 'Pyramid Chart',
            index: 14,
          ),
          _buildDrawerItem(
            icon: Icons.filter_alt,
            title: 'Funnel Chart',
            index: 15,
          ),
        ],
      ),
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;
    final theme = Theme.of(context);
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: isSelected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.6)
            : Colors.transparent,
      ),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: isSelected
                ? theme.colorScheme.primary.withValues(alpha: 0.15)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            color: isSelected
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurface.withValues(alpha: 0.7),
            size: 22,
          ),
        ),
        title: Text(
          title,
          style: TextStyle(
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
            fontSize: 15,
            color: isSelected
                ? theme.colorScheme.onPrimaryContainer
                : theme.colorScheme.onSurface,
          ),
        ),
        selected: isSelected,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        onTap: () {
          setState(() {
            _selectedIndex = index;
          });
          Navigator.of(context).pop(); // Close drawer
        },
      ),
    );
  }

  Widget _buildChartContent(ChartTheme chartTheme, ChartsConfig chartsConfig) {
    switch (_selectedIndex) {
      case 0:
        return _buildLineChart(chartTheme, chartsConfig);
      case 1:
        return _buildBarChart(chartTheme, chartsConfig);
      case 2:
        return _buildAreaChart(chartTheme, chartsConfig);
      case 3:
        return _buildPieChart(chartTheme, chartsConfig);
      case 4:
        return _buildDonutChart(chartTheme, chartsConfig);
      case 5:
        return _buildRadialChart(chartTheme, chartsConfig);
      case 6:
        return _buildSparklineChart(chartTheme, chartsConfig);
      case 7:
        return _buildScatterChart(chartTheme, chartsConfig);
      case 8:
        return _buildBubbleChart(chartTheme, chartsConfig);
      case 9:
        return _buildRadarChart(chartTheme, chartsConfig);
      case 10:
        return _buildGaugeChart(chartTheme, chartsConfig);
      case 11:
        return _buildSplineChart(chartTheme, chartsConfig);
      case 12:
        return _buildStepLineChart(chartTheme, chartsConfig);
      case 13:
        return _buildStackedColumnChart(chartTheme, chartsConfig);
      case 14:
        return _buildPyramidChart(chartTheme, chartsConfig);
      case 15:
        return _buildFunnelChart(chartTheme, chartsConfig);
      default:
        return _buildLineChart(chartTheme, chartsConfig);
    }
  }

  Widget _buildLineChart(ChartTheme chartTheme, ChartsConfig chartsConfig) {
    final lineDataSets = SampleData.generateMultiLineData();
    final usersDataSets = SampleData.generateUsersData();

    /// Line Chart
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          LineChartWidget(
            dataSets: lineDataSets,
            config: chartsConfig,
            title: 'Sales & Revenue Trend',
            subtitle: 'Last 12 months performance - Hover or tap on points!',
            isLoading: _isLoading,
            isError: _isError,
            onPointTap: (point, datasetIndex, pointIndex, position) {
              if (datasetIndex < 0 || datasetIndex >= lineDataSets.length) {
                return;
              }
              final dataSet = lineDataSets[datasetIndex];
              ChartContextMenuHelper.show(
                context,
                point: point,
                segment: null,
                position: position,
                datasetIndex: datasetIndex,
                elementIndex: pointIndex,
                datasetLabel: dataSet.dataPoint.label ?? '',
                theme: chartTheme,
                useGlassmorphism: _useGlassmorphism,
                useNeumorphism: _useNeumorphism,
                onViewDetails: () {
                  _showDetailsDialog(
                    context,
                    point: point,
                    datasetLabel: dataSet.dataPoint.label ?? '',
                  );
                },
                onExport: () {
                  _showExportSnackBar(context, 'Exporting data point...');
                },
                onShare: () {
                  _showExportSnackBar(context, 'Sharing data point...');
                },
              );
            },
            onPointHover: (point, datasetIndex, pointIndex) {
              // Hover effect is automatically shown on the chart
              // Points will highlight when you hover over them
              if (point != null && datasetIndex != null) {
                // Optional: You can add custom tooltip or other UI feedback here
                if (datasetIndex < 0 || datasetIndex >= lineDataSets.length) {
                  return;
                }
                final position = Offset(point.x, point.y);
                final dataSet = lineDataSets[datasetIndex];
                ChartContextMenuHelper.show(
                  context,
                  point: point,
                  segment: null,
                  position: position,
                  datasetIndex: datasetIndex,
                  elementIndex: pointIndex,
                  datasetLabel: dataSet.dataPoint.label ?? '',
                  theme: chartTheme,
                  useGlassmorphism: _useGlassmorphism,
                  useNeumorphism: _useNeumorphism,
                  onViewDetails: () {
                    _showDetailsDialog(
                      context,
                      point: point,
                      datasetLabel: dataSet.dataPoint.label ?? '',
                    );
                  },
                );
              }
            },
          ),
          const SizedBox(height: 24.0),
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
            dataSets: SampleData.generateLineData(count: 24, maxY: 40)
                .map(
                  (point) => ChartDataSet(
                    color: const Color(0xFFEC4899),
                    dataPoint: point,
                  ),
                )
                .toList(),
            config: chartsConfig,
            title: 'Temperature Over Time',
            subtitle: 'Without grid lines',
          ),
          const SizedBox(height: 24),
          LineChartWidget(
            dataSets: usersDataSets,
            config: chartsConfig,
            title: 'Users by Name (No Labels)',
            subtitle: 'User data without axis labels',
            onPointTap: (point, datasetIndex, pointIndex, position) {
              if (datasetIndex < 0 || datasetIndex >= usersDataSets.length) {
                return;
              }
              final userLabel = point.label ?? 'User ${point.x.toInt() + 1}';
              final dataSet = usersDataSets[datasetIndex];
              ChartContextMenuHelper.show(
                context,
                point: point,
                segment: null,
                position: position,
                datasetIndex: datasetIndex,
                elementIndex: pointIndex,
                datasetLabel: dataSet.dataPoint.label ?? '',
                theme: chartTheme,
                useGlassmorphism: _useGlassmorphism,
                useNeumorphism: _useNeumorphism,
                onViewDetails: () {
                  _showDetailsDialog(
                    context,
                    point: point,
                    datasetLabel: dataSet.dataPoint.label ?? '',
                    userLabel: userLabel,
                  );
                },
                onExport: () {
                  _showExportSnackBar(context, 'Exporting $userLabel data...');
                },
                onShare: () {
                  _showExportSnackBar(context, 'Sharing $userLabel data...');
                },
              );
            },
          ),
          const SizedBox(height: 24),
          LineChartWidget(
            dataSets: usersDataSets,
            config: chartsConfig,
            title: 'Users by Name',
            subtitle: 'User data visualization - Tap on points!',
            onPointTap: (point, datasetIndex, pointIndex, position) {
              if (datasetIndex < 0 || datasetIndex >= usersDataSets.length) {
                return;
              }
              final userLabel = point.label ?? 'User ${point.x.toInt() + 1}';
              final dataSet = usersDataSets[datasetIndex];
              ChartContextMenuHelper.show(
                context,
                point: point,
                segment: null,
                position: position,
                datasetIndex: datasetIndex,
                elementIndex: pointIndex,
                datasetLabel: dataSet.dataPoint.label ?? '',
                theme: chartTheme,
                useGlassmorphism: _useGlassmorphism,
                useNeumorphism: _useNeumorphism,
                onViewDetails: () {
                  _showDetailsDialog(
                    context,
                    point: point,
                    datasetLabel: dataSet.dataPoint.label ?? '',
                    userLabel: userLabel,
                  );
                },
                onExport: () {
                  _showExportSnackBar(context, 'Exporting $userLabel data...');
                },
                onShare: () {
                  _showExportSnackBar(context, 'Sharing $userLabel data...');
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBarChart(ChartTheme chartTheme, ChartsConfig chartsConfig) {
    final barDataSets = SampleData.generateBarData();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BarChartWidget(
            barRounded: false,
            dataSets: barDataSets,
            config: chartsConfig,
            title: 'Monthly Sales',
            subtitle: 'Quarterly breakdown - Tap on bars!',
            onBarTap: (point, datasetIndex, barIndex, position) {
              if (datasetIndex < 0 || datasetIndex >= barDataSets.length) {
                return;
              }
              final dataSet = barDataSets[datasetIndex];
              ChartContextMenuHelper.show(
                context,
                point: point,
                segment: null,
                position: position,
                datasetIndex: datasetIndex,
                elementIndex: barIndex,
                datasetLabel: dataSet.dataPoint.label ?? '',
                theme: chartTheme,
                useGlassmorphism: _useGlassmorphism,
                useNeumorphism: _useNeumorphism,
                onViewDetails: () {
                  _showDetailsDialog(
                    context,
                    point: point,
                    datasetLabel: dataSet.dataPoint.label ?? '',
                  );
                },
                onExport: () {
                  _showExportSnackBar(context, 'Exporting bar data...');
                },
                onShare: () {
                  _showExportSnackBar(context, 'Sharing bar data...');
                },
              );
            },
          ),
          const SizedBox(height: 24),
          BarChartWidget(
            barRounded: false,
            dataSets: SampleData.generateMultiLineData(),
            config: chartsConfig,
            title: 'Grouped Bar Chart',
            subtitle: 'Multiple datasets comparison',
            isGrouped: true,
          ),
          const SizedBox(height: 24),
          BarChartWidget(
            barRounded: false,
            dataSets: SampleData.generateUsersData(),
            config: chartsConfig,
            title: 'Users by Name',
            subtitle: 'User data visualization - Tap on bars!',
            onBarTap: (point, datasetIndex, barIndex, position) {
              final userLabel = point.label ?? 'User ${point.x.toInt() + 1}';
              final dataSet = SampleData.generateUsersData()[datasetIndex];
              ChartContextMenuHelper.show(
                context,
                point: point,
                segment: null,
                position: position,
                datasetIndex: datasetIndex,
                elementIndex: barIndex,
                datasetLabel: dataSet.dataPoint.label ?? '',
                theme: chartTheme,
                useGlassmorphism: _useGlassmorphism,
                useNeumorphism: _useNeumorphism,
                onViewDetails: () {
                  _showDetailsDialog(
                    context,
                    point: point,
                    datasetLabel: dataSet.dataPoint.label ?? '',
                    userLabel: userLabel,
                  );
                },
                onExport: () {
                  _showExportSnackBar(context, 'Exporting $userLabel data...');
                },
                onShare: () {
                  _showExportSnackBar(context, 'Sharing $userLabel data...');
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildAreaChart(ChartTheme chartTheme, ChartsConfig chartsConfig) {
    final areaDataSets = SampleData.generateMultiLineData();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          AreaChartWidget(
            dataSets: areaDataSets,
            config: chartsConfig,
            title: 'Revenue Area Chart',
            subtitle: 'Filled area visualization - Tap on points!',
            onPointTap: (point, datasetIndex, pointIndex, position) {
              if (datasetIndex < 0 || datasetIndex >= areaDataSets.length) {
                return;
              }
              final dataSet = areaDataSets[datasetIndex];
              ChartContextMenuHelper.show(
                context,
                point: point,
                segment: null,
                position: position,
                datasetIndex: datasetIndex,
                elementIndex: pointIndex,
                datasetLabel: dataSet.dataPoint.label ?? '',
                theme: chartTheme,
                useGlassmorphism: _useGlassmorphism,
                useNeumorphism: _useNeumorphism,
                onViewDetails: () {
                  _showDetailsDialog(
                    context,
                    point: point,
                    datasetLabel: dataSet.dataPoint.label ?? '',
                  );
                },
                onExport: () {
                  _showExportSnackBar(context, 'Exporting data point...');
                },
                onShare: () {
                  _showExportSnackBar(context, 'Sharing data point...');
                },
              );
            },
          ),
          const SizedBox(height: 24),
          AreaChartWidget(
            dataSets: [
              ...SampleData.generateLineData(count: 15).map(
                (point) => ChartDataSet(
                  color: const Color(0xFF10B981),
                  dataPoint: point,
                ),
              ),
            ],
            config: chartsConfig,
            title: 'Growth Metrics',
            subtitle: 'Single dataset area chart',
          ),
          const SizedBox(height: 24),
          AreaChartWidget(
            dataSets: SampleData.generateUsersData(),
            config: chartsConfig,
            title: 'Users Growth Trend',
            subtitle: 'User data as area chart - Tap on points!',
            onPointTap: (point, datasetIndex, pointIndex, position) {
              final userLabel = point.label ?? 'User ${point.x.toInt() + 1}';
              final dataSet = SampleData.generateUsersData()[datasetIndex];
              ChartContextMenuHelper.show(
                context,
                point: point,
                segment: null,
                position: position,
                datasetIndex: datasetIndex,
                elementIndex: pointIndex,
                datasetLabel: dataSet.dataPoint.label ?? '',
                theme: chartTheme,
                useGlassmorphism: _useGlassmorphism,
                useNeumorphism: _useNeumorphism,
                onViewDetails: () {
                  _showDetailsDialog(
                    context,
                    point: point,
                    datasetLabel: dataSet.dataPoint.label ?? '',
                    userLabel: userLabel,
                  );
                },
                onExport: () {
                  _showExportSnackBar(context, 'Exporting $userLabel data...');
                },
                onShare: () {
                  _showExportSnackBar(context, 'Sharing $userLabel data...');
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPieChart(ChartTheme chartTheme, ChartsConfig chartsConfig) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PieChartWidget(
            data: SampleData.generatePieData(),
            config: chartsConfig,
            title: 'Device Distribution',
            subtitle: 'User devices breakdown - Tap on segments!',
            onSegmentTap: (segment, segmentIndex, position) {
              ChartContextMenuHelper.show(
                context,
                point: null,
                segment: segment,
                position: position,
                elementIndex: segmentIndex,
                theme: chartTheme,
                useGlassmorphism: _useGlassmorphism,
                useNeumorphism: _useNeumorphism,
                onViewDetails: () {
                  _showDetailsDialog(context, segment: segment);
                },
                onExport: () {
                  _showExportSnackBar(
                    context,
                    'Exporting ${segment.label} data...',
                  );
                },
                onShare: () {
                  _showExportSnackBar(
                    context,
                    'Sharing ${segment.label} data...',
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildDonutChart(ChartTheme chartTheme, ChartsConfig chartsConfig) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: DonutChartWidget(
        // height: 900,
        data: SampleData.generatePieData(),
        config: chartsConfig,
        title: 'Sales Distribution',
        subtitle: 'Donut chart with center value - Tap on segments!',
        onSegmentTap: (segment, segmentIndex, position) {
          ChartContextMenuHelper.show(
            context,
            point: null,
            segment: segment,
            position: position,
            elementIndex: segmentIndex,
            theme: chartTheme,
            useGlassmorphism: _useGlassmorphism,
            useNeumorphism: _useNeumorphism,
            onViewDetails: () {
              _showDetailsDialog(context, segment: segment);
            },
            onExport: () {
              _showExportSnackBar(
                context,
                'Exporting ${segment.label} data...',
              );
            },
            onShare: () {
              _showExportSnackBar(
                context,
                'Sharing ${segment.label} data...',
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildRadialChart(ChartTheme chartTheme, ChartsConfig chartsConfig) {
    final radialDataSets = SampleData.generateRadialData();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RadialChartWidget(
            dataSets: radialDataSets,
            config: chartsConfig,
            title: 'Performance Metrics',
            subtitle: 'Multi-dimensional analysis - Tap on points!',
            onPointTap: (point, datasetIndex, pointIndex, position) {
              if (datasetIndex < 0 || datasetIndex >= radialDataSets.length) {
                return;
              }
              final dataSet = radialDataSets[datasetIndex];
              ChartContextMenuHelper.show(
                context,
                point: point,
                segment: null,
                position: position,
                datasetIndex: datasetIndex,
                elementIndex: pointIndex,
                datasetLabel: dataSet.dataPoint.label ?? '',
                theme: chartTheme,
                useGlassmorphism: _useGlassmorphism,
                useNeumorphism: _useNeumorphism,
                onViewDetails: () {
                  _showDetailsDialog(
                    context,
                    point: point,
                    datasetLabel: dataSet.dataPoint.label ?? '',
                  );
                },
                onExport: () {
                  _showExportSnackBar(
                    context,
                    'Exporting radial data point...',
                  );
                },
                onShare: () {
                  _showExportSnackBar(context, 'Sharing radial data point...');
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSparklineChart(
      ChartTheme chartTheme, ChartsConfig chartsConfig) {
    final sparklineDataSets = SampleData.generateSparklineData();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SparklineChartWidget(
            dataSets: sparklineDataSets,
            config: chartsConfig,
            title: 'Trend Analysis',
            subtitle: 'Compact sparkline visualization - Tap on points!',
            onPointTap: (point, datasetIndex, pointIndex, position) {
              if (datasetIndex < 0 ||
                  datasetIndex >= sparklineDataSets.length) {
                return;
              }
              final dataSet = sparklineDataSets[datasetIndex];
              ChartContextMenuHelper.show(
                context,
                point: point,
                segment: null,
                position: position,
                datasetIndex: datasetIndex,
                elementIndex: pointIndex,
                datasetLabel: dataSet.dataPoint.label ?? '',
                theme: chartTheme,
                useGlassmorphism: _useGlassmorphism,
                useNeumorphism: _useNeumorphism,
                onViewDetails: () {
                  _showDetailsDialog(
                    context,
                    point: point,
                    datasetLabel: dataSet.dataPoint.label ?? '',
                  );
                },
                onExport: () {
                  _showExportSnackBar(
                    context,
                    'Exporting sparkline data point...',
                  );
                },
                onShare: () {
                  _showExportSnackBar(
                    context,
                    'Sharing sparkline data point...',
                  );
                },
              );
            },
          ),
          const SizedBox(height: 24),
          Row(
            children: [
              Expanded(
                child: SparklineChartWidget(
                  dataSets: List.generate(15, (i) {
                    return ChartDataSet(
                      color: const Color(0xFF10B981),
                      dataPoint: ChartDataPoint(
                        x: i.toDouble(),
                        y: 50 + i * 2,
                        label: 'Point ${i + 1}',
                      ),
                    );
                  }),
                  config: chartsConfig,
                  title: 'Positive Trend',
                  onPointTap: (point, datasetIndex, pointIndex, position) {
                    final dataSets = List.generate(15, (i) {
                      return ChartDataSet(
                        color: const Color(0xFF10B981),
                        dataPoint: ChartDataPoint(
                          x: i.toDouble(),
                          y: 50 + i * 2,
                          label: 'Point ${i + 1}',
                        ),
                      );
                    });
                    final dataSet = datasetIndex < dataSets.length
                        ? dataSets[datasetIndex]
                        : dataSets.first;
                    ChartContextMenuHelper.show(
                      context,
                      point: point,
                      segment: null,
                      position: position,
                      datasetIndex: datasetIndex,
                      elementIndex: pointIndex,
                      datasetLabel: dataSet.dataPoint.label ?? '',
                      theme: chartTheme,
                      useGlassmorphism: _useGlassmorphism,
                      useNeumorphism: _useNeumorphism,
                      onViewDetails: () {
                        _showDetailsDialog(
                          context,
                          point: point,
                          datasetLabel: dataSet.dataPoint.label ?? '',
                        );
                      },
                      onExport: () {
                        _showExportSnackBar(
                          context,
                          'Exporting positive trend data...',
                        );
                      },
                      onShare: () {
                        _showExportSnackBar(
                          context,
                          'Sharing positive trend data...',
                        );
                      },
                    );
                  },
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: SparklineChartWidget(
                  dataSets: List.generate(15, (i) {
                    return ChartDataSet(
                      color: const Color(0xFFEF4444),
                      dataPoint:
                          ChartDataPoint(x: i.toDouble(), y: 100 - i * 2),
                    );
                  }),
                  config: chartsConfig,
                  title: 'Negative Trend',
                  onPointTap: (point, datasetIndex, pointIndex, position) {
                    final dataSets = List.generate(15, (i) {
                      return ChartDataSet(
                        color: const Color(0xFFEF4444),
                        dataPoint:
                            ChartDataPoint(x: i.toDouble(), y: 100 - i * 2),
                      );
                    });
                    final dataSet = datasetIndex < dataSets.length
                        ? dataSets[datasetIndex]
                        : dataSets.first;
                    ChartContextMenuHelper.show(
                      context,
                      point: point,
                      segment: null,
                      position: position,
                      datasetIndex: datasetIndex,
                      elementIndex: pointIndex,
                      datasetLabel: dataSet.dataPoint.label ?? '',
                      theme: chartTheme,
                      useGlassmorphism: _useGlassmorphism,
                      useNeumorphism: _useNeumorphism,
                      onViewDetails: () {
                        _showDetailsDialog(
                          context,
                          point: point,
                          datasetLabel: dataSet.dataPoint.label ?? '',
                        );
                      },
                      onExport: () {
                        _showExportSnackBar(
                          context,
                          'Exporting negative trend data...',
                        );
                      },
                      onShare: () {
                        _showExportSnackBar(
                          context,
                          'Sharing negative trend data...',
                        );
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildScatterChart(ChartTheme chartTheme, ChartsConfig chartsConfig) {
    final scatterDataSets = SampleData.generateScatterData();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ScatterChartWidget(
            dataSets: scatterDataSets,
            config: chartsConfig,
            title: 'Product Correlation',
            subtitle: 'Scatter plot showing relationship - Tap on points!',
            onPointTap: (point, datasetIndex, pointIndex, position) {
              if (datasetIndex < 0 || datasetIndex >= scatterDataSets.length) {
                return;
              }
              final dataSet = scatterDataSets[datasetIndex];
              ChartContextMenuHelper.show(
                context,
                point: point,
                segment: null,
                position: position,
                datasetIndex: datasetIndex,
                elementIndex: pointIndex,
                datasetLabel: dataSet.dataPoint.label ?? '',
                theme: chartTheme,
                useGlassmorphism: _useGlassmorphism,
                useNeumorphism: _useNeumorphism,
                onViewDetails: () {
                  _showDetailsDialog(
                    context,
                    point: point,
                    datasetLabel: dataSet.dataPoint.label ?? '',
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBubbleChart(ChartTheme chartTheme, ChartsConfig chartsConfig) {
    final bubbleDataSets = SampleData.generateBubbleData();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          BubbleChartWidget(
            dataSets: bubbleDataSets,
            config: chartsConfig,
            title: 'Regional Performance',
            subtitle: 'Bubble chart with size dimension - Tap on bubbles!',
            onBubbleTap: (point, datasetIndex, pointIndex, position) {
              // Add bounds checking to prevent RangeError
              if (datasetIndex < 0 || datasetIndex >= bubbleDataSets.length) {
                return;
              }
              final dataSet = bubbleDataSets[datasetIndex];
              if (pointIndex < 0 || pointIndex >= dataSet.dataPoints.length) {
                return;
              }
              final bubblePoint = dataSet.dataPoints[pointIndex];
              ChartContextMenuHelper.show(
                context,
                point: point,
                segment: null,
                position: position,
                datasetIndex: datasetIndex,
                elementIndex: pointIndex,
                datasetLabel: bubblePoint.label ?? '',
                theme: chartTheme,
                useGlassmorphism: _useGlassmorphism,
                useNeumorphism: _useNeumorphism,
                onViewDetails: () {
                  _showDetailsDialog(
                    context,
                    point: point,
                    datasetLabel:
                        '${bubblePoint.label ?? ''} (Size: ${bubblePoint.size.toStringAsFixed(1)})',
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildRadarChart(ChartTheme chartTheme, ChartsConfig chartsConfig) {
    final radarDataSets = SampleData.generateRadarData();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          RadarChartWidget(
            dataSets: radarDataSets,
            config: chartsConfig,
            title: 'Team Performance Comparison',
            subtitle: 'Multi-dimensional radar chart - Tap on points!',
            onPointTap: (point, datasetIndex, pointIndex, position) {
              if (datasetIndex < 0 || datasetIndex >= radarDataSets.length) {
                return;
              }
              final dataSet = radarDataSets[datasetIndex];
              if (pointIndex < 0 || pointIndex >= dataSet.dataPoints.length) {
                return;
              }
              final radarPoint = dataSet.dataPoints[pointIndex];
              ChartContextMenuHelper.show(
                context,
                point: point,
                segment: null,
                position: position,
                datasetIndex: datasetIndex,
                elementIndex: pointIndex,
                datasetLabel: radarPoint.label,
                theme: chartTheme,
                useGlassmorphism: _useGlassmorphism,
                useNeumorphism: _useNeumorphism,
                onViewDetails: () {
                  _showDetailsDialog(
                    context,
                    point: point,
                    datasetLabel: radarPoint.label,
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildGaugeChart(ChartTheme chartTheme, ChartsConfig chartsConfig) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          GaugeChartWidget(
            value: 75,
            config: chartsConfig,
            title: 'Performance Score',
            subtitle: 'Current performance metric - Tap on chart!',
            centerLabel: 'Score',
            unit: '%',
            onChartTap: () {
              _showDetailsDialog(
                context,
                point: const ChartDataPoint(
                  x: 0,
                  y: 75,
                  label: 'Performance Score',
                ),
                datasetLabel: 'Performance Score',
              );
            },
          ),
          const SizedBox(height: 24),
          GaugeChartWidget(
            value: 85,
            config: chartsConfig,
            title: 'Customer Satisfaction',
            subtitle: 'Customer satisfaction rating - Tap on chart!',
            centerLabel: 'Satisfaction',
            unit: '%',
            onChartTap: () {
              _showDetailsDialog(
                context,
                point: const ChartDataPoint(
                  x: 0,
                  y: 85,
                  label: 'Customer Satisfaction',
                ),
                datasetLabel: 'Customer Satisfaction',
              );
            },
          ),
          const SizedBox(height: 24),
          GaugeChartWidget(
            value: 60,
            config: chartsConfig,
            title: 'Sales Target',
            subtitle: 'Progress towards sales goal - Tap on chart!',
            centerLabel: 'Progress',
            unit: '%',
            onChartTap: () {
              _showDetailsDialog(
                context,
                point: const ChartDataPoint(x: 0, y: 60, label: 'Sales Target'),
                datasetLabel: 'Sales Target',
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSplineChart(ChartTheme chartTheme, ChartsConfig chartsConfig) {
    final splineDataSets = SampleData.generateMultiLineData();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SplineChartWidget(
            dataSets: splineDataSets,
            config: chartsConfig,
            title: 'Smooth Spline Chart',
            subtitle:
                'Spline curves with smooth bezier interpolation - Tap on points!',
            onPointTap: (point, datasetIndex, pointIndex, position) {
              if (datasetIndex < 0 || datasetIndex >= splineDataSets.length) {
                return;
              }
              final dataSet = splineDataSets[datasetIndex];
              ChartContextMenuHelper.show(
                context,
                point: point,
                segment: null,
                position: position,
                datasetIndex: datasetIndex,
                elementIndex: pointIndex,
                datasetLabel: dataSet.dataPoint.label ?? '',
                theme: chartTheme,
                useGlassmorphism: _useGlassmorphism,
                useNeumorphism: _useNeumorphism,
                onViewDetails: () {
                  _showDetailsDialog(
                    context,
                    point: point,
                    datasetLabel: dataSet.dataPoint.label ?? '',
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStepLineChart(ChartTheme chartTheme, ChartsConfig chartsConfig) {
    final stepLineDataSets = SampleData.generateMultiLineData();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StepLineChartWidget(
            dataSets: stepLineDataSets,
            config: chartsConfig,
            title: 'Step Line Chart',
            subtitle: 'Step function visualization - Tap on points!',
            onPointTap: (point, datasetIndex, pointIndex, position) {
              if (datasetIndex < 0 || datasetIndex >= stepLineDataSets.length) {
                return;
              }
              final dataSet = stepLineDataSets[datasetIndex];
              ChartContextMenuHelper.show(
                context,
                point: point,
                segment: null,
                position: position,
                datasetIndex: datasetIndex,
                elementIndex: pointIndex,
                datasetLabel: dataSet.dataPoint.label ?? '',
                theme: chartTheme,
                useGlassmorphism: _useGlassmorphism,
                useNeumorphism: _useNeumorphism,
                onViewDetails: () {
                  _showDetailsDialog(
                    context,
                    point: point,
                    datasetLabel: dataSet.dataPoint.label ?? '',
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStackedColumnChart(
      ChartTheme chartTheme, ChartsConfig chartsConfig) {
    final stackedBarDataSets = SampleData.generateBarData();
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          StackedColumnChartWidget(
            dataSets: stackedBarDataSets,
            config: chartsConfig,
            title: 'Stacked Column Chart',
            subtitle: 'Multiple datasets stacked vertically - Tap on bars!',
            onBarTap: (point, datasetIndex, barIndex, position) {
              if (datasetIndex < 0 ||
                  datasetIndex >= stackedBarDataSets.length) {
                return;
              }
              final dataSet = stackedBarDataSets[datasetIndex];
              ChartContextMenuHelper.show(
                context,
                point: point,
                segment: null,
                position: position,
                datasetIndex: datasetIndex,
                elementIndex: barIndex,
                datasetLabel: dataSet.dataPoint.label ?? '',
                theme: chartTheme,
                useGlassmorphism: _useGlassmorphism,
                useNeumorphism: _useNeumorphism,
                onViewDetails: () {
                  _showDetailsDialog(
                    context,
                    point: point,
                    datasetLabel: dataSet.dataPoint.label ?? '',
                  );
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPyramidChart(ChartTheme chartTheme, ChartsConfig chartsConfig) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PyramidChartWidget(
            data: SampleData.generatePieData(),
            config: chartsConfig,
            title: 'Pyramid Chart',
            subtitle: 'Hierarchical data visualization - Tap on segments!',
            onSegmentTap: (segment, segmentIndex, position) {
              ChartContextMenuHelper.show(
                context,
                point: null,
                segment: segment,
                position: position,
                elementIndex: segmentIndex,
                theme: chartTheme,
                useGlassmorphism: _useGlassmorphism,
                useNeumorphism: _useNeumorphism,
                onViewDetails: () {
                  _showDetailsDialog(context, segment: segment);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFunnelChart(ChartTheme chartTheme, ChartsConfig chartsConfig) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          FunnelChartWidget(
            data: SampleData.generatePieData(),
            config: chartsConfig,
            title: 'Funnel Chart',
            subtitle: 'Sales funnel and conversion tracking - Tap on segments!',
            onSegmentTap: (segment, segmentIndex, position) {
              ChartContextMenuHelper.show(
                context,
                point: null,
                segment: segment,
                position: position,
                elementIndex: segmentIndex,
                theme: chartTheme,
                useGlassmorphism: _useGlassmorphism,
                useNeumorphism: _useNeumorphism,
                onViewDetails: () {
                  _showDetailsDialog(context, segment: segment);
                },
              );
            },
          ),
        ],
      ),
    );
  }

  void _showDetailsDialog(
    BuildContext context, {
    ChartDataPoint? point,
    PieData? segment,
    String? datasetLabel,
    String? userLabel,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(point != null ? 'Point Details' : 'Segment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (point != null) ...[
              if (userLabel != null)
                Text(
                  'Label: $userLabel',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              if (datasetLabel != null) Text('Dataset: $datasetLabel'),
              const SizedBox(height: 8),
              Text('X Value: ${point.x.toStringAsFixed(2)}'),
              Text('Y Value: ${point.y.toStringAsFixed(2)}'),
            ] else if (segment != null) ...[
              Text(
                'Label: ${segment.label}',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Text('Value: ${segment.value.toStringAsFixed(2)}'),
              Text('Color: ${segment.color.toString()}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showExportSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}
