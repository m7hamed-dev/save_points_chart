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

## [1.2.0] - 2025-11-25

### Added
- **Haptic Feedback**: All chart interactions now provide haptic feedback on successful taps
  - Uses `HapticFeedback.selectionClick()` for better user experience
  - Applied to all chart types: Line, Bar, Area, Pie, Donut, Radial, Sparkline
- **Hover Support for Bar Charts**: Added `onBarHover` callback to BarChartWidget
  - Visual feedback with elevation and border highlighting on hover
  - Consistent with Line Chart hover behavior
- **Hover Support for Radial Charts**: Added `onPointHover` callback to RadialChartWidget
  - Visual feedback with glow effects and size changes on hover
  - Improved interactivity for radial/radar charts
- **Chart Interaction Constants**: Standardized interaction parameters
  - `ChartInteractionConstants.tapRadius = 20.0` for consistent tap detection
  - `ChartInteractionConstants.hoverRadius = 30.0` for hover detection
  - All charts now use these standardized constants

### Fixed
- **Radial Chart Selection State**: Fixed missing selection state management in RadialChartWidget
  - Added `_selectedPoint` state tracking
  - Passes `selectedPoint` and `hoveredPoint` to RadialChartPainter
  - Visual feedback now works correctly for selected/hovered points
  - Points now show proper glow, size, and border changes when selected

### Improved
- **Performance Optimization**: Removed redundant `setState()` calls
  - All charts now use single `setState()` per interaction instead of double calls
  - Improved rendering performance and reduced unnecessary rebuilds
- **Code Consistency**: Standardized onClick implementation across all charts
  - All charts use `ChartInteractionConstants` for tap/hover radius
  - Consistent haptic feedback pattern across all chart types
  - Unified selection state management approach
- **Visual Feedback**: Enhanced hover and selection visual feedback
  - Bar charts show elevation and border on hover
  - Radial charts show enhanced glow and size changes
  - Consistent visual language across all interactive elements

### Changed
- **Bar Chart Painter**: Added `hoveredBar` parameter to support hover state
  - Visual feedback includes elevation, border, and highlight changes
  - Hover state is visually distinct from selected state
- **Radial Chart Painter**: Added `selectedPoint` and `hoveredPoint` parameters
  - Points now show visual feedback when selected or hovered
  - Glow radius, point size, and border width adjust based on state

## [Unreleased]

### Planned
- Unit and widget tests
- Internationalization (i18n) support
- CI/CD pipeline with GitHub Actions
- Additional chart types (Candlestick, Heatmap)
- Export functionality (PNG, SVG)
- Zoom and pan interactions
- Real-time data streaming support

