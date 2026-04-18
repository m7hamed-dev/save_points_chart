import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/theme/chart_theme.dart';

/// One entry in a [ChartLegend].
class ChartLegendItem {
  const ChartLegendItem({required this.color, required this.label, this.value});

  /// The swatch color shown beside the label.
  final Color color;

  /// The display label for this series.
  final String label;

  /// Optional value or summary (for example, "12.5M" or "42%") shown on the
  /// right side of the row.
  final String? value;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChartLegendItem &&
          runtimeType == other.runtimeType &&
          color == other.color &&
          label == other.label &&
          value == other.value;

  @override
  int get hashCode => Object.hash(color, label, value);
}

/// Where a legend is placed relative to the chart inside a `ChartLegendScope`.
enum LegendPosition { top, bottom, left, right }

/// A tappable legend for a chart.
///
/// Each item renders a color swatch plus its label. Tapping an item calls
/// [onToggle] with that item's color so the caller can flip visibility.
/// Items whose color is in [hidden] are rendered with reduced opacity and a
/// strike-through label to signal that the series is currently hidden.
///
/// The widget is purely presentational — it does not own visibility state.
/// Combine with `ChartLegendScope` for an end-to-end toggle experience, or
/// manage the [hidden] set yourself if you need custom behavior.
///
/// ## Example
/// ```dart
/// ChartLegend(
///   items: const [
///     ChartLegendItem(color: Colors.indigo, label: 'Sales'),
///     ChartLegendItem(color: Colors.green, label: 'Revenue'),
///   ],
///   hidden: hiddenColors,
///   onToggle: (color) => setState(() {
///     hiddenColors.toggle(color);
///   }),
/// )
/// ```
class ChartLegend extends StatelessWidget {
  const ChartLegend({
    super.key,
    required this.items,
    this.hidden = const <Color>{},
    this.onToggle,
    this.theme,
    this.direction = Axis.horizontal,
    this.runSpacing = 8.0,
    this.spacing = 16.0,
    this.padding = const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
    this.swatchSize = 12.0,
    this.labelStyle,
  });

  /// Construct a legend from a list of `ChartDataSet`s, grouped by color.
  ///
  /// If multiple datasets share a color, the first one's `dataPoint.label`
  /// is used for the series label. Pass [seriesLabelFor] to control the label
  /// explicitly (for example, looking it up in an external map keyed by color).
  factory ChartLegend.fromDataSets(
    List<ChartDataSet> dataSets, {
    Key? key,
    Set<Color> hidden = const <Color>{},
    ValueChanged<Color>? onToggle,
    ChartTheme? theme,
    Axis direction = Axis.horizontal,
    String Function(Color color, List<ChartDataSet> group)? seriesLabelFor,
  }) {
    final grouped = <Color, List<ChartDataSet>>{};
    for (final set in dataSets) {
      grouped.putIfAbsent(set.color, () => <ChartDataSet>[]).add(set);
    }
    final items = [
      for (final entry in grouped.entries)
        ChartLegendItem(
          color: entry.key,
          label: seriesLabelFor != null
              ? seriesLabelFor(entry.key, entry.value)
              : (entry.value.first.dataPoint.label ?? _defaultLabel(entry.key)),
        ),
    ];
    return ChartLegend(
      key: key,
      items: items,
      hidden: hidden,
      onToggle: onToggle,
      theme: theme,
      direction: direction,
    );
  }

  static String _defaultLabel(Color color) {
    // ignore: deprecated_member_use
    final hex = color.value.toRadixString(16).padLeft(8, '0').toUpperCase();
    return 'Series #$hex';
  }

  /// The rows/columns to show.
  final List<ChartLegendItem> items;

  /// Colors whose series are currently hidden (rendered dimmed).
  final Set<Color> hidden;

  /// Called when a legend entry is tapped. Omit to render a non-interactive
  /// legend.
  final ValueChanged<Color>? onToggle;

  /// Theme used for label colors. Falls back to the ambient Material theme.
  final ChartTheme? theme;

  /// Whether items are laid out in a row (horizontal) or column (vertical).
  /// The horizontal variant wraps onto multiple lines when space runs out.
  final Axis direction;

  /// Horizontal gap between items when laid out horizontally.
  final double spacing;

  /// Vertical gap between wrapped rows (horizontal) or between items (vertical).
  final double runSpacing;

  /// Padding around each tappable row.
  final EdgeInsets padding;

  /// Diameter of the color swatch circle.
  final double swatchSize;

  /// Optional label text style override.
  final TextStyle? labelStyle;

  @override
  Widget build(BuildContext context) {
    final effectiveTheme = theme ?? ChartTheme.fromMaterialTheme(Theme.of(context));
    final baseStyle = labelStyle ??
        TextStyle(
          color: effectiveTheme.textColor,
          fontSize: 12,
          fontWeight: FontWeight.w500,
        );

    final children = items.map((item) => _LegendRow(
          item: item,
          isHidden: hidden.contains(item.color),
          onTap: onToggle == null ? null : () => onToggle!(item.color),
          style: baseStyle,
          padding: padding,
          swatchSize: swatchSize,
        ));

    if (direction == Axis.vertical) {
      return Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          for (final row in children) Padding(padding: EdgeInsets.only(bottom: runSpacing / 2), child: row),
        ],
      );
    }

    return Wrap(
      spacing: spacing,
      runSpacing: runSpacing,
      children: children.toList(),
    );
  }
}

class _LegendRow extends StatelessWidget {
  const _LegendRow({
    required this.item,
    required this.isHidden,
    required this.style,
    required this.padding,
    required this.swatchSize,
    this.onTap,
  });

  final ChartLegendItem item;
  final bool isHidden;
  final TextStyle style;
  final EdgeInsets padding;
  final double swatchSize;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final effectiveStyle = isHidden
        ? style.copyWith(
            color: style.color?.withValues(alpha: 0.5),
            decoration: TextDecoration.lineThrough,
            decorationColor: style.color?.withValues(alpha: 0.5),
          )
        : style;
    final swatchColor = isHidden ? item.color.withValues(alpha: 0.35) : item.color;

    final row = Padding(
      padding: padding,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            width: swatchSize,
            height: swatchSize,
            decoration: BoxDecoration(
              color: swatchColor,
              shape: BoxShape.circle,
              border: isHidden ? Border.all(color: swatchColor) : null,
            ),
          ),
          const SizedBox(width: 8),
          Flexible(
            child: Text(
              item.label,
              style: effectiveStyle,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (item.value != null) ...[
            const SizedBox(width: 8),
            Text(
              item.value!,
              style: effectiveStyle.copyWith(fontWeight: FontWeight.w700),
            ),
          ],
        ],
      ),
    );

    if (onTap == null) return row;
    return Semantics(
      button: true,
      toggled: isHidden,
      label: '${item.label}${isHidden ? ' (hidden)' : ''}',
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: row,
      ),
    );
  }
}
