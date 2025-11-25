import 'package:flutter/material.dart';
import 'providers/theme_provider.dart';
import 'screens/chart_demo_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ThemeProvider(
      child: _MaterialAppWithTheme(),
    );
  }
}

class _MaterialAppWithTheme extends StatelessWidget {
  const _MaterialAppWithTheme();

  @override
  Widget build(BuildContext context) {
    // This will rebuild when theme changes because it depends on InheritedWidget
    final themeProvider = ThemeProvider.of(context);

    return MaterialApp(
      title: 'Modern Charts',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF6366F1),
          brightness: Brightness.light,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF818CF8),
          brightness: Brightness.dark,
        ),
        cardTheme: CardThemeData(
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
      themeMode: themeProvider.themeMode,
      home: const ChartDemoScreen(),
    );
  }
}
