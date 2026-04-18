// The deprecated `Matrix4.scale` is convenient for test setup; the
// non-deprecated replacement is verbose and adds no value here.
// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:save_points_chart/save_points_chart.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(
    home: Scaffold(
      body: Center(
        child: SizedBox(width: 300, height: 300, child: child),
      ),
    ),
  );

  group('ChartPanZoomScope', () {
    testWidgets('renders child without controls by default', (tester) async {
      await tester.pumpWidget(
        wrap(
          const ChartPanZoomScope(
            child: ColoredBox(color: Colors.red, child: SizedBox.expand()),
          ),
        ),
      );
      expect(find.byType(InteractiveViewer), findsOneWidget);
      expect(find.byIcon(Icons.zoom_in), findsNothing);
      expect(find.byIcon(Icons.zoom_out), findsNothing);
      expect(find.byIcon(Icons.crop_free), findsNothing);
    });

    testWidgets('shows zoom controls when enabled', (tester) async {
      await tester.pumpWidget(
        wrap(
          const ChartPanZoomScope(
            showControls: true,
            child: ColoredBox(color: Colors.red, child: SizedBox.expand()),
          ),
        ),
      );
      expect(find.byIcon(Icons.zoom_in), findsOneWidget);
      expect(find.byIcon(Icons.zoom_out), findsOneWidget);
      expect(find.byIcon(Icons.crop_free), findsOneWidget);
    });

    testWidgets('zoom out is disabled at min scale (initial state)', (tester) async {
      await tester.pumpWidget(
        wrap(
          const ChartPanZoomScope(
            showControls: true,
            child: ColoredBox(color: Colors.red, child: SizedBox.expand()),
          ),
        ),
      );
      final zoomOut = tester.widget<IconButton>(
        find.ancestor(of: find.byIcon(Icons.zoom_out), matching: find.byType(IconButton)),
      );
      expect(zoomOut.onPressed, isNull);
    });

    testWidgets('reset is disabled when transform is identity', (tester) async {
      await tester.pumpWidget(
        wrap(
          const ChartPanZoomScope(
            showControls: true,
            child: ColoredBox(color: Colors.red, child: SizedBox.expand()),
          ),
        ),
      );
      final reset = tester.widget<IconButton>(
        find.ancestor(of: find.byIcon(Icons.crop_free), matching: find.byType(IconButton)),
      );
      expect(reset.onPressed, isNull);
    });

    testWidgets('external controller drives scale and enables reset', (tester) async {
      final controller = TransformationController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(
          ChartPanZoomScope(
            controller: controller,
            showControls: true,
            child: const ColoredBox(color: Colors.red, child: SizedBox.expand()),
          ),
        ),
      );

      controller.value = Matrix4.identity()..scale(2.0);
      await tester.pump();

      final reset = tester.widget<IconButton>(
        find.ancestor(of: find.byIcon(Icons.crop_free), matching: find.byType(IconButton)),
      );
      expect(reset.onPressed, isNotNull);
    });

    testWidgets('reset button returns transform to identity', (tester) async {
      final controller = TransformationController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(
          ChartPanZoomScope(
            controller: controller,
            showControls: true,
            hapticFeedback: false,
            child: const ColoredBox(color: Colors.red, child: SizedBox.expand()),
          ),
        ),
      );

      controller.value = Matrix4.identity()..scale(2.5);
      await tester.pump();
      expect(controller.value.getMaxScaleOnAxis(), closeTo(2.5, 0.001));

      await tester.tap(find.byIcon(Icons.crop_free));
      await tester.pump();
      expect(controller.value, equals(Matrix4.identity()));
    });

    testWidgets('zoom in button increases scale', (tester) async {
      final controller = TransformationController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(
          ChartPanZoomScope(
            controller: controller,
            showControls: true,
            hapticFeedback: false,
            zoomStep: 2.0,
            child: const ColoredBox(color: Colors.red, child: SizedBox.expand()),
          ),
        ),
      );

      expect(controller.value.getMaxScaleOnAxis(), closeTo(1.0, 0.001));
      await tester.tap(find.byIcon(Icons.zoom_in));
      await tester.pump();
      expect(controller.value.getMaxScaleOnAxis(), closeTo(2.0, 0.001));
    });

    testWidgets('zoom in stops at maxScale', (tester) async {
      final controller = TransformationController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        wrap(
          ChartPanZoomScope(
            controller: controller,
            showControls: true,
            hapticFeedback: false,
            maxScale: 3.0,
            zoomStep: 2.0,
            child: const ColoredBox(color: Colors.red, child: SizedBox.expand()),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.zoom_in));
      await tester.pump();
      expect(controller.value.getMaxScaleOnAxis(), closeTo(2.0, 0.001));

      await tester.tap(find.byIcon(Icons.zoom_in));
      await tester.pump();
      // Would be 4.0 but clamped to 3.0.
      expect(controller.value.getMaxScaleOnAxis(), closeTo(3.0, 0.001));
    });

    test('throws for invalid scale constraints', () {
      expect(
        () => ChartPanZoomScope(minScale: 0, child: const SizedBox()),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => ChartPanZoomScope(minScale: 3, maxScale: 1, child: const SizedBox()),
        throwsA(isA<AssertionError>()),
      );
      expect(
        () => ChartPanZoomScope(zoomStep: 1.0, child: const SizedBox()),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}
