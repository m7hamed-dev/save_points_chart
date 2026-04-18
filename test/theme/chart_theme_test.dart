import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_chart/save_points_chart.dart';

void main() {
  group('ChartTheme', () {
    test('light and dark have distinct background colors', () {
      final light = ChartTheme.light();
      final dark = ChartTheme.dark();
      expect(light.backgroundColor, isNot(equals(dark.backgroundColor)));
    });

    test('fromMaterialTheme picks light for light brightness', () {
      final theme = ChartTheme.fromMaterialTheme(ThemeData(brightness: Brightness.light));
      expect(theme, equals(ChartTheme.light()));
    });

    test('fromMaterialTheme picks dark for dark brightness', () {
      final theme = ChartTheme.fromMaterialTheme(ThemeData(brightness: Brightness.dark));
      expect(theme, equals(ChartTheme.dark()));
    });

    test('two light themes are equal (value equality)', () {
      final a = ChartTheme.light();
      final b = ChartTheme.light();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('two dark themes are equal (value equality)', () {
      final a = ChartTheme.dark();
      final b = ChartTheme.dark();
      expect(a, equals(b));
      expect(a.hashCode, equals(b.hashCode));
    });

    test('copyWith with different background changes equality', () {
      final original = ChartTheme.light();
      final modified = original.copyWith(backgroundColor: Colors.purple);
      expect(original, isNot(equals(modified)));
      expect(modified.backgroundColor, Colors.purple);
    });

    test('copyWith preserves untouched fields', () {
      final original = ChartTheme.light().copyWith(borderRadius: 32);
      final modified = original.copyWith(borderRadius: 8);
      expect(modified.borderRadius, 8);
      expect(modified.backgroundColor, equals(ChartTheme.light().backgroundColor));
      expect(modified.gradientColors, equals(ChartTheme.light().gradientColors));
    });

    test('equality distinguishes gradient color lists', () {
      final a = ChartTheme.light().copyWith(gradientColors: const [Colors.red, Colors.blue]);
      final b = ChartTheme.light().copyWith(gradientColors: const [Colors.red, Colors.green]);
      expect(a, isNot(equals(b)));
    });
  });

  group('LabelRotation', () {
    test('constants have expected values', () {
      expect(LabelRotation.none, 0);
      expect(LabelRotation.diagonalDown, 45);
      expect(LabelRotation.diagonalUp, -45);
      expect(LabelRotation.vertical, 90);
      expect(LabelRotation.verticalUp, -90);
    });
  });
}
