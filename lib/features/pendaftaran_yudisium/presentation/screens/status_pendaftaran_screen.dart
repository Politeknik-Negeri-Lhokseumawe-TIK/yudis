import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../presentation/providers/pendaftaran_provider.dart';
import '../../domain/pendaftaran_model.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/glass_button.dart';
import '../../../../shared/widgets/sidebar_aware_scaffold.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_tokens.dart';

class StatusPendaftaranScreen extends ConsumerWidget {
  const StatusPendaftaranScreen({super.key, this.id});
  final String? id;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(pendaftaranProvider);
    final pendaftaran = state.pendaftaran;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SidebarAwareScaffold(
        location: '/mahasiswa/status',
        mobileAppBar: const GlassAppBar(title: 'Status Pendaftaran'),
        body: AnimatedBackground(
          child: SafeArea(
            top: !context.isDesktop && !context.isTablet,
            child: pendaftaran == null
                ? _buildEmpty(context)
                : SingleChildScrollView(
                    physics: const ClampingScrollPhysics(),
                    padding: EdgeInsets.symmetric(
                      horizontal: context.horizontalPadding,
                      vertical: context.verticalPadding,
                    ),
                    child: Center(
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 900),
                        child: Column(
                          children: [
                            _buildStatusHero(context, pendaftaran),
                            const SizedBox(height: AppTokens.spaceLG),
                            _buildTimeline(context, pendaftaran),
                            const SizedBox(height: AppTokens.spaceLG),
                            _buildDokumenSummary(context, pendaftaran),
                            if (pendaftaran.catatanAdmin != null &&
                                pendaftaran.catatanAdmin!.isNotEmpty) ...[
                              const SizedBox(height: AppTokens.spaceLG),
                              _buildCatatanAdmin(
                                  context, pendaftaran.catatanAdmin!),
                            ],
                            const SizedBox(height: AppTokens.spaceLG),
                            _buildActionButtons(context, pendaftaran),
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

  Widget _buildEmpty(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTokens.spaceLG),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: GlassCard(
            padding: const EdgeInsets.all(AppTokens.spaceXL),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 88,
                  height: 88,
                  decoration: BoxDecoration(
                    color: AppTokens.primaryGreenLight.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: AppTokens.primaryGreenLight.withValues(alpha: 0.3),
                      width: 2,
                    ),
                  ),
                  child: const Icon(
                    Icons.assignment_outlined,
                    color: AppTokens.primaryGreenLight,
                    size: 44,
                  ),
                ),
                const SizedBox(height: AppTokens.spaceLG),
                Text(
                  'Belum Ada Pendaftaran',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w800,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTokens.spaceSM),
                Text(
                  'Kamu belum mengajukan berkas pendaftaran yudisium. Silakan lengkapi biodata, data akademik, dan unggah 12 dokumen persyaratan.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white70,
                        height: 1.5,
                      ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppTokens.spaceXL),
                GlassButton(
                  label: 'Daftar Yudisium Sekarang',
                  icon: Icons.app_registration_rounded,
                  isFullWidth: true,
                  onPressed: () => context.go('/mahasiswa/daftar'),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 400.ms).scale(
                begin: const Offset(0.95, 0.95),
                end: const Offset(1, 1),
              ),
        ),
      ),
    );
  }

  Widget _buildStatusHero(BuildContext context, PendaftaranYudisium p) {
    final color = _statusColor(p.status);
    final icon = _statusIcon(p.status);

    return GlassCard(
      fillColor: color.withValues(alpha: 0.08),
      borderColor: color.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(AppTokens.spaceXL),
      child: Column(
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: color.withValues(alpha: 0.15),
              border: Border.all(color: color.withValues(alpha: 0.4), width: 2),
            ),
            child: Icon(icon, color: color, size: 40),
          ),
          const SizedBox(height: AppTokens.spaceMD),
          Text(
            p.status.label,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
          ),
          if (p.submittedAt != null) ...[
            const SizedBox(height: AppTokens.spaceXXS),
            Text(
              'Diajukan: ${DateFormat('d MMMM yyyy, HH:mm', 'id_ID').format(p.submittedAt!)} WIB',
              style: Theme.of(context)
                  .textTheme
                  .bodySmall
                  ?.copyWith(color: Colors.white60),
            ),
          ],
          const SizedBox(height: AppTokens.spaceLG),
          // Upload progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Kelengkapan Berkas Dokumen',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white70,
                          fontWeight: FontWeight.w500,
                        ),
                  ),
                  Text(
                    '${p.dokumenTerUpload}/${p.totalDokumenWajib} Dokumen',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTokens.primaryGreenLight,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              const SizedBox(height: AppTokens.spaceXS),
              ClipRRect(
                borderRadius: BorderRadius.circular(AppTokens.radiusCircle),
                child: LinearProgressIndicator(
                  value: p.uploadProgress,
                  backgroundColor: Colors.white12,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    p.uploadProgress >= 1.0
                        ? AppTokens.success
                        : AppTokens.primaryGreenLight,
                  ),
                  minHeight: 8,
                ),
              ),
            ],
          ),
        ],
      ),
    )
        .animate()
        .fadeIn(duration: 500.ms)
        .scale(begin: const Offset(0.95, 0.95), end: const Offset(1, 1));
  }

  Widget _buildTimeline(BuildContext context, PendaftaranYudisium p) {
    final events = <_TimelineEvent>[
      _TimelineEvent(
        title: 'Akun Terverifikasi',
        subtitle: 'Akun mahasiswa aktif & disetujui admin',
        icon: Icons.how_to_reg_rounded,
        color: AppTokens.success,
        isCompleted: true,
        time: p.submittedAt?.subtract(const Duration(days: 1)),
      ),
      _TimelineEvent(
        title: 'Formulir Diajukan',
        subtitle: p.submittedAt != null
            ? 'Semua data dan dokumen telah dikirim'
            : 'Menunggu pengajuan formulir',
        icon: Icons.send_rounded,
        color: AppTokens.info,
        isCompleted: p.submittedAt != null,
        isActive: p.status == StatusPendaftaran.submitted,
        time: p.submittedAt,
      ),
      _TimelineEvent(
        title: 'Verifikasi Berkas',
        subtitle: p.status == StatusPendaftaran.revisi
            ? 'Terdapat dokumen yang perlu diperbaiki'
            : 'Admin memeriksa keabsahan 12 berkas',
        icon: Icons.manage_search_rounded,
        color: p.status == StatusPendaftaran.revisi
            ? AppTokens.warning
            : AppTokens.info,
        isCompleted: p.status == StatusPendaftaran.disetujui ||
            p.status == StatusPendaftaran.ditolak,
        isActive: p.status == StatusPendaftaran.diverifikasi ||
            p.status == StatusPendaftaran.revisi,
        time: p.verifiedAt,
      ),
      _TimelineEvent(
        title: p.status == StatusPendaftaran.ditolak
            ? 'Pendaftaran Ditolak'
            : 'Pendaftaran Disetujui',
        subtitle: p.status == StatusPendaftaran.ditolak
            ? 'Pendaftaran tidak memenuhi syarat yudisium'
            : 'Selamat! Terdaftar resmi sebagai peserta yudisium',
        icon: p.status == StatusPendaftaran.ditolak
            ? Icons.cancel_rounded
            : Icons.verified_rounded,
        color: p.status == StatusPendaftaran.ditolak
            ? AppTokens.error
            : AppTokens.success,
        isCompleted: p.status == StatusPendaftaran.disetujui ||
            p.status == StatusPendaftaran.ditolak,
        isActive: p.status == StatusPendaftaran.disetujui,
        time: p.verifiedAt,
      ),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(AppTokens.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.timeline_rounded,
                  color: AppTokens.primaryGreenLight, size: 20),
              const SizedBox(width: AppTokens.spaceXS),
              Text(
                'Alur & Riwayat Proses',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceLG),
          ...events.asMap().entries.map((e) {
            final isLast = e.key == events.length - 1;
            return _TimelineTile(event: e.value, isLast: isLast);
          }),
        ],
      ),
    ).animate().fadeIn(delay: 200.ms, duration: 400.ms);
  }

  Widget _buildDokumenSummary(BuildContext context, PendaftaranYudisium p) {
    final applicable = p.dokumenApplicable;
    final valid =
        applicable.where((d) => d.status == StatusDokumen.valid).length;
    final invalid =
        applicable.where((d) => d.status == StatusDokumen.tidakValid).length;
    final menunggu =
        applicable.where((d) => d.status == StatusDokumen.menunggu).length;
    final belum =
        applicable.where((d) => d.status == StatusDokumen.belumUpload).length;

    return GlassCard(
      padding: const EdgeInsets.all(AppTokens.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.folder_outlined,
                      color: AppTokens.primaryGreenLight, size: 20),
                  const SizedBox(width: AppTokens.spaceXS),
                  Text(
                    'Daftar Berkas Dokumen',
                    style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w700,
                        ),
                  ),
                ],
              ),
              Text(
                '${applicable.length} Syarat',
                style: const TextStyle(
                  color: Colors.white54,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceLG),
          // Stat chips row
          Row(
            children: [
              _DokStat(count: valid, label: 'Valid', color: AppTokens.success),
              const SizedBox(width: AppTokens.spaceSM),
              _DokStat(
                  count: menunggu,
                  label: 'Menunggu',
                  color: AppTokens.warning),
              const SizedBox(width: AppTokens.spaceSM),
              _DokStat(
                  count: invalid,
                  label: 'Revisi',
                  color: AppTokens.error),
              const SizedBox(width: AppTokens.spaceSM),
              _DokStat(count: belum, label: 'Belum', color: Colors.white38),
            ],
          ),
          const SizedBox(height: AppTokens.spaceLG),
          const Divider(color: Colors.white12),
          const SizedBox(height: AppTokens.spaceSM),
          // List of individual documents with status
          ...applicable.map((doc) => _buildDocTile(context, doc)),
        ],
      ),
    ).animate().fadeIn(delay: 300.ms);
  }

  Widget _buildDocTile(BuildContext context, DokumenSyarat doc) {
    final (chipColor, chipText, chipIcon) = switch (doc.status) {
      StatusDokumen.valid => (
          AppTokens.success,
          'Valid',
          Icons.check_circle_rounded
        ),
      StatusDokumen.tidakValid => (
          AppTokens.error,
          'Perlu Revisi',
          Icons.cancel_rounded
        ),
      StatusDokumen.menunggu => (
          AppTokens.warning,
          'Menunggu',
          Icons.hourglass_empty_rounded
        ),
      StatusDokumen.belumUpload => (
          Colors.white38,
          'Belum Upload',
          Icons.cloud_upload_outlined
        ),
    };

    return Container(
      margin: const EdgeInsets.only(bottom: AppTokens.spaceSM),
      padding: const EdgeInsets.all(AppTokens.spaceMD),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        border: Border.all(color: Colors.white12),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTokens.spaceXS),
            decoration: BoxDecoration(
              color: chipColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(AppTokens.radiusSM),
            ),
            child: Icon(chipIcon, color: chipColor, size: 18),
          ),
          const SizedBox(width: AppTokens.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doc.nama,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
                if (doc.catatanAdmin != null && doc.catatanAdmin!.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(
                    'Catatan: ${doc.catatanAdmin}',
                    style: TextStyle(
                      color: AppTokens.warning.withValues(alpha: 0.9),
                      fontSize: 12,
                    ),
                  ),
                ],
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: chipColor.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTokens.radiusCircle),
              border: Border.all(color: chipColor.withValues(alpha: 0.3)),
            ),
            child: Text(
              chipText,
              style: TextStyle(
                color: chipColor,
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCatatanAdmin(BuildContext context, String catatan) {
    return GlassCard(
      fillColor: AppTokens.warning.withValues(alpha: 0.08),
      borderColor: AppTokens.warning.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(AppTokens.spaceLG),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.feedback_outlined,
              color: AppTokens.warning, size: 24),
          const SizedBox(width: AppTokens.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Catatan Tim Verifikator',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        color: AppTokens.warning,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: AppTokens.spaceXS),
                Text(
                  catatan,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: Colors.white,
                        height: 1.5,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 400.ms);
  }

  Widget _buildActionButtons(BuildContext context, PendaftaranYudisium p) {
    return Row(
      children: [
        if (p.status == StatusPendaftaran.draft ||
            p.status == StatusPendaftaran.revisi)
          Expanded(
            child: GlassButton(
              label: p.status == StatusPendaftaran.revisi
                  ? 'Perbaiki Berkas / Unggah Ulang'
                  : 'Lanjutkan Pengisian Berkas',
              icon: Icons.edit_document,
              onPressed: () => context.go('/mahasiswa/daftar'),
            ),
          ),
        if (p.status == StatusPendaftaran.disetujui)
          Expanded(
            child: GlassButton(
              label: 'Unduh Bukti Pendaftaran',
              icon: Icons.download_rounded,
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                        'Bukti tanda terima pendaftaran yudisium berhasil diproses.'),
                    backgroundColor: AppTokens.primaryGreenLight,
                  ),
                );
              },
            ),
          ),
      ],
    );
  }

  Color _statusColor(StatusPendaftaran s) => switch (s) {
        StatusPendaftaran.draft => Colors.white54,
        StatusPendaftaran.submitted => AppTokens.info,
        StatusPendaftaran.diverifikasi => AppTokens.warning,
        StatusPendaftaran.revisi => AppTokens.warning,
        StatusPendaftaran.disetujui => AppTokens.success,
        StatusPendaftaran.ditolak => AppTokens.error,
      };

  IconData _statusIcon(StatusPendaftaran s) => switch (s) {
        StatusPendaftaran.draft => Icons.edit_outlined,
        StatusPendaftaran.submitted => Icons.send_rounded,
        StatusPendaftaran.diverifikasi => Icons.manage_search_rounded,
        StatusPendaftaran.revisi => Icons.rate_review_outlined,
        StatusPendaftaran.disetujui => Icons.verified_rounded,
        StatusPendaftaran.ditolak => Icons.cancel_rounded,
      };
}

class _TimelineEvent {
  const _TimelineEvent({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.isCompleted,
    this.isActive = false,
    this.time,
  });
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final bool isCompleted;
  final bool isActive;
  final DateTime? time;
}

class _TimelineTile extends StatelessWidget {
  const _TimelineTile({required this.event, required this.isLast});
  final _TimelineEvent event;
  final bool isLast;

  @override
  Widget build(BuildContext context) {
    final color = event.isCompleted || event.isActive
        ? event.color
        : Colors.white24;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Line + dot
          Column(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: 0.15),
                  border: Border.all(color: color, width: 2),
                ),
                child: Icon(event.icon, color: color, size: 14),
              ),
              if (!isLast)
                Expanded(
                  child: Container(
                    width: 2,
                    margin: const EdgeInsets.symmetric(vertical: 4),
                    color: event.isCompleted
                        ? event.color.withValues(alpha: 0.5)
                        : Colors.white12,
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppTokens.spaceMD),

          // Content
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : AppTokens.spaceMD),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          event.title,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: event.isCompleted || event.isActive
                                        ? Colors.white
                                        : Colors.white38,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                      if (event.isActive)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: event.color.withValues(alpha: 0.15),
                            borderRadius:
                                BorderRadius.circular(AppTokens.radiusCircle),
                            border: Border.all(
                                color: event.color.withValues(alpha: 0.4)),
                          ),
                          child: Text(
                            'AKTIF',
                            style: TextStyle(
                              color: event.color,
                              fontSize: 9,
                              fontWeight: FontWeight.w700,
                              letterSpacing: 1,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 2),
                  Text(
                    event.subtitle,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Colors.white38,
                        ),
                  ),
                  if (event.time != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      DateFormat('d MMM yyyy, HH:mm', 'id_ID')
                          .format(event.time!),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: event.color.withValues(alpha: 0.6),
                            fontSize: 10,
                          ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DokStat extends StatelessWidget {
  const _DokStat(
      {required this.count, required this.label, required this.color});
  final int count;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: AppTokens.spaceSM),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTokens.radiusMD),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          children: [
            Text(
              '$count',
              style: TextStyle(
                color: color,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: color.withValues(alpha: 0.8),
                fontSize: 11,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
