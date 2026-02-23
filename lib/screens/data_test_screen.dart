import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_chart.dart';

/// Test page that renders all chart types using real API data.
class DataTestScreen extends StatelessWidget {
  const DataTestScreen({super.key, required this.theme});

  final ChartTheme theme;

  // ── Shared data derived from the JSON ──────────────────────────────────

  static const _months = ['Oct 25', 'Nov 25', 'Dec 25', 'Jan 26', 'Feb 26'];
  static const _operations = [9, 0, 0, 0, 12];
  static const _totalOps = 21;

  static const _color = Color(0xFF6366F1);

  static const List<ChartDataSet> _dataSets = [
    ChartDataSet(
      color: _color,
      dataPoint: ChartDataPoint(x: 0, y: 9, label: 'Oct 25'),
    ),
    ChartDataSet(
      color: _color,
      dataPoint: ChartDataPoint(x: 1, y: 0, label: 'Nov 25'),
    ),
    ChartDataSet(
      color: _color,
      dataPoint: ChartDataPoint(x: 2, y: 0, label: 'Dec 25'),
    ),
    ChartDataSet(
      color: _color,
      dataPoint: ChartDataPoint(x: 3, y: 0, label: 'Jan 26'),
    ),
    ChartDataSet(
      color: _color,
      dataPoint: ChartDataPoint(x: 4, y: 12, label: 'Feb 26'),
    ),
  ];

  static const List<PieData> _pieData = [
    PieData(label: 'Oct 25', value: 9, color: Color(0xFF6366F1)),
    PieData(label: 'Nov 25', color: Color(0xFF8B5CF6)),
    PieData(label: 'Dec 25', color: Color(0xFFEC4899)),
    PieData(label: 'Jan 26', color: Color(0xFF10B981)),
    PieData(label: 'Feb 26', value: 12, color: Color(0xFFF59E0B)),
  ];

  static const List<PieData> _pieDataNonZero = [
    PieData(label: 'Oct 25', value: 9, color: Color(0xFF6366F1)),
    PieData(label: 'Feb 26', value: 12, color: Color(0xFFF59E0B)),
  ];

  static List<RadarDataSet> get _radarData => [
        RadarDataSet(
          color: _color,
          dataPoints: List.generate(
            _months.length,
            (i) => RadarDataPoint(label: _months[i], value: _operations[i].toDouble()),
          ),
        ),
      ];

  static List<BubbleDataSet> get _bubbleData => [
        BubbleDataSet(
          color: _color,
          dataPoints: List.generate(
            _months.length,
            (i) => BubbleDataPoint(
              x: i.toDouble(),
              y: _operations[i].toDouble(),
              size: (_operations[i] + 2).toDouble(),
              label: _months[i],
            ),
          ),
        ),
      ];

  @override
  Widget build(BuildContext context) {
    final config = ChartsConfig(theme: theme);

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        _section('Line Chart', LineChartWidget(
          dataSets: _dataSets,
          config: config,
          title: 'Monthly Operations',
          subtitle: 'Oct 2025 – Feb 2026',
          onPointTap: _onPointTap(context),
        )),
        _section('Area Chart', AreaChartWidget(
          dataSets: _dataSets,
          config: config,
          title: 'Monthly Operations (Area)',
          onPointTap: _onPointTap(context),
        )),
        _section('Stacked Area Chart', StackedAreaChartWidget(
          dataSets: _dataSets,
          config: config,
          title: 'Monthly Operations (Stacked Area)',
          onPointTap: _onPointTap(context),
        )),
        _section('Bar Chart', BarChartWidget(
          dataSets: _dataSets,
          config: config,
          title: 'Monthly Operations (Bar)',
          onBarTap: _onBarTap(context),
        )),
        _section('Stacked Column Chart', StackedColumnChartWidget(
          dataSets: _dataSets,
          config: config,
          title: 'Monthly Operations (Stacked Column)',
          onBarTap: _onBarTap(context),
        )),
        _section('Spline Chart', SplineChartWidget(
          dataSets: _dataSets,
          config: config,
          title: 'Monthly Operations (Spline)',
          onPointTap: _onPointTap(context),
        )),
        _section('Step Line Chart', StepLineChartWidget(
          dataSets: _dataSets,
          config: config,
          title: 'Monthly Operations (Step Line)',
          onPointTap: _onPointTap(context),
        )),
        _section('Sparkline Chart', SparklineChartWidget(
          dataSets: _dataSets,
          config: config,
          title: 'Operations Trend',
          onPointTap: _onPointTap(context),
        )),
        _section('Scatter Chart', ScatterChartWidget(
          dataSets: _dataSets,
          config: config,
          title: 'Monthly Operations (Scatter)',
          onPointTap: _onPointTap(context),
        )),
        _section('Pie Chart (non-zero only)', PieChartWidget(
          data: _pieDataNonZero,
          config: config,
          title: 'Operations Distribution',
          onSegmentTap: _onSegmentTap(context),
        )),
        _section('Pie Chart (all months)', PieChartWidget(
          data: _pieData,
          config: config,
          title: 'Operations – All Months',
          subtitle: 'Includes zero-value months',
          onSegmentTap: _onSegmentTap(context),
        )),
        _section('Donut Chart', DonutChartWidget(
          data: _pieDataNonZero,
          config: config,
          title: 'Operations Donut',
          onSegmentTap: _onSegmentTap(context),
        )),
        _section('Pyramid Chart', PyramidChartWidget(
          data: _pieDataNonZero,
          config: config,
          title: 'Operations Pyramid',
          onSegmentTap: _onSegmentTap(context),
        )),
        _section('Funnel Chart', FunnelChartWidget(
          data: _pieDataNonZero,
          config: config,
          title: 'Operations Funnel',
          onSegmentTap: _onSegmentTap(context),
        )),
        _section('Radial Chart', RadialChartWidget(
          dataSets: _dataSets,
          config: config,
          title: 'Operations Radial',
          onPointTap: _onPointTap(context),
        )),
        _section('Bubble Chart', BubbleChartWidget(
          dataSets: _bubbleData,
          config: config,
          title: 'Operations Bubble',
          onBubbleTap: _onBubbleTap(context),
        )),
        _section('Radar Chart', RadarChartWidget(
          dataSets: _radarData,
          config: config,
          title: 'Operations Radar',
          onPointTap: _onPointTap(context),
        )),
        _section('Gauge Chart', GaugeChartWidget(
          value: (_operations.last / _totalOps) * 100,
          config: config,
          title: 'Feb 2026 Share',
          centerLabel: 'Feb',
          unit: '%',
          onChartTap: () {
            // Gauge doesn't use ChartContextMenuHelper as it's not point-based in the same way
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Feb 2026: 12 operations (57.1%)')),
            );
          },
        )),
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
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), duration: const Duration(seconds: 1)),
    );
  }
}
