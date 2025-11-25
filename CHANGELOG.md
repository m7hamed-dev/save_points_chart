# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2025-11-25

### Added
- Initial release of Save Points Chart library
- 7 chart types: Line, Bar, Area, Pie, Donut, Radial, and Sparkline
- Full light/dark theme support with automatic adaptation
- Material 3 design principles
- Glassmorphism and Neumorphism effects
- Loading and error states for all charts
- Interactive point/bar/segment tapping
- Smooth animations for all chart types
- Performance optimizations (RepaintBoundary, efficient rendering)
- Comprehensive API documentation
- Main export file for easy imports
- Input validation and error handling
- Accessibility support (Semantics widgets)
- Comprehensive README with examples

### Features
- **Line Chart**: Multiple series, gradient fills, interactive points
- **Bar Chart**: Grouped/stacked bars, rounded corners, customizable spacing
- **Area Chart**: Filled areas with gradients, smooth curves
- **Pie Chart**: Percentage labels, legend support, animations
- **Donut Chart**: Center value display, modern design
- **Radial Chart**: Multi-dimensional data visualization
- **Sparkline Chart**: Compact inline trend visualization

### Performance
- Single-pass bounds calculation
- Isolated repaints with RepaintBoundary
- Cached calculations
- Batched canvas operations
- Optimized text rendering

### Documentation
- Complete API documentation with dartdoc
- Usage examples for all chart types
- Performance optimization guide
- Architecture documentation

## [1.1.0] - 2025-11-25

### Added
- **Optional Theme Parameter**: All chart widgets now support optional `theme` parameter
  - Charts automatically adapt to Material theme (light/dark mode) when theme is not provided
  - Backward compatible - existing code with explicit themes continues to work
  - Simplifies usage: `LineChartWidget(dataSets: data)` now works without requiring a theme

### Fixed
- **Context Menu Tap Issues**: Fixed issue where only the first tap on chart elements was working
  - Context menus now work correctly on all subsequent taps
  - Fixed overlay blocking that prevented multiple interactions
  - Improved tap handling across all chart types (Line, Bar, Area, Pie, Donut, Radial, Sparkline)
- **Overlay Management**: Improved context menu overlay handling
  - Proper cleanup of overlays before showing new menus
  - Better hit test behavior to allow taps through overlays
  - Fixed selection state management

### Improved
- **Performance**: Enhanced tap detection and interaction handling
  - Added proper state clearing when tapping outside elements
  - Optimized overlay removal timing
  - Better gesture detector behavior for all chart types

### Changed
- `theme` parameter is now optional in all chart widgets:
  - `LineChartWidget`
  - `BarChartWidget`
  - `AreaChartWidget`
  - `PieChartWidget`
  - `DonutChartWidget`
  - `RadialChartWidget`
  - `SparklineChartWidget`
  - `ChartContainer`

## [Unreleased]

### Planned
- Unit and widget tests
- Internationalization (i18n) support
- CI/CD pipeline with GitHub Actions
- Additional chart types (Candlestick, Heatmap)
- Export functionality (PNG, SVG)
- Zoom and pan interactions
- Real-time data streaming support

