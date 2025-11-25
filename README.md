# Modern Flutter Charts with Full Theme Support

A comprehensive Flutter charting solution featuring modern design principles, full light & dark theme support, and high performance.

## 🎯 Features

- **7 Chart Types**: Line, Bar, Area, Pie, Donut, Radial, and Sparkline charts
- **Modern Design**: Material 3, Neumorphism, and Glassmorphism effects
- **Full Theme Support**: Automatic light/dark theme adaptation
- **High Performance**: Optimized rendering with minimal rebuilds
- **Clean Architecture**: Modular, reusable, and maintainable code
- **Highly Customizable**: Extensive configuration options

## 📦 Dependencies

- `provider: ^6.1.1` - State management for theme switching
- **No external charting library** - Uses custom `CustomPainter` implementations for full control

## 🏗️ Architecture

```
lib/
├── models/          # Data models (ChartDataPoint, PieData, ChartDataSet)
├── theme/           # Theme configuration (ChartTheme)
├── painters/        # Custom painters (BaseChartPainter, LineChartPainter, etc.)
├── widgets/          # Chart widgets (Line, Bar, Area, Pie, Donut, Radial, Sparkline)
├── providers/        # Theme provider for state management
├── data/            # Sample data generators
└── screens/         # Demo screens
```

## 🎨 Design Decisions

### Chart Implementation: Custom CustomPainter

**Why Custom Implementation?**
- ✅ **Zero external dependencies** - No charting library required
- ✅ **Full control** - Complete customization of every aspect
- ✅ **Lightweight** - No unnecessary features or bloat
- ✅ **High performance** - Optimized rendering with direct canvas access
- ✅ **Theme-aware** - Built from the ground up with theme support
- ✅ **Maintainable** - Simple, understandable code structure

**Architecture:**
- `BaseChartPainter` - Common utilities (grid, axes, labels)
- Specialized painters for each chart type
- Efficient rendering with minimal repaints
- Smooth animations through Flutter's animation system

### Theme System

- **Adaptive Colors**: Automatically adjusts based on light/dark mode
- **Material 3**: Uses Material Design 3 principles
- **Gradient Support**: Modern gradient fills for visual appeal
- **Shadow System**: Configurable elevation and shadows
- **Glassmorphism**: Optional frosted glass effect
- **Neumorphism**: Optional soft shadow effect

## 🚀 Usage

### Basic Example

```dart
import 'package:flutter/material.dart';
import 'widgets/line_chart_widget.dart';
import 'models/chart_data.dart';
import 'theme/chart_theme.dart';

LineChartWidget(
  dataSets: [
    ChartDataSet(
      label: 'Sales',
      color: Colors.blue,
      dataPoints: [
        ChartDataPoint(x: 0, y: 10),
        ChartDataPoint(x: 1, y: 20),
        ChartDataPoint(x: 2, y: 15),
      ],
    ),
  ],
  theme: ChartTheme.light(),
  title: 'Sales Trend',
  subtitle: 'Last 3 months',
)
```

### With Theme Provider

```dart
Consumer<ThemeProvider>(
  builder: (context, themeProvider, _) {
    return LineChartWidget(
      dataSets: dataSets,
      theme: themeProvider.chartTheme,
      useGlassmorphism: true,
    );
  },
)
```

## 🎛️ Customization Options

All charts support extensive customization:

- **Colors**: Theme-aware adaptive colors
- **Gradients**: Linear gradients for fills and backgrounds
- **Line Thickness**: Configurable stroke width
- **Border Radius**: Rounded corners
- **Shadows**: Elevation and shadow effects
- **Axis Styling**: Customizable axis appearance
- **Grid Lines**: Toggle grid visibility
- **Legends**: Show/hide legends
- **Tooltips**: Interactive tooltips
- **Padding & Spacing**: Configurable spacing

## ⚡ Performance Optimizations

1. **Minimal Rebuilds**: Charts only rebuild when data changes
2. **Cached Styling**: Theme objects are cached and reused
3. **Efficient Rendering**: Optimized paint operations
4. **Lightweight Animations**: Smooth 60fps animations
5. **Lazy Loading**: Data processed only when needed

## 🌓 Theme Switching

The app includes a theme toggle button that switches between:
- Light mode
- Dark mode
- System mode (follows device settings)

## 📱 Running the App

```bash
flutter pub get
flutter run
```

## 📊 Chart Types

### Line Chart
- Smooth curves
- Gradient area fills
- Interactive tooltips
- Multiple datasets

### Bar Chart
- Grouped or stacked bars
- Rounded corners
- Gradient fills
- Customizable spacing

### Area Chart
- Filled areas with gradients
- Smooth curves
- Multiple datasets overlay

### Pie Chart
- Percentage labels
- Customizable colors
- Legend support
- Smooth animations

### Donut Chart
- Center value display
- Similar to pie with center space
- Modern donut design

### Radial Chart
- Multi-dimensional data
- Radar/spider chart
- Performance metrics visualization

### Sparkline Chart
- Compact inline charts
- Positive/negative color coding
- Trend visualization

## 🎨 Design Effects

### Glassmorphism
Enable with `useGlassmorphism: true` for a frosted glass effect with backdrop blur.

### Neumorphism
Enable with `useNeumorphism: true` for soft shadows and embossed appearance.

## 📝 Example Screens

The demo screen includes:
- Navigation rail for chart type selection
- Theme toggle button
- Design effect selector (Glassmorphism/Neumorphism)
- Multiple chart examples per type
- Responsive layout

## 🔧 Extending

To add new chart types:
1. Create a new widget in `lib/widgets/`
2. Follow the existing pattern
3. Use `ChartContainer` for consistent styling
4. Support `ChartTheme` for theme awareness

## 📄 License

This project is open source and available for use.
# save_points_chart
# save_points_chart
