import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/widgets/chart_context_menu/chart_context_menu_widget.dart';

/// Helper class to show context menu as overlay
class ChartContextMenuHelper {
  static OverlayEntry? _currentMenu;
  static ui.ImageFilter? _cachedBlurFilter;

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
    final globalPosition = _calculateGlobalPosition(context, position);
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

  static Offset _calculateGlobalPosition(
    BuildContext context,
    Offset position,
  ) {
    final renderBox = context.findRenderObject() as RenderBox?;

    try {
      final globalPosition = renderBox != null
          ? renderBox.localToGlobal(position)
          : position;

      if (!globalPosition.dx.isFinite || !globalPosition.dy.isFinite) {
        return position;
      }
      return globalPosition;
    } catch (e) {
      return position;
    }
  }

  static Offset _calculateAdjustedPosition(
    BuildContext context,
    Offset globalPosition,
  ) {
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
    final screenWidth = screenSize.width.isFinite ? screenSize.width : 800.0;
    final screenHeight = screenSize.height.isFinite ? screenSize.height : 600.0;

    return Offset(
      globalPosition.dx.isFinite
          ? globalPosition.dx.clamp(16.0, screenWidth - 316)
          : 16.0,
      globalPosition.dy.isFinite
          ? globalPosition.dy.clamp(16.0, screenHeight - 450)
          : 16.0,
    );
  }

  static void _ensureBlurFilter(bool backgroundBlur) {
    if (backgroundBlur && _cachedBlurFilter == null) {
      _cachedBlurFilter = ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8);
    }
  }

  static Widget _buildBackdrop(bool backgroundBlur) {
    return Positioned.fill(
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
    );
  }

  static void hide() {
    _currentMenu?.remove();
    _currentMenu = null;
    _cachedBlurFilter = null;
  }
}
