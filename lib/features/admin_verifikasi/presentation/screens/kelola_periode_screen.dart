import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../pendaftaran_yudisium/presentation/providers/pendaftaran_provider.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/glass_button.dart';
import '../../../../shared/widgets/sidebar_aware_scaffold.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_tokens.dart';

class KelolaPeriodeScreen extends ConsumerWidget {
  const KelolaPeriodeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final periode = ref.watch(periodeAktifProvider);
    final fmt = DateFormat('d MMMM yyyy');

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SidebarAwareScaffold(
        location: '/admin/periode',
        mobileAppBar: const GlassAppBar(title: 'Kelola Periode'),
        body: AnimatedBackground(
          child: SafeArea(
            top: !context.isDesktop && !context.isTablet,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTokens.spaceMD),
              physics: const ClampingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 900),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Periode Yudisium',
                        style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ).animate().fadeIn(),
                      const SizedBox(height: AppTokens.spaceLG),

                      // Active periode
                      if (periode != null)
                        GlassCard(
                          fillColor: AppTokens.success.withValues(alpha: 0.06),
                          borderColor: AppTokens.success.withValues(alpha: 0.3),
                          padding: const EdgeInsets.all(AppTokens.spaceLG),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Container(
                                    padding: const EdgeInsets.all(AppTokens.spaceXS),
                                    decoration: BoxDecoration(
                                      color: AppTokens.success.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                                    ),
                                    child: const Icon(Icons.event_available_rounded,
                                        color: AppTokens.success, size: 20),
                                  ),
                                  const SizedBox(width: AppTokens.spaceSM),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: AppTokens.success.withValues(alpha: 0.15),
                                      borderRadius: BorderRadius.circular(AppTokens.radiusCircle),
                                      border: Border.all(color: AppTokens.success.withValues(alpha: 0.4)),
                                    ),
                                    child: const Text(
                                      'AKTIF',
                                      style: TextStyle(
                                        color: AppTokens.success,
                                        fontSize: 10,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: 1,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: AppTokens.spaceMD),
                              Text(
                                periode.nama,
                                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                              const SizedBox(height: AppTokens.spaceXS),
                              _infoRow(context, 'Mulai',
                                  fmt.format(periode.tanggalMulai)),
                              _infoRow(context, 'Berakhir',
                                  fmt.format(periode.tanggalSelesai)),
                              if (periode.deskripsi != null) ...[
                                const SizedBox(height: AppTokens.spaceXS),
                                Text(
                                  periode.deskripsi!,
                                  style: Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.copyWith(color: Colors.white38),
                                ),
                              ],
                              const SizedBox(height: AppTokens.spaceLG),
                              GlassButton(
                                label: 'Tutup Periode',
                                icon: Icons.event_busy_rounded,
                                variant: GlassButtonVariant.outlined,
                                color: AppTokens.error,
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(
                                        content: Text(
                                            'Fitur tutup periode akan tersedia di versi mendatang')),
                                  );
                                },
                              ),
                            ],
                          ),
                        ).animate().fadeIn(delay: 200.ms).slideY(begin: 0.2, end: 0),

                      const SizedBox(height: AppTokens.spaceLG),

                      // Buat periode baru
                      GlassCard(
                        padding: const EdgeInsets.all(AppTokens.spaceLG),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                const Icon(Icons.add_circle_outline_rounded,
                                    color: AppTokens.accentGold, size: 20),
                                const SizedBox(width: AppTokens.spaceXS),
                                Text(
                                  'Buat Periode Baru',
                                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w700,
                                      ),
                                ),
                              ],
                            ),
                            const SizedBox(height: AppTokens.spaceMD),
                            Text(
                              'Periode baru akan menggantikan periode aktif saat ini. '
                              'Pastikan periode sebelumnya sudah ditutup.',
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.copyWith(color: Colors.white54),
                            ),
                            const SizedBox(height: AppTokens.spaceMD),
                            GlassButton(
                              label: 'Buat Periode Baru',
                              icon: Icons.add_rounded,
                              variant: GlassButtonVariant.outlined,
                              color: AppTokens.accentGold,
                              onPressed: () {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(
                                      content: Text(
                                          'Form buat periode akan tersedia di versi mendatang')),
                                );
                              },
                            ),
                          ],
                        ),
                      ).animate().fadeIn(delay: 400.ms),

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

  Widget _infoRow(BuildContext context, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Row(
        children: [
          SizedBox(
            width: 70,
            child: Text(label,
                style: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.copyWith(color: Colors.white38)),
          ),
          Text(value,
              style: Theme.of(context)
                  .textTheme
                  .bodyMedium
                  ?.copyWith(color: Colors.white, fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}
