import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:save_points_chart/core/engine/chart_context.dart';

/// Draws axes and grid lines on canvas.
class AxisEngine {
  const AxisEngine._();

  static void drawGrid(
    Canvas canvas,
    ChartContext context, {
    int tickCount = 5,
  }) {
    final paint = context.paintCache.get(
      key: 'grid',
      color: context.theme.gridColor,
      strokeWidth: context.theme.gridStrokeWidth,
    );
    final bounds = context.bounds;
    if (context.viewport.width <= 0 || context.viewport.height <= 0) {
      return;
    }

    for (var i = 0; i <= tickCount; i++) {
      final t = i / tickCount;
      final x = bounds.left + bounds.width * t;
      canvas.drawLine(Offset(x, bounds.top), Offset(x, bounds.bottom), paint);

      final y = bounds.bottom - bounds.height * t;
      canvas.drawLine(Offset(bounds.left, y), Offset(bounds.right, y), paint);
    }
  }

  static void drawAxes(
    Canvas canvas,
    ChartContext context, {
    int tickCount = 5,
  }) {
    final axisPaint = context.paintCache.get(
      key: 'axis',
      color: context.theme.axisColor,
      strokeWidth: context.theme.axisStrokeWidth,
    );
    final bounds = context.bounds;
    final viewport = context.viewport;
    if (viewport.width <= 0 || viewport.height <= 0) {
      return;
    }
    final textStyle = context.theme.axisTextStyle;

    canvas.drawLine(
      Offset(bounds.left, bounds.bottom),
      Offset(bounds.right, bounds.bottom),
      axisPaint,
    );
    canvas.drawLine(
      Offset(bounds.left, bounds.top),
      Offset(bounds.left, bounds.bottom),
      axisPaint,
    );

    for (var i = 0; i <= tickCount; i++) {
      final t = i / tickCount;
      final dataX = viewport.minX + viewport.width * t;
      final canvasX = bounds.left + bounds.width * t;
      _drawLabel(
        canvas,
        _formatValue(dataX),
        Offset(canvasX, bounds.bottom + 4),
        textStyle,
        align: TextAlign.center,
      );

      final dataY = viewport.minY + viewport.height * t;
      final canvasY = bounds.bottom - bounds.height * t;
      _drawLabel(
        canvas,
        _formatValue(dataY),
        Offset(bounds.left - 4, canvasY),
        textStyle,
        align: TextAlign.right,
      );
    }

    drawAxisTitles(canvas, context);
  }

  /// Draws optional X/Y axis title labels (cartesian charts).
  static void drawAxisTitles(Canvas canvas, ChartContext context) {
    final xTitle = context.config.xAxisTitle;
    final yTitle = context.config.yAxisTitle;
    if ((xTitle == null || xTitle.isEmpty) &&
        (yTitle == null || yTitle.isEmpty)) {
      return;
    }

    final bounds = context.bounds;
    final style = context.theme.axisTextStyle.copyWith(
      fontWeight: FontWeight.w600,
    );

    if (xTitle != null && xTitle.isNotEmpty) {
      _drawLabel(
        canvas,
        xTitle,
        Offset(bounds.left + bounds.width / 2, bounds.bottom + 22),
        style,
        align: TextAlign.center,
        maxWidth: bounds.width,
      );
    }

    if (yTitle != null && yTitle.isNotEmpty) {
      _drawRotatedLabel(
        canvas,
        yTitle,
        Offset(bounds.left - 8, bounds.top + bounds.height / 2),
        style,
        maxWidth: bounds.height,
      );
    }
  }

  static String _formatValue(double value) {
    if (value.abs() >= 1000) return value.toStringAsFixed(0);
    if (value == value.roundToDouble()) return value.toInt().toString();
    return value.toStringAsFixed(1);
  }

  static void _drawLabel(
    Canvas canvas,
    String text,
    Offset position,
    TextStyle style, {
    TextAlign align = TextAlign.left,
    double maxWidth = 60,
  }) {
    final paragraph = _buildParagraph(text, style, align, maxWidth);

    var dx = position.dx;
    if (align == TextAlign.center) {
      dx -= paragraph.maxIntrinsicWidth / 2;
    } else if (align == TextAlign.right) {
      dx -= paragraph.maxIntrinsicWidth;
    }

    canvas.drawParagraph(paragraph, Offset(dx, position.dy));
  }

  static void _drawRotatedLabel(
    Canvas canvas,
    String text,
    Offset center,
    TextStyle style, {
    double maxWidth = 60,
  }) {
    final paragraph = _buildParagraph(
      text,
      style,
      TextAlign.center,
      maxWidth,
    );
    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(-math.pi / 2);
    canvas.drawParagraph(
      paragraph,
      Offset(-paragraph.maxIntrinsicWidth / 2, -paragraph.height / 2),
    );
    canvas.restore();
  }

  static Paragraph _buildParagraph(
    String text,
    TextStyle style,
    TextAlign align,
    double maxWidth,
  ) {
    final builder =
        ParagraphBuilder(
            ParagraphStyle(
              textAlign: align,
              fontSize: style.fontSize,
              fontFamily: style.fontFamily,
            ),
          )
          ..pushStyle(style.getTextStyle())
          ..addText(text);
    return builder.build()..layout(ParagraphConstraints(width: maxWidth));
  }
}
