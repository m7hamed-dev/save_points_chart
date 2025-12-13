import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:save_points_chart/painters/base_chart_painter.dart';

/// A custom painter for rendering gauge charts.
///
/// This painter handles the rendering of gauge charts showing a single
/// value on a semi-circular or circular gauge.
class GaugeChartPainter extends BaseChartPainter {
  /// The current value to display.
  final double value;

  /// The minimum value of the gauge.
  final double minValue;

  /// The maximum value of the gauge.
  final double maxValue;

  /// The number of segments/divisions on the gauge.
  final int segments;

  /// The start angle in radians (0 is right, positive is clockwise).
  final double startAngle;

  /// The sweep angle in radians (how much of the circle to use).
  final double sweepAngle;

  /// The animation progress value between 0.0 and 1.0.
  final double animationProgress;

  /// The label to display in the center.
  final String? centerLabel;

  /// The unit to display after the value.
  final String? unit;

  /// Creates a gauge chart painter.
  GaugeChartPainter({
    required super.theme,
    required this.value,
    this.minValue = 0.0,
    this.maxValue = 100.0,
    this.segments = 5,
    this.startAngle = math.pi,
    this.sweepAngle = math.pi,
    this.animationProgress = 1.0,
    this.centerLabel,
    this.unit,
    super.showGrid,
    super.showAxis,
    super.showLabel,
  }) : super(dataSets: []); // Empty for gauge chart

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 40;

    // Draw background arc
    final backgroundPaint = Paint()
      ..color = theme.gridColor.withValues(alpha: 0.2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0
      ..strokeCap = StrokeCap.round;

    final backgroundRect = Rect.fromCircle(center: center, radius: radius);
    canvas.drawArc(
      backgroundRect,
      startAngle,
      sweepAngle,
      false,
      backgroundPaint,
    );

    // Draw segment divisions
    if (segments > 1 && showGrid && theme.showGrid) {
      final divisionPaint = Paint()
        ..color = theme.gridColor.withValues(alpha: 0.5)
        ..strokeWidth = 2.0;

      for (int i = 0; i <= segments; i++) {
        final angle = startAngle + (sweepAngle * i / segments);
        final startPoint = Offset(
          center.dx + (radius - 10) * math.cos(angle),
          center.dy + (radius - 10) * math.sin(angle),
        );
        final endPoint = Offset(
          center.dx + (radius + 10) * math.cos(angle),
          center.dy + (radius + 10) * math.sin(angle),
        );
        canvas.drawLine(startPoint, endPoint, divisionPaint);
      }
    }

    // Calculate value position
    final clampedValue = value.clamp(minValue, maxValue);
    final normalizedValue = (clampedValue - minValue) / (maxValue - minValue);
    final animatedValue = normalizedValue * animationProgress;
    final sweepAmount = sweepAngle * animatedValue;
    final valueAngle = startAngle + sweepAmount;

    // Validate angles
    if (!startAngle.isFinite || !valueAngle.isFinite || !sweepAmount.isFinite) {
      return; // Skip rendering if angles are invalid
    }

    // Draw value arc with gradient or solid color
    final valueRect = Rect.fromCircle(center: center, radius: radius);
    final primaryColor = theme.gradientColors.isNotEmpty
        ? theme.gradientColors[0]
        : const Color(0xFF6366F1);

    final valuePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 20.0
      ..strokeCap = StrokeCap.round;

    // Use gradient only if sweep is significant, otherwise use solid color
    if (sweepAmount.abs() > 0.01 && (valueAngle - startAngle).abs() > 0.01) {
      // Ensure endAngle is different from startAngle for gradient
      final effectiveEndAngle = math.max(
        startAngle + 0.01,
        valueAngle,
      );

      // Validate angles are finite and in reasonable range
      if (effectiveEndAngle.isFinite &&
          startAngle.isFinite &&
          (effectiveEndAngle - startAngle).abs() > 0.01) {
        try {
          // Use Alignment.center as default (gauge is centered)
          final gradient = SweepGradient(
            startAngle: startAngle,
            endAngle: effectiveEndAngle,
            colors: [
              primaryColor,
              primaryColor.withValues(alpha: 0.7),
            ],
          );
          valuePaint.shader = gradient.createShader(valueRect);
        } catch (e) {
          // Fallback to solid color if gradient creation fails
          valuePaint.color = primaryColor;
        }
      } else {
        // Use solid color if angles are invalid
        valuePaint.color = primaryColor;
      }
    } else {
      // Use solid color for very small sweeps
      valuePaint.color = primaryColor;
    }

    // Only draw arc if sweep is positive
    if (sweepAmount > 0) {
      canvas.drawArc(
        valueRect,
        startAngle,
        sweepAmount,
        false,
        valuePaint,
      );
    }

    // Draw value indicator (needle)
    final needleLength = radius * 0.8;
    final needlePaint = Paint()
      ..color = primaryColor
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    final needleEnd = Offset(
      center.dx + needleLength * math.cos(valueAngle),
      center.dy + needleLength * math.sin(valueAngle),
    );
    canvas.drawLine(center, needleEnd, needlePaint);

    // Draw center circle
    final centerPaint = Paint()
      ..color = theme.backgroundColor
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, 8, centerPaint);

    final centerBorderPaint = Paint()
      ..color = primaryColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.0;
    canvas.drawCircle(center, 8, centerBorderPaint);

    // Draw value text
    if (showLabel && theme.showAxis) {
      final valueText =
          '${clampedValue.toStringAsFixed(1)}${unit != null ? ' $unit' : ''}';
      final valueTextStyle = TextStyle(
        color: theme.textColor,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      );

      final valueTextPainter = TextPainter(
        text: TextSpan(text: valueText, style: valueTextStyle),
        textDirection: TextDirection.ltr,
        textAlign: TextAlign.center,
      );
      valueTextPainter.layout();

      final valueTextOffset = Offset(
        center.dx - valueTextPainter.width / 2,
        center.dy - valueTextPainter.height / 2 - 20,
      );
      valueTextPainter.paint(canvas, valueTextOffset);

      // Draw center label if provided
      if (centerLabel != null) {
        final labelTextStyle = TextStyle(
          color: theme.textColor.withValues(alpha: 0.7),
          fontSize: 14,
          fontWeight: FontWeight.w500,
        );

        final labelTextPainter = TextPainter(
          text: TextSpan(text: centerLabel!, style: labelTextStyle),
          textDirection: TextDirection.ltr,
          textAlign: TextAlign.center,
        );
        labelTextPainter.layout();

        final labelTextOffset = Offset(
          center.dx - labelTextPainter.width / 2,
          center.dy + valueTextPainter.height / 2 + 10,
        );
        labelTextPainter.paint(canvas, labelTextOffset);
      }
    }

    // Draw min/max labels
    if (showLabel && theme.showAxis) {
      final labelTextStyle = TextStyle(
        color: theme.axisColor.withValues(alpha: 0.8),
        fontSize: 12,
        fontWeight: FontWeight.w500,
      );

      // Min label
      final minAngle = startAngle;
      final minLabelPoint = Offset(
        center.dx + (radius + 25) * math.cos(minAngle),
        center.dy + (radius + 25) * math.sin(minAngle),
      );
      final minTextPainter = TextPainter(
        text: TextSpan(
          text: minValue.toStringAsFixed(0),
          style: labelTextStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      minTextPainter.layout();
      minTextPainter.paint(
        canvas,
        Offset(
          minLabelPoint.dx - minTextPainter.width / 2,
          minLabelPoint.dy - minTextPainter.height / 2,
        ),
      );

      // Max label
      final maxAngle = startAngle + sweepAngle;
      final maxLabelPoint = Offset(
        center.dx + (radius + 25) * math.cos(maxAngle),
        center.dy + (radius + 25) * math.sin(maxAngle),
      );
      final maxTextPainter = TextPainter(
        text: TextSpan(
          text: maxValue.toStringAsFixed(0),
          style: labelTextStyle,
        ),
        textDirection: TextDirection.ltr,
      );
      maxTextPainter.layout();
      maxTextPainter.paint(
        canvas,
        Offset(
          maxLabelPoint.dx - maxTextPainter.width / 2,
          maxLabelPoint.dy - maxTextPainter.height / 2,
        ),
      );
    }
  }

  @override
  bool shouldRepaint(covariant GaugeChartPainter oldDelegate) {
    return super.shouldRepaint(oldDelegate) ||
        oldDelegate.value != value ||
        oldDelegate.minValue != minValue ||
        oldDelegate.maxValue != maxValue ||
        oldDelegate.segments != segments ||
        oldDelegate.startAngle != startAngle ||
        oldDelegate.sweepAngle != sweepAngle ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.centerLabel != centerLabel ||
        oldDelegate.unit != unit;
  }
}
