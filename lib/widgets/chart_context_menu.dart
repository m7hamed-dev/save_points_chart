import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/theme/chart_theme.dart';

/// Web-inspired color scheme for modern UI
class _WebUIColorScheme {
  final Color surfaceColor;
  final Color borderColor;
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color accentColor;
  final Color hoverColor;
  final Color dividerColor;

  const _WebUIColorScheme({
    required this.surfaceColor,
    required this.borderColor,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.accentColor,
    required this.hoverColor,
    required this.dividerColor,
  });

  factory _WebUIColorScheme.light(Color accentColor) {
    return _WebUIColorScheme(
      surfaceColor: Colors.white,
      borderColor: const Color(0xFFE5E7EB),
      textPrimary: const Color(0xFF111827),
      textSecondary: const Color(0xFF6B7280),
      textTertiary: const Color(0xFF9CA3AF),
      accentColor: accentColor,
      hoverColor: const Color(0xFFF9FAFB),
      dividerColor: const Color(0xFFE5E7EB),
    );
  }

  factory _WebUIColorScheme.dark(Color accentColor) {
    return _WebUIColorScheme(
      surfaceColor: const Color(0xFF1F2937),
      borderColor: const Color(0xFF374151),
      textPrimary: const Color(0xFFF9FAFB),
      textSecondary: const Color(0xFFD1D5DB),
      textTertiary: const Color(0xFF9CA3AF),
      accentColor: accentColor,
      hoverColor: const Color(0xFF374151),
      dividerColor: const Color(0xFF4B5563),
    );
  }
}

/// Modern web-style context menu for chart elements
/// Inspired by contemporary web design systems (Vercel, Linear, Stripe)
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

class _ChartContextMenuState extends State<ChartContextMenu>
    with SingleTickerProviderStateMixin {
  late final Color _primaryColor;
  late final String _formattedValue;
  late final String? _formattedXValue;
  late final String _label;
  late final bool _hasPoint;
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  late final Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _hasPoint = widget.point != null;
    _primaryColor = _computePrimaryColor();
    _formattedValue = _computeFormattedValue();
    _formattedXValue = _hasPoint ? widget.point!.x.toStringAsFixed(1) : null;
    _label =
        widget.point?.label ??
        widget.segment?.label ??
        (_hasPoint ? 'Data Point' : 'Segment');

    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _computePrimaryColor() {
    if (_hasPoint) {
      return _getColorForValue(widget.point!.y);
    }
    return widget.segment?.color ?? const Color(0xFF3B82F6);
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
    final safeDx = widget.position.dx.isFinite ? widget.position.dx : 0.0;
    final safeDy = widget.position.dy.isFinite ? widget.position.dy : 0.0;

    return Positioned(
      left: safeDx,
      top: safeDy,
      child: Material(
        color: Colors.transparent,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: Tween<double>(
              begin: 0.92,
              end: 1.0,
            ).animate(_scaleAnimation),
            child: RepaintBoundary(child: _buildWebStyleMenu(context, isDark)),
          ),
        ),
      ),
    );
  }

  Widget _buildWebStyleMenu(BuildContext context, bool isDark) {
    if (widget.useGlassmorphism) {
      return _buildGlassmorphismMenu(context, isDark);
    } else if (widget.useNeumorphism) {
      return _buildNeumorphismMenu(context, isDark);
    } else {
      return _buildModernWebMenu(context, isDark);
    }
  }

  Widget _buildGlassmorphismMenu(BuildContext context, bool isDark) {
    final colorScheme = isDark
        ? _WebUIColorScheme.dark(_primaryColor)
        : _WebUIColorScheme.light(_primaryColor);
    final gradientColors = _getGlassmorphismGradientColors(isDark);
    final borderColor = _getGlassmorphismBorderColor(isDark);
    final shadows = _getGlassmorphismShadows(isDark);

    return RepaintBoundary(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ui.ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Container(
            width: 320,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: gradientColors,
              ),
              border: Border.all(color: borderColor, width: 1.5),
              boxShadow: shadows,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildWebHeader(context, colorScheme),
                _buildWebContent(context, colorScheme),
                _buildWebActions(context, colorScheme),
              ],
            ),
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
    final colorScheme = isDark
        ? _WebUIColorScheme.dark(_primaryColor)
        : _WebUIColorScheme.light(_primaryColor);
    final baseColor = _getNeumorphismBaseColor(isDark);
    final shadows = _getNeumorphismShadows(isDark);

    return RepaintBoundary(
      child: Container(
        width: 320,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: baseColor,
          boxShadow: shadows,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWebHeader(context, colorScheme),
            _buildWebContent(context, colorScheme),
            _buildWebActions(context, colorScheme),
          ],
        ),
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

  Widget _buildModernWebMenu(BuildContext context, bool isDark) {
    final colorScheme = isDark
        ? _WebUIColorScheme.dark(_primaryColor)
        : _WebUIColorScheme.light(_primaryColor);

    return Container(
      width: 320,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12),
        color: colorScheme.surfaceColor,
        border: Border.all(color: colorScheme.borderColor),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.6)
                : Colors.black.withValues(alpha: 0.08),
            blurRadius: 24,
            offset: const Offset(0, 8),
            spreadRadius: -4,
          ),
          BoxShadow(
            color: isDark
                ? Colors.black.withValues(alpha: 0.4)
                : Colors.black.withValues(alpha: 0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            _buildWebHeader(context, colorScheme),
            _buildWebContent(context, colorScheme),
            _buildWebActions(context, colorScheme),
          ],
        ),
      ),
    );
  }

  Widget _buildWebHeader(BuildContext context, _WebUIColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(color: colorScheme.dividerColor),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _primaryColor,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _primaryColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
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
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: colorScheme.textPrimary,
                    letterSpacing: -0.2,
                  ),
                ),
                if (widget.datasetLabel != null) ...[
                  const SizedBox(height: 2),
                  Text(
                    widget.datasetLabel!,
                    style: TextStyle(
                      fontSize: 12,
                      color: colorScheme.textTertiary,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ],
              ],
            ),
          ),
          _WebCloseButton(onTap: widget.onClose, colorScheme: colorScheme),
        ],
      ),
    );
  }

  Widget _buildWebContent(BuildContext context, _WebUIColorScheme colorScheme) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          Expanded(
            child: _buildMetricCard(
              label: 'Value',
              value: _formattedValue,
              colorScheme: colorScheme,
              isAccent: true,
            ),
          ),
          if (_formattedXValue != null) ...[
            const SizedBox(width: 12),
            Expanded(
              child: _buildMetricCard(
                label: 'X Axis',
                value: _formattedXValue,
                colorScheme: colorScheme,
                isAccent: false,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMetricCard({
    required String label,
    required String? value,
    required _WebUIColorScheme colorScheme,
    required bool isAccent,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isAccent
            ? _primaryColor.withValues(alpha: 0.08)
            : colorScheme.hoverColor,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: isAccent
              ? _primaryColor.withValues(alpha: 0.2)
              : colorScheme.borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label.toUpperCase(),
            style: TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w600,
              color: colorScheme.textTertiary,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            value ?? '0.00',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.w700,
              color: isAccent ? _primaryColor : colorScheme.textPrimary,
              letterSpacing: -0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWebActions(BuildContext context, _WebUIColorScheme colorScheme) {
    final hasActions =
        widget.onViewDetails != null ||
        widget.onExport != null ||
        widget.onShare != null;

    if (!hasActions) return const SizedBox.shrink();

    final actions = <_ActionItem>[];
    if (widget.onViewDetails != null) {
      actions.add(
        _ActionItem(
          icon: Icons.info_outline_rounded,
          label: 'View Details',
          onTap: () {
            widget.onClose?.call();
            widget.onViewDetails?.call();
          },
        ),
      );
    }
    if (widget.onExport != null) {
      actions.add(
        _ActionItem(
          icon: Icons.download_rounded,
          label: 'Export Data',
          onTap: () {
            widget.onClose?.call();
            widget.onExport?.call();
          },
        ),
      );
    }
    if (widget.onShare != null) {
      actions.add(
        _ActionItem(
          icon: Icons.share_rounded,
          label: 'Share',
          onTap: () {
            widget.onClose?.call();
            widget.onShare?.call();
          },
        ),
      );
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(color: colorScheme.dividerColor),
        ),
      ),
      child: Column(
        children: actions
            .asMap()
            .entries
            .map(
              (entry) => _WebActionButton(
                action: entry.value,
                colorScheme: colorScheme,
                isLast: entry.key == actions.length - 1,
              ),
            )
            .toList(),
      ),
    );
  }

  static Color _getColorForValue(double value) {
    if (value > 80) return const Color(0xFF10B981);
    if (value > 50) return const Color(0xFF3B82F6);
    if (value > 30) return const Color(0xFFF59E0B);
    return const Color(0xFFEF4444);
  }
}

class _ActionItem {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.label,
    required this.onTap,
  });
}

class _WebActionButton extends StatefulWidget {
  final _ActionItem action;
  final _WebUIColorScheme colorScheme;
  final bool isLast;

  const _WebActionButton({
    required this.action,
    required this.colorScheme,
    required this.isLast,
  });

  @override
  State<_WebActionButton> createState() => _WebActionButtonState();
}

class _WebActionButtonState extends State<_WebActionButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.action.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
          curve: Curves.easeOut,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: _isHovered
                ? widget.colorScheme.hoverColor
                : Colors.transparent,
            border: widget.isLast
                ? null
                : Border(
                    bottom: BorderSide(
                      color: widget.colorScheme.dividerColor,
                    ),
                  ),
          ),
          child: Row(
            children: [
              Icon(
                widget.action.icon,
                size: 18,
                color: widget.colorScheme.textSecondary,
              ),
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
                child: Icon(
                  Icons.arrow_forward_rounded,
                  size: 16,
                  color: widget.colorScheme.textTertiary,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _WebCloseButton extends StatefulWidget {
  final VoidCallback? onTap;
  final _WebUIColorScheme colorScheme;

  const _WebCloseButton({required this.onTap, required this.colorScheme});

  @override
  State<_WebCloseButton> createState() => _WebCloseButtonState();
}

class _WebCloseButtonState extends State<_WebCloseButton> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
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
    );
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
    // Clear cached blur filter when menu is hidden
    _cachedBlurFilter = null;
  }
}
