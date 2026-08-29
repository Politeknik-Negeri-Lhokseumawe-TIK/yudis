import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/cyber_card.dart';
import '../../../../shared/widgets/neon_stat_card.dart';
import '../../../../shared/widgets/cyber_status_badge.dart';
import '../../../../shared/widgets/ui_primitives.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../domain/models/booking_model.dart';
import '../providers/booking_provider.dart';

class DashboardPeminjamScreen extends ConsumerWidget {
  const DashboardPeminjamScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final allBookings = ref.watch(bookingListProvider);
    final user = authState.user;

    // Filter bookings
    final myBookings = allBookings; // Show current list
    final activeCount = myBookings.where((b) => b.status == BookingStatus.active || b.status == BookingStatus.approved).length;
    final pendingCount = myBookings.where((b) => b.status == BookingStatus.pending).length;
    final completedCount = myBookings.where((b) => b.status == BookingStatus.completed).length;

    return Scaffold(
      backgroundColor: AppTokens.bgDark,
      body: CustomScrollView(
        slivers: [
          // ── App Bar Header ─────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 200.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTokens.bgDarkSurface,
            actions: [
              IconButton(
                tooltip: 'Pemberitahuan',
                icon: const Icon(Icons.notifications_outlined, color: Colors.white70),
                onPressed: () => context.push('/notifikasi'),
              ),
              IconButton(
                tooltip: 'Keluar',
                icon: const Icon(Icons.logout_rounded, color: Colors.white70),
                onPressed: () => ref.read(authProvider.notifier).logout(),
              ),
              const SizedBox(width: 8),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      AppTokens.primaryPurpleDark,
                      AppTokens.bgDarkSurface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: AppTokens.primaryPurpleGlow.withValues(alpha: 0.2),
                          child: const Icon(Icons.person_rounded, color: AppTokens.primaryPurpleGlow),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Selamat Datang, ${user?.nama ?? "Mahasiswa TIK"}',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              Text(
                                '${user?.nim ?? "NIM 220401012"} • ${AppConstants.appInstitution}',
                                style: const TextStyle(color: Colors.white60, fontSize: 11),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTokens.accentGold.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTokens.accentGold.withValues(alpha: 0.4)),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.event_available_rounded, size: 13, color: AppTokens.accentGold),
                          SizedBox(width: 6),
                          Text(
                            'SIM-LAB & RUANG PBM • TA 2026/2027',
                            style: TextStyle(
                              color: AppTokens.accentGold,
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Quick Stats: Cyber Neon Stat Row ────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: NeonStatRow(
                cards: [
                  NeonStatCard(
                    title: 'Aktif / Disetujui',
                    value: '$activeCount',
                    icon: Icons.verified_rounded,
                    color: AppTokens.success,
                    delay: Duration.zero,
                  ),
                  NeonStatCard(
                    title: 'Menunggu',
                    value: '$pendingCount',
                    icon: Icons.hourglass_top_rounded,
                    color: AppTokens.accentGold,
                    delay: const Duration(milliseconds: 100),
                  ),
                  NeonStatCard(
                    title: 'Selesai',
                    value: '$completedCount',
                    icon: Icons.task_alt_rounded,
                    color: AppTokens.primaryPurpleLight,
                    delay: const Duration(milliseconds: 200),
                  ),
                ],
              ),
            ),
          ),

          // ── Main Feature Quick Actions ──────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Layanan Utama Laboratorium & Kelas',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      // Roster Digital Card
                      Expanded(
                        child: _buildActionMenuCard(
                          context,
                          title: 'Roster Digital',
                          subtitle: 'Jadwal PBM tanpa PDF',
                          icon: Icons.calendar_month_rounded,
                          color: AppTokens.primaryPurpleGlow,
                          onTap: () => context.push('/roster-digital'),
                        ),
                      ),
                      const SizedBox(width: 12),

                      // Ketersediaan Ruangan Card
                      Expanded(
                        child: _buildActionMenuCard(
                          context,
                          title: 'Ketersediaan',
                          subtitle: 'Matriks okupansi lab',
                          icon: Icons.meeting_room_rounded,
                          color: AppTokens.info,
                          onTap: () => context.push('/ketersediaan-ruangan'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  // Big New Booking Banner
                  InkWell(
                    onTap: () => context.push('/form-peminjaman'),
                    borderRadius: BorderRadius.circular(14),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [
                            AppTokens.primaryPurple,
                            AppTokens.primaryPurpleDark,
                          ],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                        borderRadius: BorderRadius.circular(14),
                        boxShadow: [
                          BoxShadow(
                            color: AppTokens.primaryPurple.withValues(alpha: 0.3),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: const Row(
                        children: [
                          Icon(Icons.add_circle_rounded, color: Colors.white, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Ajukan Peminjaman Ruang Baru',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 2),
                                Text(
                                  'Deteksi bentrok jadwal otomatis dengan roster PBM',
                                  style: TextStyle(color: Colors.white70, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          Icon(Icons.arrow_forward_ios_rounded, color: Colors.white, size: 16),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── My Bookings Section ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(16, 24, 16, 8),
              child: Row(
                children: [
                  const Text(
                    'Riwayat & Status Peminjaman',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Text(
                    '${myBookings.length} Pengajuan',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),

          if (myBookings.isEmpty)
            SliverFillRemaining(
              hasScrollBody: false,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
                child: EmptyStateWidget(
                  title: 'Belum Ada Peminjaman',
                  subtitle: 'Laboratorium & ruang kelas siap digunakan. Ajukan peminjaman sekarang dengan deteksi bentrok jadwal otomatis.',
                  icon: Icons.meeting_room_outlined,
                  actionLabel: 'Ajukan Peminjaman Sekarang',
                  action: () => context.push('/form-peminjaman'),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final booking = myBookings[index];
                    return _buildBookingItemCard(context, booking, index);
                  },
                  childCount: myBookings.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildActionMenuCard(
    BuildContext context, {
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: AppTokens.bgDarkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppTokens.glassBorderColor),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: 10),
            Text(
              title,
              style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 2),
            Text(
              subtitle,
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBookingItemCard(BuildContext context, BookingModel booking, int index) {
    final isLab = booking.roomCode.startsWith('TIK.1') || booking.roomCode.startsWith('TDC');

    return CyberCard(
      margin: const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Room & Status Badge
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isLab ? AppTokens.primaryPurple.withValues(alpha: 0.25) : Colors.blueGrey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: isLab ? AppTokens.primaryPurpleGlow : Colors.white30),
                  ),
                  child: Text(
                    booking.roomCode,
                    style: TextStyle(
                      color: isLab ? AppTokens.primaryPurpleGlow : Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    booking.roomName,
                    style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.bold),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                CyberStatusBadge.fromBookingStatus(booking.status.name),
              ],
            ),
            const SizedBox(height: 8),

            // Date & Session
            Row(
              children: [
                const Icon(Icons.access_time_rounded, size: 14, color: AppTokens.accentGold),
                const SizedBox(width: 6),
                Text(
                  '${booking.day}, ${DateFormat('dd MMM yyyy').format(booking.bookingDate)} • ${booking.sessionRangeLabel}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
            const SizedBox(height: 4),

            // Purpose & Supervisor
            Row(
              children: [
                const Icon(Icons.assignment_outlined, size: 14, color: Colors.white54),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    '${booking.purpose} (PJ: ${booking.supervisorLecturer})',
                    style: const TextStyle(color: Colors.white54, fontSize: 11),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 10),

            // Bottom Actions: E-Permit & Checkout button
            Row(
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    foregroundColor: AppTokens.primaryPurpleGlow,
                  ),
                  icon: const Icon(Icons.qr_code_2_rounded, size: 16),
                  label: const Text('E-Permit / QR', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    context.push('/detail-peminjaman?bookingId=${booking.id}');
                  },
                ),
                const Spacer(),
                if (booking.status == BookingStatus.approved || booking.status == BookingStatus.active)
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTokens.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.upload_file_rounded, size: 14),
                    label: const Text('Upload Video Selesai', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () {
                      context.push('/pengembalian-ruang?bookingId=${booking.id}');
                    },
                  )
                else if (booking.status == BookingStatus.completed)
                  const Row(
                    children: [
                      Icon(Icons.check_circle_rounded, color: AppTokens.success, size: 14),
                      SizedBox(width: 4),
                      Text('AC & Bersih Valid', style: TextStyle(color: AppTokens.success, fontSize: 11, fontWeight: FontWeight.bold)),
                    ],
                  ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms, delay: (index * 30).ms);
  }
}
