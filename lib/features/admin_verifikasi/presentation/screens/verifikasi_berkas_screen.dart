import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/admin_provider.dart';
import '../../domain/admin_models.dart';
import '../../../pendaftaran_yudisium/domain/pendaftaran_model.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/glass_button.dart';
import '../../../../shared/widgets/sidebar_aware_scaffold.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../pendaftaran_yudisium/presentation/widgets/prodi_badge_widget.dart';
import 'package:go_router/go_router.dart';

class VerifikasiBerkasScreen extends ConsumerWidget {
  const VerifikasiBerkasScreen({super.key, this.pendaftaranId});
  final String? pendaftaranId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminProvider);

    // Jika ada ID spesifik, tampilkan detail
    if (pendaftaranId != null) {
      final pa = state.pendaftaranList
          .where((p) => p.pendaftaran.id == pendaftaranId)
          .firstOrNull;
      if (pa == null) {
        return SidebarAwareScaffold(
          location: '/admin/yudisium',
          mobileAppBar: const GlassAppBar(title: 'Detail Berkas'),
          body: AnimatedBackground(
            child: const Center(
              child: Text('Data tidak ditemukan', style: TextStyle(color: Colors.white54)),
            ),
          ),
        );
      }
      return _buildDetail(context, ref, pa);
    }

    // List semua pendaftaran
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SidebarAwareScaffold(
        location: '/admin/yudisium',
        mobileAppBar: const GlassAppBar(title: 'Verifikasi Berkas'),
        body: AnimatedBackground(
          child: SafeArea(
            top: !context.isDesktop && !context.isTablet,
            child: state.pendaftaranList.isEmpty
                ? Center(
                    child: Text(
                      'Belum ada pendaftaran',
                      style: Theme.of(context)
                          .textTheme
                          .bodyLarge
                          ?.copyWith(color: Colors.white54),
                    ),
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 900),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppTokens.spaceMD),
                        physics: const ClampingScrollPhysics(),
                        itemCount: state.pendaftaranList.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppTokens.spaceMD),
                        itemBuilder: (ctx, i) {
                          final pa = state.pendaftaranList[i];
                          return _PendaftaranListTile(
                            pa: pa,
                            onTap: () => context.push(
                                '/admin/yudisium/${pa.pendaftaran.id}'),
                          ).animate().fadeIn(delay: (i * 100).ms);
                        },
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildDetail(BuildContext context, WidgetRef ref, PendaftaranAdmin pa) {
    final p = pa.pendaftaran;
    final user = pa.mahasiswa;
    final applicableDocs = p.dokumenApplicable;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SidebarAwareScaffold(
        location: '/admin/yudisium',
        mobileAppBar: GlassAppBar(title: 'Berkas ${user.nama}'),
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
                      // Mahasiswa info
                      GlassCard(
                    padding: const EdgeInsets.all(AppTokens.spaceMD),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 24,
                          backgroundColor:
                              ProdiBadgeWidget.colorFor(user.programStudi.value)
                                  .withValues(alpha: 0.2),
                          child: Text(
                            user.nama[0],
                            style: TextStyle(
                              color: ProdiBadgeWidget.colorFor(user.programStudi.value),
                              fontWeight: FontWeight.w800,
                              fontSize: 20,
                            ),
                          ),
                        ),
                        const SizedBox(width: AppTokens.spaceMD),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(user.nama,
                                  style: Theme.of(context)
                                      .textTheme
                                      .titleMedium
                                      ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w600)),
                              Text('NIM: ${user.nim} • IPK: ${p.ipk}',
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.white54)),
                            ],
                          ),
                        ),
                        ProdiBadgeWidget(
                            programStudi: user.programStudi.value,
                            size: ProdiBadgeSize.chip),
                      ],
                    ),
                  ).animate().fadeIn(duration: 400.ms),
                  const SizedBox(height: AppTokens.spaceLG),

                  // Dokumen checklist
                  Text(
                    'Dokumen (${applicableDocs.length} item)',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                  const SizedBox(height: AppTokens.spaceMD),
                  ...applicableDocs.asMap().entries.map((e) {
                    final dok = e.value;
                    return _DokumenVerifikasiTile(
                      dokumen: dok,
                      onVerify: (status, catatan) {
                        ref.read(adminProvider.notifier).verifikasiDokumen(
                              pendaftaranId: p.id,
                              dokumenId: dok.id,
                              status: status,
                              catatan: catatan,
                            );
                      },
                    )
                        .animate()
                        .fadeIn(delay: (e.key * 80).ms, duration: 300.ms);
                  }),
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
            child: Text(u.nama[0],
                style: TextStyle(
                    color: ProdiBadgeWidget.colorFor(u.programStudi.value),
                    fontWeight: FontWeight.w800)),
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
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: statusColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTokens.radiusCircle),
              border: Border.all(color: statusColor.withValues(alpha: 0.4)),
            ),
            child: Text(p.status.label,
                style: TextStyle(
                    color: statusColor, fontSize: 10, fontWeight: FontWeight.w600)),
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
  const _DokumenVerifikasiTile({required this.dokumen, required this.onVerify});
  final DokumenSyarat dokumen;
  final void Function(StatusDokumen status, String? catatan) onVerify;

  Color get _statusColor => switch (dokumen.status) {
        StatusDokumen.belumUpload => Colors.white38,
        StatusDokumen.menunggu   => AppTokens.warning,
        StatusDokumen.valid      => AppTokens.success,
        StatusDokumen.tidakValid => AppTokens.error,
      };

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTokens.spaceMD),
      child: GlassCard(
        fillColor: _statusColor.withValues(alpha: 0.05),
        borderColor: _statusColor.withValues(alpha: 0.25),
        padding: const EdgeInsets.all(AppTokens.spaceMD),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  dokumen.isUploaded ? Icons.insert_drive_file_rounded : Icons.block_rounded,
                  color: _statusColor,
                  size: 18,
                ),
                const SizedBox(width: AppTokens.spaceXS),
                Expanded(
                  child: Text(
                    dokumen.nama,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: _statusColor.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTokens.radiusCircle),
                    border: Border.all(color: _statusColor.withValues(alpha: 0.4)),
                  ),
                  child: Text(
                    dokumen.status.label,
                    style: TextStyle(
                        color: _statusColor,
                        fontSize: 10,
                        fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (dokumen.fileName != null) ...[
              const SizedBox(height: AppTokens.spaceXXS),
              Text(
                '📎 ${dokumen.fileName}',
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white38),
              ),
            ],
            if (dokumen.isUploaded && dokumen.status == StatusDokumen.menunggu) ...[
              const SizedBox(height: AppTokens.spaceSM),
              Row(
                children: [
                  Expanded(
                    child: GlassButton(
                      label: 'Tidak Valid',
                      icon: Icons.close_rounded,
                      variant: GlassButtonVariant.outlined,
                      size: GlassButtonSize.small,
                      color: AppTokens.error,
                      onPressed: () => _showCatatanDialog(context, StatusDokumen.tidakValid),
                    ),
                  ),
                  const SizedBox(width: AppTokens.spaceXS),
                  Expanded(
                    child: GlassButton(
                      label: 'Valid',
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

  void _showCatatanDialog(BuildContext context, StatusDokumen status) {
    final ctrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTokens.bgDarkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          side: const BorderSide(color: AppTokens.glassBorderColor),
        ),
        title: const Text('Catatan', style: TextStyle(color: Colors.white)),
        content: TextField(
          controller: ctrl,
          style: const TextStyle(color: Colors.white),
          maxLines: 3,
          decoration: const InputDecoration(
            hintText: 'Alasan dokumen tidak valid...',
            hintStyle: TextStyle(color: Colors.white38),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          TextButton(
            onPressed: () {
              onVerify(status, ctrl.text);
              Navigator.pop(ctx);
            },
            child: const Text('Simpan', style: TextStyle(color: AppTokens.error)),
          ),
        ],
      ),
    );
  }
}
