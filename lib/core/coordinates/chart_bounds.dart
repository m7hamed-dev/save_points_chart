import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show EdgeInsets;

/// Canvas-space bounds for the plot area (excluding margins).
@immutable
class ChartBounds {
  const ChartBounds({
    required this.left,
    required this.top,
    required this.right,
    required this.bottom,
  });

  final double left;
  final double top;
  final double right;
  final double bottom;

  double get width => right - left;
  double get height => bottom - top;

  Rect get rect => Rect.fromLTRB(left, top, right, bottom);

  Offset get center => Offset(left + width / 2, top + height / 2);

  static ChartBounds fromSize(
    Size size, {
    EdgeInsets margins = EdgeInsets.zero,
  }) {
    return ChartBounds(
      left: margins.left,
      top: margins.top,
      right: size.width - margins.right,
      bottom: size.height - margins.bottom,
    );
  }
}
