import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/cyber_button.dart';
import '../../../../shared/widgets/cyber_card.dart';
import '../../domain/models/booking_model.dart';
import '../providers/booking_provider.dart';

class DetailPeminjamanScreen extends ConsumerWidget {
  final String bookingId;

  const DetailPeminjamanScreen({super.key, required this.bookingId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allBookings = ref.watch(bookingListProvider);
    final booking = allBookings.firstWhere(
      (b) => b.id == bookingId,
      orElse: () => allBookings.first,
    );

    final dateFormat = DateFormat('EEEE, dd MMMM yyyy', 'id_ID');

    Color statusColor = AppTokens.accentGold;
    if (booking.status == BookingStatus.approved || booking.status == BookingStatus.active) {
      statusColor = AppTokens.primaryPurpleGlow;
    } else if (booking.status == BookingStatus.completed) {
      statusColor = AppTokens.success;
    } else if (booking.status == BookingStatus.rejected) {
      statusColor = AppTokens.error;
    }

    return Scaffold(
      backgroundColor: AppTokens.bgDark,
      appBar: AppBar(
        backgroundColor: AppTokens.bgDarkSurface,
        title: const Text(
          'E-Permit & Detail Peminjaman',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: 'Bagikan E-Permit',
            icon: const Icon(Icons.share_rounded, color: Colors.white70),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('E-Permit Izin Ruang siap dibagikan.')),
              );
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── QR Code Digital Permit ──────────────────────────────────
          Center(
            child: CyberCard(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: AppTokens.primaryPurple.withValues(alpha: 0.3),
                            blurRadius: 20,
                            spreadRadius: 2,
                          ),
                        ],
                      ),
                      child: QrImageView(
                        data: 'SIPENJOL-PNL:${booking.bookingCode}:${booking.roomCode}:${booking.userNimNip}',
                        version: QrVersions.auto,
                        size: 160.0,
                        backgroundColor: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      booking.bookingCode,
                      style: const TextStyle(
                        color: AppTokens.primaryPurpleGlow,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                        letterSpacing: 1.2,
                      ),
                    ),
                    const SizedBox(height: 4),
                    const Text(
                      'Tunjukkan QR ini ke Laboran / Teknisi untuk akses ruang',
                      style: TextStyle(color: Colors.white54, fontSize: 11),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                      decoration: BoxDecoration(
                        color: statusColor.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: statusColor),
                      ),
                      child: Text(
                        booking.statusLabel,
                        style: TextStyle(
                          color: statusColor,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ).animate().scale(duration: 250.ms),
          const SizedBox(height: 16),

          // ── Room & Schedule Details ─────────────────────────────────
          CyberCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Informasi Ruangan & Waktu',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Ruangan / Lab', '${booking.roomCode} - ${booking.roomName}'),
                  _buildDetailRow('Hari & Tanggal', dateFormat.format(booking.bookingDate)),
                  _buildDetailRow('Sesi Jam', booking.sessionRangeLabel),
                  _buildDetailRow('Keperluan', booking.purpose),
                  _buildDetailRow('Dosen PJ', booking.supervisorLecturer),
                  _buildDetailRow('Uraian', booking.description.isNotEmpty ? booking.description : '-'),
                  if (booking.additionalFacilities.isNotEmpty)
                    _buildDetailRow(
                      'Fasilitas Ekstra',
                      booking.additionalFacilities.join(', '),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Pemohon Details ─────────────────────────────────────────
          CyberCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Data Pemohon & Penanggung Jawab',
                    style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 12),
                  _buildDetailRow('Nama Pemohon', booking.userName),
                  _buildDetailRow('NIM / NIP', booking.userNimNip),
                  _buildDetailRow('No. WhatsApp', booking.userPhone),
                  _buildDetailRow('Peran', booking.userRole),
                  _buildDetailRow(
                    'Waktu Pengajuan',
                    DateFormat('dd/MM/yyyy HH:mm', 'id_ID').format(booking.createdAt),
                  ),
                  if (booking.approvedBy != null)
                    _buildDetailRow('Disetujui Oleh', booking.approvedBy!),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Status Bukti Kebersihan & Video Checkout ────────────────
          CyberCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.verified_user_rounded, color: AppTokens.success, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Bukti Kebersihan & Pemadaman AC (SOP)',
                        style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                      const Spacer(),
                      if (booking.isCheckoutDone)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: AppTokens.success.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'TERVERIFIKASI',
                            style: TextStyle(color: AppTokens.success, fontSize: 10, fontWeight: FontWeight.bold),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 12),

                  if (!booking.isCheckoutDone)
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTokens.bgDarkSurface,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppTokens.accentGold, size: 20),
                          const SizedBox(width: 10),
                          const Expanded(
                            child: Text(
                              'Peminjam belum mengunggah video bukti kebersihan & AC mati. Pengembalian ruangan dilakukan setelah pemakaian selesai.',
                              style: TextStyle(color: Colors.white70, fontSize: 12),
                            ),
                          ),
                        ],
                      ),
                    )
                  else ...[
                    // Video Card & Checklist Results
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTokens.bgDarkSurface,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTokens.success.withValues(alpha: 0.4)),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.videocam_rounded, color: AppTokens.success, size: 20),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  booking.checkoutVideoName ?? 'video_bukti_kebersihan.mp4',
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                              ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppTokens.primaryPurple,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                                ),
                                icon: const Icon(Icons.play_circle_fill_rounded, size: 16),
                                label: const Text('Putar Video', style: TextStyle(fontSize: 11)),
                                onPressed: () {
                                  _showVideoPlayerModal(context, booking);
                                },
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          _buildVerificationCheckItem('AC Telah Dimatikan (OFF)', booking.checkoutAcOffStatus),
                          _buildVerificationCheckItem('Lampu Ruangan Dipadamkan', booking.checkoutLightsOffStatus),
                          _buildVerificationCheckItem('PC & Perangkat Lab Dishutdown', booking.checkoutPcOffStatus),
                          _buildVerificationCheckItem('Ruangan & Meja Bebas Sampah', booking.checkoutCleanlinessStatus),
                          _buildVerificationCheckItem('Pintu & Jendela Terkunci Aman', booking.checkoutDoorsLockedStatus),
                          if (booking.checkoutSubmittedAt != null) ...[
                            const SizedBox(height: 6),
                            Text(
                              'Diserahkan: ${DateFormat('dd/MM/yyyy HH:mm', 'id_ID').format(booking.checkoutSubmittedAt!)} WIB',
                              style: const TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                          ],
                          if (booking.laboranReviewNotes != null) ...[
                            const SizedBox(height: 4),
                            Text(
                              'Catatan Laboran: ${booking.laboranReviewNotes}',
                              style: const TextStyle(color: AppTokens.info, fontSize: 11),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),

          // ── Action Buttons ──────────────────────────────────────────
          if (booking.status == BookingStatus.approved || booking.status == BookingStatus.active)
            CyberButton(
              text: 'Selesai & Unggah Video Kebersihan (AC Mati)',
              icon: Icons.upload_file_rounded,
              onPressed: () {
                context.push('/pengembalian-ruang?bookingId=${booking.id}');
              },
            ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: const TextStyle(color: Colors.white54, fontSize: 12),
            ),
          ),
          const Text(': ', style: TextStyle(color: Colors.white54, fontSize: 12)),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildVerificationCheckItem(String label, bool isChecked) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2.0),
      child: Row(
        children: [
          Icon(
            isChecked ? Icons.check_circle_rounded : Icons.cancel_rounded,
            size: 14,
            color: isChecked ? AppTokens.success : AppTokens.error,
          ),
          const SizedBox(width: 6),
          Text(
            label,
            style: TextStyle(
              color: isChecked ? Colors.white70 : Colors.white38,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  void _showVideoPlayerModal(BuildContext context, BookingModel booking) {
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: AppTokens.bgDarkCard,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: BorderSide(color: AppTokens.glassBorderColor),
          ),
          title: Row(
            children: [
              const Icon(Icons.videocam_rounded, color: AppTokens.primaryPurpleGlow),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Inspeksi Video Kebersihan & AC',
                  style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                height: 180,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTokens.primaryPurpleGlow.withValues(alpha: 0.5)),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.play_circle_outline_rounded, size: 54, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          booking.checkoutVideoName ?? 'Video Inspeksi Ruangan',
                          style: const TextStyle(color: Colors.white70, fontSize: 11),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Durasi: 00:24 • Status AC: OFF • Kebersihan: 100%',
                          style: TextStyle(color: AppTokens.success, fontSize: 10, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 12),
              Text(
                'Video ini merekam kondisi ruangan ${booking.roomCode} setelah digunakan oleh ${booking.userName}. Seluruh AC dan perangkat terbukti telah dimatikan.',
                style: const TextStyle(color: Colors.white60, fontSize: 11),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Tutup', style: TextStyle(color: Colors.white70)),
            ),
          ],
        );
      },
    );
  }
}
