import 'dart:ui';

import 'package:flutter/foundation.dart';
import 'package:save_points_chart/core/interactions/hit_test_result.dart';
import 'package:save_points_chart/core/tooltip/tooltip_data.dart';

/// Controls overlay tooltip visibility and content.
class TooltipController extends ChangeNotifier {
  TooltipData? _data;
  bool _visible = false;

  TooltipData? get data => _data;
  bool get visible => _visible;

  void show(TooltipData data) {
    _data = data;
    _visible = true;
    notifyListeners();
  }

  void hide() {
    _visible = false;
    _data = null;
    notifyListeners();
  }

  void updateFromHit(ChartHitResult? hit, Offset position) {
    if (hit == null) {
      hide();
      return;
    }
    final entries = hit.dataPercent != null
        ? [
            TooltipEntry(
              label: 'Value',
              value: hit.dataY?.toStringAsFixed(1) ?? '—',
            ),
            TooltipEntry(
              label: 'Share',
              value: '${hit.dataPercent!.toStringAsFixed(1)}%',
            ),
          ]
        : [
            TooltipEntry(
              label: 'X',
              value: hit.dataX?.toStringAsFixed(2) ?? '—',
            ),
            TooltipEntry(
              label: 'Y',
              value: hit.dataY?.toStringAsFixed(2) ?? '—',
            ),
          ];

    show(
      TooltipData(
        title: hit.region.label ?? hit.seriesId,
        position: position,
        entries: entries,
      ),
    );
  }
}
