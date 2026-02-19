# Quick Start: Web UI Context Menu

## TL;DR

The `ChartContextMenu` now features a modern web UI design with:
- ✨ Clean, professional aesthetics
- 🎯 Hover states and micro-interactions
- 🎨 Better color system for light/dark modes
- ⚡ Faster animations (250ms vs 400ms)
- 📱 Still fully mobile-friendly

**No code changes required** - it just works better!

---

## Basic Usage

```dart
import 'package:save_points_chart/widgets/chart_context_menu.dart';

// Show menu on chart tap
ChartContextMenuHelper.show(
  context,
  point: dataPoint,           // Your chart data point
  segment: null,              // Or pie chart segment
  position: tapPosition,      // Where user tapped
  datasetLabel: 'Sales Q4',   // Optional subtitle
  onViewDetails: () {
    // Handle view details
  },
  onExport: () {
    // Handle export
  },
  onShare: () {
    // Handle share
  },
);

// Hide menu
ChartContextMenuHelper.hide();
```

---

## What's New?

### Visual Changes
- **Cleaner header** with status dot indicator
- **Side-by-side metric cards** for better data display
- **Stacked action list** with hover effects
- **Subtle shadows** for professional look
- **Better spacing** throughout

### Interaction Changes
- **Hover feedback** on all buttons (desktop/web)
- **Animated arrows** on action items
- **Smooth transitions** (150ms hover, 250ms entry)
- **Better touch targets** maintained for mobile

### Color System
- **Improved contrast** in both light and dark modes
- **Semantic colors** (primary, secondary, tertiary text)
- **Consistent borders** and dividers
- **Dynamic accent** based on data values

---

## Style Variants

### Default (New Web UI)
```dart
ChartContextMenuHelper.show(
  context,
  point: dataPoint,
  position: position,
  // ... other params
);
```

### Glassmorphism
```dart
ChartContextMenuHelper.show(
  context,
  point: dataPoint,
  position: position,
  useGlassmorphism: true,  // ← Add this
  backgroundBlur: true,     // Optional backdrop blur
  // ... other params
);
```

### Neumorphism
```dart
ChartContextMenuHelper.show(
  context,
  point: dataPoint,
  position: position,
  useNeumorphism: true,  // ← Add this
  // ... other params
);
```

---

## Customization

### Colors
The menu automatically adapts to your theme:

```dart
MaterialApp(
  theme: ThemeData(
    brightness: Brightness.light,  // Light mode colors
    // ...
  ),
  darkTheme: ThemeData(
    brightness: Brightness.dark,   // Dark mode colors
    // ...
  ),
);
```

### Actions
Show only the actions you need:

```dart
// All actions
ChartContextMenuHelper.show(
  context,
  point: dataPoint,
  position: position,
  onViewDetails: () {},
  onExport: () {},
  onShare: () {},
);

// Only export
ChartContextMenuHelper.show(
  context,
  point: dataPoint,
  position: position,
  onExport: () {},  // Only this action shown
);

// No actions (just data display)
ChartContextMenuHelper.show(
  context,
  point: dataPoint,
  position: position,
  // No action callbacks
);
```

---

## Best Practices

### 1. Position Calculation
```dart
void _handleChartTap(TapDownDetails details) {
  final RenderBox box = context.findRenderObject() as RenderBox;
  final localPosition = box.globalToLocal(details.globalPosition);
  
  ChartContextMenuHelper.show(
    context,
    point: dataPoint,
    position: localPosition,  // Use local position
    // ...
  );
}
```

### 2. Close on Navigation
```dart
@override
void dispose() {
  ChartContextMenuHelper.hide();  // Clean up
  super.dispose();
}
```

### 3. Handle Actions Properly
```dart
onViewDetails: () {
  // Menu auto-closes before callback
  Navigator.push(
    context,
    MaterialPageRoute(
      builder: (context) => DetailsScreen(point: dataPoint),
    ),
  );
},
```

### 4. Responsive Positioning
The menu automatically adjusts position to stay on screen:
```dart
// No need to calculate bounds manually
ChartContextMenuHelper.show(
  context,
  point: dataPoint,
  position: tapPosition,  // Will auto-adjust if near edges
  // ...
);
```

---

## Migration Guide

### From Old Version
No changes needed! The new design is fully backward compatible:

```dart
// This still works exactly the same
ChartContextMenuHelper.show(
  context,
  point: point,
  segment: segment,
  position: position,
  datasetIndex: index,
  elementIndex: elementIndex,
  datasetLabel: label,
  theme: theme,
  onViewDetails: onViewDetails,
  onExport: onExport,
  onShare: onShare,
);
```

### New Features to Try
```dart
// Add background blur (glassmorphism)
ChartContextMenuHelper.show(
  context,
  point: point,
  position: position,
  useGlassmorphism: true,
  backgroundBlur: true,  // ← New!
  onViewDetails: () {},
);
```

---

## Examples

### Line Chart Integration
```dart
LineChart(
  LineChartData(
    lineTouchData: LineTouchData(
      touchCallback: (event, response) {
        if (event is FlTapUpEvent && response?.lineBarSpots != null) {
          final spot = response!.lineBarSpots!.first;
          
          ChartContextMenuHelper.show(
            context,
            point: ChartDataPoint(
              x: spot.x,
              y: spot.y,
              label: 'Data Point',
            ),
            position: event.localPosition,
            datasetLabel: 'Revenue',
            onViewDetails: () => _showDetails(spot),
            onExport: () => _exportData(spot),
          );
        }
      },
    ),
  ),
);
```

### Pie Chart Integration
```dart
PieChart(
  PieChartData(
    pieTouchData: PieTouchData(
      touchCallback: (event, response) {
        if (event is FlTapUpEvent && response?.touchedSection != null) {
          final section = response!.touchedSection!;
          
          ChartContextMenuHelper.show(
            context,
            segment: PieData(
              value: section.value,
              label: section.title,
              color: section.color,
            ),
            position: event.localPosition,
            onShare: () => _shareSegment(section),
          );
        }
      },
    ),
  ),
);
```

---

## Performance Tips

1. **Use RepaintBoundary** around your chart
```dart
RepaintBoundary(
  child: YourChartWidget(),
)
```

2. **Debounce rapid taps**
```dart
Timer? _debounce;

void _handleTap(Offset position) {
  _debounce?.cancel();
  _debounce = Timer(Duration(milliseconds: 100), () {
    ChartContextMenuHelper.show(/* ... */);
  });
}
```

3. **Hide menu on scroll**
```dart
NotificationListener<ScrollNotification>(
  onNotification: (notification) {
    ChartContextMenuHelper.hide();
    return false;
  },
  child: YourScrollableContent(),
)
```

---

## Troubleshooting

### Menu appears off-screen
The menu auto-adjusts, but if issues persist:
```dart
// Ensure your chart has proper constraints
SizedBox(
  width: MediaQuery.of(context).size.width,
  height: 300,
  child: YourChart(),
)
```

### Menu doesn't show
Check that you have at least one action:
```dart
// ✗ Won't show (no actions)
ChartContextMenuHelper.show(
  context,
  point: point,
  position: position,
);

// ✓ Will show
ChartContextMenuHelper.show(
  context,
  point: point,
  position: position,
  onViewDetails: () {},  // At least one action
);
```

### Hover not working
Hover effects work on desktop/web automatically. On mobile, they're replaced with tap feedback.

### Dark mode colors wrong
Ensure your MaterialApp has both themes:
```dart
MaterialApp(
  theme: ThemeData(brightness: Brightness.light),
  darkTheme: ThemeData(brightness: Brightness.dark),
  themeMode: ThemeMode.system,  // Or .light / .dark
)
```

---

## API Reference

### ChartContextMenuHelper.show()

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `context` | `BuildContext` | ✓ | - | Build context |
| `point` | `ChartDataPoint?` | - | `null` | Data point to display |
| `segment` | `PieData?` | - | `null` | Pie segment to display |
| `position` | `Offset` | ✓ | - | Menu position |
| `datasetIndex` | `int?` | - | `null` | Dataset index |
| `elementIndex` | `int?` | - | `null` | Element index |
| `datasetLabel` | `String?` | - | `null` | Subtitle text |
| `theme` | `ChartTheme?` | - | `null` | Custom theme |
| `useGlassmorphism` | `bool` | - | `false` | Glass effect |
| `useNeumorphism` | `bool` | - | `false` | Neumorphic style |
| `backgroundBlur` | `bool` | - | `false` | Blur backdrop |
| `onViewDetails` | `VoidCallback?` | - | `null` | Details action |
| `onExport` | `VoidCallback?` | - | `null` | Export action |
| `onShare` | `VoidCallback?` | - | `null` | Share action |

### ChartContextMenuHelper.hide()
Closes the currently displayed menu.

---

## Resources

- 📖 [Full Design Documentation](./WEB_UI_REDESIGN.md)
- 🔄 [Before/After Comparison](./DESIGN_COMPARISON.md)
- 💻 [Example Implementation](./lib/main.dart)

---

## Support

For issues or questions:
1. Check the troubleshooting section above
2. Review the full documentation
3. Open an issue on GitHub

---

**Enjoy the new web UI! 🎉**
