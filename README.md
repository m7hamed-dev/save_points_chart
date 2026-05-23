# save_points_chart

A modern Flutter charting library with canvas-based rendering, Material 3–friendly themes, smooth animations, and zero third-party runtime dependencies (Flutter SDK only).

[![pub package](https://img.shields.io/pub/v/save_points_chart.svg)](https://pub.dev/packages/save_points_chart)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

## Features

- **15+ chart types** — line, bar, area, pie/donut, scatter, radar, gauge, sparkline, stacked area, waterfall, funnel, bubble, heatmap, candlestick, and timeline
- **Unified API** — every chart uses `ChartConfig` + a typed widget (`LineChart`, `BarChart`, …)
- **Interactions** — tooltips, crosshair, tap selection, pinch zoom & pan (where applicable)
- **Theming** — `ChartTheme.light()`, `ChartTheme.dark()`, `ChartTheme.dashboard()`, or fully custom colors
- **Templates** — `ChartTemplateStyle.dashboard` (title, legend, grid) or `plain` (minimal chrome)
- **Animations** — configurable duration and curve tension for smooth line/area transitions
- **Export** — snapshot charts as PNG; optional PDF reports via `ChartWidgetController` / `ChartCard`
- **Accessibility** — `semanticLabel` on `ChartConfig` for screen readers
- **Extensible engine** — layer stack, render pipeline, and `ChartRenderer` plugins for custom charts

## Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  save_points_chart: ^1.9.1
```

Import the public API:

```dart
import 'package:save_points_chart/save_points_charts.dart';
```

## Quick start

```dart
import 'package:flutter/material.dart';
import 'package:save_points_chart/save_points_charts.dart';

class TrafficChart extends StatelessWidget {
  const TrafficChart({super.key});

  @override
  Widget build(BuildContext context) {
    final config = ChartConfig(
      title: 'Traffic trend',
      subtitle: 'Desktop vs mobile',
      xAxisTitle: 'Month',
      yAxisTitle: 'Users',
      showLegend: true,
      template: ChartTemplateStyle.dashboard,
      series: [
        ChartSeries(
          id: 'desktop',
          name: 'Desktop',
          points: const [
            ChartPoint(x: 0, y: 220, label: 'Jan'),
            ChartPoint(x: 1, y: 260, label: 'Feb'),
            ChartPoint(x: 2, y: 240, label: 'Mar'),
          ],
        ),
        ChartSeries(
          id: 'mobile',
          name: 'Mobile',
          points: const [
            ChartPoint(x: 0, y: 140, label: 'Jan'),
            ChartPoint(x: 1, y: 180, label: 'Feb'),
            ChartPoint(x: 2, y: 200, label: 'Mar'),
          ],
        ),
      ],
    );

    return SizedBox(
      height: 280,
      child: LineChart(config: config),
    );
  }
}
```

## Chart types

| Widget | Description | Notable options |
|--------|-------------|-----------------|
| `LineChart` | Cartesian line series | `LineChartMode.straight` / `smooth`, `fillArea` |
| `BarChart` | Vertical or horizontal bars | `BarChartOrientation`, `BarChartLayout.grouped` / `stacked` |
| `AreaChart` | Filled area under lines | Shares line renderer with fill |
| `PieChart` | Pie or donut slices | `isDonut`, `explodedIndex` |
| `ScatterChart` | XY scatter plot | — |
| `RadarChart` | Spider / radar chart | Label per point |
| `GaugeChart` | Single-value gauge | First point `y` = value |
| `SparklineChart` | Compact line (no axes chrome) | — |
| `StackedAreaChart` | Stacked filled areas | Multiple series |
| `WaterfallChart` | Running totals / P&L steps | `kWaterfallTypeKey` metadata |
| `FunnelChart` | Conversion funnel | Decreasing `y` values |
| `BubbleChart` | Sized bubbles in XY space | `toBubblePoints()` extension |
| `HeatmapChart` | Grid heatmap | — |
| `CandlestickChart` | OHLC-style financial bars | — |
| `TimelineChart` | Event timeline | — |

## Data model

### `ChartPoint`

A single `(x, y)` value with optional `label` and `metadata` (used for waterfall types, bubble size, etc.).

```dart
const ChartPoint(x: 0, y: 72, label: 'CPU');
```

### `ChartSeries`

Named list of points with optional `SeriesStyle` (color, stroke, markers, gradient).

```dart
ChartSeries(
  id: 'sales',
  name: 'Sales',
  points: [20, 25, 30, 28, 35].toChartPoints(),
  style: const SeriesStyle(showMarkers: true),
);
```

### `ChartConfig`

Global settings shared by all chart widgets:

| Property | Purpose |
|----------|---------|
| `series` | One or more `ChartSeries` |
| `title` / `subtitle` | Header text (dashboard template) |
| `xAxisTitle` / `yAxisTitle` | Axis labels |
| `theme` | Override `ChartTheme` |
| `template` | `dashboard` or `plain` |
| `showGrid` / `showAxis` | Cartesian chrome |
| `showLegend` / `legendPosition` | Legend placement |
| `animate` / `animationDuration` | Entry animation |
| `curveTension` | Smooth line curvature (0–1) |
| `viewport` | Zoom/pan bounds (`ChartViewport`) |
| `semanticLabel` | Accessibility label |

## Convenience extensions

```dart
// Iterable<num> → List<ChartPoint>
[20, 25, 30].toChartPoints();

// List<ChartPoint> → ChartSeries
points.toSeries(id: 'a', name: 'Product A');

// (x, y, size) tuples → bubble points
[(10, 20, 40), (25, 35, 80)].toBubblePoints();
```

## Waterfall metadata

Use `kWaterfallTypeKey` in point metadata for special bars:

```dart
ChartPoint(
  x: 0,
  y: 100,
  label: 'Start',
  metadata: {kWaterfallTypeKey: 'absolute'},
),
ChartPoint(
  x: 3,
  y: 0,
  label: 'Subtotal',
  metadata: {kWaterfallTypeKey: 'subtotal'},
),
```

Supported values: `delta` (default), `absolute`, `subtotal`, `total`.

## Theming

```dart
ChartConfig(
  theme: ChartTheme.dark(),
  // or ChartTheme.light(), ChartTheme.dashboard()
  series: [...],
);
```

`ChartTheme` controls background, grid, axis, tooltip, crosshair, selection highlight, series palette, shadows, and typography. Per-series colors can override the palette via `SeriesStyle.color`.

## Interactions

`ChartWidget` (used internally by every chart) supports:

- **Tooltip** — hover/tap hit testing (`enableTooltip`, default `true`)
- **Crosshair** — follows pointer on cartesian charts (`enableCrosshair`)
- **Zoom & pan** — pinch/drag on cartesian charts (`enableZoomPan`)
- **Selection** — `onSelection: (ChartHitResult hit) { ... }`

Pie, gauge, heatmap, and similar charts disable zoom/crosshair where it does not apply.

## Export (PNG / PDF)

Attach a `ChartWidgetController` and optionally wrap with `ChartCard` for toolbar buttons:

```dart
final controller = ChartWidgetController();

ChartCard(
  config: config,
  controller: controller,
  child: LineChart(config: config, controller: controller),
);

// Programmatic export
final pngBytes = await controller.exportPng();
final pdfBytes = await controller.exportPdfFromConfig(config);
```

Low-level API without a controller:

```dart
final bytes = await ChartExport.toPng(globalKey);
```

Charts render inside a `RepaintBoundary`; exports capture the canvas (tooltips overlay is excluded).

## Custom charts

Build on the engine layer exported from `save_points_charts.dart`:

1. Implement `ChartRenderer` with a `draw(Canvas, Size, ChartContext)` method.
2. Pass your renderer to `ChartWidget(config: ..., renderers: [MyRenderer()])`.
3. Optionally register plugins via `PluginRegistry` and compose layers (`GridLayer`, `AxisLayer`, `SeriesLayer`, …).

## Architecture

```
ChartWidget
  └── ChartEngine (config + theme + renderers)
        └── RenderPipeline / LayerStack
              └── ChartPainter (CustomPaint)
```

Models live under `lib/models/`, canvas renderers under `lib/charts/`, and shared infrastructure (axis, gestures, tooltips, zoom) under `lib/core/`.

## Example app

```bash
cd example
flutter run
```

The demo includes a dashboard layout and an “All charts” gallery with export buttons.

## Links

- [Pub.dev](https://pub.dev/packages/save_points_chart)
- [API documentation](https://pub.dev/documentation/save_points_chart/latest/)
- [Repository](https://github.com/m7hamed-dev/save_points_chart)
- [Issue tracker](https://github.com/m7hamed-dev/save_points_chart/issues)

## License

Apache License 2.0 — see [LICENSE](LICENSE).
