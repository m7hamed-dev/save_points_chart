import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_chart/save_points_chart.dart';

void main() {
  group('ChartDataSet', () {
    test('isAllDataPointsEmpty returns true for empty list', () {
      expect(ChartDataSet.isAllDataPointsEmpty(const []), isTrue);
    });

    test('isAllDataPointsEmpty returns true when every point is (0,0)', () {
      final sets = [
        ChartDataSet(color: Colors.red, dataPoint: ChartDataPoint(x: 0, y: 0)),
        ChartDataSet(color: Colors.blue, dataPoint: ChartDataPoint(x: 0, y: 0)),
      ];
      expect(ChartDataSet.isAllDataPointsEmpty(sets), isTrue);
    });

    test('isAllDataPointsEmpty returns false when any point is non-zero', () {
      final sets = [
        ChartDataSet(color: Colors.red, dataPoint: ChartDataPoint(x: 0, y: 0)),
        ChartDataSet(color: Colors.blue, dataPoint: ChartDataPoint(x: 1, y: 0)),
      ];
      expect(ChartDataSet.isAllDataPointsEmpty(sets), isFalse);
    });

    test('equality is structural', () {
      final a = ChartDataSet(color: Colors.red, dataPoint: ChartDataPoint(x: 1, y: 2));
      final b = ChartDataSet(color: Colors.red, dataPoint: ChartDataPoint(x: 1, y: 2));
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith preserves untouched fields', () {
      final original = ChartDataSet(color: Colors.red, dataPoint: ChartDataPoint(x: 1, y: 2));
      final modified = original.copyWith(color: Colors.blue);
      expect(modified.color, Colors.blue);
      expect(modified.dataPoint.x, 1.0);
      expect(modified.dataPoint.y, 2.0);
    });
  });
}
