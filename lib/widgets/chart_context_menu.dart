import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/theme/chart_theme.dart';

/// Color scheme for menu styling
class _MenuColorScheme {
  final List<Color> gradientColors;
  final Color iconBgColor;
  final Color titleColor;
  final Color subtitleColor;
  final Color valueLabelColor;
  final Color closeButtonColor;
  final Color valueBgColor;

  const _MenuColorScheme({
    required this.gradientColors,
    required this.iconBgColor,
    required this.titleColor,
    required this.subtitleColor,
    required this.valueLabelColor,
    required this.closeButtonColor,
    required this.valueBgColor,
  });
}

/// Color scheme for menu item styling
class _MenuItemColors {
  final Color bgColor;
  final Color iconBgColor;
  final Color textColor;
  final Color chevronColor;
  final Color borderColor;

  const _MenuItemColors({
    required this.bgColor,
    required this.iconBgColor,
    required this.textColor,
    required this.chevronColor,
    required this.borderColor,
  });
}

/// An awesome context menu that appears when tapping on chart elements
class ChartContextMenu extends StatefulWidget {
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
          duration: const Duration(milliseconds: 400),
          tween: Tween(begin: 0.0, end: 1.0),
          curve: Curves.easeOutCubic,
          builder: (context, value, child) {
            // Use RepaintBoundary to prevent unnecessary repaints
            return RepaintBoundary(
              child: Transform.scale(
                scale: 0.85 + (0.15 * value),
                child: Transform.translate(
                  offset: Offset(0, 10 * (1 - value)),
                  child: Opacity(
                    opacity: value,
                    child: child,
                  ),
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
    final gradientColors = _getGlassmorphismGradientColors(isDark);
    final borderColor = _getGlassmorphismBorderColor(isDark);
    final shadows = _getGlassmorphismShadows(isDark);

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(24),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 300,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              border: Border.all(
                color: borderColor,
                width: 1.5,
              ),
              boxShadow: shadows,
            ),
            child: _buildMenuItems(context, isDark),
          ),
        ),
      ),
    );
  }

  List<Color> _getGlassmorphismGradientColors(bool isDark) {
    return isDark
        ? [
            Colors.white.withValues(alpha: 0.15),
            Colors.white.withValues(alpha: 0.08),
            Colors.white.withValues(alpha: 0.05),
          ]
        : [
            Colors.white.withValues(alpha: 0.95),
            Colors.white.withValues(alpha: 0.85),
            Colors.white.withValues(alpha: 0.75),
          ];
  }

  Color _getGlassmorphismBorderColor(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.25)
        : Colors.black.withValues(alpha: 0.08);
  }

  List<BoxShadow> _getGlassmorphismShadows(bool isDark) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.4)
            : Colors.black.withValues(alpha: 0.15),
        blurRadius: 30,
        offset: const Offset(0, 12),
        spreadRadius: -5,
      ),
      BoxShadow(
        color: isDark
            ? Colors.white.withValues(alpha: 0.05)
            : Colors.white.withValues(alpha: 0.8),
        blurRadius: 20,
        offset: const Offset(-5, -5),
      ),
    ];
  }

  Widget _buildNeumorphismMenu(BuildContext context, bool isDark) {
    final baseColor = _getNeumorphismBaseColor(isDark);
    final shadows = _getNeumorphismShadows(isDark);

    return RepaintBoundary(
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: baseColor,
          boxShadow: shadows,
        ),
        child: _buildMenuItems(context, isDark),
      ),
    );
  }

  Color _getNeumorphismBaseColor(bool isDark) {
    return isDark ? const Color(0xFF2D2D2D) : const Color(0xFFE8E8E8);
  }

  List<BoxShadow> _getNeumorphismShadows(bool isDark) {
    final lightShadow = isDark
        ? Colors.white.withValues(alpha: 0.08)
        : Colors.white.withValues(alpha: 0.95);
    final darkShadow = isDark
        ? Colors.black.withValues(alpha: 0.6)
        : Colors.grey.withValues(alpha: 0.4);

    return [
      BoxShadow(
        color: lightShadow,
        blurRadius: 25,
        offset: const Offset(-10, -10),
      ),
      BoxShadow(
        color: darkShadow,
        blurRadius: 25,
        offset: const Offset(10, 10),
      ),
    ];
  }

  Widget _buildDefaultMenu(BuildContext context, bool isDark) {
    final backgroundColor = _getDefaultMenuBackgroundColor(isDark);
    final borderColor = _getDefaultMenuBorderColor(isDark);
    final shadows = _getDefaultMenuShadows(isDark);

    return RepaintBoundary(
      child: Container(
        width: 300,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          color: backgroundColor,
          border: Border.all(
            color: borderColor,
          ),
          boxShadow: shadows,
        ),
        child: _buildMenuItems(context, isDark),
      ),
    );
  }

  Color _getDefaultMenuBackgroundColor(bool isDark) {
    return isDark ? const Color(0xFF1A1A1A) : Colors.white;
  }

  Color _getDefaultMenuBorderColor(bool isDark) {
    return isDark
        ? Colors.white.withValues(alpha: 0.12)
        : Colors.grey.withValues(alpha: 0.15);
  }

  List<BoxShadow> _getDefaultMenuShadows(bool isDark) {
    return [
      BoxShadow(
        color: isDark
            ? Colors.black.withValues(alpha: 0.5)
            : Colors.black.withValues(alpha: 0.12),
        blurRadius: 32,
        offset: const Offset(0, 12),
        spreadRadius: -8,
      ),
      BoxShadow(
        color: isDark
            ? Colors.white.withValues(alpha: 0.03)
            : Colors.white.withValues(alpha: 0.9),
        blurRadius: 20,
        offset: const Offset(-4, -4),
      ),
    ];
  }

  Widget _buildMenuItems(BuildContext context, bool isDark) {
    final colorScheme = _getMenuColorScheme(isDark);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _buildHeader(context, isDark, colorScheme),
        _buildMenuItemsList(context, isDark),
      ],
    );
  }

  _MenuColorScheme _getMenuColorScheme(bool isDark) {
    return _MenuColorScheme(
      gradientColors: [
        _primaryColor.withValues(alpha: 0.25),
        _primaryColor.withValues(alpha: 0.12),
        _primaryColor.withValues(alpha: 0.05),
      ],
      iconBgColor: _primaryColor.withValues(alpha: 0.2),
      titleColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
      subtitleColor: isDark ? Colors.white70 : const Color(0xFF6B6B6B),
      valueLabelColor: isDark ? Colors.white60 : const Color(0xFF8E8E8E),
      closeButtonColor: isDark ? Colors.white70 : const Color(0xFF6B6B6B),
      valueBgColor: isDark
          ? Colors.white.withValues(alpha: 0.08)
          : Colors.black.withValues(alpha: 0.03),
    );
  }

  Widget _buildHeader(
      BuildContext context, bool isDark, _MenuColorScheme colorScheme,) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: colorScheme.gradientColors,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeaderRow(context, isDark, colorScheme),
          const SizedBox(height: 16),
          _buildValueDisplayCard(context, isDark, colorScheme),
        ],
      ),
    );
  }

  Widget _buildHeaderRow(
      BuildContext context, bool isDark, _MenuColorScheme colorScheme,) {
    return Row(
      children: [
        _buildHeaderIcon(colorScheme),
        const SizedBox(width: 14),
        Expanded(
          child: _buildHeaderText(context, isDark, colorScheme),
        ),
        _buildCloseButton(colorScheme),
      ],
    );
  }

  Widget _buildHeaderIcon(_MenuColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: colorScheme.iconBgColor,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.2),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        _hasPoint ? Icons.show_chart_rounded : Icons.pie_chart_rounded,
        color: _primaryColor,
        size: 22,
      ),
    );
  }

  Widget _buildHeaderText(
      BuildContext context, bool isDark, _MenuColorScheme colorScheme,) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _label,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w700,
            color: colorScheme.titleColor,
            letterSpacing: -0.3,
            height: 1.2,
          ),
        ),
        if (widget.datasetLabel != null) ...[
          const SizedBox(height: 2),
          Text(
            widget.datasetLabel!,
            style: TextStyle(
              fontSize: 13,
              color: colorScheme.subtitleColor,
              fontWeight: FontWeight.w500,
              letterSpacing: -0.2,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildCloseButton(_MenuColorScheme colorScheme) {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: widget.onClose,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.all(6),
          child: Icon(
            Icons.close_rounded,
            size: 18,
            color: colorScheme.closeButtonColor,
          ),
        ),
      ),
    );
  }

  Widget _buildValueDisplayCard(
      BuildContext context, bool isDark, _MenuColorScheme colorScheme,) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: colorScheme.valueBgColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isDark
              ? Colors.white.withValues(alpha: 0.08)
              : Colors.black.withValues(alpha: 0.05),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _buildValueColumn(colorScheme),
          if (_formattedXValue != null) ...[
            _buildDivider(isDark),
            const SizedBox(width: 16),
            _buildXAxisColumn(isDark, colorScheme),
          ],
        ],
      ),
    );
  }

  Widget _buildValueColumn(_MenuColorScheme colorScheme) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'VALUE',
            style: TextStyle(
              fontSize: 10,
              color: colorScheme.valueLabelColor,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            _formattedValue,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w800,
              color: _primaryColor,
              letterSpacing: -0.5,
              height: 1.0,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 40,
      color: isDark
          ? Colors.white.withValues(alpha: 0.1)
          : Colors.black.withValues(alpha: 0.08),
    );
  }

  Widget _buildXAxisColumn(bool isDark, _MenuColorScheme colorScheme) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Text(
          'X AXIS',
          style: TextStyle(
            fontSize: 10,
            color: colorScheme.valueLabelColor,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          _formattedXValue!,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: colorScheme.titleColor,
            letterSpacing: -0.3,
          ),
        ),
      ],
    );
  }

  Widget _buildMenuItemsList(BuildContext context, bool isDark) {
    final hasActions = widget.onViewDetails != null ||
        widget.onExport != null ||
        widget.onShare != null;

    if (!hasActions) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
      child: Column(
        children: [
          if (widget.onViewDetails != null)
            _buildMenuItem(
              context,
              icon: Icons.info_outline_rounded,
              label: 'View Details',
              onTap: () {
                widget.onClose?.call();
                widget.onViewDetails?.call();
              },
              isDark: isDark,
              index: 0,
            ),
          if (widget.onExport != null)
            _buildMenuItem(
              context,
              icon: Icons.download_rounded,
              label: 'Export Data',
              onTap: () {
                widget.onClose?.call();
                widget.onExport?.call();
              },
              isDark: isDark,
              isLast: widget.onShare == null,
              index: 1,
            ),
          if (widget.onShare != null)
            _buildMenuItem(
              context,
              icon: Icons.share_rounded,
              label: 'Share',
              onTap: () {
                widget.onClose?.call();
                widget.onShare?.call();
              },
              isDark: isDark,
              isLast: true,
              index: 2,
            ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    required bool isDark,
    required int index,
    bool isLast = false,
  }) {
    final colors = _getMenuItemColors(isDark);

    return TweenAnimationBuilder<double>(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween(begin: 0.0, end: 1.0),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, 10 * (1 - value)),
            child: child,
          ),
        );
      },
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          splashColor: _primaryColor.withValues(alpha: 0.1),
          highlightColor: _primaryColor.withValues(alpha: 0.05),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            margin: EdgeInsets.only(bottom: isLast ? 0 : 6),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              color: colors.bgColor,
              border: Border.all(
                color: colors.borderColor,
              ),
            ),
            child: Row(
              children: [
                _buildMenuItemIcon(icon, colors.iconBgColor),
                const SizedBox(width: 14),
                Expanded(
                  child: Text(
                    label,
                    style: TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: colors.textColor,
                      letterSpacing: -0.2,
                    ),
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: colors.chevronColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  _MenuItemColors _getMenuItemColors(bool isDark) {
    return _MenuItemColors(
      bgColor: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.03),
      iconBgColor: _primaryColor.withValues(alpha: 0.15),
      textColor: isDark ? Colors.white : const Color(0xFF1A1A1A),
      chevronColor: isDark ? Colors.white38 : const Color(0xFFB0B0B0),
      borderColor: isDark
          ? Colors.white.withValues(alpha: 0.06)
          : Colors.black.withValues(alpha: 0.04),
    );
  }

  Widget _buildMenuItemIcon(IconData icon, Color iconBgColor) {
    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: iconBgColor,
        borderRadius: BorderRadius.circular(11),
        boxShadow: [
          BoxShadow(
            color: _primaryColor.withValues(alpha: 0.15),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Icon(
        icon,
        size: 20,
        color: _primaryColor,
      ),
    );
  }

  static Color _getColorForValue(double value) {
    // Modern color scheme based on value
    // Using vibrant, modern colors with better gradients
    if (value > 80) return const Color(0xFF10B981); // Modern green
    if (value > 50) return const Color(0xFF3B82F6); // Modern blue
    if (value > 30) return const Color(0xFFF59E0B); // Modern amber
    return const Color(0xFFEF4444); // Modern red
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
    if (!_hasActions(onViewDetails, onExport, onShare)) {
      return;
    }

    hide();

    final overlay = Overlay.of(context);
    final globalPosition = _calculateGlobalPosition(context, position);
    final adjustedPosition =
        _calculateAdjustedPosition(context, globalPosition);

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
      BuildContext context, Offset position,) {
    final renderBox = context.findRenderObject() as RenderBox?;

    try {
      final globalPosition =
          renderBox != null ? renderBox.localToGlobal(position) : position;

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
                  child: Container(
                    color: Colors.black.withValues(alpha: 0.1),
                  ),
                ),
              )
            : Container(
                color: Colors.transparent,
              ),
      ),
    );
  }

  static void hide() {
    _currentMenu?.remove();
    _currentMenu = null;
    // Clear cached blur filter when menu is hidden
    _cachedBlurFilter = null;
  }
}
