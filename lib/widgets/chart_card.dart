import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:save_points_chart/models/chart_config.dart';
import 'package:save_points_chart/widgets/chart_widget_controller.dart';

/// Optional export toolbar above a chart (PNG / PDF).
class ChartCard extends StatelessWidget {
  const ChartCard({
    super.key,
    required this.config,
    required this.controller,
    required this.child,
    this.onExported,
  });

  final ChartConfig config;
  final ChartWidgetController controller;
  final Widget child;
  final void Function(String format, Uint8List bytes)? onExported;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerRight,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                tooltip: 'Export PNG',
                icon: const Icon(Icons.image_outlined, size: 20),
                color: Colors.white70,
                onPressed: () => _export(context, png: true),
              ),
              IconButton(
                tooltip: 'Export PDF',
                icon: const Icon(Icons.picture_as_pdf_outlined, size: 20),
                color: Colors.white70,
                onPressed: () => _export(context, png: false),
              ),
            ],
          ),
        ),
        Expanded(child: child),
      ],
    );
  }

  Future<void> _export(BuildContext context, {required bool png}) async {
    try {
      final bytes = png
          ? await controller.exportPng()
          : await controller.exportPdfFromConfig(config);
      onExported?.call(png ? 'png' : 'pdf', bytes);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'Exported ${png ? 'PNG' : 'PDF'} (${_formatSize(bytes.length)})',
            ),
          ),
        );
      }
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Export failed: $e')),
        );
      }
    }
  }

  static String _formatSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }
}
