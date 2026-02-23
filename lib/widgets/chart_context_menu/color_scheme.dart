import 'package:flutter/material.dart';

/// Web-inspired color scheme for modern UI
class WebUIColorScheme {
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accentColor;
  final Color hoverColor;
  final Color dividerColor;
  final List<BoxShadow> shadows;

  const WebUIColorScheme({
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accentColor,
    required this.hoverColor,
    required this.dividerColor,
    this.shadows = const [],
  });

  factory WebUIColorScheme.fromTheme(BuildContext context, {Color? accentColor}) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final colorScheme = theme.colorScheme;

    return WebUIColorScheme(
      surfaceColor: isDark ? const Color(0xFF1F2937) : Colors.white,
      borderColor: isDark ? const Color(0xFF374151) : const Color(0xFFE5E7EB),
      textPrimary: isDark ? const Color(0xFFF9FAFB) : const Color(0xFF111827),
      textSecondary: isDark ? const Color(0xFFD1D5DB) : const Color(0xFF6B7280),
      textTertiary: isDark ? const Color(0xFF9CA3AF) : const Color(0xFF9CA3AF),
      accentColor: accentColor ?? colorScheme.primary,
      hoverColor: isDark ? const Color(0xFF374151) : const Color(0xFFF9FAFB),
      dividerColor: isDark ? const Color(0xFF4B5563) : const Color(0xFFE5E7EB),
      shadows: [
        BoxShadow(
          color: isDark ? Colors.black.withValues(alpha: 0.5) : Colors.black.withValues(alpha: 0.1),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ],
    );
  }

  factory WebUIColorScheme.light(Color accentColor) {
    return WebUIColorScheme(
      surfaceColor: Colors.white,
      borderColor: const Color(0xFFE5E7EB),
      textPrimary: const Color(0xFF111827),
      textSecondary: const Color(0xFF6B7280),
      textTertiary: const Color(0xFF9CA3AF),
      accentColor: accentColor,
      hoverColor: const Color(0xFFF9FAFB),
      dividerColor: const Color(0xFFE5E7EB),
      shadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.08),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ],
    );
  }

  factory WebUIColorScheme.dark(Color accentColor) {
    return WebUIColorScheme(
      surfaceColor: const Color(0xFF1F2937),
      borderColor: const Color(0xFF374151),
      textPrimary: const Color(0xFFF9FAFB),
      textSecondary: const Color(0xFFD1D5DB),
      textTertiary: const Color(0xFF9CA3AF),
      accentColor: accentColor,
      hoverColor: const Color(0xFF374151),
      dividerColor: const Color(0xFF4B5563),
      shadows: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.6),
          blurRadius: 24,
          offset: const Offset(0, 8),
          spreadRadius: -4,
        ),
      ],
    );
  }
}
