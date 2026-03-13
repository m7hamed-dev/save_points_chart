import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/widgets/chart_context_menu/chart_context_menu_widget.dart';

/// Helper class to show context menu as overlay
class ChartContextMenuHelper {
  static OverlayEntry? _currentMenu;
  static ui.ImageFilter? _cachedBlurFilter;

  static const double _kMenuWidth = 230.0;
  static const double _kMenuHeight = 140.0;
  static const double _kPadding = 12.0;

  static void show(
    BuildContext context, {
    required ChartDataPoint? point,
    required PieData? segment,
    required Offset position,
    int? datasetIndex,
    int? elementIndex,
    String? datasetLabel,
    ChartTheme? theme,
    bool useGlassmorphism = false,
    bool useNeumorphism = false,
    bool backgroundBlur = false,
    VoidCallback? onViewDetails,
    VoidCallback? onExport,
    VoidCallback? onShare,
  }) {
    if (!_hasActions(onViewDetails, onExport, onShare)) {
      return;
    }

    hide();

    final overlay = Overlay.of(context);
    // `position` is expected to be in global coordinates from the chart.
    final globalPosition = _calculateGlobalPosition(position);
    final adjustedPosition = _calculateAdjustedPosition(
      context,
      globalPosition,
    );

    _ensureBlurFilter(backgroundBlur);

    _currentMenu = OverlayEntry(
      builder: (context) => RepaintBoundary(
        child: Stack(
          children: [
            _buildBackdrop(backgroundBlur),
            ChartContextMenu(
              point: point,
              segment: segment,
              datasetIndex: datasetIndex,
              elementIndex: elementIndex,
              datasetLabel: datasetLabel,
              position: adjustedPosition,
              theme: theme,
              useGlassmorphism: useGlassmorphism,
              useNeumorphism: useNeumorphism,
              onClose: hide,
              onViewDetails: onViewDetails,
              onExport: onExport,
              onShare: onShare,
            ),
          ],
        ),
      ),
    );

    overlay.insert(_currentMenu!);
  }

  static bool _hasActions(
    VoidCallback? onViewDetails,
    VoidCallback? onExport,
    VoidCallback? onShare,
  ) {
    return onViewDetails != null || onExport != null || onShare != null;
  }

  static Offset _calculateGlobalPosition(Offset position) {
    if (!position.dx.isFinite || !position.dy.isFinite) {
      return const Offset(0, 0);
    }
    return position;
  }

  static Offset _calculateAdjustedPosition(
    BuildContext context,
    Offset globalPosition,
  ) {
    final screenSize = MediaQuery.sizeOf(context);
    final screenWidth = screenSize.width.isFinite ? screenSize.width : 800.0;
    final screenHeight = screenSize.height.isFinite ? screenSize.height : 600.0;

    // Start anchored just BELOW the provided point (same x), then adjust only
    // if we would go out of bounds. This gives the effect of the chart element
    // appearing "in front" and the tooltip sitting behind/beneath it.
    double dx = globalPosition.dx;
    double dy = globalPosition.dy + 12;

    // Clamp within screen bounds with a small padding.
    if (dx + _kMenuWidth + _kPadding > screenWidth) {
      dx = screenWidth - _kMenuWidth - _kPadding;
    }
    if (dx - _kPadding < 0) {
      dx = _kPadding;
    }
    if (dy + _kMenuHeight + _kPadding > screenHeight) {
      dy = screenHeight - _kMenuHeight - _kPadding;
      if (dy < _kPadding) {
        dy = _kPadding;
      }
    }

    return Offset(dx, dy);
  }

  static void _ensureBlurFilter(bool backgroundBlur) {
    if (backgroundBlur && _cachedBlurFilter == null) {
      _cachedBlurFilter = ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8);
    }
  }

  static Widget _buildBackdrop(bool backgroundBlur) {
    return Positioned.fill(
      child: Semantics(
        label: 'Dismiss menu',
        button: true,
        onTap: hide,
        child: GestureDetector(
          onTap: hide,
          behavior: HitTestBehavior.translucent,
          child: backgroundBlur && _cachedBlurFilter != null
              ? ClipRect(
                  child: BackdropFilter(
                    filter: _cachedBlurFilter!,
                    child: Container(color: Colors.black.withValues(alpha: 0.1)),
                  ),
                )
              : Container(color: Colors.transparent),
        ),
      ),
    );
  }

  static void hide() {
    _currentMenu?.remove();
    _currentMenu = null;
    _cachedBlurFilter = null;
  }
}
