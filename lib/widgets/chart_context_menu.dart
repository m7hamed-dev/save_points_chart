import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/theme/chart_theme.dart';

/// An awesome context menu that appears when tapping on chart elements
class ChartContextMenu extends StatelessWidget {
  final ChartDataPoint? point;
  final PieData? segment;
  final int? datasetIndex;
  final int? elementIndex;
  final String? datasetLabel;
  final Offset position;
  final ChartTheme? theme;
  final bool useGlassmorphism;
  final bool useNeumorphism;
  final VoidCallback? onClose;
  final VoidCallback? onViewDetails;
  final VoidCallback? onExport;
  final VoidCallback? onShare;

  const ChartContextMenu({
    super.key,
    this.point,
    this.segment,
    this.datasetIndex,
    this.elementIndex,
    this.datasetLabel,
    required this.position,
    this.theme,
    this.useGlassmorphism = false,
    this.useNeumorphism = false,
    this.onClose,
    this.onViewDetails,
    this.onExport,
    this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Validate position to prevent NaN errors
    final safeDx = position.dx.isFinite ? position.dx : 0.0;
    final safeDy = position.dy.isFinite ? position.dy : 0.0;

    return Positioned(
      left: safeDx,
      top: safeDy,
      child: Material(
        color: Colors.transparent,
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            // Use RepaintBoundary to prevent unnecessary repaints
            return RepaintBoundary(
              child: Transform.scale(
                scale: 0.8 + (0.2 * value),
                child: Opacity(
                  opacity: value,
                  child: child,
                ),
              ),
            );
          },
          child: _buildMenuContent(context, isDark),
        ),
      ),
    );
  }

  Widget _buildMenuContent(BuildContext context, bool isDark) {
    if (useGlassmorphism) {
      return _buildGlassmorphismMenu(context, isDark);
    } else if (useNeumorphism) {
      return _buildNeumorphismMenu(context, isDark);
    } else {
      return _buildDefaultMenu(context, isDark);
    }
  }

  Widget _buildGlassmorphismMenu(BuildContext context, bool isDark) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: BackdropFilter(
        filter: ui.ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          width: 280,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: isDark
                  ? [
                      Colors.white.withValues(alpha: 0.1),
                      Colors.white.withValues(alpha: 0.05),
                    ]
                  : [
                      Colors.white.withValues(alpha: 0.8),
                      Colors.white.withValues(alpha: 0.6),
                    ],
            ),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.2)
                  : Colors.black.withValues(alpha: 0.1),
              width: 1.5,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: _buildMenuItems(context, isDark),
        ),
      ),
    );
  }

  Widget _buildNeumorphismMenu(BuildContext context, bool isDark) {
    final baseColor =
        isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE0E0E0);

    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: baseColor,
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.9),
            blurRadius: 20,
            offset: const Offset(-8, -8),
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.8)
                : Colors.grey.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(8, 8),
          ),
        ],
      ),
      child: _buildMenuItems(context, isDark),
    );
  }

  Widget _buildDefaultMenu(BuildContext context, bool isDark) {
    return Container(
      width: 280,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.1)
              : Colors.grey.withValues(alpha: 0.2),
        ),
      ),
      child: _buildMenuItems(context, isDark),
    );
  }

  Widget _buildMenuItems(BuildContext context, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Header
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                (point?.y != null
                        ? _getColorForValue(point!.y)
                        : segment?.color ?? Colors.blue)
                    .withValues(alpha: 0.2),
                (point?.y != null
                        ? _getColorForValue(point!.y)
                        : segment?.color ?? Colors.blue)
                    .withValues(alpha: 0.1),
              ],
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: (point?.y != null
                              ? _getColorForValue(point!.y)
                              : segment?.color ?? Colors.blue)
                          .withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      point != null ? Icons.show_chart : Icons.pie_chart,
                      color: point?.y != null
                          ? _getColorForValue(point!.y)
                          : segment?.color ?? Colors.blue,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          point != null
                              ? (point!.label ?? 'Data Point')
                              : (segment?.label ?? 'Segment'),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        if (datasetLabel != null)
                          Text(
                            datasetLabel!,
                            style: TextStyle(
                              fontSize: 12,
                              color: isDark ? Colors.white70 : Colors.black54,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: onClose,
                    color: isDark ? Colors.white70 : Colors.black54,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: isDark
                      ? Colors.white.withValues(alpha: 0.1)
                      : Colors.black.withValues(alpha: 0.05),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Value',
                          style: TextStyle(
                            fontSize: 11,
                            color: isDark ? Colors.white60 : Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          point != null
                              ? point!.y.toStringAsFixed(2)
                              : segment?.value.toStringAsFixed(2) ?? '0.00',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: point?.y != null
                                ? _getColorForValue(point!.y)
                                : segment?.color ?? Colors.blue,
                          ),
                        ),
                      ],
                    ),
                    if (point != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'X',
                            style: TextStyle(
                              fontSize: 11,
                              color: isDark ? Colors.white60 : Colors.black54,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            point!.x.toStringAsFixed(1),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: isDark ? Colors.white : Colors.black87,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Menu Items
        if (onViewDetails != null || onExport != null || onShare != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                if (onViewDetails != null)
                  _buildMenuItem(
                    context,
                    icon: Icons.info_outline,
                    label: 'View Details',
                    onTap: () {
                      onClose?.call();
                      onViewDetails?.call();
                    },
                    isDark: isDark,
                  ),
                if (onExport != null)
                  _buildMenuItem(
                    context,
                    icon: Icons.download,
                    label: 'Export Data',
                    onTap: () {
                      onClose?.call();
                      onExport?.call();
                    },
                    isDark: isDark,
                    isLast: onShare == null, // Last if share is not provided
                  ),
                if (onShare != null)
                  _buildMenuItem(
                    context,
                    icon: Icons.share,
                    label: 'Share',
                    onTap: () {
                      onClose?.call();
                      onShare?.call();
                    },
                    isDark: isDark,
                    isLast: true, // Always last if provided
                  ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    bool isLast = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: isDark
                ? Colors.white.withValues(alpha: 0.05)
                : Colors.black.withValues(alpha: 0.02),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: (point?.y != null
                          ? _getColorForValue(point!.y)
                          : segment?.color ?? Colors.blue)
                      .withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: point?.y != null
                      ? _getColorForValue(point!.y)
                      : segment?.color ?? Colors.blue,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: isDark ? Colors.white38 : Colors.black26,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getColorForValue(double value) {
    // Color based on value - green for high, red for low, etc.
    if (value > 80) return Colors.green;
    if (value > 50) return Colors.blue;
    if (value > 30) return Colors.orange;
    return Colors.red;
  }
}

/// Helper class to show context menu as overlay
class ChartContextMenuHelper {
  static OverlayEntry? _currentMenu;

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
    // If no actions are provided, don't show the context menu at all
    if (onViewDetails == null && onExport == null && onShare == null) {
      return;
    }

    // Close existing menu if any
    hide();

    final overlay = Overlay.of(context);
    final renderBox = context.findRenderObject() as RenderBox?;

    // Safely calculate global position with NaN checks
    Offset globalPosition;
    try {
      globalPosition =
          renderBox != null ? renderBox.localToGlobal(position) : position;

      // Validate position values (check for NaN or Infinity)
      if (!globalPosition.dx.isFinite || !globalPosition.dy.isFinite) {
        globalPosition = position; // Fallback to original position
      }
    } catch (e) {
      globalPosition = position; // Fallback to original position on error
    }

    // Get screen size safely
    final screenSize = MediaQuery.of(context).size;
    final screenWidth = screenSize.width.isFinite ? screenSize.width : 800.0;
    final screenHeight = screenSize.height.isFinite ? screenSize.height : 600.0;

    // Adjust position to keep menu on screen with NaN protection
    final adjustedPosition = Offset(
      globalPosition.dx.isFinite
          ? globalPosition.dx.clamp(16.0, screenWidth - 296)
          : 16.0,
      globalPosition.dy.isFinite
          ? globalPosition.dy.clamp(16.0, screenHeight - 400)
          : 16.0,
    );

    _currentMenu = OverlayEntry(
      builder: (context) => Stack(
        children: [
          // Backdrop - only captures taps outside the menu area
          // Use a custom approach to allow chart taps to pass through
          Positioned.fill(
            child: GestureDetector(
              onTap: () {
                // Hide menu when tapping outside
                hide();
              },
              behavior: HitTestBehavior.translucent,
              child: Container(
                color: Colors.transparent,
              ),
            ),
          ),
          // Context Menu - positioned above backdrop
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
    );

    overlay.insert(_currentMenu!);
  }

  static void hide() {
    _currentMenu?.remove();
    _currentMenu = null;
  }
}
