import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

/// Snapshot export utilities for chart [RepaintBoundary] widgets.
abstract class ChartExporter {
  const ChartExporter();

  Future<ui.Image> toImage(
    RenderRepaintBoundary boundary, {
    double pixelRatio = 3,
  });

  Future<Uint8List> toPng(
    RenderRepaintBoundary boundary, {
    double pixelRatio = 3,
  }) async {
    final image = await toImage(boundary, pixelRatio: pixelRatio);
    final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
    if (byteData == null) {
      throw StateError('Failed to encode chart as PNG');
    }
    return byteData.buffer.asUint8List();
  }
}

/// Default PNG exporter.
class PngChartExporter extends ChartExporter {
  const PngChartExporter();

  @override
  Future<ui.Image> toImage(
    RenderRepaintBoundary boundary, {
    double pixelRatio = 3,
  }) {
    return boundary.toImage(pixelRatio: pixelRatio);
  }
}

/// Embeds a chart PNG snapshot in a PDF page (optional title / subtitle header).
class PdfChartExporter extends ChartExporter {
  const PdfChartExporter();

  @override
  Future<ui.Image> toImage(
    RenderRepaintBoundary boundary, {
    double pixelRatio = 3,
  }) {
    return const PngChartExporter().toImage(boundary, pixelRatio: pixelRatio);
  }

  Future<Uint8List> toPdf(
    RenderRepaintBoundary boundary, {
    String? title,
    String? subtitle,
    double pixelRatio = 3,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) async {
    final pngBytes = await toPng(boundary, pixelRatio: pixelRatio);
    final doc = pw.Document(
      title: title ?? 'Chart',
      creator: 'save_points_chart',
    );

    doc.addPage(
      pw.Page(
        pageFormat: pageFormat,
        margin: const pw.EdgeInsets.all(32),
        build: (context) {
          return pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              if (title != null && title.isNotEmpty)
                pw.Text(
                  title,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              if (subtitle != null && subtitle.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  subtitle,
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
              if ((title != null && title.isNotEmpty) ||
                  (subtitle != null && subtitle.isNotEmpty))
                pw.SizedBox(height: 16),
              pw.Expanded(
                child: pw.Center(
                  child: pw.Image(
                    pw.MemoryImage(pngBytes),
                    fit: pw.BoxFit.contain,
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    return doc.save();
  }
}

/// High-level export helpers using a [RepaintBoundary] [GlobalKey].
class ChartExport {
  const ChartExport._();

  static RenderRepaintBoundary _boundary(GlobalKey key) {
    final context = key.currentContext;
    if (context == null) {
      throw StateError('Chart is not mounted — cannot export');
    }
    final boundary = context.findRenderObject();
    if (boundary is! RenderRepaintBoundary) {
      throw StateError('Export key is not attached to a RepaintBoundary');
    }
    return boundary;
  }

  static Future<Uint8List> toPng(
    GlobalKey boundaryKey, {
    double pixelRatio = 3,
  }) {
    return const PngChartExporter().toPng(
      _boundary(boundaryKey),
      pixelRatio: pixelRatio,
    );
  }

  static Future<Uint8List> toPdf(
    GlobalKey boundaryKey, {
    String? title,
    String? subtitle,
    double pixelRatio = 3,
    PdfPageFormat pageFormat = PdfPageFormat.a4,
  }) {
    return const PdfChartExporter().toPdf(
      _boundary(boundaryKey),
      title: title,
      subtitle: subtitle,
      pixelRatio: pixelRatio,
      pageFormat: pageFormat,
    );
  }
}
