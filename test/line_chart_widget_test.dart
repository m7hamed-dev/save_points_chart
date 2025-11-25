import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_chart/widgets/line_chart_widget.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/theme/chart_theme.dart';

void main() {
  group('LineChartWidget', () {
    final sampleData = [
      ChartDataSet(
        label: 'Sales',
        color: Colors.blue,
        dataPoints: [
          const ChartDataPoint(x: 0, y: 10),
          const ChartDataPoint(x: 1, y: 20),
          const ChartDataPoint(x: 2, y: 15),
        ],
      ),
    ];

    testWidgets('renders line chart with data', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LineChartWidget(
              dataSets: sampleData,
              theme: ChartTheme.light(),
            ),
          ),
        ),
      );

      expect(find.byType(LineChartWidget), findsOneWidget);
    });

    testWidgets('displays loading state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LineChartWidget(
              dataSets: sampleData,
              theme: ChartTheme.light(),
              isLoading: true,
            ),
          ),
        ),
      );

      expect(find.text('Loading chart data...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays error state', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LineChartWidget(
              dataSets: sampleData,
              theme: ChartTheme.light(),
              isError: true,
              errorMessage: 'Test error',
            ),
          ),
        ),
      );

      expect(find.text('Test error'), findsOneWidget);
      expect(find.byIcon(Icons.error_outline), findsOneWidget);
    });

    testWidgets('displays title and subtitle', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: LineChartWidget(
              dataSets: sampleData,
              theme: ChartTheme.light(),
              title: 'Sales Chart',
              subtitle: 'Monthly data',
            ),
          ),
        ),
      );

      expect(find.text('Sales Chart'), findsOneWidget);
      expect(find.text('Monthly data'), findsOneWidget);
    });
  });
}

