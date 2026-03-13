import 'package:flutter/material.dart';
import 'dart:ui' as ui;
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/widgets/chart_context_menu/action_item.dart';
import 'package:save_points_chart/widgets/chart_context_menu/color_scheme.dart';
import 'package:save_points_chart/widgets/chart_context_menu/web_action_button.dart';
import 'package:save_points_chart/widgets/chart_context_menu/web_close_button.dart';
import 'package:save_points_chart/utils/format_utils.dart';

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
    _formattedXValue = _hasPoint ? ChartFormatUtils.formatValue(widget.point!.x) : null;
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
      return ChartFormatUtils.formatValue(widget.point!.y);
    }
    return widget.segment != null 
        ? ChartFormatUtils.formatValue(widget.segment!.value)
        : '0';
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
            scale: Tween<double>(begin: 0.92, end: 1.0).animate(_scaleAnimation),
            child: RepaintBoundary(
              child: _buildWebStyleMenu(context, isDark),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWebStyleMenu(BuildContext context, bool isDark) {
    // Use theme-aware color scheme
    final colorScheme = WebUIColorScheme.fromTheme(context, accentColor: _primaryColor);

    if (widget.useGlassmorphism) {
      return _buildGlassmorphismMenu(context, colorScheme, isDark);
    } else if (widget.useNeumorphism) {
      return _buildNeumorphismMenu(context, colorScheme, isDark);
    } else {
      return _buildModernWebMenu(context, colorScheme, isDark);
    }
  }

  Widget _buildGlassmorphismMenu(BuildContext context, WebUIColorScheme colorScheme, bool isDark) {
    final gradientColors = _getGlassmorphismGradientColors(isDark);
    final borderColor = _getGlassmorphismBorderColor(isDark);
    final shadows = _getGlassmorphismShadows(isDark);

    return RepaintBoundary(
      child: Semantics(
        label: 'Chart context menu',
        container: true,
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

  Widget _buildNeumorphismMenu(BuildContext context, WebUIColorScheme colorScheme, bool isDark) {
    final baseColor = _getNeumorphismBaseColor(isDark);
    final shadows = _getNeumorphismShadows(isDark);

    return RepaintBoundary(
      child: Semantics(
        label: 'Chart context menu',
        container: true,
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

  Widget _buildModernWebMenu(BuildContext context, WebUIColorScheme colorScheme, bool isDark) {
    final textDirection = Directionality.of(context);
    final isRtl = textDirection == TextDirection.rtl;

    return Semantics(
      label: 'Chart context menu',
      container: true,
      child: Container(
        width: 230,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: const Color(0xFF020617),
          border: Border.all(
            color: Colors.white.withValues(alpha: 0.06),
          ),
          boxShadow: [
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.55)
                  : Colors.black.withValues(alpha: 0.18),
              blurRadius: 22,
              offset: const Offset(0, 10),
              spreadRadius: -8,
            ),
            BoxShadow(
              color: isDark
                  ? Colors.black.withValues(alpha: 0.35)
                  : Colors.black.withValues(alpha: 0.06),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment:
                isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
            children: [
              // Top row: label (e.g. month) and close button.
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                textDirection: textDirection,
                children: [
                  Expanded(
                    child: Align(
                      alignment:
                          isRtl ? Alignment.centerRight : Alignment.centerLeft,
                      child: Text(
                        _label,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                          letterSpacing: -0.1,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  WebCloseButton(
                    onTap: widget.onClose,
                    colorScheme: colorScheme,
                  ),
                ],
              ),
              const SizedBox(height: 8),

              // Middle row: main value, aligned opposite to label like the reference screenshot.
              Align(
                alignment:
                    isRtl ? Alignment.centerLeft : Alignment.centerRight,
                child: Text(
                  _formattedValue,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                    letterSpacing: -0.3,
                  ),
                ),
              ),

              const SizedBox(height: 8),

              // Legend-style rows similar to the provided design: small colored square + label.
              if (widget.datasetLabel != null || _formattedXValue != null)
                Column(
                  crossAxisAlignment:
                      isRtl ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (widget.datasetLabel != null)
                      _buildLegendRow(
                        context,
                        colorScheme,
                        isRtl: isRtl,
                        label: widget.datasetLabel!,
                        color: _primaryColor,
                      ),
                    if (_formattedXValue != null) ...[
                      const SizedBox(height: 4),
                      _buildLegendRow(
                        context,
                        colorScheme,
                        isRtl: isRtl,
                        label: _formattedXValue,
                        color: colorScheme.textTertiary,
                      ),
                    ],
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLegendRow(
    BuildContext context,
    WebUIColorScheme colorScheme, {
    required bool isRtl,
    required String label,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      children: [
        Container(
          width: 10,
          height: 10,
          margin: EdgeInsetsDirectional.only(
            end: isRtl ? 0 : 8,
            start: isRtl ? 8 : 0,
          ),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        Flexible(
          child: Text(
            label,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w500,
              color: colorScheme.textSecondary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildWebHeader(BuildContext context, WebUIColorScheme colorScheme) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: colorScheme.dividerColor,
          ),
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
          WebCloseButton(
            onTap: widget.onClose,
            colorScheme: colorScheme,
          ),
        ],
      ),
    );
  }

  Widget _buildWebContent(BuildContext context, WebUIColorScheme colorScheme) {
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
    required WebUIColorScheme colorScheme,
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

  Widget _buildWebActions(BuildContext context, WebUIColorScheme colorScheme) {
    final hasActions =
        widget.onViewDetails != null ||
        widget.onExport != null ||
        widget.onShare != null;

    if (!hasActions) return const SizedBox.shrink();

    final actions = <ActionItem>[];
    if (widget.onViewDetails != null) {
      actions.add(ActionItem(
        icon: Icons.info_outline_rounded,
        label: 'View Details',
        onTap: () {
          widget.onClose?.call();
          widget.onViewDetails?.call();
        },
      ));
    }
    if (widget.onExport != null) {
      actions.add(ActionItem(
        icon: Icons.download_rounded,
        label: 'Export Data',
        onTap: () {
          widget.onClose?.call();
          widget.onExport?.call();
        },
      ));
    }
    if (widget.onShare != null) {
      actions.add(ActionItem(
        icon: Icons.share_rounded,
        label: 'Share',
        onTap: () {
          widget.onClose?.call();
          widget.onShare?.call();
        },
      ));
    }

    return Container(
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: colorScheme.dividerColor,
          ),
        ),
      ),
      child: Column(
        children: actions
            .asMap()
            .entries
            .map((entry) => WebActionButton(
                  action: entry.value,
                  colorScheme: colorScheme,
                  isLast: entry.key == actions.length - 1,
                ))
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
