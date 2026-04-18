import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_chart/save_points_chart.dart';

void main() {
  // A minimal host widget that exposes its BuildContext so we can call
  // ChartContextMenuHelper.show from inside the framework.
  Future<BuildContext> pumpHost(WidgetTester tester) async {
    late BuildContext capturedContext;
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: Builder(
            builder: (context) {
              capturedContext = context;
              return const SizedBox.expand();
            },
          ),
        ),
      ),
    );
    return capturedContext;
  }

  ChartDataPoint makePoint() => ChartDataPoint(x: 1, y: 2, label: 'Jan');

  tearDown(() {
    // Leave no overlay entries across tests.
    ChartContextMenuHelper.hide();
  });

  group('ChartContextMenuHelper.show / hide', () {
    testWidgets('is a no-op when no actions are provided', (tester) async {
      final context = await pumpHost(tester);

      ChartContextMenuHelper.show(
        context,
        point: makePoint(),
        segment: null,
        position: const Offset(100, 100),
      );
      await tester.pump();

      expect(ChartContextMenuHelper.isVisible, isFalse);
      expect(find.byType(ChartContextMenu), findsNothing);
    });

    testWidgets('shows a menu when at least one action is provided', (tester) async {
      final context = await pumpHost(tester);

      ChartContextMenuHelper.show(
        context,
        point: makePoint(),
        segment: null,
        position: const Offset(100, 100),
        onViewDetails: () {},
      );
      await tester.pump();

      expect(ChartContextMenuHelper.isVisible, isTrue);
      expect(find.byType(ChartContextMenu), findsOneWidget);
    });

    testWidgets('hide() removes the menu', (tester) async {
      final context = await pumpHost(tester);

      ChartContextMenuHelper.show(
        context,
        point: makePoint(),
        segment: null,
        position: const Offset(100, 100),
        onExport: () {},
      );
      await tester.pump();
      expect(find.byType(ChartContextMenu), findsOneWidget);

      ChartContextMenuHelper.hide();
      await tester.pump();

      expect(ChartContextMenuHelper.isVisible, isFalse);
      expect(find.byType(ChartContextMenu), findsNothing);
    });

    testWidgets('hide() is idempotent (safe to call twice)', (tester) async {
      await pumpHost(tester);

      ChartContextMenuHelper.hide();
      ChartContextMenuHelper.hide();
      await tester.pump();

      expect(ChartContextMenuHelper.isVisible, isFalse);
    });

    testWidgets('show replaces an existing menu', (tester) async {
      final context = await pumpHost(tester);

      ChartContextMenuHelper.show(
        context,
        point: makePoint(),
        segment: null,
        position: const Offset(10, 10),
        onViewDetails: () {},
      );
      await tester.pump();
      expect(find.byType(ChartContextMenu), findsOneWidget);

      ChartContextMenuHelper.show(
        context,
        point: makePoint(),
        segment: null,
        position: const Offset(200, 200),
        onExport: () {},
      );
      await tester.pump();
      expect(find.byType(ChartContextMenu), findsOneWidget);
    });

    testWidgets('tapping the backdrop dismisses the menu', (tester) async {
      final context = await pumpHost(tester);

      ChartContextMenuHelper.show(
        context,
        point: makePoint(),
        segment: null,
        position: const Offset(100, 100),
        onViewDetails: () {},
      );
      await tester.pump();
      expect(find.byType(ChartContextMenu), findsOneWidget);

      // Tap an area well away from the menu content.
      await tester.tapAt(const Offset(5, 5));
      await tester.pump();

      expect(find.byType(ChartContextMenu), findsNothing);
    });

    testWidgets('pressing Escape dismisses the menu', (tester) async {
      final context = await pumpHost(tester);

      ChartContextMenuHelper.show(
        context,
        point: makePoint(),
        segment: null,
        position: const Offset(100, 100),
        onViewDetails: () {},
      );
      await tester.pump();
      expect(find.byType(ChartContextMenu), findsOneWidget);

      await tester.sendKeyEvent(LogicalKeyboardKey.escape);
      await tester.pump();

      expect(find.byType(ChartContextMenu), findsNothing);
    });

    testWidgets('accepts a non-finite position without throwing', (tester) async {
      final context = await pumpHost(tester);

      ChartContextMenuHelper.show(
        context,
        point: makePoint(),
        segment: null,
        position: const Offset(double.nan, double.infinity),
        onExport: () {},
      );
      await tester.pump();

      // Menu is shown and recovered to a sane position; no exception.
      expect(tester.takeException(), isNull);
      expect(find.byType(ChartContextMenu), findsOneWidget);
    });
  });
}
