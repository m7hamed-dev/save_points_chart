import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/theme/chart_theme.dart';

/// An awesome context menu that appears when tapping on chart elements
class ChartContextMenu extends StatefulWidget {
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
  State<ChartContextMenu> createState() => _ChartContextMenuState();
}

class _ChartContextMenuState extends State<ChartContextMenu> {
  // Cached computed values to avoid recalculating on every build
  late final Color _primaryColor;
  late final String _formattedValue;
  late final String? _formattedXValue;
  late final String _label;
  late final bool _hasPoint;

  @override
  void initState() {
    super.initState();
    _hasPoint = widget.point != null;
    _primaryColor = _computePrimaryColor();
    _formattedValue = _computeFormattedValue();
    _formattedXValue = _hasPoint ? widget.point!.x.toStringAsFixed(1) : null;
    _label = widget.point?.label ??
        widget.segment?.label ??
        (_hasPoint ? 'Data Point' : 'Segment');
  }

  Color _computePrimaryColor() {
    if (_hasPoint) {
      return _getColorForValue(widget.point!.y);
    }
    return widget.segment?.color ?? Colors.blue;
  }

  String _computeFormattedValue() {
    if (_hasPoint) {
      return widget.point!.y.toStringAsFixed(2);
    }
    return widget.segment?.value.toStringAsFixed(2) ?? '0.00';
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Validate position to prevent NaN errors
    final safeDx = widget.position.dx.isFinite ? widget.position.dx : 0.0;
    final safeDy = widget.position.dy.isFinite ? widget.position.dy : 0.0;

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
    if (widget.useGlassmorphism) {
      return _buildGlassmorphismMenu(context, isDark);
    } else if (widget.useNeumorphism) {
      return _buildNeumorphismMenu(context, isDark);
    } else {
      return _buildDefaultMenu(context, isDark);
    }
  }

  Widget _buildGlassmorphismMenu(BuildContext context, bool isDark) {
    // Cache gradient colors and border color
    final gradientColors = isDark
        ? [
            Colors.white.withValues(alpha: 0.1),
            Colors.white.withValues(alpha: 0.05),
          ]
        : [
            Colors.white.withValues(alpha: 0.8),
            Colors.white.withValues(alpha: 0.6),
          ];
    final borderColor = isDark
        ? Colors.white.withValues(alpha: 0.2)
        : Colors.black.withValues(alpha: 0.1);

    return RepaintBoundary(
      child: ClipRRect(
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
                colors: gradientColors,
              ),
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
              boxShadow: const [
                BoxShadow(
                  color:
                      Color(0x33000000), // Colors.black.withValues(alpha: 0.2)
                  blurRadius: 20,
                  offset: Offset(0, 10),
                ),
              ],
            ),
            child: _buildMenuItems(context, isDark),
          ),
        ),
      ),
    );
  }

  Widget _buildNeumorphismMenu(BuildContext context, bool isDark) {
    final baseColor =
        isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE0E0E0);

    // Cache shadow colors
    final lightShadow = isDark
        ? const Color(0x80000000) // Colors.black.withValues(alpha: 0.5)
        : const Color(0xE6FFFFFF); // Colors.white.withValues(alpha: 0.9)
    final darkShadow = isDark
        ? const Color(0xCC000000) // Colors.black.withValues(alpha: 0.8)
        : const Color(0x4D808080); // Colors.grey.withValues(alpha: 0.3)

    return RepaintBoundary(
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: baseColor,
          boxShadow: [
            BoxShadow(
              color: lightShadow,
              blurRadius: 20,
              offset: const Offset(-8, -8),
            ),
            BoxShadow(
              color: darkShadow,
              blurRadius: 20,
              offset: const Offset(8, 8),
            ),
          ],
        ),
        child: _buildMenuItems(context, isDark),
      ),
    );
  }

  Widget _buildDefaultMenu(BuildContext context, bool isDark) {
    final backgroundColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final borderColor = isDark
        ? const Color(0x1AFFFFFF) // Colors.white.withValues(alpha: 0.1)
        : const Color(0x33BDBDBD); // Colors.grey.withValues(alpha: 0.2)

    return RepaintBoundary(
      child: Container(
        width: 280,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: backgroundColor,
          boxShadow: const [
            BoxShadow(
              color: Color(0x4D000000), // Colors.black.withValues(alpha: 0.3)
              blurRadius: 20,
              offset: Offset(0, 10),
            ),
          ],
          border: Border.all(color: borderColor),
        ),
        child: _buildMenuItems(context, isDark),
      ),
    );
  }

  Widget _buildMenuItems(BuildContext context, bool isDark) {
    // Cache gradient colors
    final gradientColor1 = _primaryColor.withValues(alpha: 0.2);
    final gradientColor2 = _primaryColor.withValues(alpha: 0.1);
    final iconBgColor = _primaryColor.withValues(alpha: 0.2);

    // Cache text colors
    final titleColor = isDark ? Colors.white : Colors.black87;
    final subtitleColor = isDark ? Colors.white70 : Colors.black54;
    final valueLabelColor = isDark ? Colors.white60 : Colors.black54;
    final closeButtonColor = isDark ? Colors.white70 : Colors.black54;

    // Cache background colors
    final valueBgColor = isDark
        ? const Color(0x1AFFFFFF) // Colors.white.withValues(alpha: 0.1)
        : const Color(0x0D000000); // Colors.black.withValues(alpha: 0.05)

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
              colors: [gradientColor1, gradientColor2],
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
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      _hasPoint ? Icons.show_chart : Icons.pie_chart,
                      color: _primaryColor,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _label,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: titleColor,
                          ),
                        ),
                        if (widget.datasetLabel != null)
                          Text(
                            widget.datasetLabel!,
                            style: TextStyle(
                              fontSize: 12,
                              color: subtitleColor,
                            ),
                          ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 18),
                    onPressed: widget.onClose,
                    color: closeButtonColor,
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
                  color: valueBgColor,
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
                            color: valueLabelColor,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _formattedValue,
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: _primaryColor,
                          ),
                        ),
                      ],
                    ),
                    if (_formattedXValue != null)
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            'X',
                            style: TextStyle(
                              fontSize: 11,
                              color: valueLabelColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formattedXValue!,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: titleColor,
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
        if (widget.onViewDetails != null ||
            widget.onExport != null ||
            widget.onShare != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Column(
              children: [
                if (widget.onViewDetails != null)
                  _buildMenuItem(
                    context,
                    icon: Icons.info_outline,
                    label: 'View Details',
                    onTap: () {
                      widget.onClose?.call();
                      widget.onViewDetails?.call();
                    },
                    isDark: isDark,
                  ),
                if (widget.onExport != null)
                  _buildMenuItem(
                    context,
                    icon: Icons.download,
                    label: 'Export Data',
                    onTap: () {
                      widget.onClose?.call();
                      widget.onExport?.call();
                    },
                    isDark: isDark,
                    isLast: widget.onShare == null,
                  ),
                if (widget.onShare != null)
                  _buildMenuItem(
                    context,
                    icon: Icons.share,
                    label: 'Share',
                    onTap: () {
                      widget.onClose?.call();
                      widget.onShare?.call();
                    },
                    isDark: isDark,
                    isLast: true,
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
    // Cache colors
    final bgColor = isDark
        ? const Color(0x0DFFFFFF) // Colors.white.withValues(alpha: 0.05)
        : const Color(0x05000000); // Colors.black.withValues(alpha: 0.02)
    final iconBgColor = _primaryColor.withValues(alpha: 0.1);
    final textColor = isDark ? Colors.white : Colors.black87;
    final chevronColor = isDark ? Colors.white38 : Colors.black26;

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
            color: bgColor,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: iconBgColor,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 20,
                  color: _primaryColor,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: textColor,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                size: 20,
                color: chevronColor,
              ),
            ],
          ),
        ),
      ),
    );
  }

  static Color _getColorForValue(double value) {
    // Color based on value - green for high, red for low, etc.
    // Use const colors for better performance
    if (value > 80) return Colors.green;
    if (value > 50) return Colors.blue;
    if (value > 30) return Colors.orange;
    return Colors.red;
  }
}

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

    // Get screen size safely - cache MediaQuery to avoid multiple lookups
    final mediaQuery = MediaQuery.of(context);
    final screenSize = mediaQuery.size;
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

    // Cache blur filter for better performance
    if (backgroundBlur && _cachedBlurFilter == null) {
      _cachedBlurFilter = ui.ImageFilter.blur(sigmaX: 5, sigmaY: 5);
    }

    _currentMenu = OverlayEntry(
      builder: (context) => RepaintBoundary(
        child: Stack(
          children: [
            // Backdrop - only captures taps outside the menu area
            // Use a custom approach to allow chart taps to pass through
            Positioned.fill(
              child: GestureDetector(
                onTap: hide,
                behavior: HitTestBehavior.translucent,
                child: backgroundBlur && _cachedBlurFilter != null
                    ? ClipRect(
                        child: BackdropFilter(
                          filter: _cachedBlurFilter!,
                          child: const SizedBox.expand(),
                        ),
                      )
                    : const SizedBox.expand(),
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
      ),
    );

    overlay.insert(_currentMenu!);
  }

  static void hide() {
    _currentMenu?.remove();
    _currentMenu = null;
    // Clear cached blur filter when menu is hidden
    _cachedBlurFilter = null;
  }
}
