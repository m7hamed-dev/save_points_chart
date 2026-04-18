import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/models/chart_interaction.dart';
import 'package:save_points_chart/theme/chart_theme.dart';

/// Custom painter for pie and donut charts
class PieChartPainter extends CustomPainter {
  final List<PieData> data;
  final ChartTheme theme;
  final double centerSpaceRadius;
  final double borderWidth;
  final double animationProgress;
  final ChartInteractionResult? selectedSegment;
  final bool showLabel;

  const PieChartPainter({
    required this.data,
    required this.theme,
    this.centerSpaceRadius = 0.0,
    this.borderWidth = 2.0,
    this.animationProgress = 1.0,
    this.selectedSegment,
    this.showLabel = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (data.isEmpty) return;

    // Validate size
    if (!size.width.isFinite || !size.height.isFinite || size.width <= 0 || size.height <= 0) {
      return;
    }

    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2 - 20;

    // Validate radius
    if (!radius.isFinite || radius <= 0) {
      return;
    }

    // Clamp the inner hole so the ring is always at least [minRingThickness]
    // pixels wide. Without this, a caller that hard-codes a
    // [centerSpaceRadius] (e.g. 70.0) on a small chart ends up with a hole
    // that equals or exceeds the outer radius, which makes every segment
    // path degenerate to empty and the ring disappears completely.
    const minRingThickness = 12.0;
    final double effectiveCenterSpaceRadius = centerSpaceRadius > 0
        ? centerSpaceRadius.clamp(0.0, math.max(0.0, radius - minRingThickness)).toDouble()
        : 0.0;

    final total = data.map((d) => d.value).reduce((a, b) => a + b);

    // Validate total
    if (!total.isFinite || total <= 0) {
      return;
    }

    // Start from top, with rotation animation
    double startAngle = -math.pi / 2 - (1.0 - animationProgress) * math.pi;

    // Pre-calculate paths and paints to optimize drawing order
    final List<
      ({
        Path path,
        Paint paint,
        Paint shadowPaint,
        bool isSelected,
        double startAngle,
        double sweepAngle,
        Offset center,
      })
    >
    segments = [];

    for (int index = 0; index < data.length; index++) {
      final item = data[index];

      // Validate item value - skip invalid or negative values
      // Zero values are allowed (they just won't draw anything visible)
      if (!item.value.isFinite || item.value < 0) {
        continue;
      }

      final sweepAngle = (item.value / total) * 2 * math.pi;

      // Skip segments with zero or near-zero sweep angle to avoid degenerate paths
      if (sweepAngle.abs() < 0.001) {
        startAngle += sweepAngle; // Still advance the angle for next segment
        continue;
      }

      // Animate each segment with stagger
      final segmentProgress = math.max(0.0, math.min(1.0, (animationProgress - (index / data.length) * 0.5) / 0.5));
      final animatedSweepAngle = sweepAngle * segmentProgress;

      // Check if this segment is selected
      final isSelected = selectedSegment != null && selectedSegment!.isHit && selectedSegment!.elementIndex == index;

      // Calculate offset for selected segment (explode effect)
      final midAngle = startAngle + sweepAngle / 2;
      final offset = isSelected ? 12.0 : 0.0;

      final effectiveCenter = Offset(center.dx + math.cos(midAngle) * offset, center.dy + math.sin(midAngle) * offset);

      // Draw segment with professional gradient (brighter if selected)
      final rect = Rect.fromCircle(center: effectiveCenter, radius: radius);
      final gradientCenter = Offset(
        effectiveCenter.dx + math.cos(midAngle) * (radius * 0.3),
        effectiveCenter.dy + math.sin(midAngle) * (radius * 0.3),
      );

      // Enhanced gradient with better depth and highlights
      final baseColor = isSelected ? item.color.withValues(alpha: 1.0) : item.color;
      final secondaryColor = isSelected ? item.color.withValues(alpha: 0.9) : item.color.withValues(alpha: 0.8);
      final tertiaryColor = isSelected ? item.color.withValues(alpha: 0.85) : item.color.withValues(alpha: 0.7);

      final paint = Paint()
        ..shader = RadialGradient(
          center: Alignment(
            (gradientCenter.dx - effectiveCenter.dx) / radius,
            (gradientCenter.dy - effectiveCenter.dy) / radius,
          ),
          radius: 0.9,
          colors: [baseColor, secondaryColor, tertiaryColor, item.color.withValues(alpha: 0.75)],
          stops: const [0.0, 0.3, 0.7, 1.0],
        ).createShader(rect)
        ..style = PaintingStyle.fill;

      // Add subtle shadow for depth
      final shadowPaint = Paint()
        ..color = Colors.black.withValues(alpha: 0.2)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4.0)
        ..style = PaintingStyle.fill;

      Path path;

      // Handle full circle (2π) specially - arcTo doesn't work well with exactly 2π
      // When animated sweep angle is very close to 2π, use addOval for reliable rendering
      // For animation, we still use arcTo until it's very close to full circle
      final isAnimatedFullCircle = animatedSweepAngle.abs() >= 2 * math.pi - 0.01;

      if (effectiveCenterSpaceRadius > 0) {
        // Donut chart
        if (isAnimatedFullCircle) {
          // Full circle donut - use addOval for reliable full circle rendering
          final outerPath = Path()..addOval(rect);
          final innerRect = Rect.fromCircle(center: effectiveCenter, radius: effectiveCenterSpaceRadius);
          final innerPath = Path()..addOval(innerRect);
          path = Path.combine(PathOperation.difference, outerPath, innerPath);
        } else {
          // Partial donut or animating - use arcTo
          final outerPath = Path()
            ..moveTo(effectiveCenter.dx, effectiveCenter.dy)
            ..arcTo(rect, startAngle, animatedSweepAngle, false)
            ..lineTo(effectiveCenter.dx, effectiveCenter.dy)
            ..close();

          final innerRect = Rect.fromCircle(center: effectiveCenter, radius: effectiveCenterSpaceRadius);
          final innerPath = Path()
            ..moveTo(effectiveCenter.dx, effectiveCenter.dy)
            ..arcTo(innerRect, startAngle + animatedSweepAngle, -animatedSweepAngle, false)
            ..lineTo(effectiveCenter.dx, effectiveCenter.dy)
            ..close();

          path = Path.combine(PathOperation.difference, outerPath, innerPath);
        }
      } else {
        // Pie chart
        if (isAnimatedFullCircle) {
          // Full circle pie - use addOval for reliable full circle rendering
          path = Path()..addOval(rect);
        } else {
          // Partial pie or animating - use arcTo
          path = Path()
            ..moveTo(effectiveCenter.dx, effectiveCenter.dy)
            ..arcTo(rect, startAngle, animatedSweepAngle, false)
            ..close();
        }
      }

      segments.add((
        path: path,
        paint: paint,
        shadowPaint: shadowPaint,
        isSelected: isSelected,
        startAngle: startAngle,
        sweepAngle: animatedSweepAngle,
        center: effectiveCenter,
      ));

      startAngle += sweepAngle; // Use original angle for positioning
    }

    // Draw shadows first (except selected)
    for (final segment in segments) {
      if (!segment.isSelected) {
        final shadowOffset = const Offset(2, 2);
        final shadowPath = Path()..addPath(segment.path, shadowOffset);
        canvas.drawPath(shadowPath, segment.shadowPaint);
      }
    }

    // Draw unselected segments
    for (final segment in segments) {
      if (!segment.isSelected) {
        canvas.drawPath(segment.path, segment.paint);
        _drawHighlight(canvas, segment.path, segment.paint.shader);
      }
    }

    // Draw selected segment shadow
    for (final segment in segments) {
      if (segment.isSelected) {
        final shadowOffset = const Offset(4, 4); // Larger shadow for selected
        final shadowPath = Path()..addPath(segment.path, shadowOffset);
        canvas.drawPath(shadowPath, segment.shadowPaint);
      }
    }

    // Draw selected segment
    for (final segment in segments) {
      if (segment.isSelected) {
        canvas.drawPath(segment.path, segment.paint);
        _drawHighlight(canvas, segment.path, segment.paint.shader);

        // Draw border
        final borderPaint = Paint()
          ..color = Colors.white
          ..style = PaintingStyle.stroke
          ..strokeWidth = borderWidth + 1;
        canvas.drawPath(segment.path, borderPaint);
      }
    }

    // Draw labels
    for (int i = 0; i < segments.length; i++) {
      final segment = segments[i];
      final item = data[i];

      if (showLabel && segment.sweepAngle > 0.3) {
        _drawLabel(
          canvas,
          segment.center,
          radius,
          effectiveCenterSpaceRadius,
          segment.startAngle,
          segment.sweepAngle,
          item,
          total,
        );
      }
    }
  }

  void _drawHighlight(Canvas canvas, Path path, Shader? shader) {
    final highlightPaint = Paint()
      ..shader = LinearGradient(
        begin: Alignment.topCenter,
        end: Alignment.bottomCenter,
        colors: [Colors.white.withValues(alpha: 0.3), Colors.white.withValues(alpha: 0.0)],
      ).createShader(path.getBounds())
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.5;
    canvas.drawPath(path, highlightPaint);
  }

  void _drawLabel(
    Canvas canvas,
    Offset center,
    double radius,
    double centerSpace,
    double startAngle,
    double sweepAngle,
    PieData item,
    double total,
  ) {
    final labelAngle = startAngle + sweepAngle / 2;
    final labelRadius = centerSpace > 0 ? (radius + centerSpace) / 2 : radius * 0.7;

    final labelX = center.dx + math.cos(labelAngle) * labelRadius;
    final labelY = center.dy + math.sin(labelAngle) * labelRadius;

    final percentage = ((item.value / total) * 100).toStringAsFixed(1);

    // Pill background is the segment color itself (nearly opaque) so it reads
    // clearly on any card/theme background. Text color is chosen to contrast
    // with that pill, not with the theme — this is what makes labels legible
    // in both light and dark modes.
    final pillColor = item.color.withValues(alpha: 0.92);
    final textColor = ThemeData.estimateBrightnessForColor(pillColor) == Brightness.dark
        ? Colors.white
        : const Color(0xFF111827);

    final textSpan = TextSpan(
      text: '$percentage%',
      style: TextStyle(color: textColor, fontSize: 13, fontWeight: FontWeight.w600, letterSpacing: 0.3),
    );
    final textPainter = TextPainter(text: textSpan, textDirection: TextDirection.ltr, textAlign: TextAlign.center);
    textPainter.layout();

    final bgRect = Rect.fromCenter(
      center: Offset(labelX, labelY),
      width: textPainter.width + 10,
      height: textPainter.height + 6,
    );
    final bgPaint = Paint()
      ..color = pillColor
      ..style = PaintingStyle.fill;
    canvas.drawRRect(RRect.fromRectAndRadius(bgRect, const .circular(6)), bgPaint);

    textPainter.paint(canvas, Offset(labelX - textPainter.width / 2, labelY - textPainter.height / 2));
  }

  @override
  bool shouldRepaint(covariant PieChartPainter oldDelegate) {
    return oldDelegate.data != data ||
        oldDelegate.theme != theme ||
        oldDelegate.centerSpaceRadius != centerSpaceRadius ||
        oldDelegate.animationProgress != animationProgress ||
        oldDelegate.selectedSegment != selectedSegment ||
        oldDelegate.showLabel != showLabel;
  }
}
