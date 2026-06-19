# save_points_chart

A modern Flutter charting library with canvas-based rendering, Material 3–friendly themes, smooth animations, and a single lightweight dependency (`pdf`, used only for PDF export — everything else is pure Flutter SDK).

[![pub package](https://img.shields.io/pub/v/save_points_chart.svg)](https://pub.dev/packages/save_points_chart)
[![pub points](https://img.shields.io/pub/points/save_points_chart.svg)](https://pub.dev/packages/save_points_chart/score)
[![platform](https://img.shields.io/badge/platform-Flutter-02569B.svg?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

## Contents

- [Features](#features)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Chart types](#chart-types)
- [Data model](#data-model)
- [Convenience extensions](#convenience-extensions)
- [Waterfall metadata](#waterfall-metadata)
- [Theming](#theming)
- [Interactions](#interactions)
- [Export (PNG / PDF)](#export-png--pdf)
- [Custom charts](#custom-charts)
- [Architecture](#architecture)
- [Example app](#example-app)
- [Links](#links)

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
- **Lightweight** — pure-Flutter rendering; the only runtime dependency is `pdf`, pulled in for report export

## Requirements

| | Version |
|---|---|
| Dart SDK | `^3.12.0` |
| Flutter | `>=1.17.0` |

## Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  save_points_chart: ^1.9.1
```

Or from the command line:

```bash
flutter pub add save_points_chart
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

The same `ChartConfig` drops into any chart widget — swap `LineChart` for `BarChart`, `AreaChart`, `ScatterChart`, and so on without touching your data.

## Chart types

| Widget | Description | Notable options |
|--------|-------------|-----------------|
| `LineChart` | Cartesian line series | `mode: LineChartMode.smooth` (default) / `straight`, `fillArea` |
| `BarChart` | Vertical or horizontal bars | `orientation: BarChartOrientation`, `layout: BarChartLayout.grouped` (default) / `stacked` |
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

Every widget accepts a `controller` (`ChartWidgetController`) for export and an optional `theme` override.

## Data model

### `ChartPoint`

A single `(x, y)` value with optional `label` and `metadata` (used for waterfall types, bubble size, etc.).

```dart
const ChartPoint(x: 0, y: 72, label: 'CPU');
```

### `ChartSeries`

Named list of points with optional `SeriesStyle`:

```dart
ChartSeries(
  id: 'sales',
  name: 'Sales',
  points: [20, 25, 30, 28, 35].toChartPoints(),
  style: const SeriesStyle(showMarkers: true),
);
```

`SeriesStyle` fields:

| Field | Default | Purpose |
|-------|---------|---------|
| `color` | theme palette | Stroke / fill base color |
| `strokeWidth` | `2.0` | Line thickness |
| `fillColor` | — | Area fill override |
| `gradient` | — | Gradient fill (overrides `fillColor`) |
| `showMarkers` | `false` | Draw point markers |
| `markerRadius` | `4.0` | Marker size |
| `opacity` | `1.0` | Series opacity |

### `ChartConfig`

Global settings shared by all chart widgets:

| Property | Default | Purpose |
|----------|---------|---------|
| `series` | `[]` | One or more `ChartSeries` |
| `title` / `subtitle` | — | Header text (dashboard template) |
| `xAxisTitle` / `yAxisTitle` | — | Axis labels |
| `theme` | — | Override `ChartTheme` |
| `template` | `dashboard` | `dashboard` or `plain` |
| `showGrid` / `showAxis` | `true` | Cartesian chrome |
| `showBorder` | `false` | Outer chart border |
| `showLegend` / `legendPosition` | `false` / `bottom` | Legend toggle and placement |
| `barBorderRadius` | `4` | Bar corner radius |
| `animate` / `animationDuration` | `true` / `300ms` | Entry animation |
| `curveTension` | `0.35` | Smooth line curvature (0–1) |
| `viewport` | auto | Zoom/pan bounds (`ChartViewport`) |
| `semanticLabel` | — | Accessibility label |

`ChartConfig` is immutable — use `copyWith(...)` to derive variants.

### `ChartViewport`

Constrains the visible data-space region. Build one from your data with `ChartViewport.fromPoints(xs, ys, padding: 0.05)`, or set bounds explicitly:

```dart
const ChartViewport(minX: 0, maxX: 12, minY: 0, maxY: 300);
```

## Convenience extensions

```dart
// Iterable<num> → List<ChartPoint>  (x auto-indexed; tune with startX / step)
[20, 25, 30].toChartPoints();
[20, 25, 30].toChartPoints(startX: 2020, step: 1);

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

`ChartTheme` controls background, grid, axis, tooltip, crosshair, selection highlight, series palette, shadows, and typography. Per-series colors can override the palette via `SeriesStyle.color`. A `theme` set on a widget takes precedence over the one on `ChartConfig`.

## Interactions

`ChartWidget` (used internally by every chart) supports:

- **Tooltip** — hover/tap hit testing (`enableTooltip`, default `true`)
- **Crosshair** — follows pointer on cartesian charts (`enableCrosshair`, default `true`)
- **Zoom & pan** — pinch/drag on cartesian charts (`enableZoomPan`, default `true`)
- **Selection** — `onSelection: (ChartHitResult hit) { ... }`

Pie, gauge, heatmap, and similar charts disable zoom/crosshair where it does not apply.

## Export (PNG / PDF)

Charts render inside a `RepaintBoundary`, so any chart can be snapshotted to a PNG image or an A4 PDF report. There are three layers of API.

### 1. `ChartWidgetController` (recommended)

Hold a controller, pass it to a chart widget, then export. The controller waits for the next frame before snapshotting so the canvas is current:

```dart
final controller = ChartWidgetController();

LineChart(config: config, controller: controller);

final pngBytes = await controller.exportPng();                       // pixelRatio: 3
final pdfBytes = await controller.exportPdf(title: 'Q2', subtitle: 'Revenue');
final fromCfg  = await controller.exportPdfFromConfig(config);       // reuses config.title / subtitle
```

| Method | Optional params | Returns |
|--------|-----------------|---------|
| `exportPng` | `pixelRatio` (3) | `Uint8List` PNG |
| `exportPdf` | `title`, `subtitle`, `pixelRatio` (3), `pageFormat` (A4) | `Uint8List` PDF |
| `exportPdfFromConfig` | `config`, `pixelRatio`, `pageFormat` | `Uint8List` PDF |

### 2. `ChartCard` (built-in toolbar)

Wrap a chart in `ChartCard` to get ready-made export buttons; it drives the same controller and reports results via `onExported`:

```dart
ChartCard(
  config: config,
  controller: controller,
  child: LineChart(config: config, controller: controller),
);
```

### 3. `ChartExport` (low-level statics)

When you manage your own `RepaintBoundary` `GlobalKey`:

```dart
final pngBytes = await ChartExport.toPng(boundaryKey, pixelRatio: 3);
final pdfBytes = await ChartExport.toPdf(boundaryKey, title: '…', pageFormat: PdfPageFormat.a4);
```

### How it works & things to know

- **PNG** is `RepaintBoundary.toImage(pixelRatio)` encoded as PNG — raise `pixelRatio` for sharper, larger output (default `3`).
- **PDF** embeds that same PNG snapshot in a `pdf` page (A4 by default) with an optional bold title and grey subtitle header — it is a raster image of the chart, not vector.
- **Tooltips and overlays are excluded** — only the chart canvas inside the `RepaintBoundary` is captured.
- **The chart must be mounted** — exporting an unmounted (or non-`RepaintBoundary`) key throws a `StateError`.
- **PDF text is ASCII-folded** for the built-in Helvetica font: smart quotes, en/em dashes, bullets, and ellipsis are converted to ASCII; other non-Latin-1 characters become `?`. Keep that in mind for Unicode titles/subtitles.
- `pdf` is the only runtime dependency, pulled in solely for this PDF path.

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

The demo includes a dashboard layout and an "All charts" gallery with export buttons.

## Links

- [Pub.dev](https://pub.dev/packages/save_points_chart)
- [API documentation](https://pub.dev/documentation/save_points_chart/latest/)
- [Repository](https://github.com/m7hamed-dev/save_points_chart)
- [Issue tracker](https://github.com/m7hamed-dev/save_points_chart/issues)

## Contributing

Issues and pull requests are welcome on the [GitHub repository](https://github.com/m7hamed-dev/save_points_chart). Please run `flutter analyze` and `flutter test` before submitting.

## License

Apache License 2.0 — see [LICENSE](LICENSE).
