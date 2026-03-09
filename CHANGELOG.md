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

## [1.2.1] - 2025-01-27

### Fixed
- **Theme Toggle Issue**: Fixed theme not changing when clicking the theme toggle icon
  - Fixed `InheritedWidget.updateShouldNotify` to properly compare theme values
  - Theme changes now immediately update MaterialApp and all dependent widgets
  - Added proper state management for theme mode changes
- **NaN Value Handling**: Comprehensive fixes for NaN and invalid value handling
  - Added validation in `pointToCanvas` to filter out NaN and infinite values
  - Fixed axis label drawing to handle zero ranges and invalid calculations
  - Added validation in all chart painters to prevent NaN offsets
  - Charts now gracefully handle edge cases: empty data, zero ranges, invalid bounds
  - All drawing operations now validate values before painting to prevent crashes
- **Line Chart Edge Cases**: Fixed rendering issues with invalid data points
  - Points with NaN or infinite values are now filtered out
  - Bezier curve calculations validate all control points
  - Area path completion handles edge cases properly

### Improved
- **Error Handling**: Better error handling for edge cases throughout the library
  - All coordinate calculations validate inputs and outputs
  - Graceful degradation when encountering invalid data
  - No crashes when data contains NaN, infinity, or zero ranges

### Documentation
- Added live demo link to README
- Added screenshots section to README
- Updated documentation with edge case handling information

## [1.3.0] - 2025-01-27

### Added
- **Example App**: Added comprehensive example application demonstrating all chart types
  - Example directory with working demo app
  - Shows Line, Area, Bar, Pie, and Donut charts
  - Includes interactive callbacks and theme switching
  - Demonstrates best practices for using the library

### Improved
- **Documentation**: Enhanced documentation for AreaChartWidget
  - Added comprehensive class-level documentation with examples
  - Documented all public properties and constructor parameters
  - Improved API documentation coverage

### Fixed
- **Package Description**: Shortened package description to meet pub.dev requirements (60-180 characters)
  - Description now optimized for search engine display

## [1.3.1] - 2025-01-27

### Improved
- **Documentation**: Added comprehensive documentation for BarChartPainter
  - Documented class, constructor, and all public properties
  - Added examples and usage information
  - Improved API documentation coverage

### Fixed
- **Example Detection**: Fixed .pubignore to include example directory for pub.dev detection
  - Example app is now properly included in published package
- **Documentation References**: Fixed import for BarChartWidget reference in BarChartPainter documentation

## [1.4.0] - 2025-12-13

### Added
- **4 New Chart Types**: Expanded from 8 to 12 chart types
  - **Scatter Chart**: Relationship visualization with correlation analysis
  - **Bubble Chart**: Three-dimensional data visualization with size encoding
  - **Radar Chart**: Multi-dimensional data comparison with spider/web visualization
  - **Gauge Chart**: Single metric visualization for KPIs and progress indicators
- **Stacked Area Chart**: Cumulative multi-series visualization with stacked layers
- **Drawer Navigation**: Replaced NavigationRail with Drawer for better mobile experience
  - Modern drawer with gradient header
  - Visual selection indicators
  - Auto-close on selection
  - Better mobile-friendly navigation

### Improved
- **Documentation**: Updated README to reflect all 12 chart types
  - Complete chart type descriptions
  - Updated feature list
  - Replaced screenshots with animated demo video
- **UI/UX**: Enhanced navigation experience with drawer
  - Better mobile responsiveness
  - Improved visual hierarchy
  - Theme-aware drawer styling

### Fixed
- **Empty Dataset Test**: Fixed test case that was causing assertion errors
  - Replaced with informative message explaining expected behavior
  - Better error handling documentation

### Changed
- **Chart Count**: Library now supports 12 chart types (previously 8)
- **Navigation**: Changed from NavigationRail to Drawer for better cross-platform support
- **Demo**: Replaced static screenshots with animated GIF demo

## [1.4.1] - 2025-12-13

### Fixed
- **Code Formatting**: Fixed Dart formatter compliance in `bubble_chart_widget.dart`
  - Corrected multi-line constructor formatting
  - Ensures package passes static analysis checks

## [1.5.0] - 2025-01-27

### Added
- **Click Interaction for All Charts**: Added comprehensive click interaction support across all chart types
  - **Step Line Chart**: `onPointTap` callback with point selection and details dialog
  - **Stacked Column Chart**: `onBarTap` callback with bar selection and details dialog
  - **Spline Chart**: `onPointTap` callback with point selection and details dialog
  - **Pyramid Chart**: `onSegmentTap` callback with segment selection and details dialog
  - **Funnel Chart**: `onSegmentTap` callback with segment selection and details dialog
  - **Radar Chart**: `onPointTap` callback with point selection and details dialog
  - **Gauge Chart**: `onChartTap` callback with gauge value details dialog
- **Visual Border Highlighting**: All charts now show prominent white borders when elements are clicked
  - White 3-4px borders for selected elements (vs 1.5-2px default)
  - Consistent visual feedback across all chart types
  - Enhanced visibility with highlight overlays for selected segments
- **Chart Interaction Helpers**: New helper functions for detecting interactions
  - `findPyramidSegment()` - Detects taps on pyramid chart segments
  - `findFunnelSegment()` - Detects taps on funnel chart segments
  - `findRadarPoint()` - Detects taps on radar chart points
  - `_isPointInTrapezoid()` - Helper for trapezoid hit testing
- **Details Dialog**: Enhanced details dialog showing comprehensive chart element information
  - Shows point/segment values, labels, and dataset information
  - Available for all interactive chart types
  - Consistent UI across all chart interactions

### Improved
- **Visual Feedback**: Enhanced visual feedback for all chart interactions
  - Selected elements show white borders for better visibility
  - Highlight overlays for selected segments in Pyramid and Funnel charts
  - Glow effects for selected points in Radar charts
  - Consistent border styling (3-4px white borders) across all chart types
- **Interaction Consistency**: Standardized interaction patterns across all charts
  - All charts use the same context menu system
  - Consistent haptic feedback on all interactions
  - Unified details dialog presentation
- **Chart Painter Updates**: All painters now support selected state with border highlighting
  - Line Chart: White 3px border for selected points
  - Bar Chart: White 3px border for selected bars
  - Pie/Donut Chart: White border (borderWidth + 3) for selected segments
  - Scatter Chart: White 3px border for selected points
  - Stacked Area Chart: White 3px border for selected points
  - Radial Chart: White 3px border for selected points
  - Spline Chart: White 3px border for selected points
  - Step Line Chart: White 3px border for selected points
  - Bubble Chart: White 3px border for selected bubbles
  - Stacked Column Chart: White 3px border for selected bars
  - Pyramid Chart: White 4px border for selected segments
  - Funnel Chart: White 4px border for selected segments
  - Radar Chart: White border with glow for selected points

### Changed
- **Chart Widgets**: All chart widgets now support click interaction callbacks
  - Step Line, Stacked Column, Spline charts: Added `onPointTap`/`onBarTap` callbacks
  - Pyramid, Funnel charts: Added `onSegmentTap` callbacks
  - Radar chart: Added `onPointTap` callback
  - Gauge chart: Added `onChartTap` callback
- **Demo Screen**: Updated demo screen to show interactive examples
  - All charts in demo now have click handlers
  - Updated subtitles to indicate charts are interactive
  - Shows details dialog when clicking on chart elements

## [1.5.1] - 2025-01-27

### Fixed
- **Documentation Warnings**: Fixed comment reference warnings in `ChartInteractionHelper`
  - Corrected parameter names in `findPieSegment` documentation to match actual function signature
  - Fixed parameter references in `findRadarPoint` documentation
  - All documentation now accurately reflects function parameters
- **Pub.dev Compatibility**: Removed `sample_data.dart` from main library exports
  - `SampleData` is now imported directly in example files
  - Fixes pub.dev dependency constraint validation errors

### Improved
- **Documentation Coverage**: Added comprehensive dartdoc comments to public APIs
  - Enhanced documentation for `StepLineChartWidget`, `StackedColumnChartWidget`
  - Enhanced documentation for `PyramidChartWidget`, `FunnelChartWidget`
  - Added detailed documentation for all `ChartInteractionHelper` methods
  - Improved `ChartInteractionResult` class documentation
  - All public APIs now have proper dartdoc comments meeting pub.dev requirements

## [1.5.2] - 2025-01-10

### Fixed
- **Critical NaN Gradient Crash**: Fixed application crashes when rendering charts with invalid data
  - **Bar Chart**: Added comprehensive validation to prevent NaN values in gradient coordinates
    - Validates point data (x, y values) before calculations
    - Validates bar dimensions before creating gradients
    - Protects against division by zero in maxYAdjusted
  - **All Chart Types**: Applied NaN validation across all 15 chart painters
    - Bubble Chart: Validates point coordinates, size, and canvas points
    - Pie/Donut Chart: Validates size, radius, total values, and item values
    - Stacked Column Chart: Validates bar heights and calculated dimensions
    - Radar Chart: Validates angles, radius, and normalized values
    - Funnel Chart: Validates segment dimensions and percentages
    - Pyramid Chart: Validates segment values and calculated dimensions
    - Scatter Chart: Validates point coordinates and bounds
    - Radial Chart: Validates radial values and polar coordinates
    - Line Chart: Enhanced existing validations for control points
    - Spline Chart: Enhanced existing validations for bezier curves
    - Stacked Area Chart: Enhanced existing validations for cumulative paths
    - Step Line Chart: Enhanced existing validations for step patterns
    - Gauge Chart: Enhanced existing validations for angles and gradients
  - Charts now gracefully skip invalid data points instead of crashing
  - All gradient creation operations validate rect/circle dimensions before shader creation

### Improved
- **Error Handling**: Comprehensive validation throughout all chart rendering pipelines
  - All coordinate calculations validate inputs and outputs for finite values
  - Dimension checks ensure positive, finite values before drawing
  - Graceful degradation when encountering NaN, Infinity, or invalid ranges
  - No crashes when data contains invalid numerical values
- **Stability**: Significantly improved application stability in Analytics sections
  - Bar charts and all other chart types now handle edge cases robustly
  - Invalid data is filtered out rather than causing application crashes
  - Better protection against malformed or corrupted data inputs

### Technical Details
- Added `isFinite` checks for all numerical values before use in calculations
- Validates dimensions (width, height, radius) are positive before creating Paint shaders
- Protects against division by zero in normalization and scaling operations
- Validates all Offset coordinates before path operations
- Ensures all gradient rect/circle bounds are valid before shader creation

## [1.6.0] - 2025-01-23

### Added
- **Custom Height Property**: All chart widgets now support customizable `height` property
  - Allows flexible chart sizing for different layout requirements
  - Default heights optimized for each chart type when not specified
  - Enables better control over chart dimensions in responsive layouts
- **Header and Footer Support**: All chart widgets now support optional `header` and `footer` properties
  - Header appears below subtitle (if provided) and above the chart
  - Footer appears below the chart
  - Both accept any Flutter widget for maximum flexibility
  - Enables adding additional content, controls, or information to charts
- **Enhanced Data Point Labels**: Chart data points now support labels directly
  - Labels are now part of `ChartDataPoint` for better data organization
  - Improved clarity and consistency across chart widgets
  - Better integration with axis labels and tooltips

### Improved
- **Chart Visualization**: Enhanced padding and clipping in chart painters
  - Better visual consistency across all chart types
  - Improved point rendering without clipping at chart edges
  - Enhanced X-axis padding calculation to prevent point clipping
  - Better handling of edge cases in chart rendering
- **Data Handling**: Refactored chart data handling for improved clarity
  - Streamlined data structure with labels on data points
  - Better widget structure and organization
  - Improved code maintainability and consistency
- **Chart Interaction**: Enhanced DonutChartWidget tap handling and layout
  - Improved interaction clarity and responsiveness
  - Better visual feedback on user interactions

### Changed
- **Data Structure**: Removed dataset-level labels in favor of point-level labels
  - Labels are now specified directly on `ChartDataPoint` objects
  - More flexible and consistent data representation
  - Better alignment with chart rendering requirements

### Technical Details
- All chart widgets now include `height`, `header`, and `footer` parameters
- Enhanced padding calculations in all chart painters
- Improved clipping boundaries for better point visibility
- Refactored data models for better label handling

## [1.7.2] - 2025-01-29

### Added
- **Pie & Donut chart layout**: `legendLayout` parameter for row or column layout
  - `PieChartWidget` and `DonutChartWidget` now support `legendLayout` (`Axis.horizontal` or `.vertical`)
  - **Row** (default): chart on the left, legend on the right (`Axis.horizontal`)
  - **Column**: chart on top, legend below (`.vertical`)
  - Use `legendLayout: .vertical` for stacked layout on narrow screens or compact UIs

### Changed
- Pie and Donut chart content is built from shared chart/legend widgets for consistent row vs column behavior

### Documentation
- **ChartsConfig**: README now documents `ChartsConfig` (shared theme, effects, empty/error UI, shadows) and points to `lib/theme/charts_config.dart` for the full API

## [1.7.1] - 2025-01-26

### Fixed
- Version update and documentation improvements

## [1.7.0] - 2025-01-25

### Changed
- Chart widget updates across area, bar, bubble, donut, funnel, gauge, line, pie, pyramid, radar, radial, scatter, sparkline, spline, stacked area, stacked column, step line, and chart container

## [1.8.0] - 2026-03-09

### Added
- **Dynamic Data Support**: `ChartDataPoint`, `PieData`, `BubbleDataPoint`, and `RadarDataPoint` now accept `dynamic` values (`int`, `double`, `String`) for numeric fields (`value`, `x`, `y`, `size`).
  - Values are automatically parsed to `double` internally.
  - Simplifies data handling by allowing direct use of API responses without manual parsing.
- **Smart Number Formatting**: Introduced `ChartFormatUtils` for intelligent number formatting.
  - Whole numbers are displayed without decimals (e.g., "10" instead of "10.0").
  - Fractional values retain their precision based on configuration.
  - Applied across all chart types for axis labels, tooltips, and legends.

### Improved
- **Donut Chart UI/UX**: Enhanced `DonutChartWidget` with:
  - Dynamic center text that updates on segment selection.
  - Improved animations for segment transitions.
  - Better responsive layout for legends.
- **Pie Chart Rendering**: Optimized `PieChartPainter` drawing order.
  - Shadows and segments are now drawn in separate passes to prevent visual glitches with overlapping elements.
  - Enhanced visual hierarchy for selected vs. unselected segments.

## [1.7.8] - 2025-01-29

### Changed
- Version bump

## [Unreleased]

### Planned
- Unit and widget tests
- Internationalization (i18n) support
- CI/CD pipeline with GitHub Actions
- Additional chart types (Candlestick, Heatmap)
- Export functionality (PNG, SVG)
- Zoom and pan interactions
- Real-time data streaming support

