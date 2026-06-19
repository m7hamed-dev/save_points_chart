# save_points_chart

A modern Flutter charting library with canvas-based rendering, Material 3–friendly themes, smooth animations, and zero third-party runtime dependencies (Flutter SDK only).

[![pub package](https://img.shields.io/pub/v/save_points_chart.svg)](https://pub.dev/packages/save_points_chart)
[![pub points](https://img.shields.io/pub/points/save_points_chart.svg)](https://pub.dev/packages/save_points_chart/score)
[![platform](https://img.shields.io/badge/platform-Flutter-02569B.svg?logo=flutter)](https://flutter.dev)
[![License](https://img.shields.io/badge/license-Apache%202.0-blue.svg)](LICENSE)

## Contents

- [What's new](#whats-new)
- [Features](#features)
- [Installation](#installation)
- [Quick start](#quick-start)
- [Chart types](#chart-types)
- [Render styles](#render-styles)
- [Smooth curves](#smooth-curves)
- [Data model](#data-model)
- [Convenience extensions](#convenience-extensions)
- [Waterfall metadata](#waterfall-metadata)
- [Theming](#theming)
- [Interactions](#interactions)
- [Custom charts](#custom-charts)
- [Architecture](#architecture)
- [Example app](#example-app)
- [Links](#links)

## What's new

- 🎨 **Render styles** — pick `gradient`, `flat`, or `glass` per chart via `ChartConfig.style`. See [Render styles](#render-styles).
- ✨ **Modern visuals by default** — gradient fills, soft glow, and radial highlights across every chart type.
- 📈 **Overshoot-free smooth curves** — monotone cubic interpolation keeps smoothed lines and stacked areas faithful to the data. See [Smooth curves](#smooth-curves).
- 🌙 **Refreshed dark theme** — deep-navy gradient background, plus `ChartTheme.backgroundGradient` for custom gradient backdrops.
- 🧭 **Upgraded example app** — navigation drawer, light/dark toggle, and a live render-style picker.

> **Note:** the PNG/PDF export API (`ChartExport`, `ChartCard`, `ChartWidgetController`) was removed in 2.0.0, dropping the `pdf` dependency — the library is now pure Flutter SDK. See [CHANGELOG](CHANGELOG.md) for migration notes.

## Features

- **15+ chart types** — line, bar, area, pie/donut, scatter, radar, gauge, sparkline, stacked area, waterfall, funnel, bubble, heatmap, candlestick, and timeline
- **Unified API** — every chart uses `ChartConfig` + a typed widget (`LineChart`, `BarChart`, …)
- **Render styles** ✨ — switch any chart between `ChartStyle.gradient` (default), `flat`, or `glass` with one field
- **Modern visuals** — gradient fills, soft glow, and radial highlights out of the box
- **Overshoot-free curves** — smooth lines use monotone cubic interpolation (no false peaks or dips between points)
- **Interactions** — tooltips, crosshair, tap selection, pinch zoom & pan (where applicable)
- **Theming** — `ChartTheme.light()`, `ChartTheme.dark()` (deep-navy gradient background), `ChartTheme.dashboard()`, or fully custom colors and gradients
- **Templates** — `ChartTemplateStyle.dashboard` (title, legend, grid) or `plain` (minimal chrome)
- **Animations** — configurable duration and curve tension for smooth line/area transitions
- **Accessibility** — `semanticLabel` on `ChartConfig` for screen readers
- **Extensible engine** — layer stack, render pipeline, and `ChartRenderer` plugins for custom charts
- **Zero dependencies** — pure-Flutter canvas rendering, no third-party runtime packages

## Requirements

| | Version |
|---|---|
| Dart SDK | `^3.12.0` |
| Flutter | `>=1.17.0` |

## Installation

Add to `pubspec.yaml`:

```yaml
dependencies:
  save_points_chart: ^1.9.2
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

Every widget accepts an optional `theme` override that takes precedence over the one on `ChartConfig`.

## Render styles

Set `style` on `ChartConfig` to change how series are painted — independent of the color theme. Every chart type honors it.

```dart
ChartConfig(
  style: ChartStyle.glass, // gradient (default) · flat · glass
  series: [...],
);

// or derive a variant
config.copyWith(style: ChartStyle.flat);
```

| Style | Look |
|-------|------|
| `ChartStyle.gradient` *(default)* | Gradient fills & strokes, soft glow, radial highlights — vibrant and dimensional |
| `ChartStyle.flat` | Solid fills, crisp strokes, no gradients or glow — calm and data-first |
| `ChartStyle.glass` | Frosted translucent fills with a light highlight — glassmorphism |

## Smooth curves

Smooth lines (`LineChart`, `AreaChart`, `SparklineChart`, `StackedAreaChart`) use **monotone cubic interpolation** (Fritsch–Carlson) rather than a plain cardinal spline. The curve never overshoots the data — no false peaks, no dips below a baseline, no excursions below zero — so a smoothed line stays a faithful reading of the values while still looking smooth.

```dart
LineChart(
  config: config,
  mode: LineChartMode.smooth, // default; use .straight for polyline
);
```

`curveTension` (on `ChartConfig`) applies to the cardinal fallback used for non-monotonic x data.

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
| `style` | `gradient` | Render style — `gradient` / `flat` / `glass` |
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

Themes can paint a **gradient background** via the optional `backgroundGradient` field (the dark preset ships with a deep-navy gradient):

```dart
const ChartTheme(
  backgroundColor: Color(0xFF121826), // fallback when gradient is null
  backgroundGradient: LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [Color(0xFF1B2438), Color(0xFF0D1220)],
  ),
  // …remaining theme fields
);
```

## Interactions

`ChartWidget` (used internally by every chart) supports:

- **Tooltip** — hover/tap hit testing (`enableTooltip`, default `true`)
- **Crosshair** — follows pointer on cartesian charts (`enableCrosshair`, default `true`)
- **Zoom & pan** — pinch/drag on cartesian charts (`enableZoomPan`, default `true`)
- **Selection** — `onSelection: (ChartHitResult hit) { ... }`

Pie, gauge, heatmap, and similar charts disable zoom/crosshair where it does not apply.

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

The demo includes a dashboard layout and an "All charts" gallery, with a navigation drawer, a **light/dark** toggle, and a **render-style** picker (gradient / flat / glass) in the app bar.

## Links

- [Pub.dev](https://pub.dev/packages/save_points_chart)
- [API documentation](https://pub.dev/documentation/save_points_chart/latest/)
- [Repository](https://github.com/m7hamed-dev/save_points_chart)
- [Issue tracker](https://github.com/m7hamed-dev/save_points_chart/issues)

## Contributing

Issues and pull requests are welcome on the [GitHub repository](https://github.com/m7hamed-dev/save_points_chart). Please run `flutter analyze` and `flutter test` before submitting.

## License

Apache License 2.0 — see [LICENSE](LICENSE).
