import 'dart:ui' show Offset;

import 'package:flutter/material.dart' show Color;

/// Data model for overlay tooltip display.
class TooltipData {
  const TooltipData({
    required this.title,
    required this.position,
    this.subtitle,
    this.entries = const [],
  });

  final String title;
  final String? subtitle;
  final Offset position;
  final List<TooltipEntry> entries;
}

class TooltipEntry {
  const TooltipEntry({
    required this.label,
    required this.value,
    this.color,
  });

  final String label;
  final String value;
  final Color? color;
}
