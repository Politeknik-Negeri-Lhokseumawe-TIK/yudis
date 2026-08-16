import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../presentation/providers/pendaftaran_provider.dart';
import '../../domain/pendaftaran_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/domain/user_model.dart';
import '../../../notifikasi/presentation/screens/notifikasi_screen.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/countdown_timer_widget.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/sidebar_aware_scaffold.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_tokens.dart';
import '../widgets/prodi_badge_widget.dart';

class DashboardMahasiswaScreen extends ConsumerWidget {
  const DashboardMahasiswaScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final pendaftaranState = ref.watch(pendaftaranProvider);
    final notifsAsync = ref.watch(notifikasiStreamProvider);
    final unreadNotifs = notifsAsync.value?.where((n) => !n.isRead).length ?? 0;
    final isDesktop = context.isDesktopWithSidebar;
    final isTablet = context.isTablet;

    // Target deadline 26 Agustus 2026
    final targetDeadline = pendaftaranState.periode?.tanggalSelesai ?? DateTime(2026, 8, 26);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SidebarAwareScaffold(
        location: '/mahasiswa/dashboard',
        mobileAppBar: GlassAppBar(
          showBackButton: false,
          titleWidget: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTokens.spaceXXS),
                decoration: BoxDecoration(
                  color: AppTokens.primaryGreen.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                ),
                child: const Icon(
                  Icons.school_rounded,
                  color: AppTokens.primaryGreenLight,
                  size: 22,
                ),
              ),
              const SizedBox(width: AppTokens.spaceXS),
              Text(
                'Yudisium TIK PNL',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          actions: [
            IconButton(
              onPressed: () => context.push('/mahasiswa/notifikasi'),
              icon: Badge(
                isLabelVisible: unreadNotifs > 0,
                label: Text('$unreadNotifs',
                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),
                backgroundColor: AppTokens.error,
                child: const Icon(Icons.notifications_outlined, color: Colors.white),
              ),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
              color: AppTokens.bgDarkCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMD),
              ),
              onSelected: (value) async {
                if (value == 'logout') {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                }
              },
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      Icon(Icons.logout_rounded, color: Colors.white70, size: 18),
                      SizedBox(width: 8),
                      Text('Keluar', style: TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: AnimatedBackground(
          child: SafeArea(
            top: !isDesktop && !isTablet,
            child: SingleChildScrollView(
              physics: const ClampingScrollPhysics(),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: Breakpoints.maxContentWidth),
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: context.horizontalPadding,
                      vertical: context.verticalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (isDesktop || isTablet) const SizedBox(height: AppTokens.spaceXS),

                        // ── Banner: Menunggu Verifikasi Admin ─────────────
                        if (ref.watch(authProvider).isPendingVerifikasi)
                          _buildPendingVerifikasiBanner(context)
                              .animate()
                              .fadeIn(duration: 400.ms)
                              .slideY(begin: -0.15, end: 0),

                        if (ref.watch(authProvider).isPendingVerifikasi)
                          const SizedBox(height: AppTokens.spaceLG),

                        // ── Hero Greeting + Academic Stats ───────────────
                        _buildHeroGreeting(context, user, pendaftaranState)
                            .animate()
                            .fadeIn(duration: 400.ms)
                            .slideY(begin: -0.1, end: 0),

                        const SizedBox(height: AppTokens.spaceLG),

                        // ── Main Content: 2-Column on Desktop ────────────
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Column (Status & Timeline + Countdown + Info)
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    _buildInteractiveStatusCard(context, pendaftaranState)
                                        .animate()
                                        .fadeIn(delay: 200.ms, duration: 400.ms),
                                    const SizedBox(height: AppTokens.spaceLG),
                                    CountdownTimerWidget(targetDate: targetDeadline)
                                        .animate()
                                        .fadeIn(delay: 300.ms, duration: 400.ms),
                                    const SizedBox(height: AppTokens.spaceLG),
                                    _buildInfoCard(context)
                                        .animate()
                                        .fadeIn(delay: 400.ms),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppTokens.spaceLG),
                              // Right Column (2x2 Quick Action Grid)
                              Expanded(
                                flex: 2,
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        Container(
                                          padding: const EdgeInsets.all(AppTokens.spaceXS),
                                          decoration: BoxDecoration(
                                            color: AppTokens.primaryPurple.withValues(alpha: 0.15),
                                            borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                                          ),
                                          child: const Icon(Icons.dashboard_customize_rounded,
                                              color: AppTokens.primaryPurpleLight, size: 18),
                                        ),
                                        const SizedBox(width: AppTokens.spaceSM),
                                        Text(
                                          'Menu Cepat',
                                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                                color: Colors.white,
                                                fontWeight: FontWeight.w700,
                                              ),
                                        ),
                                      ],
                                    ).animate().fadeIn(delay: 250.ms),
                                    const SizedBox(height: AppTokens.spaceMD),
                                    _buildQuickActionsGrid(context, pendaftaranState)
                                        .animate()
                                        .fadeIn(delay: 350.ms, duration: 400.ms),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else ...[
                          _buildInteractiveStatusCard(context, pendaftaranState)
                              .animate()
                              .fadeIn(delay: 200.ms, duration: 400.ms)
                              .slideY(begin: 0.1, end: 0),

                          const SizedBox(height: AppTokens.spaceLG),

                          CountdownTimerWidget(targetDate: targetDeadline)
                              .animate()
                              .fadeIn(delay: 300.ms, duration: 400.ms),

                          const SizedBox(height: AppTokens.spaceLG),

                          Text(
                            'Menu Cepat',
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                          ).animate().fadeIn(delay: 350.ms),

                          const SizedBox(height: AppTokens.spaceMD),

                          _buildQuickActionsGrid(context, pendaftaranState)
                              .animate()
                              .fadeIn(delay: 400.ms, duration: 400.ms),

                          const SizedBox(height: AppTokens.spaceLG),

                          _buildInfoCard(context).animate().fadeIn(delay: 500.ms),
                        ],

                        const SizedBox(height: AppTokens.spaceXL),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ── Hero Greeting + Mini Academic Stat Cards ─────────────────────
  Widget _buildHeroGreeting(BuildContext context, User? user, PendaftaranState state) {
    final hour = DateTime.now().hour;
    final greeting = hour < 11
        ? 'Selamat Pagi'
        : hour < 15
            ? 'Selamat Siang'
            : hour < 18
                ? 'Selamat Sore'
                : 'Selamat Malam';

    final ipk = state.pendaftaran?.ipk ?? 3.85;
    final sks = state.pendaftaran?.totalSks ?? 144;
    final sem = state.pendaftaran?.semester ?? 8;

    return GlassCard(
      padding: const EdgeInsets.all(AppTokens.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          greeting,
                          style: const TextStyle(
                            color: AppTokens.accentGoldLight,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Container(
                          width: 4,
                          height: 4,
                          decoration: const BoxDecoration(
                            color: Colors.white38,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'NIM: ${user?.nim ?? "2021903430045"}',
                          style: const TextStyle(color: Colors.white54, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user?.nama ?? 'Mahasiswa',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: context.isDesktop ? 28 : 22,
                          ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              if (user != null)
                ProdiBadgeWidget(
                  programStudi: user.programStudi.value,
                  size: ProdiBadgeSize.large,
                ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceMD),
          const Divider(color: AppTokens.glassBorderColor, height: 1),
          const SizedBox(height: AppTokens.spaceMD),

          // 3 Mini Academic Stat Cards
          Row(
            children: [
              Expanded(
                child: _buildMiniStat(
                  context: context,
                  label: 'Indeks Prestasi (IPK)',
                  value: ipk.toStringAsFixed(2),
                  icon: Icons.auto_graph_rounded,
                  color: AppTokens.accentGoldLight,
                ),
              ),
              const SizedBox(width: AppTokens.spaceMD),
              Expanded(
                child: _buildMiniStat(
                  context: context,
                  label: 'Total SKS Lulus',
                  value: '$sks SKS',
                  icon: Icons.school_outlined,
                  color: AppTokens.primaryPurpleLight,
                ),
              ),
              const SizedBox(width: AppTokens.spaceMD),
              Expanded(
                child: _buildMiniStat(
                  context: context,
                  label: 'Semester Akhir',
                  value: 'Semester $sem',
                  icon: Icons.calendar_today_outlined,
                  color: AppTokens.info,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMiniStat({
    required BuildContext context,
    required String label,
    required String value,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(6),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 16),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  value,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: context.isDesktop ? 15 : 13,
                  ),
                ),
                Text(
                  label,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── Interactive Glowing Timeline Status Card ─────────────────────
  Widget _buildInteractiveStatusCard(BuildContext context, PendaftaranState state) {
    final hasPendaftaran = state.pendaftaran != null;
    final status = state.pendaftaran?.status ?? StatusPendaftaran.draft;
    final step = hasPendaftaran ? status.step : 0;
    final progress = state.pendaftaran?.uploadProgress ?? 0.0;
    final uploadedDocs = state.pendaftaran?.dokumenTerUpload ?? 0;
    final totalDocs = state.pendaftaran?.totalDokumenWajib ?? 8;

    final steps = [
      ('Diajukan', Icons.send_rounded),
      ('Diverifikasi', Icons.manage_search_rounded),
      ('Selesai', Icons.verified_rounded),
    ];

    return GlassCard(
      padding: const EdgeInsets.all(AppTokens.spaceLG),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTokens.spaceXS),
                decoration: BoxDecoration(
                  color: AppTokens.primaryPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                ),
                child: const Icon(Icons.assignment_outlined,
                    color: AppTokens.primaryPurpleLight, size: 20),
              ),
              const SizedBox(width: AppTokens.spaceSM),
              Text(
                'Progres Pendaftaran Yudisium',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: _statusColor(status).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTokens.radiusCircle),
                  border: Border.all(color: _statusColor(status).withValues(alpha: 0.4)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: BoxDecoration(
                        color: _statusColor(status),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      status.label,
                      style: TextStyle(
                        color: _statusColor(status),
                        fontSize: 11,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceLG),

          // Glowing Step Timeline
          Row(
            children: List.generate(steps.length * 2 - 1, (i) {
              if (i.isOdd) {
                final stepIdx = i ~/ 2;
                final isActive = stepIdx < step;
                return Expanded(
                  child: Container(
                    height: 3,
                    decoration: BoxDecoration(
                      color: isActive ? AppTokens.primaryPurpleLight : Colors.white12,
                      borderRadius: BorderRadius.circular(2),
                      boxShadow: isActive
                          ? [
                              BoxShadow(
                                color: AppTokens.primaryPurpleLight.withValues(alpha: 0.6),
                                blurRadius: 6,
                              ),
                            ]
                          : null,
                    ),
                  ),
                );
              }
              final stepIdx = i ~/ 2;
              final isCompleted = stepIdx < step;
              final isCurrent = stepIdx == step - 1;
              final (label, icon) = steps[stepIdx];

              return Column(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: BoxDecoration(
                      gradient: isCompleted || isCurrent
                          ? const LinearGradient(
                              colors: [AppTokens.primaryPurple, AppTokens.primaryPurpleGlow],
                            )
                          : null,
                      color: isCompleted || isCurrent ? null : Colors.white10,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: isCompleted || isCurrent
                            ? AppTokens.primaryPurpleGlow
                            : Colors.white24,
                        width: 2,
                      ),
                      boxShadow: isCurrent
                          ? [
                              BoxShadow(
                                color: AppTokens.primaryPurple.withValues(alpha: 0.6),
                                blurRadius: 12,
                                spreadRadius: 2,
                              ),
                            ]
                          : null,
                    ),
                    child: Icon(
                      icon,
                      size: 20,
                      color: isCompleted || isCurrent ? Colors.white : Colors.white38,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    label,
                    style: TextStyle(
                      color: isCompleted || isCurrent ? Colors.white : Colors.white38,
                      fontSize: 11,
                      fontWeight: isCurrent ? FontWeight.bold : FontWeight.w500,
                    ),
                  ),
                ],
              );
            }),
          ),
          const SizedBox(height: AppTokens.spaceLG),

          // Document Upload Progress Bar
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.03),
              borderRadius: BorderRadius.circular(AppTokens.radiusMD),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Kelengkapan Dokumen Persyaratan',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    Text(
                      '$uploadedDocs dari $totalDocs Dokumen (${(progress * 100).toInt()}%)',
                      style: const TextStyle(
                        color: AppTokens.accentGoldLight,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(4),
                  child: TweenAnimationBuilder<double>(
                    tween: Tween<double>(begin: 0.0, end: progress),
                    duration: const Duration(milliseconds: 800),
                    curve: Curves.easeOutCubic,
                    builder: (context, val, child) {
                      return LinearProgressIndicator(
                        value: val,
                        minHeight: 8,
                        backgroundColor: Colors.white.withValues(alpha: 0.06),
                        valueColor: const AlwaysStoppedAnimation<Color>(AppTokens.primaryPurpleLight),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
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

  // ── 2x2 Quick Action Grid ─────────────────────────────────────────
  Widget _buildQuickActionsGrid(BuildContext context, PendaftaranState state) {
    final hasPendaftaran = state.pendaftaran != null;

    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: AppTokens.spaceMD,
      mainAxisSpacing: AppTokens.spaceMD,
      childAspectRatio: 1.25,
      children: [
        _VibrantActionCard(
          icon: hasPendaftaran ? Icons.edit_document : Icons.add_circle_outline_rounded,
          label: hasPendaftaran ? 'Lanjutkan Daftar' : 'Mulai Daftar',
          sub: 'Formulir Berkas',
          gradient: const [Color(0xFF7C3AED), Color(0xFF9333EA)],
          iconColor: Colors.white,
          onTap: () => context.push('/mahasiswa/daftar'),
        ),
        _VibrantActionCard(
          icon: Icons.track_changes_rounded,
          label: 'Lihat Status',
          sub: 'Pantau Verifikasi',
          gradient: const [Color(0xFF0284C7), Color(0xFF38BDF8)],
          iconColor: Colors.white,
          onTap: () => context.push('/mahasiswa/status'),
        ),
        _VibrantActionCard(
          icon: Icons.notifications_active_outlined,
          label: 'Notifikasi',
          sub: 'Pengumuman Baru',
          gradient: const [Color(0xFFD97706), Color(0xFFF59E0B)],
          iconColor: Colors.white,
          onTap: () => context.push('/mahasiswa/notifikasi'),
        ),
        _VibrantActionCard(
          icon: Icons.security_rounded,
          label: 'Panduan & Syarat',
          sub: 'Keamanan & Ketentuan',
          gradient: const [Color(0xFFDB2777), Color(0xFFEC4899)],
          iconColor: Colors.white,
          onTap: () => _showSecurityPanduanDialog(context),
        ),
      ],
    );
  }

  Widget _buildInfoCard(BuildContext context) {
    return GlassCard(
      fillColor: AppTokens.info.withValues(alpha: 0.06),
      borderColor: AppTokens.info.withValues(alpha: 0.25),
      padding: const EdgeInsets.all(AppTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.info_outline_rounded, color: AppTokens.info, size: 18),
              const SizedBox(width: AppTokens.spaceXS),
              Text(
                'Informasi Penting Yudisium',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: AppTokens.info,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceSM),
          _infoItem(context, '📅', 'Batas akhir pengumpulan berkas: 26 Agustus 2026.'),
          _infoItem(context, '📋', 'Lengkapi seluruh dokumen format PDF dengan ukuran maksimal 2MB.'),
          _infoItem(context, '📞', 'Hubungi admin jika ada kendala validasi data transkrip.'),
        ],
      ),
    );
  }

  Widget _infoItem(BuildContext context, String emoji, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: AppTokens.spaceXS),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 14)),
          const SizedBox(width: AppTokens.spaceXS),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.white70),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPendingVerifikasiBanner(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(AppTokens.spaceMD),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTokens.accentGold.withValues(alpha: 0.15),
            AppTokens.accentGold.withValues(alpha: 0.06),
          ],
        ),
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        border: Border.all(
          color: AppTokens.accentGold.withValues(alpha: 0.5),
          width: 1.5,
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppTokens.accentGold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.lock_clock_rounded, color: AppTokens.accentGold, size: 22),
          ),
          const SizedBox(width: AppTokens.spaceMD),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Akun Sedang Diverifikasi',
                  style: Theme.of(context).textTheme.titleSmall?.copyWith(
                        color: AppTokens.accentGoldLight,
                        fontWeight: FontWeight.w700,
                      ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Akun Anda sedang menunggu verifikasi oleh Admin Jurusan TIK PNL. Formulir pendaftaran yudisium akan terbuka segera setelah akun disetujui.',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white60,
                        height: 1.4,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showSecurityPanduanDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.75),
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF130826),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          side: const BorderSide(color: AppTokens.primaryPurpleLight, width: 1.5),
        ),
        title: const Row(
          children: [
            Icon(Icons.shield_outlined, color: AppTokens.primaryPurpleLight, size: 24),
            SizedBox(width: 10),
            Text('Panduan Keamanan & Syarat', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ],
        ),
        content: const SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '1. Seluruh dokumen wajib diunggah dalam format PDF berstandar ISO.\n\n'
                '2. Batas akhir pendaftaran adalah tanggal 26 Agustus 2026.\n\n'
                '3. Data akademik dilindungi enkripsi kriptografis SHA-256 dan verifikasi berlapis oleh Admin TIK PNL.\n\n'
                '4. Jika membutuhkan bantuan, hubungi helpdesk TIK PNL.',
                style: TextStyle(color: Colors.white70, fontSize: 13, height: 1.5),
              ),
            ],
          ),
        ),
        actions: [
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx),
            style: ElevatedButton.styleFrom(backgroundColor: AppTokens.primaryPurple),
            child: const Text('Mengerti', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// VIBRANT ACTION CARD (2x2 GRID)
// ─────────────────────────────────────────────────────────────────────────────
class _VibrantActionCard extends StatelessWidget {
  const _VibrantActionCard({
    required this.icon,
    required this.label,
    required this.sub,
    required this.gradient,
    required this.iconColor,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sub;
  final List<Color> gradient;
  final Color iconColor;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusLG),
      child: Container(
        padding: const EdgeInsets.all(AppTokens.spaceMD),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.04),
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          border: Border.all(color: gradient.first.withValues(alpha: 0.35)),
          boxShadow: [
            BoxShadow(
              color: gradient.first.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: gradient),
                borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                boxShadow: [
                  BoxShadow(color: gradient.first.withValues(alpha: 0.4), blurRadius: 8),
                ],
              ),
              child: Icon(icon, color: iconColor, size: 20),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  sub,
                  style: const TextStyle(color: Colors.white54, fontSize: 11),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
