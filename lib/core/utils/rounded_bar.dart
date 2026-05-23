import 'dart:ui';

/// Draws a bar/rod shape with optional corner rounding.
void drawRoundedBar(
  Canvas canvas,
  Rect rect, {
  required double radius,
  required Paint paint,
  bool roundTop = true,
  bool roundBottom = false,
}) {
  if (rect.isEmpty) return;

  final maxR = rect.shortestSide / 2;
  final r = radius.clamp(0.0, maxR);
  if (r <= 0) {
    canvas.drawRect(rect, paint);
    return;
  }

  canvas.drawRRect(
    RRect.fromRectAndCorners(
      rect,
      topLeft: roundTop ? Radius.circular(r) : Radius.zero,
      topRight: roundTop ? Radius.circular(r) : Radius.zero,
      bottomLeft: roundBottom ? Radius.circular(r) : Radius.zero,
      bottomRight: roundBottom ? Radius.circular(r) : Radius.zero,
    ),
    paint,
  );
}

/// Vertical bars: round the end away from the baseline ([baseY]).
void drawVerticalBar(
  Canvas canvas,
  Rect rect, {
  required double radius,
  required Paint paint,
  required double baseY,
}) {
  final growsUp = rect.bottom >= baseY - 0.5;
  drawRoundedBar(
    canvas,
    rect,
    radius: radius,
    paint: paint,
    roundTop: growsUp,
    roundBottom: !growsUp,
  );
}
