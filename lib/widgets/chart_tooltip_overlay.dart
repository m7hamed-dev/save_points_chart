import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/utils/format_utils.dart';
import 'package:save_points_chart/widgets/chart_tooltip.dart';

class ChartTooltipOverlay {
  static OverlayEntry? _entry;
  static ui.ImageFilter? _blur;

  static void show(
    BuildContext context, {
    required Offset globalAnchor,
    required ChartTheme theme,
    required ChartDataPoint point,
    Color? color,
    String? seriesLabel,
  }) {
    hide();
    final overlay = Overlay.of(context);
    final screen = MediaQuery.sizeOf(context);

    final safeAnchor = Offset(
      globalAnchor.dx.isFinite ? globalAnchor.dx : 0,
      globalAnchor.dy.isFinite ? globalAnchor.dy : 0,
    );

    _blur ??= ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10);

    _entry = OverlayEntry(
      builder: (context) {
        // Prefer showing above/right of cursor; clamp into viewport.
        const margin = 12.0;
        final dx = (safeAnchor.dx + 14).clamp(margin, screen.width - margin);
        final dy = (safeAnchor.dy - 14).clamp(margin, screen.height - margin);

        return Positioned(
          left: dx,
          top: dy,
          child: IgnorePointer(
            child: RepaintBoundary(
              child: ClipRRect(
                borderRadius: const .all(.circular(12)),
                child: BackdropFilter(
                  filter: _blur!,
                  child: ChartTooltip(
                    theme: theme,
                    title: point.label ?? 'Value',
                    subtitle: seriesLabel,
                    value: ChartFormatUtils.formatValue(point.y),
                    color: color,
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );

    overlay.insert(_entry!);
  }

  static void hide() {
    _entry?.remove();
    _entry = null;
  }
}
