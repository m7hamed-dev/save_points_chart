import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_chart/save_points_chart.dart';

void main() {
  Widget wrap(Widget child) {
    return MaterialApp(
      home: Scaffold(body: Padding(padding: const EdgeInsets.all(16), child: child)),
    );
  }

  group('ChartVisibilityController', () {
    test('starts empty', () {
      final c = ChartVisibilityController();
      expect(c.hidden, isEmpty);
      expect(c.isHidden(Colors.red), isFalse);
    });

    test('starts with initiallyHidden seed', () {
      final c = ChartVisibilityController(initiallyHidden: const [Colors.red]);
      expect(c.isHidden(Colors.red), isTrue);
      expect(c.isHidden(Colors.blue), isFalse);
    });

    test('toggle adds and removes', () {
      final c = ChartVisibilityController();
      c.toggle(Colors.red);
      expect(c.isHidden(Colors.red), isTrue);
      c.toggle(Colors.red);
      expect(c.isHidden(Colors.red), isFalse);
    });

    test('hide / show / showAll', () {
      final c = ChartVisibilityController();
      c.hide(Colors.red);
      c.hide(Colors.blue);
      expect(c.hidden.length, 2);
      c.show(Colors.red);
      expect(c.hidden, {Colors.blue});
      c.showAll();
      expect(c.hidden, isEmpty);
    });

    test('solo hides everything except the target', () {
      final c = ChartVisibilityController();
      c.solo(Colors.red, const [Colors.red, Colors.blue, Colors.green]);
      expect(c.isHidden(Colors.red), isFalse);
      expect(c.isHidden(Colors.blue), isTrue);
      expect(c.isHidden(Colors.green), isTrue);
    });

    test('filter removes hidden datasets', () {
      final c = ChartVisibilityController();
      final sets = [
        ChartDataSet(color: Colors.red, dataPoint: ChartDataPoint(x: 0, y: 1)),
        ChartDataSet(color: Colors.blue, dataPoint: ChartDataPoint(x: 0, y: 2)),
        ChartDataSet(color: Colors.red, dataPoint: ChartDataPoint(x: 1, y: 3)),
      ];
      c.hide(Colors.red);
      final filtered = c.filter(sets);
      expect(filtered, hasLength(1));
      expect(filtered.single.color, Colors.blue);
    });

    test('filter returns original when nothing hidden', () {
      final c = ChartVisibilityController();
      final sets = [
        ChartDataSet(color: Colors.red, dataPoint: ChartDataPoint(x: 0, y: 1)),
      ];
      expect(c.filter(sets), same(sets));
    });

    test('notifies listeners on state change', () {
      final c = ChartVisibilityController();
      var count = 0;
      c.addListener(() => count++);
      c.toggle(Colors.red);
      c.hide(Colors.red); // already hidden
      c.show(Colors.red);
      expect(count, 2);
    });
  });

  group('ChartLegend', () {
    testWidgets('renders items and strikes through hidden ones', (tester) async {
      await tester.pumpWidget(
        wrap(
          ChartLegend(
            items: const [
              ChartLegendItem(color: Colors.red, label: 'Sales'),
              ChartLegendItem(color: Colors.blue, label: 'Revenue'),
            ],
            hidden: {Colors.red},
          ),
        ),
      );
      expect(find.text('Sales'), findsOneWidget);
      expect(find.text('Revenue'), findsOneWidget);
      final salesText = tester.widget<Text>(find.text('Sales'));
      expect(salesText.style?.decoration, TextDecoration.lineThrough);
    });

    testWidgets('fires onToggle when tapped', (tester) async {
      Color? tapped;
      await tester.pumpWidget(
        wrap(
          ChartLegend(
            items: const [ChartLegendItem(color: Colors.red, label: 'Sales')],
            onToggle: (c) => tapped = c,
          ),
        ),
      );
      await tester.tap(find.text('Sales'));
      await tester.pump();
      expect(tapped, Colors.red);
    });

    testWidgets('fromDataSets groups by color', (tester) async {
      final sets = [
        ChartDataSet(color: Colors.red, dataPoint: ChartDataPoint(x: 0, y: 1, label: 'Sales')),
        ChartDataSet(color: Colors.red, dataPoint: ChartDataPoint(x: 1, y: 2, label: 'Sales')),
        ChartDataSet(color: Colors.blue, dataPoint: ChartDataPoint(x: 0, y: 3, label: 'Revenue')),
      ];
      await tester.pumpWidget(wrap(ChartLegend.fromDataSets(sets)));
      expect(find.text('Sales'), findsOneWidget);
      expect(find.text('Revenue'), findsOneWidget);
    });
  });

  group('ChartLegendScope', () {
    testWidgets('tapping a legend item hides its series from the builder', (tester) async {
      final sets = [
        ChartDataSet(color: Colors.red, dataPoint: ChartDataPoint(x: 0, y: 1, label: 'A')),
        ChartDataSet(color: Colors.blue, dataPoint: ChartDataPoint(x: 0, y: 2, label: 'B')),
      ];

      await tester.pumpWidget(
        wrap(
          SizedBox(
            width: 400,
            height: 400,
            child: ChartLegendScope(
              dataSets: sets,
              builder: (context, visible) {
                // Report visible count via a Text we can assert on.
                return Text('visible=${visible.length}');
              },
            ),
          ),
        ),
      );

      expect(find.text('visible=2'), findsOneWidget);

      await tester.tap(find.text('A'));
      await tester.pump();

      expect(find.text('visible=1'), findsOneWidget);

      await tester.tap(find.text('A'));
      await tester.pump();

      expect(find.text('visible=2'), findsOneWidget);
    });

    testWidgets('honors an external controller', (tester) async {
      final controller = ChartVisibilityController(initiallyHidden: const [Colors.red]);
      addTearDown(controller.dispose);

      final sets = [
        ChartDataSet(color: Colors.red, dataPoint: ChartDataPoint(x: 0, y: 1, label: 'A')),
        ChartDataSet(color: Colors.blue, dataPoint: ChartDataPoint(x: 0, y: 2, label: 'B')),
      ];

      await tester.pumpWidget(
        wrap(
          ChartLegendScope(
            controller: controller,
            dataSets: sets,
            builder: (context, visible) => Text('visible=${visible.length}'),
          ),
        ),
      );

      expect(find.text('visible=1'), findsOneWidget);

      controller.showAll();
      await tester.pump();
      expect(find.text('visible=2'), findsOneWidget);
    });
  });
}
