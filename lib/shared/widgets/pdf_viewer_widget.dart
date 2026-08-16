import 'package:flutter/material.dart';
import 'pdf_viewer_stub.dart'
    if (dart.library.html) 'pdf_viewer_web.dart' as platform;

/// Cross-platform PDF Document Viewer Widget
class PdfViewerWidget extends StatelessWidget {
  const PdfViewerWidget({
    super.key,
    required this.url,
    this.fileName,
  });

  final String url;
  final String? fileName;

  @override
  Widget build(BuildContext context) {
    return platform.buildPdfViewer(url: url, fileName: fileName);
  }
}
