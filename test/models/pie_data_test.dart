import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_chart/save_points_chart.dart';

void main() {
  group('PieData', () {
    test('creates with defaults', () {
      final pie = PieData(label: 'Mobile', value: 45, color: Colors.blue);
      expect(pie.label, 'Mobile');
      expect(pie.value, 45.0);
      expect(pie.color, Colors.blue);
      expect(pie.showValue, isTrue);
      expect(pie.showLabel, isTrue);
      expect(pie.circleSize, 18.0);
    });

    test('parses numeric string values', () {
      final pie = PieData(label: 'A', value: '12.5', color: Colors.red);
      expect(pie.value, 12.5);
    });

    test('asserts label is not empty', () {
      expect(() => PieData(label: '', value: 1, color: Colors.red), throwsA(isA<AssertionError>()));
    });

    test('asserts value is non-negative', () {
      expect(
        () => PieData(label: 'X', value: -1, color: Colors.red),
        throwsA(isA<AssertionError>()),
      );
    });

    test('asserts value is finite', () {
      expect(
        () => PieData(label: 'X', value: double.infinity, color: Colors.red),
        throwsA(isA<AssertionError>()),
      );
    });

    test('throws on unparseable values', () {
      expect(() => PieData(label: 'X', value: 'bad', color: Colors.red), throwsArgumentError);
    });

    test('equality is structural', () {
      final a = PieData(label: 'A', value: 1, color: Colors.red);
      final b = PieData(label: 'A', value: 1, color: Colors.red);
      final c = PieData(label: 'A', value: 2, color: Colors.red);
      expect(a, equals(b));
      expect(a, isNot(equals(c)));
    });
  });
}
