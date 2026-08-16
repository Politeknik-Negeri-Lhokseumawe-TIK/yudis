import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../providers/admin_provider.dart';
import '../widgets/prodi_progress_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/animated_counter.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/sidebar_aware_scaffold.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_tokens.dart';

class AdminDashboardScreen extends ConsumerWidget {
  const AdminDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adminState = ref.watch(adminProvider);
    final user = ref.watch(currentUserProvider);
    final isDesktop = context.isDesktopWithSidebar;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SidebarAwareScaffold(
        location: '/admin/dashboard',
        mobileAppBar: GlassAppBar(
          showBackButton: false,
          titleWidget: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: AppTokens.primaryPurple.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.admin_panel_settings_rounded,
                    color: AppTokens.primaryPurpleLight, size: 20),
              ),
              const SizedBox(width: AppTokens.spaceXS),
              Text(
                'Admin Panel TIK',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white70),
              onPressed: () => ref.read(adminProvider.notifier).loadAll(),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
              color: AppTokens.bgDarkCard,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTokens.radiusMD),
              ),
              onSelected: (v) async {
                if (v == 'logout') {
                  await ref.read(authProvider.notifier).logout();
                  if (context.mounted) context.go('/login');
                }
              },
              itemBuilder: (_) => [
                PopupMenuItem(
                  value: 'logout',
                  child: Row(
                    children: [
                      const Icon(Icons.logout_rounded, color: Colors.white70, size: 18),
                      const SizedBox(width: 8),
                      Text('Keluar (${user?.nama ?? "Admin"})',
                          style: const TextStyle(color: Colors.white70)),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
        body: AnimatedBackground(
          child: SafeArea(
            top: !isDesktop,
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
                        // ── Header & LIVE Badge ─────────────────────────
                        _buildHeader(context, adminState, user?.nama ?? 'Admin'),
                        const SizedBox(height: AppTokens.spaceLG),

                        // ── 4 Live Animated Stat Cards ──────────────────
                        _buildLiveStatsGrid(context, adminState)
                            .animate()
                            .fadeIn(delay: 150.ms, duration: 400.ms)
                            .slideY(begin: 0.15, end: 0),

                        const SizedBox(height: AppTokens.spaceLG),

                        // ── Main Content: 2 Columns on Desktop ──────────
                        if (isDesktop)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Left Column (Prodi Distribution + Quick Actions)
                              Expanded(
                                flex: 3,
                                child: Column(
                                  children: [
                                    ProdiProgressCard(
                                      totalPendaftar: adminState.pendaftaranList.length,
                                      trkjCount: adminState.stats['trkj'] ?? 2,
                                      trmmCount: adminState.stats['trmm'] ?? 1,
                                      tiCount: adminState.stats['ti'] ?? 1,
                                    ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
                                    const SizedBox(height: AppTokens.spaceLG),
                                    _buildQuickActions(context)
                                        .animate()
                                        .fadeIn(delay: 350.ms, duration: 400.ms),
                                  ],
                                ),
                              ),
                              const SizedBox(width: AppTokens.spaceLG),
                              // Right Column (Live Activity Feed + Pending Attention)
                              Expanded(
                                flex: 2,
                                child: Column(
                                  children: [
                                    _buildLiveActivityFeed(context, adminState)
                                        .animate()
                                        .fadeIn(delay: 300.ms, duration: 400.ms),
                                    const SizedBox(height: AppTokens.spaceLG),
                                    if (adminState.pendingAccounts.isNotEmpty)
                                      _buildPendingAttention(context, adminState)
                                          .animate()
                                          .fadeIn(delay: 450.ms, duration: 400.ms),
                                  ],
                                ),
                              ),
                            ],
                          )
                        else ...[
                          ProdiProgressCard(
                            totalPendaftar: adminState.pendaftaranList.length,
                            trkjCount: adminState.stats['trkj'] ?? 2,
                            trmmCount: adminState.stats['trmm'] ?? 1,
                            tiCount: adminState.stats['ti'] ?? 1,
                          ).animate().fadeIn(delay: 250.ms, duration: 400.ms),
                          const SizedBox(height: AppTokens.spaceLG),
                          _buildLiveActivityFeed(context, adminState)
                              .animate()
                              .fadeIn(delay: 300.ms, duration: 400.ms),
                          const SizedBox(height: AppTokens.spaceLG),
                          _buildQuickActions(context)
                              .animate()
                              .fadeIn(delay: 350.ms, duration: 400.ms),
                          const SizedBox(height: AppTokens.spaceLG),
                          if (adminState.pendingAccounts.isNotEmpty)
                            _buildPendingAttention(context, adminState)
                                .animate()
                                .fadeIn(delay: 400.ms, duration: 400.ms),
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

  // ── Header Greeting & LIVE Indicator ─────────────────────────────
  Widget _buildHeader(BuildContext context, AdminState state, String adminName) {
    final now = DateTime.now();
    final df = DateFormat('EEEE, d MMMM yyyy', 'id_ID');

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Selamat Bertugas, $adminName',
                style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const SizedBox(height: 4),
              Text(
                '${df.format(now)}  •  Jurusan TIK Politeknik Negeri Lhokseumawe',
                style: const TextStyle(color: Colors.white54, fontSize: 13),
              ),
            ],
          ),
        ),
        // Live indicator badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTokens.success.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(AppTokens.radiusCircle),
            border: Border.all(color: AppTokens.success.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 8,
                height: 8,
                decoration: BoxDecoration(
                  color: AppTokens.success,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppTokens.success.withValues(alpha: 0.8),
                      blurRadius: 6,
                      spreadRadius: 2,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 6),
              const Text(
                'LIVE REAL-TIME',
                style: TextStyle(
                  color: AppTokens.success,
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 1,
                ),
              ),
            ],
          ),
        ),
      ],
    ).animate().fadeIn(duration: 400.ms);
  }

  // ── 4 Live Animated Stat Cards ───────────────────────────────────
  Widget _buildLiveStatsGrid(BuildContext context, AdminState state) {
    final stats = state.stats;
    final total = state.pendaftaranList.length;
    final disetujui = stats['disetujui'] ?? 1;
    final pendingAkun = stats['pending_akun'] ?? 3;
    final submitted = stats['submitted'] ?? 2;

    return Row(
      children: [
        Expanded(
          child: _LiveStatCard(
            title: 'Total Pendaftar',
            value: total,
            subtitle: 'Real-time pendaftar',
            icon: Icons.people_outline_rounded,
            color: AppTokens.primaryPurpleLight,
            gradient: const [Color(0xFF7C3AED), Color(0xFFC084FC)],
          ),
        ),
        const SizedBox(width: AppTokens.spaceMD),
        Expanded(
          child: _LiveStatCard(
            title: 'Disetujui',
            value: disetujui,
            subtitle: 'Dokumen valid',
            icon: Icons.verified_rounded,
            color: AppTokens.success,
            gradient: const [Color(0xFF059669), Color(0xFF34D399)],
          ),
        ),
        const SizedBox(width: AppTokens.spaceMD),
        Expanded(
          child: _LiveStatCard(
            title: 'Akun Pending',
            value: pendingAkun,
            subtitle: 'Perlu persetujuan',
            icon: Icons.person_add_outlined,
            color: AppTokens.accentGold,
            gradient: const [Color(0xFFD97706), Color(0xFFFDE047)],
          ),
        ),
        const SizedBox(width: AppTokens.spaceMD),
        Expanded(
          child: _LiveStatCard(
            title: 'Menunggu Review',
            value: submitted,
            subtitle: 'Berkas masuk',
            icon: Icons.assignment_late_outlined,
            color: AppTokens.info,
            gradient: const [Color(0xFF0284C7), Color(0xFF38BDF8)],
          ),
        ),
      ],
    );
  }

  // ── Live Activity Feed ───────────────────────────────────────────
  Widget _buildLiveActivityFeed(BuildContext context, AdminState state) {
    final logs = state.activityLogs.take(5).toList();
    final df = DateFormat('HH:mm', 'id_ID');

    return GlassCard(
      padding: const EdgeInsets.all(AppTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppTokens.spaceXS),
                decoration: BoxDecoration(
                  color: AppTokens.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                ),
                child: const Icon(Icons.bolt_rounded, color: AppTokens.info, size: 18),
              ),
              const SizedBox(width: AppTokens.spaceSM),
              Text(
                'Aktivitas Terbaru',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
              const Spacer(),
              Text(
                'Live Log',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.4), fontSize: 11),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceMD),
          if (logs.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Center(
                child: Text('Belum ada log aktivitas', style: TextStyle(color: Colors.white38, fontSize: 12)),
              ),
            )
          else
            ...logs.map((log) {
              return Container(
                margin: const EdgeInsets.only(bottom: 10),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.03),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.06)),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(6),
                      decoration: BoxDecoration(
                        color: log.color.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(log.icon, color: log.color, size: 14),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            log.actorName,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                            overflow: TextOverflow.ellipsis,
                          ),
                          Text(
                            log.description,
                            style: const TextStyle(color: Colors.white60, fontSize: 11),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                    Text(
                      df.format(log.timestamp),
                      style: const TextStyle(color: Colors.white38, fontSize: 10),
                    ),
                  ],
                ),
              );
            }),
        ],
      ),
    );
  }

  // ── Quick Actions ────────────────────────────────────────────────
  Widget _buildQuickActions(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTokens.spaceMD),
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
                child: const Icon(Icons.flash_on_rounded, color: AppTokens.primaryPurpleLight, size: 18),
              ),
              const SizedBox(width: AppTokens.spaceSM),
              Text(
                'Menu Cepat Admin',
                style: Theme.of(context).textTheme.titleSmall?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceMD),
          Row(
            children: [
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.person_search_rounded,
                  label: 'Verifikasi Akun',
                  sub: 'Pendaftar Baru & Password',
                  color: AppTokens.accentGold,
                  onTap: () => context.go('/admin/akun/pending'),
                ),
              ),
              const SizedBox(width: AppTokens.spaceSM),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.fact_check_rounded,
                  label: 'Verifikasi Berkas',
                  sub: 'Validasi Dokumen Syarat',
                  color: AppTokens.primaryPurpleLight,
                  onTap: () => context.go('/admin/yudisium'),
                ),
              ),
              const SizedBox(width: AppTokens.spaceSM),
              Expanded(
                child: _QuickActionButton(
                  icon: Icons.summarize_rounded,
                  label: 'Rekap Peserta',
                  sub: 'Daftar Calon Wisudawan',
                  color: AppTokens.info,
                  onTap: () => context.go('/admin/rekap'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Pending Attention ────────────────────────────────────────────
  Widget _buildPendingAttention(BuildContext context, AdminState state) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.warning_amber_rounded, color: AppTokens.accentGold, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Antrean Akun Pending',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
              ),
              const Spacer(),
              TextButton(
                onPressed: () => context.go('/admin/akun/pending'),
                child: const Text('Lihat Semua', style: TextStyle(color: AppTokens.accentGoldLight, fontSize: 11)),
              ),
            ],
          ),
          ...state.pendingAccounts.take(3).map((acc) {
            return InkWell(
              onTap: () => context.go('/admin/akun/pending'),
              borderRadius: BorderRadius.circular(8),
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 16,
                      backgroundColor: AppTokens.accentGold.withValues(alpha: 0.2),
                      child: Text(
                        acc.user.nama.substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: AppTokens.accentGoldLight,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            acc.user.nama,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          Text(
                            '${acc.user.nim} • ${acc.user.programStudi.value}',
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: Colors.white38, size: 16),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// REUSABLE LIVE STAT CARD
// ─────────────────────────────────────────────────────────────────────────────
class _LiveStatCard extends StatelessWidget {
  const _LiveStatCard({
    required this.title,
    required this.value,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.gradient,
  });

  final String title;
  final int value;
  final String subtitle;
  final IconData icon;
  final Color color;
  final List<Color> gradient;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(AppTokens.spaceMD),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  gradient: LinearGradient(colors: gradient),
                  borderRadius: BorderRadius.circular(AppTokens.radiusSM),
                  boxShadow: [
                    BoxShadow(color: color.withValues(alpha: 0.35), blurRadius: 8),
                  ],
                ),
                child: Icon(icon, color: Colors.white, size: 18),
              ),
              Container(
                width: 6,
                height: 6,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTokens.spaceMD),
          AnimatedCounter(
            value: value,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w900,
                  fontSize: 28,
                ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 13),
          ),
          Text(
            subtitle,
            style: const TextStyle(color: Colors.white38, fontSize: 10),
          ),
        ],
      ),
    );
  }
}

class _QuickActionButton extends StatelessWidget {
  const _QuickActionButton({
    required this.icon,
    required this.label,
    required this.sub,
    required this.color,
    required this.onTap,
  });

  final IconData icon;
  final String label;
  final String sub;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusMD),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(AppTokens.radiusMD),
          border: Border.all(color: color.withValues(alpha: 0.25)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: color, size: 22),
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
            const SizedBox(height: 2),
            Text(sub, style: const TextStyle(color: Colors.white54, fontSize: 10)),
          ],
        ),
      ),
    );
  }
}
