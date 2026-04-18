import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/widgets/chart_context_menu/chart_context_menu_widget.dart';

/// Helper for displaying a chart context menu as an application overlay.
///
/// Usage (from inside a chart's tap callback):
/// ```dart
/// ChartContextMenuHelper.show(
///   context,
///   point: point,
///   segment: null,
///   position: globalTapPosition,
///   onViewDetails: () { /* ... */ },
/// );
/// ```
///
/// Only one menu is shown at a time; calling [show] again replaces the current
/// menu. Calling [hide] is idempotent.
class ChartContextMenuHelper {
  ChartContextMenuHelper._();

  static OverlayEntry? _currentMenu;

  /// Horizontal inset between the menu and the edge of the available area.
  static const double _kPadding = 12.0;

  /// Gap between the tap point and the top edge of the menu when it opens
  /// below, or the bottom edge when it opens above.
  static const double _kAnchorGap = 12.0;

  /// Modern/compact menu width. Matches the default style used by
  /// [ChartContextMenu].
  static const double _kMenuWidthCompact = 230.0;

  /// Glassmorphism / neumorphism menu width. Matches those styles used by
  /// [ChartContextMenu].
  static const double _kMenuWidthWide = 320.0;

  /// Heuristic base heights before per-action rows are added. These do not
  /// need to be pixel-exact — they're only used to decide whether the menu
  /// should flip above the tap point and to clamp within the safe area.
  static const double _kMenuBaseHeightCompact = 120.0;
  static const double _kMenuBaseHeightWide = 180.0;
  static const double _kActionRowHeight = 44.0;

  /// The blur filter used when [show] is called with `backgroundBlur: true`.
  /// Creating this on every show is essentially free, but we keep a single
  /// reusable instance to avoid churn when menus are opened in rapid
  /// succession (e.g. dragging across data points).
  static final ui.ImageFilter _blurFilter =
      ui.ImageFilter.blur(sigmaX: 8, sigmaY: 8);

  /// Whether a menu is currently on screen.
  static bool get isVisible => _currentMenu != null;

  /// Display a context menu anchored near [position] (in global coordinates).
  ///
  /// - At least one of [onViewDetails], [onExport], or [onShare] must be
  ///   provided. Without any actions the menu has nothing to show, so the
  ///   call is a no-op.
  /// - [useGlassmorphism] and [useNeumorphism] are mutually exclusive; if
  ///   both are true, glassmorphism takes priority (matches the widget
  ///   behavior).
  /// - The menu flips above the tap point when there isn't enough room below,
  ///   and otherwise opens below. It also stays within the safe area on
  ///   notched devices.
  static void show(
    BuildContext context, {
    required ChartDataPoint? point,
    required PieData? segment,
    required Offset position,
    int? datasetIndex,
    int? elementIndex,
    String? datasetLabel,
    ChartTheme? theme,
    Color? backgroundColor,
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

    // Attach to the root overlay so the menu survives inside nested
    // Navigators, BottomSheets, and dialogs instead of being torn down with
    // the surrounding route.
    final overlay = Overlay.of(context, rootOverlay: true);

    final actionCount = [onViewDetails, onExport, onShare]
        .where((a) => a != null)
        .length;
    final menuSize = _estimateMenuSize(
      useGlassmorphism: useGlassmorphism,
      useNeumorphism: useNeumorphism,
      actionCount: actionCount,
    );

    final adjustedPosition = _calculateAdjustedPosition(
      context,
      _sanitizePosition(position),
      menuSize,
    );

    _currentMenu = OverlayEntry(
      builder: (overlayContext) {
        return _DismissibleMenuHost(
          onDismiss: hide,
          backgroundBlur: backgroundBlur,
          child: ChartContextMenu(
            point: point,
            segment: segment,
            datasetIndex: datasetIndex,
            elementIndex: elementIndex,
            datasetLabel: datasetLabel,
            position: adjustedPosition,
            theme: theme,
            backgroundColor: backgroundColor,
            useGlassmorphism: useGlassmorphism,
            useNeumorphism: useNeumorphism,
            onClose: hide,
            onViewDetails: onViewDetails,
            onExport: onExport,
            onShare: onShare,
          ),
        );
      },
    );

    overlay.insert(_currentMenu!);
  }

  /// Dismiss the current menu if any. Safe to call when no menu is visible.
  static void hide() {
    final entry = _currentMenu;
    _currentMenu = null;
    if (entry == null) return;
    // Guard against a race where the overlay entry has already been removed
    // (for example, if the surrounding Overlay was torn down).
    try {
      entry.remove();
    } catch (_) {
      // Ignored: entry was already removed.
    }
  }

  // ── Internal helpers ────────────────────────────────────────────────────

  static bool _hasActions(
    VoidCallback? onViewDetails,
    VoidCallback? onExport,
    VoidCallback? onShare,
  ) =>
      onViewDetails != null || onExport != null || onShare != null;

  static Offset _sanitizePosition(Offset position) {
    if (!position.dx.isFinite || !position.dy.isFinite) return Offset.zero;
    return position;
  }

  /// Estimate the menu's rendered size based on which style will be used and
  /// how many actions it will show. Used only for bounds-checking and the
  /// flip-above decision — the real size is determined by the widget layout.
  static Size _estimateMenuSize({
    required bool useGlassmorphism,
    required bool useNeumorphism,
    required int actionCount,
  }) {
    final wide = useGlassmorphism || useNeumorphism;
    final width = wide ? _kMenuWidthWide : _kMenuWidthCompact;
    final base = wide ? _kMenuBaseHeightWide : _kMenuBaseHeightCompact;
    final height = base + actionCount * _kActionRowHeight;
    return Size(width, height);
  }

  /// Decide where to place the top-left of the menu so it fits inside the
  /// current safe area, flips above the tap point if there isn't enough room
  /// below, and stays anchored close to [globalPosition] horizontally.
  static Offset _calculateAdjustedPosition(
    BuildContext context,
    Offset globalPosition,
    Size menuSize,
  ) {
    final screenSize = MediaQuery.sizeOf(context);
    final safePadding = MediaQuery.paddingOf(context);

    final screenWidth = screenSize.width.isFinite ? screenSize.width : 800.0;
    final screenHeight =
        screenSize.height.isFinite ? screenSize.height : 600.0;

    final minX = safePadding.left + _kPadding;
    final maxX = screenWidth - safePadding.right - menuSize.width - _kPadding;
    final minY = safePadding.top + _kPadding;
    final maxY =
        screenHeight - safePadding.bottom - menuSize.height - _kPadding;

    // Preferred position: anchored at the tap x, just below the tap point.
    double dx = globalPosition.dx;
    double dy = globalPosition.dy + _kAnchorGap;

    // Flip above the tap if there isn't enough room below.
    if (dy > maxY) {
      final above = globalPosition.dy - _kAnchorGap - menuSize.height;
      // Only flip if flipping actually improves fit, otherwise just clamp.
      if (above >= minY) {
        dy = above;
      } else {
        dy = maxY;
      }
    }

    // Horizontal clamp with safe-area awareness.
    if (maxX >= minX) {
      dx = dx.clamp(minX, maxX).toDouble();
    } else {
      // Viewport is narrower than the menu: just sit against the leading edge.
      dx = minX;
    }

    // Final vertical clamp in case we still overflow (tiny viewport).
    if (maxY >= minY) {
      dy = dy.clamp(minY, maxY).toDouble();
    } else {
      dy = minY;
    }

    return Offset(dx, dy);
  }
}

/// Wraps the menu content with a full-screen barrier that supports tap and
/// keyboard (Escape) dismissal. Lives in its own widget so it can take focus
/// and participate in the focus tree, which the old implementation couldn't.
class _DismissibleMenuHost extends StatelessWidget {
  const _DismissibleMenuHost({
    required this.child,
    required this.onDismiss,
    required this.backgroundBlur,
  });

  final Widget child;
  final VoidCallback onDismiss;
  final bool backgroundBlur;

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: FocusScope(
        autofocus: true,
        child: Shortcuts(
          shortcuts: const <ShortcutActivator, Intent>{
            SingleActivator(LogicalKeyboardKey.escape): _DismissIntent(),
          },
          child: Actions(
            actions: <Type, Action<Intent>>{
              _DismissIntent: CallbackAction<_DismissIntent>(
                onInvoke: (_) {
                  onDismiss();
                  return null;
                },
              ),
            },
            child: Focus(
              autofocus: true,
              child: Stack(
                children: [
                  _Backdrop(onTap: onDismiss, blurred: backgroundBlur),
                  child,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _DismissIntent extends Intent {
  const _DismissIntent();
}

class _Backdrop extends StatelessWidget {
  const _Backdrop({required this.onTap, required this.blurred});

  final VoidCallback onTap;
  final bool blurred;

  @override
  Widget build(BuildContext context) {
    final barrier = GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: blurred
          ? ClipRect(
              child: BackdropFilter(
                filter: ChartContextMenuHelper._blurFilter,
                child: Container(color: Colors.black.withValues(alpha: 0.1)),
              ),
            )
          : Container(color: Colors.transparent),
    );

    return Positioned.fill(
      child: Semantics(
        label: 'Dismiss menu',
        button: true,
        container: true,
        child: barrier,
      ),
    );
  }
}
