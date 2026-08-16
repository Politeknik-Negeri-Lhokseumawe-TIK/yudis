import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/admin_provider.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/glass_button.dart';
import '../../../../shared/widgets/sidebar_aware_scaffold.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../pendaftaran_yudisium/presentation/widgets/prodi_badge_widget.dart';

class RekapScreen extends ConsumerWidget {
  const RekapScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(adminProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SidebarAwareScaffold(
        location: '/admin/rekap',
        mobileAppBar: const GlassAppBar(title: 'Rekap Peserta'),
        body: AnimatedBackground(
          child: SafeArea(
            top: !context.isDesktop && !context.isTablet,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTokens.spaceMD),
              physics: const ClampingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1000),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Rekap Peserta Yudisium',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ).animate().fadeIn(),
                      const SizedBox(height: AppTokens.spaceXS),
                      Text(
                        'Periode: Semester Genap 2025/2026  •  Batas: 26 Agt 2026',
                        style: Theme.of(context)
                            .textTheme
                            .bodyMedium
                            ?.copyWith(color: Colors.white54),
                      ).animate().fadeIn(delay: 100.ms),
                      const SizedBox(height: AppTokens.spaceLG),

                      // Summary stats
                      Row(
                        children: [
                          Expanded(
                            child: GlassStatCard(
                              title: 'Total',
                              value: '${state.pendaftaranList.length}',
                              icon: Icons.people_outline_rounded,
                              color: AppTokens.info,
                            ),
                          ),
                          const SizedBox(width: AppTokens.spaceMD),
                          Expanded(
                            child: GlassStatCard(
                              title: 'Disetujui',
                              value: '${state.stats['disetujui'] ?? 0}',
                              icon: Icons.verified_rounded,
                              color: AppTokens.success,
                            ),
                          ),
                        ],
                      ).animate().fadeIn(delay: 200.ms),
                      const SizedBox(height: AppTokens.spaceLG),

                      // Table
                      GlassCard(
                        padding: const EdgeInsets.all(AppTokens.spaceMD),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.table_chart_outlined,
                                    color: AppTokens.primaryGreenLight, size: 20),
                                const SizedBox(width: AppTokens.spaceXS),
                                Expanded(
                                  child: Text(
                                    'Daftar Peserta',
                                    style: Theme.of(context)
                                        .textTheme
                                        .titleLarge
                                        ?.copyWith(
                                          color: Colors.white,
                                          fontWeight: FontWeight.w700,
                                        ),
                                  ),
                                ),
                                GlassButton(
                                  label: 'Ekspor',
                                  icon: Icons.download_rounded,
                                  size: GlassButtonSize.small,
                                  variant: GlassButtonVariant.outlined,
                                  isFullWidth: false,
                                  onPressed: () {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      const SnackBar(
                                          content: Text(
                                              'Ekspor akan tersedia di versi mendatang')),
                                    );
                                  },
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTokens.spaceMD),

                            if (state.pendaftaranList.isEmpty)
                              Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(AppTokens.spaceXL),
                                  child: Text(
                                    'Belum ada peserta',
                                    style: Theme.of(context)
                                        .textTheme
                                        .bodyMedium
                                        ?.copyWith(color: Colors.white38),
                                  ),
                                ),
                              )
                            else
                              // Table header
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppTokens.spaceXS,
                                    horizontal: AppTokens.spaceSM),
                                decoration: BoxDecoration(
                                  color: Colors.white.withValues(alpha: 0.05),
                                  borderRadius:
                                      BorderRadius.circular(AppTokens.radiusSM),
                                ),
                                child: Row(
                                  children: [
                                    _tableHeader(context, 'No', flex: 1),
                                    _tableHeader(context, 'Nama', flex: 4),
                                    _tableHeader(context, 'NIM', flex: 3),
                                    _tableHeader(context, 'Prodi', flex: 2),
                                    _tableHeader(context, 'Status', flex: 3),
                                  ],
                                ),
                              ),

                            ...state.pendaftaranList.asMap().entries.map((e) {
                              final pa = e.value;
                              return Container(
                                padding: const EdgeInsets.symmetric(
                                    vertical: AppTokens.spaceXS,
                                    horizontal: AppTokens.spaceSM),
                                decoration: BoxDecoration(
                                  border: Border(
                                    bottom: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.05)),
                                  ),
                                ),
                                child: Row(
                                  children: [
                                    Expanded(
                                      flex: 1,
                                      child: Text(
                                        '${e.key + 1}',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.white54),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 4,
                                      child: Text(
                                        pa.mahasiswa.nama,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w500),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        pa.mahasiswa.nim,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(color: Colors.white54),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 2,
                                      child: ProdiBadgeWidget(
                                        programStudi:
                                            pa.mahasiswa.programStudi.value,
                                        size: ProdiBadgeSize.chip,
                                      ),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Text(
                                        pa.pendaftaran.status.label,
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodySmall
                                            ?.copyWith(
                                                color: Colors.white54,
                                                fontSize: 10),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ).animate().fadeIn(delay: 300.ms),
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

  Widget _tableHeader(BuildContext context, String label, {int flex = 1}) {
    return Expanded(
      flex: flex,
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: Colors.white38,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.5,
            ),
      ),
    );
  }
}
