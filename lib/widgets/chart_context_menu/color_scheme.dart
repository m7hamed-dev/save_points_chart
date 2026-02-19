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

  const WebUIColorScheme({
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accentColor,
    required this.hoverColor,
    required this.dividerColor,
  });

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
    );
  }
}
