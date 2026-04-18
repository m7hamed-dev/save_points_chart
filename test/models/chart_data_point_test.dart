import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_chart/save_points_chart.dart';

void main() {
  group('ChartDataPoint', () {
    test('accepts num values for x and y', () {
      final point = ChartDataPoint(x: 10, y: 20.5);
      expect(point.x, 10.0);
      expect(point.y, 20.5);
    });

    test('parses numeric strings for x and y', () {
      final point = ChartDataPoint(x: '10', y: '20.5');
      expect(point.x, 10.0);
      expect(point.y, 20.5);
    });

    test('defaults showValue to true', () {
      final point = ChartDataPoint(x: 0, y: 0);
      expect(point.showValue, isTrue);
    });

    test('throws ArgumentError on non-numeric strings', () {
      expect(() => ChartDataPoint(x: 'abc', y: 0), throwsArgumentError);
      expect(() => ChartDataPoint(x: 0, y: 'xyz'), throwsArgumentError);
    });

    test('throws ArgumentError on unsupported types', () {
      expect(() => ChartDataPoint(x: [1, 2], y: 0), throwsArgumentError);
      expect(() => ChartDataPoint(x: 0, y: {'k': 1}), throwsArgumentError);
    });

    test('asserts that x and y are finite', () {
      expect(() => ChartDataPoint(x: double.nan, y: 0), throwsA(isA<AssertionError>()));
      expect(() => ChartDataPoint(x: 0, y: double.infinity), throwsA(isA<AssertionError>()));
      expect(() => ChartDataPoint(x: 0, y: double.negativeInfinity), throwsA(isA<AssertionError>()));
    });

    test('equality is structural', () {
      final a = ChartDataPoint(x: 1, y: 2, label: 'A');
      final b = ChartDataPoint(x: 1, y: 2, label: 'A');
      final c = ChartDataPoint(x: 1, y: 2, label: 'B');
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
      expect(a, isNot(equals(c)));
    });

    test('copyWith preserves untouched fields', () {
      final original = ChartDataPoint(x: 1, y: 2, label: 'A', showValue: false);
      final modified = original.copyWith(y: 99);
      expect(modified.x, 1.0);
      expect(modified.y, 99.0);
      expect(modified.label, 'A');
      expect(modified.showValue, isFalse);
    });
  });
}
