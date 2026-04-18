import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_chart/save_points_chart.dart';

void main() {
  group('RadarDataPoint', () {
    test('accepts num values', () {
      final point = RadarDataPoint(label: 'Speed', value: 80);
      expect(point.label, 'Speed');
      expect(point.value, 80.0);
    });

    test('parses numeric strings for value', () {
      final point = RadarDataPoint(label: 'Speed', value: '75.5');
      expect(point.value, 75.5);
    });

    test('asserts label is not empty', () {
      expect(() => RadarDataPoint(label: '', value: 50), throwsA(isA<AssertionError>()));
    });

    test('asserts value is non-negative', () {
      expect(() => RadarDataPoint(label: 'X', value: -1), throwsA(isA<AssertionError>()));
    });

    test('asserts value is finite', () {
      expect(
        () => RadarDataPoint(label: 'X', value: double.nan),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws on unparseable values', () {
      expect(() => RadarDataPoint(label: 'X', value: 'bad'), throwsArgumentError);
    });

    test('equality is structural', () {
      final a = RadarDataPoint(label: 'S', value: 1);
      final b = RadarDataPoint(label: 'S', value: 1);
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });
  });
}
