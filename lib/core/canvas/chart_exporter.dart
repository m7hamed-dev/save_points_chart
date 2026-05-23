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

/// Maps typographic Unicode to ASCII for PDF built-in fonts (Helvetica).
String pdfAsciiText(String text) {
  const replacements = <String, String>{
    '\u2013': '-', // en dash
    '\u2014': '-', // em dash
    '\u2212': '-', // minus sign
    '\u2022': '*', // bullet
    '\u2018': "'",
    '\u2019': "'",
    '\u201C': '"',
    '\u201D': '"',
    '\u2026': '...',
  };
  var result = text;
  replacements.forEach((from, to) {
    result = result.replaceAll(from, to);
  });
  final buffer = StringBuffer();
  for (final codeUnit in result.codeUnits) {
    if (codeUnit <= 0xFF) {
      buffer.writeCharCode(codeUnit);
    } else {
      buffer.write('?');
    }
  }
  return buffer.toString();
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
    final safeTitle = title != null ? pdfAsciiText(title) : null;
    final safeSubtitle = subtitle != null ? pdfAsciiText(subtitle) : null;

    final doc = pw.Document(
      title: safeTitle ?? 'Chart',
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
              if (safeTitle != null && safeTitle.isNotEmpty)
                pw.Text(
                  safeTitle,
                  style: pw.TextStyle(
                    fontSize: 18,
                    fontWeight: pw.FontWeight.bold,
                  ),
                ),
              if (safeSubtitle != null && safeSubtitle.isNotEmpty) ...[
                pw.SizedBox(height: 4),
                pw.Text(
                  safeSubtitle,
                  style: const pw.TextStyle(
                    fontSize: 12,
                    color: PdfColors.grey700,
                  ),
                ),
              ],
              if ((safeTitle != null && safeTitle.isNotEmpty) ||
                  (safeSubtitle != null && safeSubtitle.isNotEmpty))
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
