import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/admin_provider.dart';
import '../../domain/admin_models.dart';
import '../../domain/auto_verification_service.dart';
import '../../data/admin_repository.dart';
import '../../../pendaftaran_yudisium/domain/pendaftaran_model.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/glass_button.dart';
import '../../../../shared/widgets/sidebar_aware_scaffold.dart';
import '../../../../shared/widgets/document_preview_dialog.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../pendaftaran_yudisium/presentation/widgets/prodi_badge_widget.dart';
import 'package:go_router/go_router.dart';

class VerifikasiBerkasScreen extends ConsumerStatefulWidget {
  const VerifikasiBerkasScreen({super.key, this.pendaftaranId});
  final String? pendaftaranId;

  @override
  ConsumerState<VerifikasiBerkasScreen> createState() =>
      _VerifikasiBerkasScreenState();
}

class _VerifikasiBerkasScreenState extends ConsumerState<VerifikasiBerkasScreen> {
  String _selectedFilter = 'semua';
  bool _isBatchProcessing = false;

  Future<void> _runBatchAutoVerify() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1B1630),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          side: const BorderSide(color: Colors.white12),
        ),
        title: const Row(
          children: [
            Icon(Icons.auto_awesome_rounded,
                color: AppTokens.accentGold, size: 24),
            SizedBox(width: 10),
            Text('Auto-Verifikasi Sistem (Massal)',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: const Text(
          'Sistem akan memeriksa kelengkapan, format biner, kesesuaian kata kunci, dan aturan akademik seluruh berkas pendaftaran mahasiswa secara otomatis.\n\nApakah Anda ingin menjalankan proses ini sekarang?',
          style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Batal'),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.primaryPurple,
            ),
            icon: const Icon(Icons.play_arrow_rounded, size: 18),
            label: const Text('Mulai Auto-Verifikasi'),
            onPressed: () => Navigator.pop(ctx, true),
          ),
        ],
      ),
    );

    if (confirm != true || !mounted) return;

    setState(() => _isBatchProcessing = true);
    try {
      final repo = AdminRepository();
      final result = await repo.batchAutoVerifyAll();
      await ref.read(adminProvider.notifier).loadAll();

      if (mounted) {
        showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            backgroundColor: const Color(0xFF1B1630),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTokens.radiusLG),
              side: const BorderSide(color: Colors.white12),
            ),
            title: const Row(
              children: [
                Icon(Icons.verified_rounded,
                    color: AppTokens.success, size: 24),
                SizedBox(width: 10),
                Text('Auto-Verifikasi Selesai! 🎉',
                    style: TextStyle(color: Colors.white, fontSize: 16)),
              ],
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Total Mahasiswa Diproses: ${result["total"]}',
                  style: const TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    const Icon(Icons.check_circle_rounded,
                        color: AppTokens.success, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Disetujui Otomatis: ${result["auto_approved"]} mahasiswa',
                      style: const TextStyle(color: AppTokens.success),
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.flag_rounded,
                        color: AppTokens.warning, size: 16),
                    const SizedBox(width: 6),
                    Text(
                      'Perlu Peninjauan Manual: ${result["flagged"]} mahasiswa',
                      style: const TextStyle(color: AppTokens.warning),
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(ctx),
                child: const Text('Selesai'),
              ),
            ],
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            backgroundColor: AppTokens.error,
            content: Text('Gagal menjalankan auto-verifikasi: $e'),
          ),
        );
      }
    } finally {
      if (mounted) setState(() => _isBatchProcessing = false);
    }
  } // 'semua', 'review', 'disetujui', 'revisi', 'draft'

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(adminProvider);

    // Jika ada ID spesifik, tampilkan detail
    if (widget.pendaftaranId != null) {
      final pa = state.pendaftaranList
          .where((p) => p.pendaftaran.id == widget.pendaftaranId)
          .firstOrNull;
      if (pa == null) {
        return SidebarAwareScaffold(
          location: '/admin/yudisium',
          mobileAppBar: const GlassAppBar(title: 'Detail Berkas'),
          body: AnimatedBackground(
            child: const Center(
              child: Text('Data pendaftaran tidak ditemukan',
                  style: TextStyle(color: Colors.white54)),
            ),
          ),
        );
      }
      return _buildDetail(context, pa);
    }

    // Filter daftar pendaftaran
    final filteredList = state.pendaftaranList.where((pa) {
      final s = pa.pendaftaran.status;
      if (_selectedFilter == 'review') {
        return s == StatusPendaftaran.submitted ||
            s == StatusPendaftaran.diverifikasi;
      }
      if (_selectedFilter == 'disetujui') {
        return s == StatusPendaftaran.disetujui;
      }
      if (_selectedFilter == 'revisi') {
        return s == StatusPendaftaran.revisi;
      }
      if (_selectedFilter == 'draft') {
        return s == StatusPendaftaran.draft;
      }
      return true;
    }).toList();

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SidebarAwareScaffold(
        location: '/admin/yudisium',
        mobileAppBar: const GlassAppBar(title: 'Verifikasi Berkas Yudisium'),
        body: AnimatedBackground(
          child: SafeArea(
            top: !context.isDesktop && !context.isTablet,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 960),
                child: Column(
                  children: [
                    // Header & Filter Tabs
                    Padding(
                      padding: const EdgeInsets.fromLTRB(
                          AppTokens.spaceMD, AppTokens.spaceMD, AppTokens.spaceMD, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Text(
                                'Verifikasi Berkas Yudisium',
                                style: Theme.of(context)
                                    .textTheme
                                    .titleLarge
                                    ?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w800,
                                    ),
                              ),
                              const Spacer(),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTokens.accentGold
                                      .withValues(alpha: 0.15),
                                  foregroundColor: AppTokens.accentGold,
                                  side: BorderSide(
                                    color: AppTokens.accentGold
                                        .withValues(alpha: 0.6),
                                    width: 1.2,
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 12, vertical: 8),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                ),
                                icon: _isBatchProcessing
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                            strokeWidth: 2,
                                            color: AppTokens.accentGold),
                                      )
                                    : const Icon(Icons.auto_awesome_rounded,
                                        size: 16),
                                label: Text(
                                  _isBatchProcessing
                                      ? 'Memproses...'
                                      : '⚡ Auto-Verifikasi Sistem (Batch)',
                                  style: const TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                ),
                                onPressed: _isBatchProcessing
                                    ? null
                                    : _runBatchAutoVerify,
                              ),
                              const SizedBox(width: 8),
                              IconButton(
                                tooltip: 'Muat Ulang',
                                icon: const Icon(Icons.refresh_rounded,
                                    color: Colors.white70),
                                onPressed: () =>
                                    ref.read(adminProvider.notifier).loadAll(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          // Filter Pill Chips
                          SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip(
                                    'Semua (${state.pendaftaranList.length})',
                                    'semua'),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                    'Perlu Review (${state.pendaftaranList.where((p) => p.pendaftaran.status == StatusPendaftaran.submitted || p.pendaftaran.status == StatusPendaftaran.diverifikasi).length})',
                                    'review',
                                    color: AppTokens.accentGold),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                    'Disetujui (${state.pendaftaranList.where((p) => p.pendaftaran.status == StatusPendaftaran.disetujui).length})',
                                    'disetujui',
                                    color: AppTokens.success),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                    'Perlu Revisi (${state.pendaftaranList.where((p) => p.pendaftaran.status == StatusPendaftaran.revisi).length})',
                                    'revisi',
                                    color: AppTokens.error),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                    'Draft (${state.pendaftaranList.where((p) => p.pendaftaran.status == StatusPendaftaran.draft).length})',
                                    'draft',
                                    color: Colors.white54),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: AppTokens.spaceMD),

                    // List Items
                    Expanded(
                      child: filteredList.isEmpty
                          ? Center(
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(Icons.folder_open_rounded,
                                      size: 56,
                                      color: Colors.white.withValues(alpha: 0.2)),
                                  const SizedBox(height: 12),
                                  Text(
                                    'Tidak ada berkas pada kategori ini',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyLarge
                                        ?.copyWith(color: Colors.white54),
                                  ),
                                ],
                              ),
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.all(AppTokens.spaceMD),
                              physics: const ClampingScrollPhysics(),
                              itemCount: filteredList.length,
                              separatorBuilder: (_, _) =>
                                  const SizedBox(height: AppTokens.spaceMD),
                              itemBuilder: (ctx, i) {
                                final pa = filteredList[i];
                                return _PendaftaranListTile(
                                  pa: pa,
                                  onTap: () => context.push(
                                      '/admin/yudisium/${pa.pendaftaran.id}'),
                                ).animate().fadeIn(delay: (i * 60).ms);
                              },
                            ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip(String label, String value, {Color? color}) {
    final isSelected = _selectedFilter == value;
    final activeColor = color ?? AppTokens.primaryPurpleLight;
    return GestureDetector(
      onTap: () => setState(() => _selectedFilter = value),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.2)
              : Colors.white.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(AppTokens.radiusSM),
          border: Border.all(
            color: isSelected ? activeColor : Colors.white12,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, PendaftaranAdmin pa) {
    final p = pa.pendaftaran;
    final user = pa.mahasiswa;
    final applicableDocs = p.dokumenApplicable;

    final validCount =
        applicableDocs.where((d) => d.status == StatusDokumen.valid).length;
    final invalidCount =
        applicableDocs.where((d) => d.status == StatusDokumen.tidakValid).length;
    final allValid = applicableDocs.isNotEmpty &&
        applicableDocs.every((d) => d.status == StatusDokumen.valid);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SidebarAwareScaffold(
        location: '/admin/yudisium',
        mobileAppBar: GlassAppBar(title: 'Verifikasi: ${user.nama}'),
        body: AnimatedBackground(
          child: SafeArea(
            top: !context.isDesktop && !context.isTablet,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              padding: const EdgeInsets.all(AppTokens.spaceMD),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Mahasiswa Info Card
                      GlassCard(
                        padding: const EdgeInsets.all(AppTokens.spaceMD),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                CircleAvatar(
                                  radius: 28,
                                  backgroundColor: ProdiBadgeWidget.colorFor(
                                          user.programStudi.value)
                                      .withValues(alpha: 0.2),
                                  child: Text(
                                    user.nama.isNotEmpty ? user.nama[0] : 'M',
                                    style: TextStyle(
                                      color: ProdiBadgeWidget.colorFor(
                                          user.programStudi.value),
                                      fontWeight: FontWeight.w800,
                                      fontSize: 22,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppTokens.spaceMD),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        user.nama,
                                        style: Theme.of(context)
                                            .textTheme
                                            .titleLarge
                                            ?.copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w700,
                                            ),
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        'NIM: ${user.nim}  •  ${user.programStudi.label} (${p.jenjang.value})',
                                        style: const TextStyle(
                                            color: Colors.white70, fontSize: 13),
                                      ),
                                      Text(
                                        'IPK: ${p.ipk}  •  Total SKS: ${p.totalSks}  •  Semester: ${p.semester}',
                                        style: const TextStyle(
                                            color: Colors.white54, fontSize: 12),
                                      ),
                                    ],
                                  ),
                                ),
                                ProdiBadgeWidget(
                                  programStudi: user.programStudi.value,
                                  size: ProdiBadgeSize.chip,
                                ),
                              ],
                            ),
                            if (p.biodata.judulTga != null &&
                                p.biodata.judulTga!.isNotEmpty) ...[
                              const Divider(color: Colors.white12, height: 24),
                              Text(
                                'Judul TGA / Skripsi:',
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.5),
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              const SizedBox(height: 2),
                              Text(
                                p.biodata.judulTga!,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w500,
                                  fontStyle: FontStyle.italic,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ).animate().fadeIn(duration: 350.ms),
                      const SizedBox(height: AppTokens.spaceLG),

                      // ── Card Analisis Auto-Verifikasi Sistem ──────────────
                      () {
                        final autoSummary =
                            AutoVerificationService.verifyRegistration(pa);
                        final score = autoSummary.overallScore;
                        final isHighConfidence = score >= 75;

                        return GlassCard(
                          padding: const EdgeInsets.all(AppTokens.spaceMD),
                          fillColor: isHighConfidence
                              ? AppTokens.success.withValues(alpha: 0.08)
                              : AppTokens.warning.withValues(alpha: 0.08),
                          borderColor: isHighConfidence
                              ? AppTokens.success.withValues(alpha: 0.3)
                              : AppTokens.warning.withValues(alpha: 0.3),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(
                                    isHighConfidence
                                        ? Icons.auto_awesome_rounded
                                        : Icons.warning_amber_rounded,
                                    color: isHighConfidence
                                        ? AppTokens.success
                                        : AppTokens.warning,
                                    size: 22,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          'Analisis Sistem Verifikasi Otomatis',
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall
                                              ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                        Text(
                                          'Skor Kelayakan Berkas: $score% • ${isHighConfidence ? "Direkomendasikan Lolos Otomatis" : "Perlu Peninjauan Manual"}',
                                          style: TextStyle(
                                            color: isHighConfidence
                                                ? AppTokens.success
                                                : AppTokens.warning,
                                            fontSize: 12,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTokens.primaryPurple,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 10, vertical: 6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                      ),
                                    ),
                                    icon: const Icon(
                                        Icons.check_circle_outline_rounded,
                                        size: 14),
                                    label: const Text(
                                      'Terapkan Rekomendasi ⚡',
                                      style: TextStyle(
                                          fontSize: 11,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    onPressed: () async {
                                      final repo = AdminRepository();
                                      await repo.autoVerifyRegistration(pa);
                                      await ref
                                          .read(adminProvider.notifier)
                                          .loadAll();
                                      if (context.mounted) {
                                        ScaffoldMessenger.of(context)
                                            .showSnackBar(
                                          const SnackBar(
                                            content: Text(
                                                'Hasil verifikasi otomatis berhasil diterapkan ✅'),
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                ],
                              ),
                              if (autoSummary.academicWarnings.isNotEmpty) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(6),
                                  decoration: BoxDecoration(
                                    color: AppTokens.error
                                        .withValues(alpha: 0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    'Peringatan Akademik: ${autoSummary.academicWarnings.join(", ")}',
                                    style: const TextStyle(
                                        color: AppTokens.error, fontSize: 11),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        );
                      }(),
                      const SizedBox(height: AppTokens.spaceMD),

                      // Progress Bar & Dokumen Checklist Header
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Kelengkapan Berkas (${applicableDocs.length} Dokumen)',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Valid: $validCount  •  Revisi: $invalidCount  •  Total: ${applicableDocs.length}',
                                  style: const TextStyle(
                                      color: Colors.white54, fontSize: 12),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppTokens.spaceMD),

                      // List 12 Dokumen Syarat
                      ...applicableDocs.asMap().entries.map((e) {
                        final dok = e.value;
                        return _DokumenVerifikasiTile(
                          dokumen: dok,
                          nim: user.nim,
                          namaMahasiswa: user.nama,
                          jenjang: p.jenjang,
                          tinggalDiAsrama: p.tinggalDiAsrama,
                          onVerify: (status, catatan) {
                            ref
                                .read(adminProvider.notifier)
                                .verifikasiDokumen(
                                  pendaftaranId: p.id,
                                  dokumenId: dok.id,
                                  status: status,
                                  catatan: catatan,
                                );
                          },
                        )
                            .animate()
                            .fadeIn(delay: (e.key * 60).ms, duration: 250.ms);
                      }),
                      const SizedBox(height: AppTokens.spaceLG),

                      // ── Card Keputusan Akhir Verifikasi ──────────────────
                      GlassCard(
                        padding: const EdgeInsets.all(AppTokens.spaceLG),
                        fillColor: AppTokens.primaryPurple.withValues(alpha: 0.1),
                        borderColor:
                            AppTokens.primaryPurple.withValues(alpha: 0.3),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.gavel_rounded,
                                    color: AppTokens.accentGold, size: 20),
                                const SizedBox(width: 8),
                                Text(
                                  'Keputusan Akhir Pendaftaran Yudisium',
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 8),
                            Text(
                              allValid
                                  ? 'Semua berkas persyaratan telah divalidasi. Anda dapat menyetujui pendaftaran yudisium mahasiswa ini.'
                                  : 'Periksa seluruh berkas di atas dengan tombol "Buka Berkas". Berikan catatan jika ada berkas yang perlu diperbaiki.',
                              style: const TextStyle(
                                  color: Colors.white70, fontSize: 12),
                            ),
                            const SizedBox(height: AppTokens.spaceMD),
                            Row(
                              children: [
                                // Tombol Minta Revisi
                                Expanded(
                                  child: GlassButton(
                                    label: 'Minta Revisi Berkas',
                                    icon: Icons.edit_note_rounded,
                                    variant: GlassButtonVariant.outlined,
                                    color: AppTokens.warning,
                                    onPressed: () => _showMintaRevisiDialog(
                                      context,
                                      p.id,
                                      user.id,
                                      user.nama,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: AppTokens.spaceMD),
                                // Tombol Setujui Pendaftaran
                                Expanded(
                                  child: GlassButton(
                                    label: 'Setujui Yudisium 🎉',
                                    icon: Icons.check_circle_rounded,
                                    color: AppTokens.success,
                                    onPressed: () => _konfirmasiSetujui(
                                      context,
                                      p.id,
                                      user.id,
                                      user.nama,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms, duration: 400.ms),
                      const SizedBox(height: AppTokens.spaceXL),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _konfirmasiSetujui(BuildContext context, String pendaftaranId,
      String userId, String namaMahasiswa) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16122C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          side: const BorderSide(color: AppTokens.glassBorderColor),
        ),
        title: const Row(
          children: [
            Icon(Icons.verified_rounded, color: AppTokens.success),
            SizedBox(width: 8),
            Text('Setujui Pendaftaran?',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Text(
          'Apakah Anda yakin ingin MENYETUJUI pendaftaran yudisium atas nama $namaMahasiswa? Mahasiswa akan mendapatkan notifikasi kelulusan berkas yudisium.',
          style: const TextStyle(color: Colors.white70, fontSize: 13),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          GlassButton(
            label: 'Ya, Setujui',
            icon: Icons.check_rounded,
            color: AppTokens.success,
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(adminProvider.notifier).setujuiPendaftaran(
                    pendaftaranId: pendaftaranId,
                    userId: userId,
                    namaMahasiswa: namaMahasiswa,
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Pendaftaran yudisium $namaMahasiswa berhasil disetujui!'),
                  backgroundColor: AppTokens.success,
                ),
              );
              context.pop();
            },
          ),
        ],
      ),
    );
  }

  void _showMintaRevisiDialog(BuildContext context, String pendaftaranId,
      String userId, String namaMahasiswa) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16122C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          side: const BorderSide(color: AppTokens.glassBorderColor),
        ),
        title: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: AppTokens.warning),
            SizedBox(width: 8),
            Text('Instruksi Revisi Berkas',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tuliskan catatan revisi untuk $namaMahasiswa:',
              style: const TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white),
              maxLines: 4,
              decoration: InputDecoration(
                hintText:
                    'Contoh: Pas foto harus berlatar belakang merah, scan transkrip buram...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          GlassButton(
            label: 'Kirim Permintaan',
            icon: Icons.send_rounded,
            color: AppTokens.warning,
            onPressed: () {
              Navigator.pop(ctx);
              ref.read(adminProvider.notifier).mintaRevisiPendaftaran(
                    pendaftaranId: pendaftaranId,
                    userId: userId,
                    namaMahasiswa: namaMahasiswa,
                    catatan: ctrl.text.trim().isNotEmpty
                        ? ctrl.text.trim()
                        : null,
                  );
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Permintaan revisi berhasil dikirim ke $namaMahasiswa'),
                  backgroundColor: AppTokens.warning,
                ),
              );
              context.pop();
            },
          ),
        ],
      ),
    );
  }
}

class _PendaftaranListTile extends StatelessWidget {
  const _PendaftaranListTile({required this.pa, this.onTap});
  final PendaftaranAdmin pa;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final p = pa.pendaftaran;
    final u = pa.mahasiswa;
    final statusColor = _colorForStatus(p.status);

    return GlassCard(
      onTap: onTap,
      padding: const EdgeInsets.all(AppTokens.spaceMD),
      child: Row(
        children: [
          CircleAvatar(
            radius: 20,
            backgroundColor:
                ProdiBadgeWidget.colorFor(u.programStudi.value).withValues(alpha: 0.2),
            child: Text(
              u.nama.isNotEmpty ? u.nama[0] : 'M',
              style: TextStyle(
                color: ProdiBadgeWidget.colorFor(u.programStudi.value),
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          const SizedBox(width: AppTokens.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(u.nama,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: Colors.white, fontWeight: FontWeight.w600)),
                Text('${u.nim} • ${p.jenjang.value} • IPK ${p.ipk}',
                    style: Theme.of(context)
                        .textTheme
                        .bodySmall
                        ?.copyWith(color: Colors.white54)),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTokens.radiusCircle),
              border: Border.all(color: statusColor.withValues(alpha: 0.4)),
            ),
            child: Text(
              p.status.label,
              style: TextStyle(
                color: statusColor,
                fontSize: 11,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _colorForStatus(StatusPendaftaran s) => switch (s) {
        StatusPendaftaran.submitted    => AppTokens.info,
        StatusPendaftaran.diverifikasi => AppTokens.warning,
        StatusPendaftaran.revisi       => AppTokens.warning,
        StatusPendaftaran.disetujui    => AppTokens.success,
        StatusPendaftaran.ditolak      => AppTokens.error,
        _                              => Colors.white38,
      };
}

class _DokumenVerifikasiTile extends StatelessWidget {
  const _DokumenVerifikasiTile({
    required this.dokumen,
    required this.nim,
    required this.namaMahasiswa,
    required this.jenjang,
    required this.tinggalDiAsrama,
    required this.onVerify,
  });

  final DokumenSyarat dokumen;
  final String nim;
  final String namaMahasiswa;
  final Jenjang jenjang;
  final bool tinggalDiAsrama;
  final void Function(StatusDokumen status, String? catatan) onVerify;

  Color get _statusColor => switch (dokumen.status) {
        StatusDokumen.belumUpload => Colors.white38,
        StatusDokumen.menunggu   => AppTokens.warning,
        StatusDokumen.valid      => AppTokens.success,
        StatusDokumen.tidakValid => AppTokens.error,
      };

  void _openPreview(BuildContext context) {
    if (dokumen.filePath == null) return;
    showDialog(
      context: context,
      builder: (ctx) => DocumentPreviewDialog(
        title: dokumen.nama,
        fileUrl: dokumen.filePath!,
        fileName: dokumen.fileName,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final autoResult = AutoVerificationService.verifyDocument(
      doc: dokumen,
      nim: nim,
      namaMahasiswa: namaMahasiswa,
      jenjang: jenjang,
      tinggalDiAsrama: tinggalDiAsrama,
    );

    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.spaceMD),
      child: GlassCard(
        fillColor: _statusColor.withValues(alpha: 0.05),
        borderColor: _statusColor.withValues(alpha: 0.25),
        padding: const EdgeInsets.all(AppTokens.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Baris Judul & Status Badge
            Row(
              children: [
                Icon(
                  dokumen.isUploaded
                      ? Icons.insert_drive_file_rounded
                      : Icons.block_rounded,
                  color: _statusColor,
                  size: 20,
                ),
                const SizedBox(width: AppTokens.spaceXS),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        dokumen.nama,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                      if (dokumen.deskripsi.isNotEmpty)
                        Text(
                          dokumen.deskripsi,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.5),
                            fontSize: 11,
                          ),
                        ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTokens.radiusCircle),
                    border:
                        Border.all(color: _statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    dokumen.status.label,
                    style: TextStyle(
                      color: _statusColor,
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),

            // Smart System Score Pill
            if (dokumen.isUploaded) ...[
              const SizedBox(height: 8),
              Wrap(
                spacing: 6,
                runSpacing: 4,
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                    decoration: BoxDecoration(
                      color: (autoResult.confidenceScore >= 75
                              ? AppTokens.success
                              : AppTokens.warning)
                          .withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: (autoResult.confidenceScore >= 75
                                ? AppTokens.success
                                : AppTokens.warning)
                            .withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          autoResult.confidenceScore >= 75
                              ? Icons.auto_awesome_rounded
                              : Icons.warning_amber_rounded,
                          size: 11,
                          color: autoResult.confidenceScore >= 75
                              ? AppTokens.success
                              : AppTokens.warning,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          'Skor Sistem: ${autoResult.confidenceScore}%',
                          style: TextStyle(
                            color: autoResult.confidenceScore >= 75
                                ? AppTokens.success
                                : AppTokens.warning,
                            fontSize: 10.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  ...autoResult.passedChecks.take(2).map((check) => Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 3),
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.05),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          '✓ $check',
                          style: const TextStyle(
                              color: Colors.white60, fontSize: 10),
                        ),
                      )),
                ],
              ),
              if (autoResult.warnings.isNotEmpty) ...[
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: AppTokens.warning.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.info_outline_rounded,
                          color: AppTokens.warning, size: 12),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          autoResult.warnings.first,
                          style: const TextStyle(
                              color: AppTokens.warning, fontSize: 10.5),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],

            if (dokumen.fileName != null) ...[
              const SizedBox(height: 6),
              Row(
                children: [
                  const Icon(Icons.attachment_rounded,
                      size: 13, color: Colors.white38),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${dokumen.fileName} ${dokumen.fileSizeFormatted.isNotEmpty ? "(${dokumen.fileSizeFormatted})" : ""}',
                      style: const TextStyle(color: Colors.white54, fontSize: 11),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ],

            if (dokumen.catatanAdmin != null &&
                dokumen.catatanAdmin!.isNotEmpty) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppTokens.error.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(
                      color: AppTokens.error.withValues(alpha: 0.3)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.info_outline_rounded,
                        color: AppTokens.error, size: 14),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        'Catatan: ${dokumen.catatanAdmin!}',
                        style: const TextStyle(
                            color: AppTokens.error, fontSize: 11),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            // Action Buttons (Buka Berkas, Valid, Revisi)
            if (dokumen.isUploaded) ...[
              const SizedBox(height: 12),
              Row(
                children: [
                  // Tombol Buka / Preview Berkas
                  Expanded(
                    child: GlassButton(
                      label: 'Buka Berkas 👁️',
                      icon: Icons.visibility_rounded,
                      variant: GlassButtonVariant.outlined,
                      size: GlassButtonSize.small,
                      color: AppTokens.primaryPurpleLight,
                      onPressed: () => _openPreview(context),
                    ),
                  ),
                  const SizedBox(width: AppTokens.spaceXS),
                  // Tombol Tandai Tidak Valid
                  Expanded(
                    child: GlassButton(
                      label: 'Revisi ❌',
                      icon: Icons.close_rounded,
                      variant: GlassButtonVariant.outlined,
                      size: GlassButtonSize.small,
                      color: AppTokens.error,
                      onPressed: () => _showCatatanDialog(
                        context,
                        StatusDokumen.tidakValid,
                        autoResult.autoDraftedNote,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTokens.spaceXS),
                  // Tombol Tandai Valid
                  Expanded(
                    child: GlassButton(
                      label: 'Valid ✅',
                      icon: Icons.check_rounded,
                      size: GlassButtonSize.small,
                      color: AppTokens.success,
                      onPressed: () => onVerify(StatusDokumen.valid, null),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  void _showCatatanDialog(
      BuildContext context, StatusDokumen status, String? suggestedNote) {
    final ctrl = TextEditingController(
        text: dokumen.catatanAdmin?.isNotEmpty == true
            ? dokumen.catatanAdmin!
            : suggestedNote ?? '');
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF16122C),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          side: const BorderSide(color: AppTokens.glassBorderColor),
        ),
        title: const Row(
          children: [
            Icon(Icons.edit_note_rounded, color: AppTokens.error),
            SizedBox(width: 8),
            Text('Catatan Revisi Dokumen',
                style: TextStyle(color: Colors.white, fontSize: 16)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Alasan dokumen "${dokumen.nama}" perlu direvisi:',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            if (suggestedNote != null) ...[
              const SizedBox(height: 6),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppTokens.primaryPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  '💡 Draf catatan otomatis telah diisi dari hasil analisis sistem.',
                  style: TextStyle(
                      color: AppTokens.primaryPurpleLight, fontSize: 10.5),
                ),
              ),
            ],
            const SizedBox(height: 8),
            TextField(
              controller: ctrl,
              style: const TextStyle(color: Colors.white),
              maxLines: 3,
              decoration: InputDecoration(
                hintText: 'Contoh: File tidak terbaca / scan terpotong...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 12),
                filled: true,
                fillColor: Colors.white.withValues(alpha: 0.05),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: Colors.white24),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          GlassButton(
            label: 'Simpan Catatan',
            icon: Icons.check_rounded,
            color: AppTokens.error,
            onPressed: () {
              onVerify(status, ctrl.text.trim());
              Navigator.pop(ctx);
            },
          ),
        ],
      ),
    );
  }
}

