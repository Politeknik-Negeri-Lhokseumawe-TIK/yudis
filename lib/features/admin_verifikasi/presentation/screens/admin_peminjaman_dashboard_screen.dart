import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/cyber_card.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../peminjaman_ruang/domain/models/booking_model.dart';
import '../../../peminjaman_ruang/domain/models/room_model.dart';
import '../../../peminjaman_ruang/presentation/providers/booking_provider.dart';
import '../../../peminjaman_ruang/presentation/providers/roster_provider.dart';

class AdminPeminjamanDashboardScreen extends ConsumerStatefulWidget {
  const AdminPeminjamanDashboardScreen({super.key});

  @override
  ConsumerState<AdminPeminjamanDashboardScreen> createState() =>
      _AdminPeminjamanDashboardScreenState();
}

class _AdminPeminjamanDashboardScreenState
    extends ConsumerState<AdminPeminjamanDashboardScreen> {
  bool _isExporting = false;
  String _selectedTab = 'Semua'; // Semua, Menunggu, Disetujui, Selesai

  @override
  Widget build(BuildContext context) {
    final allBookings = ref.watch(bookingListProvider);
    final allRooms = ref.watch(roomsProvider);

    final pendingList = allBookings.where((b) => b.status == BookingStatus.pending).toList();
    final approvedList = allBookings
        .where((b) => b.status == BookingStatus.approved || b.status == BookingStatus.active)
        .toList();
    final completedList = allBookings.where((b) => b.status == BookingStatus.completed).toList();

    List<BookingModel> displayedBookings = allBookings;
    if (_selectedTab == 'Menunggu') displayedBookings = pendingList;
    if (_selectedTab == 'Disetujui') displayedBookings = approvedList;
    if (_selectedTab == 'Selesai') displayedBookings = completedList;

    return Scaffold(
      backgroundColor: AppTokens.bgDark,
      body: CustomScrollView(
        slivers: [
          // ── Admin App Bar ───────────────────────────────────────────
          SliverAppBar(
            expandedHeight: 180.0,
            floating: false,
            pinned: true,
            backgroundColor: AppTokens.bgDarkSurface,
            actions: [
              // Export Excel Button
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8.0),
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF107C41), // Excel Green
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  icon: _isExporting
                      ? const SizedBox(
                          width: 14,
                          height: 14,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                        )
                      : const Icon(Icons.table_view_rounded, size: 16),
                  label: const Text(
                    'Export Excel (.xlsx)',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                  onPressed: _isExporting ? null : () => _handleExportExcel(allRooms),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                tooltip: 'Roster Digital',
                icon: const Icon(Icons.calendar_month_rounded, color: AppTokens.primaryPurpleGlow),
                onPressed: () => context.push('/roster-digital'),
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
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      const Color(0xFF3B0764), // Deep Purple
                      AppTokens.bgDarkSurface,
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                padding: const EdgeInsets.fromLTRB(20, 50, 20, 16),
                child: const Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.admin_panel_settings_rounded, color: AppTokens.accentGold, size: 20),
                        SizedBox(width: 8),
                        Text(
                          'PORTAL LABORAN & ADMIN TIK',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                            color: AppTokens.accentGold,
                            letterSpacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Manajemen Peminjaman & Verifikasi Lab',
                      style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Persetujuan izin ruang, monitoring SOP kebersihan & AC mati, serta rekap spreadsheet.',
                      style: TextStyle(color: Colors.white60, fontSize: 12),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // ── Stats Summary ───────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  _buildAdminStatCard('Perlu Approval', '${pendingList.length}', AppTokens.accentGold, Icons.pending_actions_rounded),
                  const SizedBox(width: 10),
                  _buildAdminStatCard('Sedang Berjalan', '${approvedList.length}', AppTokens.primaryPurpleGlow, Icons.meeting_room_rounded),
                  const SizedBox(width: 10),
                  _buildAdminStatCard('Selesai & Valid', '${completedList.length}', AppTokens.success, Icons.verified_user_rounded),
                ],
              ),
            ),
          ),

          // ── Filter Segment ──────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                children: ['Semua', 'Menunggu', 'Disetujui', 'Selesai'].map((tab) {
                  final isSelected = _selectedTab == tab;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8.0),
                    child: ChoiceChip(
                      label: Text(tab),
                      selected: isSelected,
                      onSelected: (val) {
                        if (val) setState(() => _selectedTab = tab);
                      },
                      selectedColor: AppTokens.primaryPurple,
                      backgroundColor: AppTokens.bgDarkCard,
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.white : Colors.white70,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        fontSize: 12,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                        side: BorderSide(
                          color: isSelected ? AppTokens.primaryPurpleGlow : AppTokens.glassBorderColor,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 12)),

          // ── Bookings Approval List ──────────────────────────────────
          if (displayedBookings.isEmpty)
            const SliverFillRemaining(
              hasScrollBody: false,
              child: Center(
                child: Text(
                  'Tidak ada data peminjaman pada kategori ini.',
                  style: TextStyle(color: Colors.white54),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final booking = displayedBookings[index];
                    return _buildAdminBookingCard(context, booking, index);
                  },
                  childCount: displayedBookings.length,
                ),
              ),
            ),
          const SliverToBoxAdapter(child: SizedBox(height: 80)),
        ],
      ),
    );
  }

  Widget _buildAdminStatCard(String title, String count, Color color, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTokens.bgDarkCard,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(icon, size: 16, color: color),
                const Spacer(),
                Text(
                  count,
                  style: TextStyle(color: color, fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 4),
            Text(
              title,
              style: const TextStyle(color: Colors.white70, fontSize: 11),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAdminBookingCard(BuildContext context, BookingModel booking, int index) {
    Color statusColor = AppTokens.accentGold;
    if (booking.status == BookingStatus.approved || booking.status == BookingStatus.active) {
      statusColor = AppTokens.primaryPurpleGlow;
    } else if (booking.status == BookingStatus.completed) {
      statusColor = AppTokens.success;
    } else if (booking.status == BookingStatus.rejected) {
      statusColor = AppTokens.error;
    }

    return CyberCard(
      margin: const EdgeInsets.only(bottom: 14),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Booking code, Date, Status
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTokens.primaryPurple.withValues(alpha: 0.25),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    booking.bookingCode,
                    style: const TextStyle(
                      color: AppTokens.primaryPurpleGlow,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${booking.day}, ${DateFormat('dd/MM/yyyy').format(booking.bookingDate)}',
                  style: const TextStyle(color: Colors.white70, fontSize: 12),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: statusColor.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: statusColor),
                  ),
                  child: Text(
                    booking.statusLabel,
                    style: TextStyle(color: statusColor, fontSize: 10, fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            // Room & Purpose
            Text(
              '${booking.roomCode} - ${booking.roomName}',
              style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4),
            Text(
              'Keperluan: ${booking.purpose}',
              style: const TextStyle(color: AppTokens.accentGold, fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 4),
            Text(
              'Pemohon: ${booking.userName} (${booking.userNimNip}) • WA: ${booking.userPhone}',
              style: const TextStyle(color: Colors.white70, fontSize: 12),
            ),
            Text(
              'Dosen PJ: ${booking.supervisorLecturer} • Sesi: ${booking.sessionRangeLabel}',
              style: const TextStyle(color: Colors.white54, fontSize: 11),
            ),
            if (booking.additionalFacilities.isNotEmpty) ...[
              const SizedBox(height: 4),
              Text(
                'Alat Tambahan: ${booking.additionalFacilities.join(", ")}',
                style: const TextStyle(color: AppTokens.info, fontSize: 11),
              ),
            ],
            const SizedBox(height: 12),
            const Divider(color: Colors.white12, height: 1),
            const SizedBox(height: 10),

            // Video Verification Status if completed
            if (booking.isCheckoutDone)
              Container(
                padding: const EdgeInsets.all(10),
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: AppTokens.bgDarkSurface,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppTokens.success.withValues(alpha: 0.4)),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.videocam_rounded, color: AppTokens.success, size: 18),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Bukti Video: ${booking.checkoutVideoName ?? "Tersedia"}',
                            style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.bold),
                          ),
                          Text(
                            'Status: AC Mati (${booking.checkoutAcOffStatus ? "Ya" : "Tidak"}) • Bersih (${booking.checkoutCleanlinessStatus ? "Ya" : "Tidak"})',
                            style: const TextStyle(color: AppTokens.success, fontSize: 10),
                          ),
                        ],
                      ),
                    ),
                    TextButton(
                      style: TextButton.styleFrom(padding: EdgeInsets.zero),
                      onPressed: () {
                        context.push('/detail-peminjaman?bookingId=${booking.id}');
                      },
                      child: const Text('Lihat Video', style: TextStyle(color: AppTokens.primaryPurpleGlow, fontSize: 11)),
                    ),
                  ],
                ),
              ),

            // Action Buttons for Laboran
            Row(
              children: [
                TextButton.icon(
                  icon: const Icon(Icons.info_outline_rounded, size: 16),
                  label: const Text('Detail / QR', style: TextStyle(fontSize: 12)),
                  onPressed: () {
                    context.push('/detail-peminjaman?bookingId=${booking.id}');
                  },
                ),
                const Spacer(),

                // If Pending: Show Approve & Reject buttons
                if (booking.status == BookingStatus.pending) ...[
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTokens.error,
                      side: const BorderSide(color: AppTokens.error),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    ),
                    icon: const Icon(Icons.close_rounded, size: 14),
                    label: const Text('Tolak', style: TextStyle(fontSize: 11)),
                    onPressed: () => _showRejectDialog(context, booking),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTokens.primaryPurple,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    ),
                    icon: const Icon(Icons.check_rounded, size: 14),
                    label: const Text('Setujui', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                    onPressed: () async {
                      await ref.read(bookingListProvider.notifier).updateStatus(
                            booking.id,
                            BookingStatus.approved,
                            approvedBy: 'Staff Laboran TIK',
                          );
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text('Peminjaman ${booking.bookingCode} berhasil disetujui!'),
                            backgroundColor: AppTokens.success,
                          ),
                        );
                      }
                    },
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms, delay: (index * 25).ms);
  }

  Future<void> _handleExportExcel(List<RoomModel> allRooms) async {
    setState(() => _isExporting = true);

    final success = await ref.read(bookingListProvider.notifier).exportToExcel(allRooms);

    setState(() => _isExporting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(success
              ? 'Laporan Excel (.xlsx) berhasil digenerate dan diunduh!'
              : 'Gagal mengekspor laporan Excel.'),
          backgroundColor: success ? const Color(0xFF107C41) : AppTokens.error,
        ),
      );
    }
  }

  void _showRejectDialog(BuildContext context, BookingModel booking) {
    final reasonCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTokens.bgDarkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppTokens.glassBorderColor),
          ),
          title: const Text('Tolak Permohonan Peminjaman', style: TextStyle(color: Colors.white, fontSize: 16)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Alasan penolakan untuk ${booking.bookingCode}:', style: const TextStyle(color: Colors.white70, fontSize: 12)),
              const SizedBox(height: 10),
              TextField(
                controller: reasonCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Contoh: Lab sedang dalam jadwal pemeliharaan jaringan...',
                  hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                  filled: true,
                  fillColor: AppTokens.bgDarkSurface,
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Batal', style: TextStyle(color: Colors.white70)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: AppTokens.error),
              onPressed: () async {
                final reason = reasonCtrl.text.trim().isNotEmpty
                    ? reasonCtrl.text.trim()
                    : 'Tidak memenuhi syarat peminjaman ruangan.';
                await ref.read(bookingListProvider.notifier).updateStatus(
                      booking.id,
                      BookingStatus.rejected,
                      rejectionReason: reason,
                    );
                if (ctx.mounted) Navigator.pop(ctx);
              },
              child: const Text('Tolak Permohonan', style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }
}
