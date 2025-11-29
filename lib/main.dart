import 'package:flutter/material.dart';
import 'package:save_points_chart/providers/theme_provider.dart';
import 'package:save_points_chart/screens/chart_demo_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ThemeProvider(
      child: _MaterialAppWithTheme(),
    );
  }
}

class _MaterialAppWithTheme extends StatefulWidget {
  const _MaterialAppWithTheme();

  @override
  State<_MaterialAppWithTheme> createState() => _MaterialAppWithThemeState();
}

class _MaterialAppWithThemeState extends State<_MaterialAppWithTheme> {
  @override
  Widget build(BuildContext context) {
    // Use Builder to ensure we get the correct context for ThemeProvider
    return Builder(
      builder: (context) {
        // This will rebuild when theme changes because it depends on InheritedWidget
        final themeProvider = ThemeProvider.of(context);

        return MaterialApp(
          // Key ensures MaterialApp rebuilds when themeMode changes
          key: ValueKey(themeProvider.themeMode),
          title: 'Modern Charts',
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
            useMaterial3: true,
            colorScheme: ColorScheme.fromSeed(
              seedColor: const Color(0xFF6366F1),
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
      },
    );
  }
}
