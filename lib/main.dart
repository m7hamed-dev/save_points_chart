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
  // Define themes here to keep build method clean
  ThemeData _buildTheme(Brightness brightness) {
    // Use slightly different seed colors for light/dark to optimize contrast
    final seedColor = brightness == Brightness.light 
        ? const Color(0xFF6366F1) 
        : const Color(0xFF818CF8);
        
    final colorScheme = ColorScheme.fromSeed(
      seedColor: seedColor,
      brightness: brightness,
    );
    
    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
    );
  }

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
          theme: _buildTheme(Brightness.light),
          darkTheme: _buildTheme(Brightness.dark),
          themeMode: themeProvider.themeMode,
          home: const ChartDemoScreen(),
        );
      },
    );
  }
}
