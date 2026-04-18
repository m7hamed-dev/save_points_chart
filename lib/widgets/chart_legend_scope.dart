import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_data.dart';
import 'package:save_points_chart/theme/chart_theme.dart';
import 'package:save_points_chart/widgets/chart_legend.dart';

/// Controller that tracks which series are currently hidden.
///
/// Pass an instance to [ChartLegendScope] (or use it standalone with a
/// [ChartLegend] you build yourself) to keep visibility state outside the
/// widget tree, for example to persist it across rebuilds or share it across
/// multiple charts.
///
/// ## Example
/// ```dart
/// final controller = ChartVisibilityController();
/// // ...
/// controller.hide(Colors.red);
/// controller.toggle(Colors.blue);
/// if (controller.isHidden(Colors.red)) { /* ... */ }
/// ```
class ChartVisibilityController extends ChangeNotifier {
  ChartVisibilityController({Iterable<Color> initiallyHidden = const <Color>[]})
      : _hidden = Set<Color>.from(initiallyHidden);

  final Set<Color> _hidden;

  /// Unmodifiable view of the hidden colors.
  Set<Color> get hidden => Set<Color>.unmodifiable(_hidden);

  bool isHidden(Color color) => _hidden.contains(color);

  void toggle(Color color) {
    if (!_hidden.remove(color)) _hidden.add(color);
    notifyListeners();
  }

  void hide(Color color) {
    if (_hidden.add(color)) notifyListeners();
  }

  void show(Color color) {
    if (_hidden.remove(color)) notifyListeners();
  }

  /// Hide everything except [color]. Useful for "solo" legend interactions
  /// (double-tap or long-press).
  void solo(Color color, Iterable<Color> all) {
    final target = {for (final c in all) if (c != color) c};
    if (!setEquals(target, _hidden)) {
      _hidden
        ..clear()
        ..addAll(target);
      notifyListeners();
    }
  }

  void showAll() {
    if (_hidden.isNotEmpty) {
      _hidden.clear();
      notifyListeners();
    }
  }

  /// Filters a list of [ChartDataSet]s, removing any whose color is hidden.
  List<ChartDataSet> filter(List<ChartDataSet> dataSets) {
    if (_hidden.isEmpty) return dataSets;
    return [for (final set in dataSets) if (!_hidden.contains(set.color)) set];
  }
}

/// Composes any chart with a tappable legend that toggles series visibility.
///
/// Pass your full [dataSets], render the chart inside [builder] using the
/// filtered list that the builder receives. Tapping a legend item hides or
/// shows the corresponding series without you having to touch the underlying
/// chart widget.
///
/// ## Example
/// ```dart
/// ChartLegendScope(
///   dataSets: myDataSets,
///   builder: (context, visibleDataSets) {
///     return LineChartWidget(dataSets: visibleDataSets);
///   },
/// )
/// ```
///
/// ## With an external controller
/// ```dart
/// final controller = ChartVisibilityController();
///
/// ChartLegendScope(
///   controller: controller,
///   dataSets: myDataSets,
///   position: LegendPosition.top,
///   builder: (context, visible) => BarChartWidget(dataSets: visible),
/// )
/// ```
class ChartLegendScope extends StatefulWidget {
  const ChartLegendScope({
    super.key,
    required this.dataSets,
    required this.builder,
    this.controller,
    this.position = LegendPosition.bottom,
    this.spacing = 12.0,
    this.theme,
    this.seriesLabelFor,
    this.showLegend = true,
  });

  /// The full list of datasets. Not mutated.
  final List<ChartDataSet> dataSets;

  /// Renders the chart. Receives the filtered (visible) list of datasets.
  final Widget Function(BuildContext context, List<ChartDataSet> visibleDataSets) builder;

  /// Optional external controller. If omitted, the scope creates its own.
  final ChartVisibilityController? controller;

  /// Where to place the legend relative to the chart.
  final LegendPosition position;

  /// Gap between the chart and the legend.
  final double spacing;

  /// Theme used for label colors. Falls back to the ambient Material theme.
  final ChartTheme? theme;

  /// Optional custom label resolver (see [ChartLegend.fromDataSets]).
  final String Function(Color color, List<ChartDataSet> group)? seriesLabelFor;

  /// Set to false to hide the legend but still render the chart; useful when
  /// you want to manage toggling via your own UI.
  final bool showLegend;

  @override
  State<ChartLegendScope> createState() => _ChartLegendScopeState();
}

class _ChartLegendScopeState extends State<ChartLegendScope> {
  ChartVisibilityController? _internal;
  ChartVisibilityController get _controller => widget.controller ?? _internal!;

  @override
  void initState() {
    super.initState();
    if (widget.controller == null) {
      _internal = ChartVisibilityController();
    }
    _controller.addListener(_onControllerChanged);
  }

  @override
  void didUpdateWidget(covariant ChartLegendScope oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.controller != oldWidget.controller) {
      (oldWidget.controller ?? _internal)?.removeListener(_onControllerChanged);
      if (widget.controller == null) {
        _internal ??= ChartVisibilityController();
      } else {
        _internal?.dispose();
        _internal = null;
      }
      _controller.addListener(_onControllerChanged);
    }
  }

  @override
  void dispose() {
    _controller.removeListener(_onControllerChanged);
    _internal?.dispose();
    super.dispose();
  }

  void _onControllerChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final visible = _controller.filter(widget.dataSets);
    final chart = widget.builder(context, visible);

    if (!widget.showLegend) return chart;

    final legend = ChartLegend.fromDataSets(
      widget.dataSets,
      hidden: _controller.hidden,
      onToggle: _controller.toggle,
      theme: widget.theme,
      direction: (widget.position == LegendPosition.left || widget.position == LegendPosition.right)
          ? Axis.vertical
          : Axis.horizontal,
      seriesLabelFor: widget.seriesLabelFor,
    );

    switch (widget.position) {
      case LegendPosition.top:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            legend,
            SizedBox(height: widget.spacing),
            chart,
          ],
        );
      case LegendPosition.bottom:
        return Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            chart,
            SizedBox(height: widget.spacing),
            legend,
          ],
        );
      case LegendPosition.left:
        return Row(
          children: [
            legend,
            SizedBox(width: widget.spacing),
            Expanded(child: chart),
          ],
        );
      case LegendPosition.right:
        return Row(
          children: [
            Expanded(child: chart),
            SizedBox(width: widget.spacing),
            legend,
          ],
        );
    }
  }
}
