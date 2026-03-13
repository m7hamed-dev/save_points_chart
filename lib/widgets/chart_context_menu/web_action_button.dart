import 'package:flutter/material.dart';
import 'package:save_points_chart/widgets/chart_context_menu/action_item.dart';
import 'package:save_points_chart/widgets/chart_context_menu/color_scheme.dart';

/// Web-style action button with hover effects
class WebActionButton extends StatefulWidget {
  final ActionItem action;
  final WebUIColorScheme colorScheme;
  final bool isLast;

  const WebActionButton({super.key, required this.action, required this.colorScheme, required this.isLast});

  @override
  State<WebActionButton> createState() => _WebActionButtonState();
}

class _WebActionButtonState extends State<WebActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: widget.action.label,
      enabled: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.action.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            curve: Curves.easeOut,
            padding: const .symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _isHovered ? widget.colorScheme.hoverColor : Colors.transparent,
              border: widget.isLast ? null : Border(bottom: BorderSide(color: widget.colorScheme.dividerColor)),
            ),
            child: Row(
              children: [
                Icon(widget.action.icon, size: 18, color: widget.colorScheme.textSecondary),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    widget.action.label,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: widget.colorScheme.textPrimary,
                      letterSpacing: -0.1,
                    ),
                  ),
                ),
                AnimatedRotation(
                  duration: const Duration(milliseconds: 150),
                  turns: _isHovered ? 0 : -0.125,
                  child: Icon(Icons.arrow_forward_rounded, size: 16, color: widget.colorScheme.textTertiary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
