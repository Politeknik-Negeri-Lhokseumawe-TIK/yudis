import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/models/booking_model.dart';
import '../../domain/models/roster_item_model.dart';
import '../providers/booking_provider.dart';
import '../providers/receptionist_provider.dart';
import '../providers/roster_provider.dart';

class KioskMahasiswaScreen extends ConsumerStatefulWidget {
  const KioskMahasiswaScreen({super.key});

  @override
  ConsumerState<KioskMahasiswaScreen> createState() =>
      _KioskMahasiswaScreenState();
}

class _KioskMahasiswaScreenState extends ConsumerState<KioskMahasiswaScreen> {
  String _selectedProdi = 'TRKJ'; // 'TRKJ', 'TRMM', 'TI'
  late String _selectedDay;
  String _searchClassQuery = '';

  // Timer Jam & Auto Reset
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
    final dayName = _getTodayDayName();
    _selectedDay = (dayName == 'Sabtu' || dayName == 'Minggu') ? 'Senin' : dayName;

    _clockTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _clockTimer.cancel();
    super.dispose();
  }

  String _getTodayDayName() {
    switch (_currentTime.weekday) {
      case 1:
        return 'Senin';
      case 2:
        return 'Selasa';
      case 3:
        return 'Rabu';
      case 4:
        return 'Kamis';
      case 5:
        return 'Jumat';
      case 6:
        return 'Sabtu';
      case 7:
        return 'Minggu';
      default:
        return 'Senin';
    }
  }

  void _showTakeKeyDialog(RosterItemModel item) {
    final activeOfficer = ref.read(activeOfficerProvider);
    final nameCtrl = TextEditingController();
    final nimCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final formKey = GlobalKey<FormState>();
    bool isSubmitting = false;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return Dialog(
            backgroundColor: Colors.transparent,
            insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
            child: Container(
              width: 560,
              decoration: BoxDecoration(
                color: const Color(0xFF0D1322),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppTokens.accentGold, width: 1.5),
                boxShadow: [
                  BoxShadow(
                    color: AppTokens.accentGold.withValues(alpha: 0.2),
                    blurRadius: 30,
                    spreadRadius: 2,
                  ),
                ],
              ),
              padding: const EdgeInsets.all(24),
              child: Form(
                key: formKey,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header Form
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTokens.accentGold.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(Icons.vpn_key_rounded, color: AppTokens.accentGold, size: 24),
                        ),
                        const SizedBox(width: 14),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Form Pengambilan Kunci Ruang PBM',
                                style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.w900),
                              ),
                              Text(
                                'Kelas ${item.className} • ${item.courseName}',
                                style: const TextStyle(color: AppTokens.accentGold, fontSize: 12, fontWeight: FontWeight.w600),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded, color: Colors.white54),
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    const Divider(color: Colors.white12, height: 1),
                    const SizedBox(height: 16),

                    // Detail Jadwal Roster Box
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E293B),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFF334155)),
                      ),
                      child: Column(
                        children: [
                          _detailRow('Ruangan yang Dituju', item.roomCode, isHighlight: true),
                          const SizedBox(height: 6),
                          _detailRow('Dosen Pengajar', item.lecturerName),
                          const SizedBox(height: 6),
                          _detailRow('Waktu / Jam Sesi', '${item.day}, Sesi ${item.startSession}-${item.endSession} (${item.startTime} - ${item.endTime} WIB)'),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Input Identitas Komti / Mahasiswa
                    const Text(
                      'Identitas Ketua Tingkat (Komti) / Perwakilan Mahasiswa:',
                      style: TextStyle(color: Colors.white70, fontSize: 12, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),

                    TextFormField(
                      controller: nameCtrl,
                      style: const TextStyle(color: Colors.white, fontSize: 13),
                      decoration: const InputDecoration(
                        labelText: 'Nama Lengkap Mahasiswa / Komti',
                        prefixIcon: Icon(Icons.person_rounded, color: AppTokens.primaryPurpleGlow),
                        hintText: 'Contoh: Muhammad Al-Fatih',
                      ),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Nama wajib diisi' : null,
                    ),
                    const SizedBox(height: 10),

                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            controller: nimCtrl,
                            keyboardType: TextInputType.number,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: const InputDecoration(
                              labelText: 'NIM Mahasiswa',
                              prefixIcon: Icon(Icons.badge_rounded, color: AppTokens.accentGold),
                              hintText: 'Contoh: 220401015',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'NIM wajib diisi' : null,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextFormField(
                            controller: phoneCtrl,
                            keyboardType: TextInputType.phone,
                            style: const TextStyle(color: Colors.white, fontSize: 13),
                            decoration: const InputDecoration(
                              labelText: 'No. WhatsApp / HP',
                              prefixIcon: Icon(Icons.phone_rounded, color: AppTokens.success),
                              hintText: 'Contoh: 08123456789',
                            ),
                            validator: (v) => v == null || v.trim().isEmpty ? 'No. HP wajib diisi' : null,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Petugas Jaga Notice
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1B4B).withValues(alpha: 0.7),
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTokens.accentGold.withValues(alpha: 0.5)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.info_outline_rounded, color: AppTokens.accentGold, size: 18),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'Kunci akan diserahkan langsung oleh Dosen/Petugas Piket: ${activeOfficer.name} (NIP: ${activeOfficer.nip}) di Komputer 1.',
                              style: const TextStyle(color: Colors.white, fontSize: 11),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),

                    // Tombol Submit
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTokens.success,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                        ),
                        icon: isSubmitting
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                              )
                            : const Icon(Icons.send_rounded, size: 18),
                        label: Text(
                          isSubmitting ? 'Memproses Pengajuan...' : 'KIRIM PERMOHONAN KUNCI KE RESEPSIONIS',
                          style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, letterSpacing: 0.5),
                        ),
                        onPressed: isSubmitting
                            ? null
                            : () async {
                                if (!formKey.currentState!.validate()) return;
                                setDialogState(() => isSubmitting = true);

                                final bookingCode =
                                    'PBM-${DateFormat('yyyyMMdd').format(_currentTime)}-${item.roomCode}-${100 + DateTime.now().millisecond}';

                                final newBooking = BookingModel(
                                  id: 'BKG-${DateTime.now().millisecondsSinceEpoch}',
                                  bookingCode: bookingCode,
                                  userId: 'kiosk-student',
                                  userName: '${nameCtrl.text.trim()} (Komti ${item.className})',
                                  userNimNip: nimCtrl.text.trim(),
                                  userPhone: phoneCtrl.text.trim(),
                                  userRole: 'Mahasiswa (Komti ${item.className})',
                                  roomCode: item.roomCode,
                                  roomName: 'Ruang ${item.roomCode}',
                                  bookingDate: _currentTime,
                                  day: item.day,
                                  startSession: item.startSession,
                                  endSession: item.endSession,
                                  startTime: item.startTime,
                                  endTime: item.endTime,
                                  purpose: 'Perkuliahan Roster: ${item.courseName}',
                                  description: 'Kelas ${item.className} • Dosen: ${item.lecturerName}',
                                  supervisorLecturer: item.lecturerName,
                                  status: BookingStatus.approved, // Langsung status approved (siap serah kunci)
                                  createdAt: DateTime.now(),
                                );

                                await ref.read(bookingListProvider.notifier).createBooking(newBooking);

                                if (!dialogCtx.mounted) return;
                                Navigator.pop(dialogCtx);
                                _showSuccessDialog(item, nameCtrl.text.trim(), activeOfficer);
                              },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showSuccessDialog(RosterItemModel item, String komtiName, dynamic officer) {
    int countdown = 15;
    Timer? countdownTimer;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          countdownTimer ??= Timer.periodic(const Duration(seconds: 1), (t) {
            if (countdown > 1) {
              setDialogState(() => countdown--);
            } else {
              t.cancel();
              if (dialogCtx.mounted) Navigator.pop(dialogCtx);
            }
          });

          return Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: 500,
              padding: const EdgeInsets.all(28),
              decoration: BoxDecoration(
                color: const Color(0xFF0B132B),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppTokens.success, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: AppTokens.success.withValues(alpha: 0.25),
                    blurRadius: 40,
                    spreadRadius: 4,
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 70,
                    height: 70,
                    decoration: BoxDecoration(
                      color: AppTokens.success.withValues(alpha: 0.2),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.check_circle_rounded, color: AppTokens.success, size: 48),
                  ),
                  const SizedBox(height: 16),
                  const Text(
                    'PERMOHONAN KUNCI TERKIRIM!',
                    style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Kelas ${item.className} • Ruang ${item.roomCode}',
                    style: const TextStyle(color: AppTokens.accentGold, fontSize: 14, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: const Color(0xFF334155)),
                    ),
                    child: Column(
                      children: [
                        const Text(
                          '👉 LANGKAH SELANJUTNYA:',
                          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.bold, fontSize: 12),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Silakan langsung menuju ke KOMPUTER 1 (Meja Resepsionis) untuk menerima kunci fisik dari Dosen/Petugas Piket:',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: Colors.white.withValues(alpha: 0.8), fontSize: 12),
                        ),
                        const SizedBox(height: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: AppTokens.accentGold.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '👨‍🏫 ${officer.name}\n(NIP: ${officer.nip})',
                            textAlign: TextAlign.center,
                            style: const TextStyle(color: AppTokens.accentGold, fontWeight: FontWeight.w900, fontSize: 12.5),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF1E1B4B),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    onPressed: () {
                      countdownTimer?.cancel();
                      Navigator.pop(dialogCtx);
                    },
                    child: Text('Selesai (Kembali dalam ${countdown}d)', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool isHighlight = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Colors.white54, fontSize: 11)),
        Text(
          value,
          style: TextStyle(
            color: isHighlight ? AppTokens.accentGold : Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: isHighlight ? 13 : 11.5,
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeOfficer = ref.watch(activeOfficerProvider);
    final allSchedules = ref.watch(allRosterSchedulesProvider);
    final allBookings = ref.watch(bookingListProvider);

    final timeStr = DateFormat('HH:mm:ss').format(_currentTime);
    final dateStr = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_currentTime);

    // Filter jadwal berdasarkan Prodi, Hari ini, dan Search
    final todaySchedules = allSchedules.where((s) {
      if (s.studyProgram.toUpperCase() != _selectedProdi.toUpperCase()) return false;
      if (s.day.toLowerCase() != _selectedDay.toLowerCase()) return false;
      if (_searchClassQuery.isNotEmpty) {
        final q = _searchClassQuery.toLowerCase();
        return s.className.toLowerCase().contains(q) ||
            s.courseName.toLowerCase().contains(q) ||
            s.roomCode.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF060913),
      body: Column(
        children: [
          // ── 1. KIOSK TOP BAR WITH LIVE OFFICER INTEGRATION ──────────
          _buildKioskHeader(timeStr, dateStr, activeOfficer),

          // ── 2. PRODI & DAY SELECTOR BAR ─────────────────────────────
          _buildProdiSelectorBar(),

          // ── 3. ROSTER CLASS GRID (TODAY SCHEDULES) ──────────────────
          Expanded(
            child: todaySchedules.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.event_busy_rounded, color: Colors.white.withValues(alpha: 0.2), size: 64),
                        const SizedBox(height: 14),
                        Text(
                          'Tidak ada jadwal perkuliahan $_selectedDay untuk Prodi $_selectedProdi',
                          style: const TextStyle(color: Colors.white60, fontSize: 14, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'Pilih Hari atau Program Studi lain di atas untuk melihat jadwal perkuliahan.',
                          style: TextStyle(color: Colors.white38, fontSize: 11),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: const EdgeInsets.all(20),
                    gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 3,
                      crossAxisSpacing: 16,
                      mainAxisSpacing: 16,
                      childAspectRatio: 1.35,
                    ),
                    itemCount: todaySchedules.length,
                    itemBuilder: (ctx, idx) {
                      final item = todaySchedules[idx];
                      final isKeyActive = allBookings.any((b) =>
                          b.roomCode == item.roomCode &&
                          b.status == BookingStatus.active &&
                          b.startSession == item.startSession);

                      return _buildScheduleCard(item, isKeyActive);
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── HEADER KIOSK DENGAN STATUS TERHUBUNG KE RESEPSIONIS ──────────────
  Widget _buildKioskHeader(String timeStr, String dateStr, dynamic officer) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1322),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1.5)),
      ),
      child: Row(
        children: [
          // Logo Kiosk
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: const LinearGradient(colors: [Color(0xFF0284C7), Color(0xFF0369A1)]),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.touch_app_rounded, color: Colors.white, size: 26),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    'TERMINAL MANDIRI KELAS PBM TIK PNL',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5),
                  ),
                  SizedBox(width: 8),
                  Text('• KIOSK MAHASISWA', style: TextStyle(color: AppTokens.accentGold, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              Text(
                'Pengambilan Kunci Ruang Laboratorium & Kelas Berdasarkan Jadwal Roster Semester',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
              ),
            ],
          ),
          const Spacer(),

          // ── Banner Live Dosen Piket Jaga Terhubung ke PC 1 ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF1E1B4B),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppTokens.accentGold, width: 1.2),
            ),
            child: Row(
              children: [
                const Icon(Icons.verified_user_rounded, color: AppTokens.accentGold, size: 20),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'TERHUBUNG KE MEJA RESEPSIONIS (PC 1)',
                      style: TextStyle(color: Colors.white70, fontSize: 9.5, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      'Dosen/Petugas Piket: ${officer.name} (NIP: ${officer.nip})',
                      style: const TextStyle(color: AppTokens.accentGold, fontSize: 11.5, fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Clock
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF0F172A),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '$timeStr WIB',
                  style: const TextStyle(color: Colors.white, fontFamily: 'monospace', fontWeight: FontWeight.w900, fontSize: 14),
                ),
                Text(dateStr, style: const TextStyle(color: Colors.white54, fontSize: 10)),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Switch ke Resepsionis (Admin)
          IconButton(
            tooltip: 'Masuk Meja Resepsionis (Admin)',
            icon: const Icon(Icons.admin_panel_settings_rounded, color: Colors.white54),
            onPressed: () => context.push('/resepsionis'),
          ),
        ],
      ),
    );
  }

  // ── SELECTOR PRODI & HARI & KELAS SEARCH ─────────────────────────────
  Widget _buildProdiSelectorBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF090D1A),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        children: [
          // Prodi Selector
          const Text(
            'PRODI: ',
            style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          _prodiButton('TRKJ', 'Teknologi Rekayasa Komputer Jaringan'),
          const SizedBox(width: 6),
          _prodiButton('TRMM', 'Teknologi Rekayasa Multimedia'),
          const SizedBox(width: 6),
          _prodiButton('TI', 'Teknik Informatika'),
          const SizedBox(width: 20),

          // Day Selector
          const Text(
            'HARI: ',
            style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 8),
          ...['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'].map((day) {
            final isDaySelected = _selectedDay.toLowerCase() == day.toLowerCase();
            return Padding(
              padding: const EdgeInsets.only(right: 6),
              child: InkWell(
                onTap: () => setState(() => _selectedDay = day),
                borderRadius: BorderRadius.circular(6),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDaySelected ? const Color(0xFF0284C7) : const Color(0xFF1E293B),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(
                      color: isDaySelected ? Colors.white70 : Colors.white12,
                    ),
                  ),
                  child: Text(
                    day,
                    style: TextStyle(
                      color: isDaySelected ? Colors.white : Colors.white60,
                      fontWeight: FontWeight.bold,
                      fontSize: 11,
                    ),
                  ),
                ),
              ),
            );
          }),
          const Spacer(),

          // Search Kelas
          SizedBox(
            width: 240,
            height: 36,
            child: TextField(
              style: const TextStyle(color: Colors.white, fontSize: 12),
              decoration: InputDecoration(
                hintText: 'Cari Kelas (contoh: TRKJ 1A)...',
                hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54, size: 16),
                filled: true,
                fillColor: const Color(0xFF1E293B),
                contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 0),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8), borderSide: BorderSide.none),
              ),
              onChanged: (v) => setState(() => _searchClassQuery = v),
            ),
          ),
        ],
      ),
    );
  }

  Widget _prodiButton(String prodiKey, String fullName) {
    final isSelected = _selectedProdi == prodiKey;

    return InkWell(
      onTap: () => setState(() => _selectedProdi = prodiKey),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppTokens.primaryPurple : const Color(0xFF1E293B),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: isSelected ? AppTokens.primaryPurpleGlow : Colors.white12,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Text(
          prodiKey,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.white70,
            fontWeight: FontWeight.w900,
            fontSize: 13,
          ),
        ),
      ),
    );
  }

  // ── KARTU JADWAL PERKULIAHAN ROSTER ──────────────────────────────────
  Widget _buildScheduleCard(RosterItemModel item, bool isKeyActive) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isKeyActive ? AppTokens.error.withValues(alpha: 0.8) : const Color(0xFF1E293B),
          width: isKeyActive ? 1.5 : 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Card: Kelas & Ruangan
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTokens.primaryPurple.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.className,
                  style: const TextStyle(color: AppTokens.primaryPurpleGlow, fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTokens.accentGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  item.roomCode,
                  style: const TextStyle(color: AppTokens.accentGold, fontWeight: FontWeight.w900, fontSize: 13),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: isKeyActive ? AppTokens.error.withValues(alpha: 0.2) : AppTokens.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  isKeyActive ? 'KUNCI AKTIF' : 'KUNCI DI RAK',
                  style: TextStyle(
                    color: isKeyActive ? AppTokens.error : AppTokens.success,
                    fontSize: 9,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Nama Mata Kuliah
          Text(
            item.courseName,
            style: const TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w800),
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),

          // Dosen Pengajar
          Row(
            children: [
              const Icon(Icons.school_rounded, size: 13, color: Colors.white54),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.lecturerName,
                  style: const TextStyle(color: Colors.white70, fontSize: 11),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),

          // Jam Sesi
          Row(
            children: [
              const Icon(Icons.access_time_rounded, size: 13, color: Colors.white54),
              const SizedBox(width: 6),
              Text(
                'Sesi ${item.startSession}-${item.endSession} • ${item.startTime} - ${item.endTime} WIB',
                style: const TextStyle(color: Colors.white60, fontSize: 11, fontFamily: 'monospace'),
              ),
            ],
          ),
          const Spacer(),

          // Tombol Ambil Kunci
          SizedBox(
            width: double.infinity,
            height: 38,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isKeyActive ? const Color(0xFF334155) : const Color(0xFF0284C7),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              icon: Icon(isKeyActive ? Icons.lock_clock_rounded : Icons.vpn_key_rounded, size: 16),
              label: Text(
                isKeyActive ? 'Kunci Sedang Digunakan' : 'Ambil Kunci Kelas Ini',
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 11.5),
              ),
              onPressed: isKeyActive ? null : () => _showTakeKeyDialog(item),
            ),
          ),
        ],
      ),
    );
  }
}
