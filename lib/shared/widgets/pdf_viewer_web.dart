// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;
import 'dart:ui_web' as ui_web;
import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

final Set<String> _registeredViewTypes = {};

/// Embedded PDF Viewer for Flutter Web using HTML iframe
Widget buildPdfViewer({
  required String url,
  String? fileName,
}) {
  final viewType = 'pdf-viewer-${url.hashCode}';

  if (!_registeredViewTypes.contains(viewType)) {
    ui_web.platformViewRegistry.registerViewFactory(
      viewType,
      (int viewId) {
        final iframe = html.IFrameElement()
          ..src = url
          ..style.border = 'none'
          ..style.width = '100%'
          ..style.height = '100%'
          ..style.borderRadius = '8px'
          ..style.backgroundColor = '#1a1630'
          ..allowFullscreen = true;
        return iframe;
      },
    );
    _registeredViewTypes.add(viewType);
  }

  return ClipRRect(
    borderRadius: BorderRadius.circular(AppTokens.radiusMD),
    child: HtmlElementView(viewType: viewType),
  );
}
