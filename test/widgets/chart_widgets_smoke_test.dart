import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_chart/save_points_chart.dart';

/// Smoke tests: every chart widget should build without throwing for a minimal
/// but meaningful data set.
void main() {
  // ── Sample data builders ────────────────────────────────────────────────

  List<ChartDataSet> lineLikeData() => List.generate(
    5,
    (i) => ChartDataSet(
      color: const Color(0xFF6366F1),
      dataPoint: ChartDataPoint(x: i, y: 10.0 + i * 3, label: 'M${i + 1}'),
    ),
  );

  List<BubbleDataSet> bubbleData() => [
    BubbleDataSet(
      color: Colors.indigo,
      dataPoints: List.generate(
        4,
        (i) => BubbleDataPoint(x: i, y: 10 + i * 2, size: 20 + i * 5, label: 'B$i'),
      ),
    ),
  ];

  List<RadarDataSet> radarData() => [
    RadarDataSet(
      color: Colors.indigo,
      dataPoints: [
        RadarDataPoint(label: 'Speed', value: 80),
        RadarDataPoint(label: 'Quality', value: 90),
        RadarDataPoint(label: 'Design', value: 75),
      ],
    ),
  ];

  List<PieData> pieData() => [
    PieData(label: 'Mobile', value: 45, color: Colors.blue),
    PieData(label: 'Desktop', value: 35, color: Colors.green),
    PieData(label: 'Tablet', value: 20, color: Colors.orange),
  ];

  Widget wrap(Widget child, {double width = 400, double height = 400}) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(width: width, height: height, child: child),
      ),
    );
  }

  Future<void> pumpAndLetAnimationsRun(
    WidgetTester tester,
    Widget child, {
    double width = 400,
    double height = 400,
  }) async {
    await tester.pumpWidget(wrap(child, width: width, height: height));
    // Pump through any entrance animations.
    await tester.pump(const Duration(milliseconds: 50));
    await tester.pump(const Duration(seconds: 2));
  }

  group('Chart widgets smoke tests', () {
    testWidgets('LineChartWidget builds', (tester) async {
      await pumpAndLetAnimationsRun(tester, LineChartWidget(dataSets: lineLikeData()));
      expect(find.byType(LineChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('BarChartWidget builds', (tester) async {
      await pumpAndLetAnimationsRun(tester, BarChartWidget(dataSets: lineLikeData()));
      expect(find.byType(BarChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('AreaChartWidget builds', (tester) async {
      await pumpAndLetAnimationsRun(tester, AreaChartWidget(dataSets: lineLikeData()));
      expect(find.byType(AreaChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('StackedAreaChartWidget builds', (tester) async {
      await pumpAndLetAnimationsRun(tester, StackedAreaChartWidget(dataSets: lineLikeData()));
      expect(find.byType(StackedAreaChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('PieChartWidget builds', (tester) async {
      await pumpAndLetAnimationsRun(tester, PieChartWidget(data: pieData()));
      expect(find.byType(PieChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('DonutChartWidget builds', (tester) async {
      await pumpAndLetAnimationsRun(tester, DonutChartWidget(data: pieData()));
      expect(find.byType(DonutChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RadialChartWidget builds', (tester) async {
      await pumpAndLetAnimationsRun(tester, RadialChartWidget(dataSets: lineLikeData()));
      expect(find.byType(RadialChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SparklineChartWidget builds', (tester) async {
      await pumpAndLetAnimationsRun(tester, SparklineChartWidget(dataSets: lineLikeData()));
      expect(find.byType(SparklineChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('ScatterChartWidget builds', (tester) async {
      await pumpAndLetAnimationsRun(tester, ScatterChartWidget(dataSets: lineLikeData()));
      expect(find.byType(ScatterChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('BubbleChartWidget builds', (tester) async {
      await pumpAndLetAnimationsRun(tester, BubbleChartWidget(dataSets: bubbleData()));
      expect(find.byType(BubbleChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('RadarChartWidget builds', (tester) async {
      // Radar needs more vertical space for its axis labels.
      await pumpAndLetAnimationsRun(tester, RadarChartWidget(dataSets: radarData()), height: 600);
      expect(find.byType(RadarChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('GaugeChartWidget builds', (tester) async {
      await pumpAndLetAnimationsRun(tester, const GaugeChartWidget(value: 75));
      expect(find.byType(GaugeChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('SplineChartWidget builds', (tester) async {
      await pumpAndLetAnimationsRun(tester, SplineChartWidget(dataSets: lineLikeData()));
      expect(find.byType(SplineChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('StepLineChartWidget builds', (tester) async {
      await pumpAndLetAnimationsRun(tester, StepLineChartWidget(dataSets: lineLikeData()));
      expect(find.byType(StepLineChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('StackedColumnChartWidget builds', (tester) async {
      await pumpAndLetAnimationsRun(tester, StackedColumnChartWidget(dataSets: lineLikeData()));
      expect(find.byType(StackedColumnChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('PyramidChartWidget builds', (tester) async {
      await pumpAndLetAnimationsRun(tester, PyramidChartWidget(data: pieData()));
      expect(find.byType(PyramidChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('FunnelChartWidget builds', (tester) async {
      await pumpAndLetAnimationsRun(tester, FunnelChartWidget(data: pieData()));
      expect(find.byType(FunnelChartWidget), findsOneWidget);
      expect(tester.takeException(), isNull);
    });
  });

  group('Chart widgets loading/error states', () {
    testWidgets('LineChartWidget renders loading state', (tester) async {
      await pumpAndLetAnimationsRun(
        tester,
        LineChartWidget(dataSets: lineLikeData(), isLoading: true),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('LineChartWidget renders error state via config', (tester) async {
      await pumpAndLetAnimationsRun(
        tester,
        LineChartWidget(
          dataSets: lineLikeData(),
          isError: true,
          config: const ChartsConfig(errorMessage: 'Failed to load'),
        ),
      );
      expect(tester.takeException(), isNull);
    });

    testWidgets('LineChartWidget renders empty dataset without crashing', (tester) async {
      await pumpAndLetAnimationsRun(tester, const LineChartWidget(dataSets: []));
      expect(tester.takeException(), isNull);
    });
  });

  group('ChartEmptyScope', () {
    testWidgets('shows emptyWidget when all data points are (0,0)', (tester) async {
      final emptySets = [
        ChartDataSet(color: Colors.red, dataPoint: ChartDataPoint(x: 0, y: 0)),
      ];
      await tester.pumpWidget(
        wrap(
          ChartEmptyScope(
            dataSets: emptySets,
            emptyWidget: const Text('No data'),
            child: const Text('Chart'),
          ),
        ),
      );
      expect(find.text('No data'), findsOneWidget);
      expect(find.text('Chart'), findsNothing);
    });

    testWidgets('shows child when data is non-empty', (tester) async {
      final sets = [
        ChartDataSet(color: Colors.red, dataPoint: ChartDataPoint(x: 1, y: 2)),
      ];
      await tester.pumpWidget(
        wrap(
          ChartEmptyScope(
            dataSets: sets,
            emptyWidget: const Text('No data'),
            child: const Text('Chart'),
          ),
        ),
      );
      expect(find.text('Chart'), findsOneWidget);
      expect(find.text('No data'), findsNothing);
    });
  });
}
