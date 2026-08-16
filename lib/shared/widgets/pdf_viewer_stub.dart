import 'package:flutter/material.dart';
import '../../core/theme/app_tokens.dart';

/// Fallback PDF Viewer for test and non-web platforms
Widget buildPdfViewer({
  required String url,
  String? fileName,
}) {
  return Container(
    padding: const EdgeInsets.all(AppTokens.spaceLG),
    decoration: BoxDecoration(
      color: Colors.black26,
      borderRadius: BorderRadius.circular(AppTokens.radiusMD),
    ),
    child: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.picture_as_pdf_rounded,
            color: AppTokens.accentGold,
            size: 54,
          ),
          const SizedBox(height: 12),
          Text(
            fileName ?? 'Dokumen PDF',
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            url,
            style: const TextStyle(color: Colors.white38, fontSize: 11),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
  );
}
