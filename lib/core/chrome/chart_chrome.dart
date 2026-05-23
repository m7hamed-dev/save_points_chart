import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:save_points_chart/core/engine/chart_context.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/models/legend_position.dart';

/// Shared chart chrome: title, legend, and card border.
class ChartChrome {
  const ChartChrome._();

  static const double _titleLineHeight = 22;
  static const double _subtitleLineHeight = 18;
  static const double _legendHeight = 36;
  static const double _swatchWidth = 14;
  static const double _swatchHeight = 10;
  static const double _legendGap = 20;

  /// Top margin for title + subtitle block.
  static double headerReservedHeight(ChartConfig config) {
    var height = 0.0;
    if (_hasText(config.title)) {
      height += _titleLineHeight;
    }
    if (_hasText(config.subtitle)) {
      height += _subtitleLineHeight;
    }
    return height;
  }

  static bool _hasText(String? value) => value != null && value.isNotEmpty;

  static double legendReservedHeight(ChartConfig config) {
    if (!config.showLegend) return 0;
    return switch (config.legendPosition) {
      LegendPosition.bottom || LegendPosition.top => _legendHeight,
      LegendPosition.left || LegendPosition.right => 0,
    };
  }

  static double legendReservedLeft(ChartConfig config) {
    if (!config.showLegend) return 0;
    return config.legendPosition == LegendPosition.left ? 80 : 0;
  }

  static double legendReservedRight(ChartConfig config) {
    if (!config.showLegend) return 0;
    return config.legendPosition == LegendPosition.right ? 80 : 0;
  }

  static void drawBorder(Canvas canvas, Size size, ChartContext context) {
    if (!context.config.showBorder) return;
    final rrect = RRect.fromRectAndRadius(
      Offset.zero & size,
      Radius.circular(context.theme.cardBorderRadius),
    );
    canvas.drawRRect(
      rrect,
      context.paintCache.get(
        key: 'card-border',
        color: context.theme.borderColor,
      ),
    );
  }

  static void drawTitle(Canvas canvas, Size size, ChartContext context) {
    final title = context.config.title;
    if (title == null || title.isEmpty) return;

    final style =
        context.theme.titleTextStyle ??
        context.theme.axisTextStyle.copyWith(
          fontWeight: FontWeight.w600,
          fontSize: (context.theme.axisTextStyle.fontSize ?? 11) + 3,
        );

    final builder =
        ParagraphBuilder(
            ParagraphStyle(
              textAlign: TextAlign.left,
              fontSize: style.fontSize,
              fontFamily: style.fontFamily,
              fontWeight: style.fontWeight,
            ),
          )
          ..pushStyle(style.getTextStyle())
          ..addText(title);

    final paragraph = builder.build()
      ..layout(
        ParagraphConstraints(
          width: size.width - context.theme.padding.horizontal,
        ),
      );

    canvas.drawParagraph(
      paragraph,
      Offset(context.theme.padding.left, context.theme.padding.top),
    );
  }

  static void drawSubtitle(Canvas canvas, Size size, ChartContext context) {
    final subtitle = context.config.subtitle;
    if (!_hasText(subtitle)) return;

    final style =
        context.theme.subtitleTextStyle ??
        context.theme.axisTextStyle.copyWith(
          fontSize: (context.theme.axisTextStyle.fontSize ?? 11) + 1,
          color: const Color(0xFF9E9E9E),
        );

    final y =
        context.theme.padding.top +
        (_hasText(context.config.title) ? _titleLineHeight : 0);

    final builder =
        ParagraphBuilder(
            ParagraphStyle(
              textAlign: TextAlign.left,
              fontSize: style.fontSize,
              fontFamily: style.fontFamily,
            ),
          )
          ..pushStyle(style.getTextStyle())
          ..addText(subtitle!);

    final paragraph = builder.build()
      ..layout(
        ParagraphConstraints(
          width: size.width - context.theme.padding.horizontal,
        ),
      );

    canvas.drawParagraph(paragraph, Offset(context.theme.padding.left, y));
  }

  static void drawLegend(Canvas canvas, Size size, ChartContext context) {
    if (!context.config.showLegend) return;

    final items = _legendItems(context);
    if (items.isEmpty) return;

    final style = context.theme.legendTextStyle ?? context.theme.axisTextStyle;

    switch (context.config.legendPosition) {
      case LegendPosition.bottom:
        _drawLegendHorizontal(
          canvas,
          size,
          context,
          items,
          style,
          y: context.bounds.bottom + 10,
        );
      case LegendPosition.top:
        _drawLegendHorizontal(
          canvas,
          size,
          context,
          items,
          style,
          y: context.bounds.top - _legendHeight + 6,
        );
      case LegendPosition.left:
        _drawLegendVertical(
          canvas,
          context,
          items,
          style,
          x: context.theme.padding.left,
          y: context.bounds.top,
        );
      case LegendPosition.right:
        _drawLegendVertical(
          canvas,
          context,
          items,
          style,
          x: context.bounds.right + 8,
          y: context.bounds.top,
        );
    }
  }

  static List<({String label, Color color})> _legendItems(
    ChartContext context,
  ) {
    final items = <({String label, Color color})>[];
    final series = context.config.series;
    if (series.isEmpty) return items;

    final first = series.first;
    if (first.points.length > 1 &&
        first.points.any((p) => p.label != null && p.label!.isNotEmpty)) {
      for (var i = 0; i < first.points.length; i++) {
        final p = first.points[i];
        items.add((
          label: p.label ?? 'Item ${i + 1}',
          color: context.theme.seriesColor(i),
        ));
      }
      return items;
    }

    for (var s = 0; s < series.length; s++) {
      final ser = series[s];
      items.add((
        label: ser.name,
        color: ser.style.color ?? context.theme.seriesColor(s),
      ));
    }
    return items;
  }

  static void _drawLegendHorizontal(
    Canvas canvas,
    Size size,
    ChartContext context,
    List<({String label, Color color})> items,
    TextStyle style, {
    required double y,
  }) {
    final paragraphs = <Paragraph>[];
    var totalWidth = 0.0;

    for (final item in items) {
      final builder = ParagraphBuilder(ParagraphStyle(fontSize: style.fontSize))
        ..pushStyle(style.getTextStyle())
        ..addText(item.label);
      final paragraph = builder.build()
        ..layout(const ParagraphConstraints(width: 120));
      paragraphs.add(paragraph);
      totalWidth += _swatchWidth + 6 + paragraph.maxIntrinsicWidth;
    }
    totalWidth += _legendGap * (items.length - 1);

    var x = (size.width - totalWidth) / 2;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, y + 2, _swatchWidth, _swatchHeight),
          const Radius.circular(2),
        ),
        context.paintCache.fill('legend-$i', item.color),
      );
      x += _swatchWidth + 6;
      canvas.drawParagraph(paragraphs[i], Offset(x, y));
      x += paragraphs[i].maxIntrinsicWidth + _legendGap;
    }
  }

  static void _drawLegendVertical(
    Canvas canvas,
    ChartContext context,
    List<({String label, Color color})> items,
    TextStyle style, {
    required double x,
    required double y,
  }) {
    var rowY = y;
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(x, rowY + 2, _swatchWidth, _swatchHeight),
          const Radius.circular(2),
        ),
        context.paintCache.fill('legend-v-$i', item.color),
      );
      final builder = ParagraphBuilder(ParagraphStyle(fontSize: style.fontSize))
        ..pushStyle(style.getTextStyle())
        ..addText(item.label);
      final paragraph = builder.build()
        ..layout(const ParagraphConstraints(width: 64));
      canvas.drawParagraph(paragraph, Offset(x + _swatchWidth + 6, rowY));
      rowY += 20;
    }
  }
}
