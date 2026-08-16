import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../domain/pendaftaran_model.dart';
import '../providers/pendaftaran_provider.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/document_preview_dialog.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Tile upload dokumen dengan status chip dan progress
class UploadDokumenTile extends ConsumerStatefulWidget {
  const UploadDokumenTile({
    super.key,
    required this.dokumen,
    this.isReadOnly = false,
    this.onStatusChanged,
  });

  final DokumenSyarat dokumen;
  final bool isReadOnly;
  final VoidCallback? onStatusChanged;

  @override
  ConsumerState<UploadDokumenTile> createState() => _UploadDokumenTileState();
}

class _UploadDokumenTileState extends ConsumerState<UploadDokumenTile> {
  bool _isUploading = false;

  Color get _statusColor => switch (widget.dokumen.status) {
        StatusDokumen.belumUpload => Colors.white38,
        StatusDokumen.menunggu   => AppTokens.warning,
        StatusDokumen.valid      => AppTokens.success,
        StatusDokumen.tidakValid => AppTokens.error,
      };

  IconData get _statusIcon => switch (widget.dokumen.status) {
        StatusDokumen.belumUpload => Icons.upload_file_rounded,
        StatusDokumen.menunggu   => Icons.hourglass_top_rounded,
        StatusDokumen.valid      => Icons.check_circle_rounded,
        StatusDokumen.tidakValid => Icons.cancel_rounded,
      };

  Future<void> _pickFile() async {
    if (_isUploading) return;

    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['pdf', 'jpg', 'jpeg', 'png'],
      withData: true, // Perlu bytes untuk Supabase Storage upload
    );

    if (result == null || result.files.isEmpty) return;

    final file = result.files.first;
    if (file.bytes == null) return;

    // ── Validasi Batas Ukuran File (Client-Side Pre-Check) ──
    if (file.size > widget.dokumen.maxSizeBytes) {
      final actualSizeStr = _formatSize(file.size);
      final maxSizeStr = widget.dokumen.maxSizeFormatted;

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: const Color(0xFF2E1020),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
              side: const BorderSide(color: AppTokens.error, width: 1.5),
            ),
            content: Row(
              children: [
                const Icon(Icons.error_outline_rounded, color: AppTokens.error, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Ukuran File Melebihi Batas!',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        'File "${file.name}" ($actualSizeStr) terlalu besar. Batas maksimal yang diizinkan adalah $maxSizeStr.',
                        style: const TextStyle(
                          color: Colors.white70,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            duration: const Duration(seconds: 4),
          ),
        );
      }
      return;
    }

    final userId = ref.read(authProvider).user?.id ?? '';
    setState(() => _isUploading = true);

    await ref.read(pendaftaranProvider.notifier).uploadDokumen(
          dokumenId: widget.dokumen.id,
          fileBytes: file.bytes!,
          fileName: file.name,
          fileSize: file.size,
          userId: userId,
        );

    if (mounted) {
      setState(() => _isUploading = false);
      widget.onStatusChanged?.call();
    }
  }

  String _formatSize(int? bytes) {
    if (bytes == null) return '';
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  @override
  Widget build(BuildContext context) {
    final dok = widget.dokumen;
    final isUploaded = dok.isUploaded;

    return GlassCard(
      fillColor: isUploaded
          ? _statusColor.withValues(alpha: 0.05)
          : Colors.white.withValues(alpha: 0.04),
      borderColor: isUploaded
          ? _statusColor.withValues(alpha: 0.3)
          : Colors.white.withValues(alpha: 0.1),
      padding: const EdgeInsets.all(AppTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Nomor / Icon
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                ),
                child: _isUploading
                    ? Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: _statusColor,
                        ),
                      )
                    : Icon(_statusIcon, color: _statusColor, size: 18),
              ),
              const SizedBox(width: AppTokens.spaceSM),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            dok.nama,
                            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        // Badge Batas Ukuran MB
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppTokens.accentGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(6),
                            border: Border.all(
                              color: AppTokens.accentGold.withValues(alpha: 0.35),
                              width: 0.8,
                            ),
                          ),
                          child: Text(
                            'Maks. ${dok.maxSizeFormatted}',
                            style: const TextStyle(
                              color: AppTokens.accentGoldLight,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),
                        ),
                        const SizedBox(width: 6),
                        // Status chip
                        _StatusChip(
                          label: dok.status.label,
                          color: _statusColor,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTokens.spaceXXS),
                    Text(
                      dok.deskripsi,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: Colors.white54,
                          ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          // File info
          if (isUploaded && dok.fileName != null) ...[
            const SizedBox(height: AppTokens.spaceXS),
            const Divider(color: Colors.white10),
            const SizedBox(height: AppTokens.spaceXXS),
            Row(
              children: [
                const Icon(Icons.attach_file_rounded, color: Colors.white38, size: 14),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    dok.fileName!,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white54,
                        ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                if (dok.fileSize != null)
                  Text(
                    _formatSize(dok.fileSize),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white38,
                        ),
                  ),
              ],
            ),
          ],

          // Catatan admin
          if (dok.catatanAdmin != null && dok.catatanAdmin!.isNotEmpty) ...[
            const SizedBox(height: AppTokens.spaceXS),
            Container(
              padding: const EdgeInsets.all(AppTokens.spaceSM),
              decoration: BoxDecoration(
                color: AppTokens.error.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                border: Border.all(color: AppTokens.error.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline_rounded,
                      color: AppTokens.error, size: 14),
                  const SizedBox(width: AppTokens.spaceXS),
                  Expanded(
                    child: Text(
                      dok.catatanAdmin!,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTokens.error,
                          ),
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Upload & Preview buttons
          if (!widget.isReadOnly) ...[
            const SizedBox(height: AppTokens.spaceSM),
            Row(
              children: [
                if (isUploaded && dok.filePath != null) ...[
                  Expanded(
                    child: OutlinedButton.icon(
                      onPressed: () {
                        showDialog(
                          context: context,
                          builder: (ctx) => DocumentPreviewDialog(
                            title: dok.nama,
                            fileUrl: dok.filePath!,
                            fileName: dok.fileName,
                          ),
                        );
                      },
                      icon: const Icon(Icons.visibility_rounded, size: 15),
                      label: const Text(
                        'Buka Berkas 👁️',
                        style: TextStyle(fontSize: AppTokens.textXS),
                      ),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppTokens.primaryPurpleLight,
                        side: BorderSide(
                          color: AppTokens.primaryPurpleLight.withValues(alpha: 0.5),
                        ),
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTokens.spaceMD,
                          vertical: AppTokens.spaceXS,
                        ),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTokens.spaceXS),
                ],
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _isUploading ? null : _pickFile,
                    icon: Icon(
                      isUploaded ? Icons.refresh_rounded : Icons.upload_rounded,
                      size: 16,
                    ),
                    label: Text(
                      _isUploading
                          ? 'Mengupload...'
                          : isUploaded
                              ? 'Ganti File'
                              : 'Upload File (PDF / JPG / PNG)',
                      style: const TextStyle(fontSize: AppTokens.textXS),
                    ),
                    style: OutlinedButton.styleFrom(
                      foregroundColor:
                          isUploaded ? AppTokens.success : Colors.white70,
                      side: BorderSide(
                        color: isUploaded
                            ? AppTokens.success.withValues(alpha: 0.5)
                            : Colors.white24,
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.spaceMD,
                        vertical: AppTokens.spaceXS,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ] else if (isUploaded && dok.filePath != null) ...[
            const SizedBox(height: AppTokens.spaceSM),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  showDialog(
                    context: context,
                    builder: (ctx) => DocumentPreviewDialog(
                      title: dok.nama,
                      fileUrl: dok.filePath!,
                      fileName: dok.fileName,
                    ),
                  );
                },
                icon: const Icon(Icons.visibility_rounded, size: 15),
                label: const Text(
                  'Buka Berkas 👁️',
                  style: TextStyle(fontSize: AppTokens.textXS),
                ),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTokens.primaryPurpleLight,
                  side: BorderSide(
                    color: AppTokens.primaryPurpleLight.withValues(alpha: 0.5),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTokens.spaceMD,
                    vertical: AppTokens.spaceXS,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                  ),
                ),
              ),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }
}

class _StatusChip extends StatelessWidget {
  const _StatusChip({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTokens.radiusCircle),
        border: Border.all(color: color.withValues(alpha: 0.4)),
      ),
      child: Text(
        label,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
