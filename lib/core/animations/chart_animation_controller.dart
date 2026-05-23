import 'package:flutter/animation.dart';

/// Wraps Flutter animation primitives for chart transitions.
class ChartAnimationController {
  ChartAnimationController({
    required TickerProvider vsync,
    Duration duration = const Duration(milliseconds: 380),
    Curve curve = Curves.easeInOut,
  }) {
    _controller = AnimationController(vsync: vsync, duration: duration);
    _animation = CurvedAnimation(parent: _controller, curve: curve);
  }

  late final AnimationController _controller;
  late final Animation<double> _animation;

  Animation<double> get animation => _animation;
  double get value => _animation.value;

  bool get isAnimating => _controller.isAnimating;

  Future<void> forward({double? from}) async {
    if (from != null) _controller.value = from;
    await _controller.forward(from: from);
  }

  Future<void> reverse() => _controller.reverse();

  void reset() => _controller.reset();

  void dispose() => _controller.dispose();
}
