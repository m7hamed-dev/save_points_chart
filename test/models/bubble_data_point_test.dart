import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_chart/save_points_chart.dart';

void main() {
  group('BubbleDataPoint', () {
    test('accepts num values for size', () {
      final point = BubbleDataPoint(x: 1, y: 2, size: 50);
      expect(point.size, 50.0);
    });

    test('parses numeric strings for size', () {
      final point = BubbleDataPoint(x: 1, y: 2, size: '42.5');
      expect(point.size, 42.5);
    });

    test('inherits x/y validation from ChartDataPoint', () {
      expect(() => BubbleDataPoint(x: 'bad', y: 0, size: 10), throwsArgumentError);
    });

    test('asserts size is positive', () {
      expect(() => BubbleDataPoint(x: 0, y: 0, size: 0), throwsA(isA<AssertionError>()));
      expect(() => BubbleDataPoint(x: 0, y: 0, size: -5), throwsA(isA<AssertionError>()));
    });

    test('asserts size is finite', () {
      expect(
        () => BubbleDataPoint(x: 0, y: 0, size: double.infinity),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws ArgumentError on non-numeric size', () {
      expect(() => BubbleDataPoint(x: 0, y: 0, size: 'nope'), throwsArgumentError);
    });

    test('equality includes size', () {
      final a = BubbleDataPoint(x: 1, y: 2, size: 10);
      final b = BubbleDataPoint(x: 1, y: 2, size: 10);
      final c = BubbleDataPoint(x: 1, y: 2, size: 11);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });

    test('copyWith preserves untouched fields', () {
      final original = BubbleDataPoint(x: 1, y: 2, size: 10, label: 'A');
      final modified = original.copyWith(size: 20);
      expect(modified.x, 1.0);
      expect(modified.y, 2.0);
      expect(modified.size, 20.0);
      expect(modified.label, 'A');
    });
  });
}
