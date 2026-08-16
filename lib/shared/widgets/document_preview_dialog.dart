import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_tokens.dart';
import 'glass_button.dart';
import 'pdf_viewer_widget.dart';

/// Dialog modal untuk pratinjau dokumen (Gambar / PDF) dengan penampil isi berkas langsung
class DocumentPreviewDialog extends StatefulWidget {
  const DocumentPreviewDialog({
    super.key,
    required this.title,
    required this.fileUrl,
    this.fileName,
  });

  final String title;
  final String fileUrl;
  final String? fileName;

  @override
  State<DocumentPreviewDialog> createState() => _DocumentPreviewDialogState();
}

class _DocumentPreviewDialogState extends State<DocumentPreviewDialog> {
  bool _useGoogleDocsFallback = false;

  bool get _isImage {
    final lower = (widget.fileName ?? widget.fileUrl).toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  String get _effectivePdfUrl {
    if (_useGoogleDocsFallback) {
      return 'https://docs.google.com/viewer?url=${Uri.encodeComponent(widget.fileUrl)}&embedded=true';
    }
    return widget.fileUrl;
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(widget.fileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final dialogWidth = size.width > 1000 ? 950.0 : size.width * 0.92;
    final dialogHeight = size.height > 850 ? 780.0 : size.height * 0.88;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      child: Container(
        width: dialogWidth,
        height: dialogHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF110E24).withValues(alpha: 0.96),
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          border: Border.all(
            color: AppTokens.primaryPurple.withValues(alpha: 0.35),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTokens.primaryPurple.withValues(alpha: 0.3),
              blurRadius: 36,
              spreadRadius: 6,
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header (Judul, Tipe Berkas, Actions) ────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 14, 14),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTokens.primaryPurple.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                    ),
                    child: Icon(
                      _isImage
                          ? Icons.image_rounded
                          : Icons.picture_as_pdf_rounded,
                      color: _isImage
                          ? AppTokens.primaryPurpleLight
                          : AppTokens.accentGold,
                      size: 22,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Flexible(
                              child: Text(
                                widget.title,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: _isImage
                                    ? AppTokens.primaryPurple
                                        .withValues(alpha: 0.2)
                                    : AppTokens.accentGold
                                        .withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                _isImage ? 'GAMBAR' : 'DOKUMEN PDF',
                                style: TextStyle(
                                  color: _isImage
                                      ? AppTokens.primaryPurpleLight
                                      : AppTokens.accentGold,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (widget.fileName != null)
                          Text(
                            widget.fileName!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.55),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),

                  // Mode Alternatif Google Docs Viewer jika browser memblokir iframe langsung
                  if (!_isImage)
                    IconButton(
                      tooltip: _useGoogleDocsFallback
                          ? 'Beralih ke Viewer Langsung'
                          : 'Beralih ke Google Docs Viewer',
                      icon: Icon(
                        _useGoogleDocsFallback
                            ? Icons.swap_horiz_rounded
                            : Icons.document_scanner_rounded,
                        color: _useGoogleDocsFallback
                            ? AppTokens.accentGold
                            : Colors.white60,
                        size: 20,
                      ),
                      onPressed: () {
                        setState(() {
                          _useGoogleDocsFallback = !_useGoogleDocsFallback;
                        });
                      },
                    ),

                  // Tombol Buka Tab Penuh
                  IconButton(
                    tooltip: 'Buka di Tab Baru / Unduh Berkas',
                    icon: const Icon(Icons.open_in_new_rounded,
                        color: Colors.white70, size: 20),
                    onPressed: _openInBrowser,
                  ),

                  // Tombol Tutup
                  IconButton(
                    tooltip: 'Tutup (ESC)',
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white70, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white12, height: 1),

            // ── Body Pratinjau Dokumen ──────────────────────────────────
            Expanded(
              child: Container(
                color: Colors.black.withValues(alpha: 0.35),
                padding: const EdgeInsets.all(8),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                  child: _isImage
                      ? Center(
                          child: InteractiveViewer(
                            maxScale: 5.0,
                            child: Image.network(
                              widget.fileUrl,
                              fit: BoxFit.contain,
                              loadingBuilder:
                                  (context, child, loadingProgress) {
                                if (loadingProgress == null) return child;
                                return const Center(
                                  child: CircularProgressIndicator(
                                    color: AppTokens.primaryPurpleLight,
                                  ),
                                );
                              },
                              errorBuilder: (context, error, stackTrace) =>
                                  _buildErrorView(),
                            ),
                          ),
                        )
                      : PdfViewerWidget(
                          url: _effectivePdfUrl,
                          fileName: widget.fileName,
                        ),
                ),
              ),
            ),

            const Divider(color: Colors.white12, height: 1),

            // ── Footer Toolbar ──────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              child: Row(
                children: [
                  const Icon(
                    Icons.verified_user_outlined,
                    size: 14,
                    color: AppTokens.success,
                  ),
                  const SizedBox(width: 6),
                  const Text(
                    'Pratinjau Resmi Sistem Yudisium TIK PNL',
                    style: TextStyle(
                      color: Colors.white60,
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  OutlinedButton.icon(
                    onPressed: _openInBrowser,
                    icon: const Icon(Icons.download_rounded, size: 14),
                    label: const Text('Buka / Unduh PDF',
                        style: TextStyle(fontSize: 12)),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTokens.primaryPurpleLight,
                      side: BorderSide(
                        color: AppTokens.primaryPurpleLight
                            .withValues(alpha: 0.5),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 8),
                    ),
                    child: const Text('Tutup (ESC)'),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorView() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.broken_image_rounded,
              color: AppTokens.error, size: 48),
          const SizedBox(height: 12),
          const Text(
            'Gagal memuat dokumen',
            style: TextStyle(color: Colors.white70),
          ),
          const SizedBox(height: 12),
          GlassButton(
            label: 'Buka di Browser',
            icon: Icons.open_in_browser_rounded,
            onPressed: _openInBrowser,
          ),
        ],
      ),
    );
  }
}

