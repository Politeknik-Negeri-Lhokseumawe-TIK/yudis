import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../core/theme/app_tokens.dart';
import 'glass_button.dart';

/// Dialog modal untuk pratinjau dokumen (Gambar / PDF) dengan tombol Buka dan Tutup
class DocumentPreviewDialog extends StatelessWidget {
  const DocumentPreviewDialog({
    super.key,
    required this.title,
    required this.fileUrl,
    this.fileName,
  });

  final String title;
  final String fileUrl;
  final String? fileName;

  bool get _isImage {
    final lower = (fileName ?? fileUrl).toLowerCase();
    return lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp');
  }

  Future<void> _openInBrowser() async {
    final uri = Uri.parse(fileUrl);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 800, maxHeight: 750),
        decoration: BoxDecoration(
          color: const Color(0xFF131127).withValues(alpha: 0.95),
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          border: Border.all(
            color: AppTokens.primaryPurple.withValues(alpha: 0.3),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: AppTokens.primaryPurple.withValues(alpha: 0.25),
              blurRadius: 30,
              spreadRadius: 4,
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Header (Judul & Tombol Tutup) ──────────────────────────
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
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
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (fileName != null)
                          Text(
                            fileName!,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.5),
                              fontSize: 11,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 8),
                  // Tombol Buka Tab Baru
                  IconButton(
                    tooltip: 'Buka di Tab Baru',
                    icon: const Icon(Icons.open_in_new_rounded,
                        color: Colors.white70, size: 20),
                    onPressed: _openInBrowser,
                  ),
                  // Tombol Tutup
                  IconButton(
                    tooltip: 'Tutup',
                    icon: const Icon(Icons.close_rounded,
                        color: Colors.white70, size: 22),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                ],
              ),
            ),

            const Divider(color: Colors.white12, height: 1),

            // ── Body Pratinjau ──────────────────────────────────────────
            Expanded(
              child: Container(
                color: Colors.black.withValues(alpha: 0.3),
                padding: const EdgeInsets.all(16),
                child: Center(
                  child: _isImage
                      ? InteractiveViewer(
                          maxScale: 4.0,
                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusSM),
                            child: Image.network(
                              fileUrl,
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
                                  Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  const Icon(Icons.broken_image_rounded,
                                      color: AppTokens.error, size: 48),
                                  const SizedBox(height: 12),
                                  const Text(
                                    'Gagal memuat gambar',
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
                            ),
                          ),
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(24),
                              decoration: BoxDecoration(
                                color: AppTokens.primaryPurple
                                    .withValues(alpha: 0.12),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: AppTokens.primaryPurple
                                      .withValues(alpha: 0.3),
                                ),
                              ),
                              child: const Icon(
                                Icons.picture_as_pdf_rounded,
                                color: AppTokens.accentGold,
                                size: 56,
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              fileName ?? 'Dokumen PDF',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Dokumen PDF siap untuk ditinjau dan diperiksa keabsahannya.',
                              style: TextStyle(
                                color: Colors.white.withValues(alpha: 0.6),
                                fontSize: 12,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 24),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                GlassButton(
                                  label: 'Buka Dokumen PDF 🔗',
                                  icon: Icons.open_in_new_rounded,
                                  color: AppTokens.primaryPurpleLight,
                                  onPressed: _openInBrowser,
                                ),
                              ],
                            ),
                          ],
                        ),
                ),
              ),
            ),

            const Divider(color: Colors.white12, height: 1),

            // ── Footer ──────────────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Row(
                children: [
                  Icon(
                    Icons.security_rounded,
                    size: 14,
                    color: Colors.white.withValues(alpha: 0.4),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Tersimpan aman di Supabase Storage PNL',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.4),
                      fontSize: 11,
                    ),
                  ),
                  const Spacer(),
                  TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white70,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 10),
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
}
