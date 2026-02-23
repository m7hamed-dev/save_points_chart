import 'package:flutter/material.dart';
import 'package:save_points_chart/widgets/chart_context_menu/color_scheme.dart';

/// Web-style close button with hover effect
class WebCloseButton extends StatefulWidget {
  final VoidCallback? onTap;
  final WebUIColorScheme colorScheme;

  const WebCloseButton({
    super.key,
    required this.onTap,
    required this.colorScheme,
  });

  @override
  State<WebCloseButton> createState() => _WebCloseButtonState();
}

class _WebCloseButtonState extends State<WebCloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: 'Close menu',
      enabled: true,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: _isHovered
                  ? widget.colorScheme.hoverColor
                  : Colors.transparent,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Icon(
              Icons.close_rounded,
              size: 16,
              color: widget.colorScheme.textSecondary,
            ),
          ),
        ),
      ),
    );
  }
}
