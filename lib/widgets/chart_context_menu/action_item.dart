import 'package:flutter/material.dart';

/// Represents an action item in the context menu
class ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}
