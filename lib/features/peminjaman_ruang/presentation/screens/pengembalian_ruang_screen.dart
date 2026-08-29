import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/cyber_button.dart';
import '../../../../shared/widgets/cyber_card.dart';
import '../providers/booking_provider.dart';

class PengembalianRuangScreen extends ConsumerStatefulWidget {
  final String bookingId;

  const PengembalianRuangScreen({super.key, required this.bookingId});

  @override
  ConsumerState<PengembalianRuangScreen> createState() =>
      _PengembalianRuangScreenState();
}

class _PengembalianRuangScreenState
    extends ConsumerState<PengembalianRuangScreen> {
  bool _acOff = false;
  bool _lightsOff = false;
  bool _pcOff = false;
  bool _cleanliness = false;
  bool _doorsLocked = false;

  PlatformFile? _pickedVideo;
  final TextEditingController _notesCtrl = TextEditingController();
  bool _isSubmitting = false;

  @override
  void dispose() {
    _notesCtrl.dispose();
    super.dispose();
  }

  bool get _canSubmit {
    return _acOff &&
        _lightsOff &&
        _pcOff &&
        _cleanliness &&
        _doorsLocked &&
        _pickedVideo != null;
  }

  Future<void> _pickVideo() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['mp4', 'mov', 'avi', 'mkv', 'webm'],
        withData: true,
      );

      if (result != null && result.files.isNotEmpty) {
        setState(() {
          _pickedVideo = result.files.first;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Gagal memilih video: $e'), backgroundColor: AppTokens.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final allBookings = ref.watch(bookingListProvider);
    final booking = allBookings.firstWhere(
      (b) => b.id == widget.bookingId,
      orElse: () => allBookings.first,
    );

    return Scaffold(
      backgroundColor: AppTokens.bgDark,
      appBar: AppBar(
        backgroundColor: AppTokens.bgDarkSurface,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Pengembalian & Bukti Kebersihan',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'SOP Serah Terima Ruang & Pemadaman AC/Listrik',
              style: TextStyle(fontSize: 11, color: Colors.white60),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // ── Booking Summary Header ────────────────────────────────
          CyberCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppTokens.primaryPurple.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          booking.bookingCode,
                          style: const TextStyle(
                            color: AppTokens.primaryPurpleGlow,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        booking.statusLabel,
                        style: const TextStyle(color: AppTokens.accentGold, fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    '${booking.roomCode} - ${booking.roomName}',
                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${booking.day}, ${DateFormat('dd MMMM yyyy', 'id_ID').format(booking.bookingDate)} • ${booking.sessionRangeLabel}',
                    style: const TextStyle(color: Colors.white70, fontSize: 12),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Peminjam: ${booking.userName} (${booking.userNimNip})',
                    style: const TextStyle(color: Colors.white54, fontSize: 12),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Checklist Wajib SOP ────────────────────────────────────
          CyberCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.checklist_rounded, color: AppTokens.accentGold, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Checklist Wajib Sebelum Meninggalkan Ruangan',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Semua poin di bawah ini wajib dicentang dan diverifikasi oleh peminjam.',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 14),

                  _buildChecklistTile(
                    title: 'Seluruh Unit AC telah dimatikan (Power OFF)',
                    subtitle: 'Remote AC telah diletakkan kembali di meja instruktur/dudukan.',
                    icon: Icons.ac_unit_rounded,
                    iconColor: AppTokens.info,
                    value: _acOff,
                    onChanged: (val) => setState(() => _acOff = val ?? false),
                  ),
                  const Divider(color: Colors.white12, height: 1),

                  _buildChecklistTile(
                    title: 'Lampu Penerangan Ruangan telah dipadamkan',
                    subtitle: 'Saklar utama lampu dalam posisi OFF.',
                    icon: Icons.lightbulb_outline_rounded,
                    iconColor: AppTokens.accentGold,
                    value: _lightsOff,
                    onChanged: (val) => setState(() => _lightsOff = val ?? false),
                  ),
                  const Divider(color: Colors.white12, height: 1),

                  _buildChecklistTile(
                    title: 'Semua Komputer & Perangkat Lab telah Dishutdown',
                    subtitle: 'Monitor, CPU, proyektor, dan terminal listrik dimatikan.',
                    icon: Icons.power_settings_new_rounded,
                    iconColor: AppTokens.error,
                    value: _pcOff,
                    onChanged: (val) => setState(() => _pcOff = val ?? false),
                  ),
                  const Divider(color: Colors.white12, height: 1),

                  _buildChecklistTile(
                    title: 'Ruangan Bersih & Sampah Telah Dibuang',
                    subtitle: 'Meja/kursi tertata rapi, papan tulis bersih, bebas sisa makanan.',
                    icon: Icons.cleaning_services_rounded,
                    iconColor: AppTokens.success,
                    value: _cleanliness,
                    onChanged: (val) => setState(() => _cleanliness = val ?? false),
                  ),
                  const Divider(color: Colors.white12, height: 1),

                  _buildChecklistTile(
                    title: 'Pintu & Jendela Terkunci Aman',
                    subtitle: 'Kunci siap diserahkan ke Laboran / Pos Teknisi TIK.',
                    icon: Icons.lock_outline_rounded,
                    iconColor: AppTokens.primaryPurpleGlow,
                    value: _doorsLocked,
                    onChanged: (val) => setState(() => _doorsLocked = val ?? false),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // ── Video Upload Section ──────────────────────────────────
          CyberCard(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.videocam_rounded, color: AppTokens.primaryPurpleGlow, size: 20),
                      SizedBox(width: 8),
                      Text(
                        'Unggah Video Bukti Kebersihan & AC Mati',
                        style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Rekam video singkat (10-30 detik) menyorot kondisi saklar/layar AC mati, kebersihan meja, komputer mati, dan pintu terkunci.',
                    style: TextStyle(color: Colors.white54, fontSize: 11),
                  ),
                  const SizedBox(height: 14),

                  if (_pickedVideo == null)
                    InkWell(
                      onTap: _pickVideo,
                      borderRadius: BorderRadius.circular(12),
                      child: Container(
                        height: 130,
                        width: double.infinity,
                        decoration: BoxDecoration(
                          color: AppTokens.bgDarkSurface,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AppTokens.primaryPurpleGlow.withValues(alpha: 0.5),
                            style: BorderStyle.solid,
                            width: 1.5,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppTokens.primaryPurple.withValues(alpha: 0.2),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(
                                Icons.video_call_rounded,
                                color: AppTokens.primaryPurpleGlow,
                                size: 32,
                              ),
                            ),
                            const SizedBox(height: 10),
                            const Text(
                              'Klik untuk Pilih / Rekam Video (.MP4 / .MOV)',
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 13,
                              ),
                            ),
                            const SizedBox(height: 4),
                            const Text(
                              'Maksimal ukuran berkas: 50 MB',
                              style: TextStyle(color: Colors.white38, fontSize: 11),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: AppTokens.bgDarkSurface,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: AppTokens.success, width: 1.5),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              color: AppTokens.success.withValues(alpha: 0.2),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(Icons.movie_creation_rounded, color: AppTokens.success, size: 24),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _pickedVideo!.name,
                                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Ukuran: ${(_pickedVideo!.size / (1024 * 1024)).toStringAsFixed(2)} MB • Siap Diverifikasi',
                                  style: const TextStyle(color: AppTokens.success, fontSize: 11),
                                ),
                              ],
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.edit_rounded, color: Colors.white70),
                            onPressed: _pickVideo,
                            tooltip: 'Ganti Video',
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete_outline_rounded, color: AppTokens.error),
                            onPressed: () => setState(() => _pickedVideo = null),
                            tooltip: 'Hapus',
                          ),
                        ],
                      ),
                    ),
                  const SizedBox(height: 14),

                  // Catatan Tambahan
                  TextField(
                    controller: _notesCtrl,
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 2,
                    decoration: InputDecoration(
                      labelText: 'Catatan Serah Terima (Opsional)',
                      labelStyle: const TextStyle(color: Colors.white70, fontSize: 12),
                      hintText: 'Misal: Kunci diserahkan ke Pak Munawir di ruang laboran lantai 1...',
                      hintStyle: const TextStyle(color: Colors.white24, fontSize: 12),
                      filled: true,
                      fillColor: AppTokens.bgDarkSurface,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // ── Submit Checkout Button ────────────────────────────────
          CyberButton(
            text: _canSubmit
                ? 'Kirim Bukti & Selesaikan Peminjaman'
                : 'Lengkapi Checklist & Unggah Video',
            icon: Icons.check_circle_outline_rounded,
            isLoading: _isSubmitting,
            onPressed: _canSubmit ? _handleSubmitCheckout : null,
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  Widget _buildChecklistTile({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color iconColor,
    required bool value,
    required ValueChanged<bool?> onChanged,
  }) {
    return CheckboxListTile(
      value: value,
      onChanged: onChanged,
      contentPadding: const EdgeInsets.symmetric(vertical: 4),
      activeColor: AppTokens.primaryPurple,
      checkColor: Colors.white,
      secondary: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, size: 18, color: iconColor),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: value ? Colors.white : Colors.white70,
          fontWeight: value ? FontWeight.bold : FontWeight.normal,
          fontSize: 13,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: const TextStyle(color: Colors.white38, fontSize: 11),
      ),
    );
  }

  Future<void> _handleSubmitCheckout() async {
    setState(() => _isSubmitting = true);

    final videoName = _pickedVideo?.name ?? 'video_checkout_${DateTime.now().millisecondsSinceEpoch}.mp4';
    const mockVideoUrl = 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4';

    await ref.read(bookingListProvider.notifier).submitRoomCheckout(
          bookingId: widget.bookingId,
          isClean: _cleanliness,
          isAcOff: _acOff,
          isLightsOff: _lightsOff,
          isPcOff: _pcOff,
          isDoorsLocked: _doorsLocked,
          videoName: videoName,
          videoUrl: mockVideoUrl,
          notes: _notesCtrl.text.trim(),
        );

    setState(() => _isSubmitting = false);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Bukti kebersihan & pemadaman AC berhasil diunggah! Peminjaman selesai.'),
          backgroundColor: AppTokens.success,
        ),
      );
      context.pushReplacement('/detail-peminjaman?bookingId=${widget.bookingId}');
    }
  }
}
