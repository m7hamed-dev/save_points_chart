import 'package:flutter/material.dart';
import 'package:save_points_chart/theme/chart_theme.dart';

/// InheritedWidget that provides theme state to descendant widgets
class _ThemeProviderInherited extends InheritedWidget {
  const _ThemeProviderInherited({
    required this.state,
    required this.themeMode,
    required this.chartTheme,
    required super.child,
  });

  final ThemeProviderState state;
  final ThemeMode themeMode;
  final ChartTheme chartTheme;

  @override
  bool updateShouldNotify(_ThemeProviderInherited oldWidget) {
    return themeMode != oldWidget.themeMode ||
        chartTheme != oldWidget.chartTheme;
  }
}

/// Theme provider for managing app theme state using InheritedWidget
class ThemeProvider extends StatefulWidget {
  const ThemeProvider({super.key, required this.child});
  final Widget child;

  /// Get the ThemeProviderState from the widget tree
  static ThemeProviderState of(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_ThemeProviderInherited>();
    assert(inherited != null, 'ThemeProvider not found in widget tree');
    return inherited!.state;
  }

  /// Get the ThemeProviderState from the widget tree (without listening)
  static ThemeProviderState? maybeOf(BuildContext context) {
    final inherited =
        context.dependOnInheritedWidgetOfExactType<_ThemeProviderInherited>();
    return inherited?.state;
  }

  @override
  State<ThemeProvider> createState() => ThemeProviderState();
}

/// State class that holds the theme data
class ThemeProviderState extends State<ThemeProvider> {
  ThemeMode _themeMode = ThemeMode.system;
  ChartTheme _chartTheme = ChartTheme.light();

  ThemeMode get themeMode => _themeMode;
  ChartTheme get chartTheme => _chartTheme;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  @override
  void initState() {
    super.initState();
    _updateChartTheme();
  }

  void setThemeMode(ThemeMode mode) {
    setState(() {
      _themeMode = mode;
      _updateChartTheme();
    });
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      // If system, check current system brightness
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      setThemeMode(
        brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark,
      );
    }
  }

  void _updateChartTheme() {
    if (_themeMode == ThemeMode.dark) {
      _chartTheme = ChartTheme.dark();
    } else if (_themeMode == ThemeMode.light) {
      _chartTheme = ChartTheme.light();
    } else {
      // System mode - use current system brightness
      final brightness =
          WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _chartTheme = brightness == Brightness.dark
          ? ChartTheme.dark()
          : ChartTheme.light();
    }
  }

  void updateChartTheme(ChartTheme theme) {
    setState(() {
      _chartTheme = theme;
    });
  }

  @override
  Widget build(BuildContext context) {
    return _ThemeProviderInherited(
      state: this,
      themeMode: _themeMode,
      chartTheme: _chartTheme,
      child: widget.child,
    );
  }
}
