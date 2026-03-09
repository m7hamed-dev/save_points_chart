import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_chart.dart';

/// Test page that renders all chart types using real API data.
class DataTestScreen extends StatelessWidget {
  const DataTestScreen({super.key, required this.theme});

  final ChartTheme theme;

  // ── Shared data derived from the JSON ──────────────────────────────────

  static const Map<String, dynamic> _jsonData = {
    'success': true,
    'data': {
      'customer_count': 13,
      'refrigerators_count': 47,
      'area_active_count': 1,
      'operations_counts': 21,
      'refrigerators': [], // Truncated for brevity
      'customers': [],
      'maintenance_officers': [],
      'representatives': [],
      'operation': [],
      'reports': [
        {'month': '2026-02', 'operations': 12},
        {'month': '2026-01', 'operations': 0},
        {'month': '2025-12', 'operations': 0},
        {'month': '2025-11', 'operations': 0},
        {'month': '2025-10', 'operations': 9},
      ],
      'status': 200,
    },
    'message': 'messages.refrigerator_returned_successfully',
  };

  static List<Map<String, dynamic>> get _reports {
    final reports = List<Map<String, dynamic>>.from(_jsonData['data']['reports']);
    // Sort by month ascending (oldest to newest)
    reports.sort((a, b) => (a['month'] as String).compareTo(b['month'] as String));
    return reports;
  }

  static String _formatDate(String dateStr) {
    final parts = dateStr.split('-');
    final year = parts[0].substring(2);
    final month = int.parse(parts[1]);
    const months = ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
    return '${months[month]} $year';
  }

  static List<int> get _operations => _reports.map((e) => e['operations'] as int).toList();
  static int get _totalOps => _operations.fold(0, (sum, item) => sum + item);

  static const _color = Color(0xFF6366F1);

  static List<ChartDataSet> get _dataSets {
    return _reports.asMap().entries.map((entry) {
      final index = entry.key;
      final report = entry.value;
      return ChartDataSet(
        color: _color,
        dataPoint: ChartDataPoint(
          x: index.toDouble(),
          y: (report['operations'] as int).toDouble(),
          label: _formatDate(report['month'] as String),
        ),
      );
    }).toList();
  }

  static List<PieData> get _pieData {
    final colors = [
      const Color(0xFF6366F1),
      const Color(0xFF8B5CF6),
      const Color(0xFFEC4899),
      const Color(0xFF10B981),
      const Color(0xFFF59E0B),
    ];

    return _reports.asMap().entries.map((entry) {
      final index = entry.key;
      final report = entry.value;
      return PieData(
        label: _formatDate(report['month'] as String),
        value: (report['operations'] as int).toDouble(),
        color: colors[index % colors.length],
      );
    }).toList();
  }

  static List<PieData> get _pieDataNonZero => _pieData.where((e) => e.value > 0).toList();

  static List<RadarDataSet> get _radarData => [
    RadarDataSet(
      color: _color,
      dataPoints: _reports.map((report) {
        return RadarDataPoint(
          label: _formatDate(report['month'] as String),
          value: (report['operations'] as int).toDouble(),
        );
      }).toList(),
    ),
  ];

  static List<BubbleDataSet> get _bubbleData => [
    BubbleDataSet(
      color: _color,
      dataPoints: _reports.asMap().entries.map((entry) {
        final index = entry.key;
        final report = entry.value;
        final operations = report['operations'] as int;
        return BubbleDataPoint(
          x: index.toDouble(),
          y: operations.toDouble(),
          size: (operations + 2).toDouble(),
          label: _formatDate(report['month'] as String),
        );
      }).toList(),
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final config = ChartsConfig(theme: theme);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _section(
          'Line Chart',
          LineChartWidget(
            dataSets: _dataSets,
            config: config,
            title: 'Monthly Operations',
            subtitle: 'Oct 2025 – Feb 2026',
            onPointTap: _onPointTap(context),
          ),
        ),
        _section(
          'Area Chart',
          AreaChartWidget(
            dataSets: _dataSets,
            config: config,
            title: 'Monthly Operations (Area)',
            onPointTap: _onPointTap(context),
          ),
        ),
        _section(
          'Stacked Area Chart',
          StackedAreaChartWidget(
            dataSets: _dataSets,
            config: config,
            title: 'Monthly Operations (Stacked Area)',
            onPointTap: _onPointTap(context),
          ),
        ),
        _section(
          'Bar Chart',
          BarChartWidget(
            dataSets: _dataSets,
            config: config,
            title: 'Monthly Operations (Bar)',
            onBarTap: _onBarTap(context),
          ),
        ),
        _section(
          'Stacked Column Chart',
          StackedColumnChartWidget(
            dataSets: _dataSets,
            config: config,
            title: 'Monthly Operations (Stacked Column)',
            onBarTap: _onBarTap(context),
          ),
        ),
        _section(
          'Spline Chart',
          SplineChartWidget(
            dataSets: _dataSets,
            config: config,
            title: 'Monthly Operations (Spline)',
            onPointTap: _onPointTap(context),
          ),
        ),
        _section(
          'Step Line Chart',
          StepLineChartWidget(
            dataSets: _dataSets,
            config: config,
            title: 'Monthly Operations (Step Line)',
            onPointTap: _onPointTap(context),
          ),
        ),
        _section(
          'Sparkline Chart',
          SparklineChartWidget(
            dataSets: _dataSets,
            config: config,
            title: 'Operations Trend',
            onPointTap: _onPointTap(context),
          ),
        ),
        _section(
          'Scatter Chart',
          ScatterChartWidget(
            dataSets: _dataSets,
            config: config,
            title: 'Monthly Operations (Scatter)',
            onPointTap: _onPointTap(context),
          ),
        ),
        _section(
          'Pie Chart (non-zero only)',
          PieChartWidget(
            data: _pieDataNonZero,
            config: config,
            title: 'Operations Distribution',
            onSegmentTap: _onSegmentTap(context),
          ),
        ),
        _section(
          'Pie Chart (all months)',
          PieChartWidget(
            data: _pieData,
            config: config,
            title: 'Operations – All Months',
            subtitle: 'Includes zero-value months',
            onSegmentTap: _onSegmentTap(context),
          ),
        ),
        _section(
          'Donut Chart',
          DonutChartWidget(
            data: _pieDataNonZero,
            config: config,
            title: 'Operations Donut',
            onSegmentTap: _onSegmentTap(context),
          ),
        ),
        _section(
          'Pyramid Chart',
          PyramidChartWidget(
            data: _pieDataNonZero,
            config: config,
            title: 'Operations Pyramid',
            onSegmentTap: _onSegmentTap(context),
          ),
        ),
        _section(
          'Funnel Chart',
          FunnelChartWidget(
            data: _pieDataNonZero,
            config: config,
            title: 'Operations Funnel',
            onSegmentTap: _onSegmentTap(context),
          ),
        ),
        _section(
          'Radial Chart',
          RadialChartWidget(
            dataSets: _dataSets,
            config: config,
            title: 'Operations Radial',
            onPointTap: _onPointTap(context),
          ),
        ),
        _section(
          'Bubble Chart',
          BubbleChartWidget(
            dataSets: _bubbleData,
            config: config,
            title: 'Operations Bubble',
            onBubbleTap: _onBubbleTap(context),
          ),
        ),
        _section(
          'Radar Chart',
          RadarChartWidget(
            dataSets: _radarData,
            config: config,
            title: 'Operations Radar',
            onPointTap: _onPointTap(context),
          ),
        ),
        _section(
          'Gauge Chart',
          GaugeChartWidget(
            value: (_operations.last / _totalOps) * 100,
            config: config,
            title: 'Feb 2026 Share',
            centerLabel: 'Feb',
            unit: '%',
            onChartTap: () {
              // Gauge doesn't use ChartContextMenuHelper as it's not point-based in the same way
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(const SnackBar(content: Text('Feb 2026: 12 operations (57.1%)')));
            },
          ),
        ),
        const SizedBox(height: 32),
      ],
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────

  Widget _section(String label, Widget chart) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              chart,
            ],
          ),
        ),
      ),
    );
  }

  ChartPointCallback _onPointTap(BuildContext context) {
    return (point, datasetIndex, pointIndex, position) {
      ChartContextMenuHelper.show(
        context,
        point: point,
        segment: null,
        position: position,
        datasetIndex: datasetIndex,
        elementIndex: pointIndex,
        datasetLabel: point.label ?? 'Point',
        theme: theme,
        onViewDetails: () {
          _showDetailsDialog(context, point: point);
        },
        onExport: () {
          _showSnackBar(context, 'Exporting ${point.label ?? 'data'}...');
        },
        onShare: () {
          _showSnackBar(context, 'Sharing ${point.label ?? 'data'}...');
        },
      );
    };
  }

  BarCallback _onBarTap(BuildContext context) {
    return (point, datasetIndex, barIndex, position) {
      ChartContextMenuHelper.show(
        context,
        point: point,
        segment: null,
        position: position,
        datasetIndex: datasetIndex,
        elementIndex: barIndex,
        datasetLabel: point.label ?? 'Bar',
        theme: theme,
        onViewDetails: () {
          _showDetailsDialog(context, point: point);
        },
        onExport: () {
          _showSnackBar(context, 'Exporting ${point.label ?? 'data'}...');
        },
        onShare: () {
          _showSnackBar(context, 'Sharing ${point.label ?? 'data'}...');
        },
      );
    };
  }

  BubbleTapCallback _onBubbleTap(BuildContext context) {
    return (point, datasetIndex, pointIndex, position) {
      ChartContextMenuHelper.show(
        context,
        point: point,
        segment: null,
        position: position,
        datasetIndex: datasetIndex,
        elementIndex: pointIndex,
        datasetLabel: point.label ?? 'Bubble',
        theme: theme,
        onViewDetails: () {
          _showDetailsDialog(context, point: point);
        },
        onExport: () {
          _showSnackBar(context, 'Exporting ${point.label ?? 'data'}...');
        },
        onShare: () {
          _showSnackBar(context, 'Sharing ${point.label ?? 'data'}...');
        },
      );
    };
  }

  PieSegmentCallback _onSegmentTap(BuildContext context) {
    return (segment, index, position) {
      ChartContextMenuHelper.show(
        context,
        point: null,
        segment: segment,
        position: position,
        elementIndex: index,
        datasetLabel: segment.label,
        theme: theme,
        onViewDetails: () {
          _showDetailsDialog(context, segment: segment);
        },
        onExport: () {
          _showSnackBar(context, 'Exporting ${segment.label}...');
        },
        onShare: () {
          _showSnackBar(context, 'Sharing ${segment.label}...');
        },
      );
    };
  }

  void _showDetailsDialog(BuildContext context, {ChartDataPoint? point, PieData? segment}) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(point != null ? 'Point Details' : 'Segment Details'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (point != null) ...[
              Text('Label: ${point.label ?? 'N/A'}'),
              Text('Value: ${point.y.toStringAsFixed(2)}'),
              if (point is BubbleDataPoint) Text('Size: ${point.size.toStringAsFixed(2)}'),
            ] else if (segment != null) ...[
              Text('Label: ${segment.label}'),
              Text('Value: ${segment.value.toStringAsFixed(2)}'),
            ],
          ],
        ),
        actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Close'))],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message), duration: const Duration(seconds: 1)));
  }
}
