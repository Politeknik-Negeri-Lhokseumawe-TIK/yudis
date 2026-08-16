import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../domain/notifikasi_model.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/sidebar_aware_scaffold.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

// ── Provider untuk notifikasi user ───────────────────────────
final notifikasiStreamProvider =
    StreamProvider.autoDispose<List<Notifikasi>>((ref) {
  final user = ref.watch(authProvider).user;
  if (user == null) return const Stream.empty();
  return NotifikasiRepository.notifikasiStream(user.id);
});

enum NotifFilter { semua, belumDibaca, penting }

class NotifikasiScreen extends ConsumerStatefulWidget {
  const NotifikasiScreen({super.key});

  @override
  ConsumerState<NotifikasiScreen> createState() => _NotifikasiScreenState();
}

class _NotifikasiScreenState extends ConsumerState<NotifikasiScreen> {
  NotifFilter _selectedFilter = NotifFilter.semua;

  @override
  Widget build(BuildContext context) {
    final notifAsync = ref.watch(notifikasiStreamProvider);
    final user = ref.watch(authProvider).user;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SidebarAwareScaffold(
        location: '/mahasiswa/notifikasi',
        mobileAppBar: const GlassAppBar(title: 'Notifikasi'),
        body: AnimatedBackground(
          child: SafeArea(
            top: !context.isDesktop && !context.isTablet,
            child: notifAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: AppTokens.primaryPurpleLight,
                ),
              ),
              error: (e, _) => Center(
                child: Text(
                  'Gagal memuat notifikasi: $e',
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge
                      ?.copyWith(color: Colors.white54),
                ),
              ),
              data: (notifs) {
                final unreadCount =
                    notifs.where((n) => !n.isRead).length;

                final filteredList = notifs.where((n) {
                  return switch (_selectedFilter) {
                    NotifFilter.semua => true,
                    NotifFilter.belumDibaca => !n.isRead,
                    NotifFilter.penting =>
                      n.type == NotifikasiType.warning ||
                          n.type == NotifikasiType.error ||
                          n.type == NotifikasiType.success,
                  };
                }).toList();

                return Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 850),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        // ── Header Toolbar ──────────────────────────────
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 16, 20, 12),
                          child: Row(
                            children: [
                              const Icon(Icons.notifications_active_rounded,
                                  color: AppTokens.accentGold, size: 24),
                              const SizedBox(width: 10),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Pusat Notifikasi & Informasi',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text(
                                    unreadCount > 0
                                        ? '$unreadCount notifikasi baru belum dibaca'
                                        : 'Semua notifikasi telah dibaca',
                                    style: TextStyle(
                                      color: unreadCount > 0
                                          ? AppTokens.warning
                                          : Colors.white38,
                                      fontSize: 12,
                                    ),
                                  ),
                                ],
                              ),
                              const Spacer(),
                              if (unreadCount > 0 && user != null)
                                TextButton.icon(
                                  onPressed: () async {
                                    await NotifikasiRepository.markAllAsRead(
                                        user.id);
                                    if (context.mounted) {
                                      ScaffoldMessenger.of(context)
                                          .showSnackBar(
                                        const SnackBar(
                                          content: Text(
                                              'Semua notifikasi ditandai sudah dibaca ✅'),
                                          duration: Duration(seconds: 2),
                                        ),
                                      );
                                    }
                                  },
                                  icon: const Icon(Icons.done_all_rounded,
                                      size: 16, color: AppTokens.primaryPurpleLight),
                                  label: const Text(
                                    'Tandai Semua Dibaca',
                                    style: TextStyle(
                                      color: AppTokens.primaryPurpleLight,
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                            ],
                          ),
                        ),

                        // ── Filter Chips ────────────────────────────────
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 20),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip(
                                  label: 'Semua (${notifs.length})',
                                  filter: NotifFilter.semua,
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  label: 'Belum Dibaca ($unreadCount)',
                                  filter: NotifFilter.belumDibaca,
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  label: 'Verifikasi & Revisi',
                                  filter: NotifFilter.penting,
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),

                        // ── List Notifikasi ─────────────────────────────
                        Expanded(
                          child: filteredList.isEmpty
                              ? Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Icon(
                                          Icons.notifications_off_outlined,
                                          color: Colors.white24,
                                          size: 64),
                                      const SizedBox(
                                          height: AppTokens.spaceMD),
                                      Text(
                                        _selectedFilter == NotifFilter.belumDibaca
                                            ? 'Tidak ada notifikasi yang belum dibaca'
                                            : 'Belum ada notifikasi',
                                        style: Theme.of(context)
                                            .textTheme
                                            .bodyLarge
                                            ?.copyWith(color: Colors.white38),
                                      ),
                                    ],
                                  ),
                                )
                              : ListView.separated(
                                  padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: filteredList.length,
                                  separatorBuilder: (_, _) =>
                                      const SizedBox(height: AppTokens.spaceSM),
                                  itemBuilder: (ctx, i) {
                                    final notif = filteredList[i];
                                    return _NotifTile(
                                      notif: notif,
                                      onTap: () async {
                                        if (!notif.isRead) {
                                          await NotifikasiRepository.markAsRead(
                                              notif.id);
                                        }
                                        if (context.mounted) {
                                          _showDetailDialog(context, notif);
                                        }
                                      },
                                    )
                                        .animate()
                                        .fadeIn(
                                            delay: (i * 40).ms,
                                            duration: 250.ms)
                                        .slideX(begin: 0.03, end: 0);
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required NotifFilter filter,
  }) {
    final isSelected = _selectedFilter == filter;
    return ChoiceChip(
      label: Text(
        label,
        style: TextStyle(
          color: isSelected ? Colors.white : Colors.white60,
          fontSize: 12,
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
        ),
      ),
      selected: isSelected,
      onSelected: (_) => setState(() => _selectedFilter = filter),
      selectedColor: AppTokens.primaryPurple,
      backgroundColor: Colors.white.withValues(alpha: 0.05),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(
          color: isSelected
              ? AppTokens.primaryPurpleLight
              : Colors.white.withValues(alpha: 0.12),
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
    );
  }

  void _showDetailDialog(BuildContext context, Notifikasi notif) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF19142E),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          side: const BorderSide(color: Colors.white12),
        ),
        title: Row(
          children: [
            Icon(
              switch (notif.type) {
                NotifikasiType.info => Icons.info_outline_rounded,
                NotifikasiType.success => Icons.check_circle_outline_rounded,
                NotifikasiType.warning => Icons.warning_amber_rounded,
                NotifikasiType.error => Icons.error_outline_rounded,
              },
              color: switch (notif.type) {
                NotifikasiType.info => AppTokens.info,
                NotifikasiType.success => AppTokens.success,
                NotifikasiType.warning => AppTokens.warning,
                NotifikasiType.error => AppTokens.error,
              },
              size: 24,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                notif.judul,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              notif.pesan,
              style: const TextStyle(
                color: Colors.white70,
                fontSize: 13.5,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DateFormat('EEEE, d MMMM yyyy • HH:mm', 'id_ID')
                  .format(notif.waktu),
              style: const TextStyle(color: Colors.white38, fontSize: 11),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Tutup', style: TextStyle(color: Colors.white70)),
          ),
        ],
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({
    required this.notif,
    required this.onTap,
  });

  final Notifikasi notif;
  final VoidCallback onTap;

  Color get _color => switch (notif.type) {
        NotifikasiType.info => AppTokens.info,
        NotifikasiType.success => AppTokens.success,
        NotifikasiType.warning => AppTokens.warning,
        NotifikasiType.error => AppTokens.error,
      };

  IconData get _icon => switch (notif.type) {
        NotifikasiType.info => Icons.info_outline_rounded,
        NotifikasiType.success => Icons.check_circle_outline_rounded,
        NotifikasiType.warning => Icons.warning_amber_rounded,
        NotifikasiType.error => Icons.error_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(notif.waktu);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppTokens.radiusMD),
      child: GlassCard(
        fillColor: notif.isRead
            ? Colors.white.withValues(alpha: 0.02)
            : _color.withValues(alpha: 0.08),
        borderColor: notif.isRead
            ? Colors.white.withValues(alpha: 0.08)
            : _color.withValues(alpha: 0.3),
        padding: const EdgeInsets.all(AppTokens.spaceMD),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              padding: const EdgeInsets.all(AppTokens.spaceXS),
              decoration: BoxDecoration(
                color: _color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTokens.radiusSM),
              ),
              child: Icon(_icon, color: _color, size: 18),
            ),
            const SizedBox(width: AppTokens.spaceSM),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notif.judul,
                          style:
                              Theme.of(context).textTheme.titleMedium?.copyWith(
                                    color: notif.isRead
                                        ? Colors.white60
                                        : Colors.white,
                                    fontWeight: notif.isRead
                                        ? FontWeight.w500
                                        : FontWeight.w700,
                                  ),
                        ),
                      ),
                      if (!notif.isRead)
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: _color.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                            border: Border.all(
                                color: _color.withValues(alpha: 0.5)),
                          ),
                          child: Text(
                            'BARU',
                            style: TextStyle(
                              color: _color,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: AppTokens.spaceXXS),
                  Text(
                    notif.pesan,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: notif.isRead ? Colors.white38 : Colors.white70,
                        ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      const Icon(Icons.access_time_rounded,
                          size: 11, color: Colors.white24),
                      const SizedBox(width: 4),
                      Text(
                        timeAgo,
                        style: const TextStyle(
                          color: Colors.white30,
                          fontSize: 10.5,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';
    return DateFormat('d MMM yyyy').format(time);
  }
}
