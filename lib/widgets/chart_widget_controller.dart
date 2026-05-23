import 'dart:typed_data';

import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:save_points_chart/core/canvas/chart_exporter.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/save_points_charts.dart' show ChartWidget;
import 'package:save_points_chart/widgets/chart_widget.dart' show ChartWidget;

/// Controls export for a mounted [ChartWidget] via its [repaintBoundaryKey].
class ChartWidgetController {
  ChartWidgetController();

  final GlobalKey repaintBoundaryKey = GlobalKey();
  VoidCallback? _prepareExport;

  void registerPrepareExport(VoidCallback prepare) {
    _prepareExport = prepare;
  }

  void unregisterPrepareExport() {
    _prepareExport = null;
  }

  Future<void> _ensureFrame() async {
    _prepareExport?.call();
    await WidgetsBinding.instance.endOfFrame;
  }

  /// PNG bytes of the chart canvas (excludes overlay tooltips).
  Future<Uint8List> exportPng({double pixelRatio = 3}) async {
    await _ensureFrame();
    return ChartExport.toPng(repaintBoundaryKey, pixelRatio: pixelRatio);
  }

  /// PDF with an embedded chart image and optional header text.
  Future<Uint8List> exportPdf({
    String? title,
    String? subtitle,
    double pixelRatio = 3,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    await _ensureFrame();
    return ChartExport.toPdf(
      repaintBoundaryKey,
      title: title,
      subtitle: subtitle,
      pixelRatio: pixelRatio,
      pageFormat: pageFormat,
    );
  }

  /// Convenience: export using [config] title / subtitle when not overridden.
  Future<Uint8List> exportPdfFromConfig(
    ChartConfig config, {
    double pixelRatio = 3,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) {
    return exportPdf(
      title: config.title,
      subtitle: config.subtitle,
      pixelRatio: pixelRatio,
      pageFormat: pageFormat,
    );
  }
}
