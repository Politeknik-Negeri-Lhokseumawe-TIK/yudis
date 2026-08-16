import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../domain/notifikasi_model.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_app_bar.dart';
import '../../../../shared/widgets/sidebar_aware_scaffold.dart';
import '../../../../core/responsive/breakpoints.dart';
import '../../../../core/theme/app_tokens.dart';

class NotifikasiScreen extends StatelessWidget {
  const NotifikasiScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: SidebarAwareScaffold(
        location: '/mahasiswa/notifikasi',
        mobileAppBar: const GlassAppBar(title: 'Notifikasi'),
        body: AnimatedBackground(
          child: SafeArea(
            top: !context.isDesktop && !context.isTablet,
            child: mockNotifikasi.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.notifications_off_outlined,
                            color: Colors.white24, size: 64),
                        const SizedBox(height: AppTokens.spaceMD),
                        Text(
                          'Tidak ada notifikasi',
                          style: Theme.of(context)
                              .textTheme
                              .bodyLarge
                              ?.copyWith(color: Colors.white38),
                        ),
                      ],
                    ),
                  )
                : Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 800),
                      child: ListView.separated(
                        padding: const EdgeInsets.all(AppTokens.spaceMD),
                        physics: const ClampingScrollPhysics(),
                        itemCount: mockNotifikasi.length,
                        separatorBuilder: (_, _) =>
                            const SizedBox(height: AppTokens.spaceSM),
                        itemBuilder: (ctx, i) {
                          final notif = mockNotifikasi[i];
                          return _NotifTile(notif: notif)
                              .animate()
                              .fadeIn(delay: (i * 80).ms, duration: 300.ms)
                              .slideX(begin: 0.05, end: 0);
                        },
                      ),
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}

class _NotifTile extends StatelessWidget {
  const _NotifTile({required this.notif});
  final Notifikasi notif;

  Color get _color => switch (notif.type) {
        NotifikasiType.info    => AppTokens.info,
        NotifikasiType.success => AppTokens.success,
        NotifikasiType.warning => AppTokens.warning,
        NotifikasiType.error   => AppTokens.error,
      };

  IconData get _icon => switch (notif.type) {
        NotifikasiType.info    => Icons.info_outline_rounded,
        NotifikasiType.success => Icons.check_circle_outline_rounded,
        NotifikasiType.warning => Icons.warning_amber_rounded,
        NotifikasiType.error   => Icons.error_outline_rounded,
      };

  @override
  Widget build(BuildContext context) {
    final timeAgo = _formatTimeAgo(notif.waktu);

    return GlassCard(
      fillColor: notif.isRead
          ? Colors.white.withValues(alpha: 0.03)
          : _color.withValues(alpha: 0.06),
      borderColor: notif.isRead
          ? Colors.white.withValues(alpha: 0.08)
          : _color.withValues(alpha: 0.25),
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
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                              color: notif.isRead ? Colors.white54 : Colors.white,
                              fontWeight: notif.isRead ? FontWeight.w500 : FontWeight.w600,
                            ),
                      ),
                    ),
                    if (!notif.isRead)
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _color,
                          shape: BoxShape.circle,
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: AppTokens.spaceXXS),
                Text(
                  notif.pesan,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: notif.isRead ? Colors.white30 : Colors.white54,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: AppTokens.spaceXXS),
                Text(
                  timeAgo,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white24,
                        fontSize: 10,
                      ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimeAgo(DateTime time) {
    final diff = DateTime.now().difference(time);
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit yang lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam yang lalu';
    if (diff.inDays < 7) return '${diff.inDays} hari yang lalu';
    return DateFormat('d MMM yyyy').format(time);
  }
}
