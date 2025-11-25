import 'package:flutter/material.dart';
import '../theme/chart_theme.dart';

/// Theme provider for managing app theme state
class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  ChartTheme _chartTheme = ChartTheme.light();

  ThemeMode get themeMode => _themeMode;
  ChartTheme get chartTheme => _chartTheme;

  bool get isDarkMode => _themeMode == ThemeMode.dark;

  ThemeProvider() {
    _updateChartTheme();
  }

  void setThemeMode(ThemeMode mode) {
    _themeMode = mode;
    _updateChartTheme();
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeMode == ThemeMode.light) {
      setThemeMode(ThemeMode.dark);
    } else if (_themeMode == ThemeMode.dark) {
      setThemeMode(ThemeMode.light);
    } else {
      // If system, check current system brightness
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      setThemeMode(brightness == Brightness.dark ? ThemeMode.light : ThemeMode.dark);
    }
  }

  void _updateChartTheme() {
    if (_themeMode == ThemeMode.dark) {
      _chartTheme = ChartTheme.dark();
    } else if (_themeMode == ThemeMode.light) {
      _chartTheme = ChartTheme.light();
    } else {
      // System mode - use current system brightness
      final brightness = WidgetsBinding.instance.platformDispatcher.platformBrightness;
      _chartTheme = brightness == Brightness.dark ? ChartTheme.dark() : ChartTheme.light();
    }
  }

  void updateChartTheme(ChartTheme theme) {
    _chartTheme = theme;
    notifyListeners();
  }
}

