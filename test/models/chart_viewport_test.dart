import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_chart/models/viewport.dart';

void main() {
  group('ChartViewport.fromPoints', () {
    test('single point yields non-zero width and height', () {
      final viewport = ChartViewport.fromPoints([0], [72]);

      expect(viewport.width, greaterThan(0));
      expect(viewport.height, greaterThan(0));
    });

    test('duplicate coordinates expand to a minimum span', () {
      final viewport = ChartViewport.fromPoints([5, 5], [10, 10]);

      expect(viewport.width, greaterThan(0));
      expect(viewport.height, greaterThan(0));
    });
  });
}
