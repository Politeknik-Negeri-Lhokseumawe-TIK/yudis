import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/ui_primitives.dart';
import '../../domain/models/booking_model.dart';
import '../../domain/models/receptionist_officer_model.dart';
import '../../domain/models/room_model.dart';
import '../../domain/models/roster_item_model.dart';
import '../providers/booking_provider.dart';
import '../providers/receptionist_provider.dart';
import '../providers/roster_provider.dart';
import '../widgets/slip_tanda_terima_dialog.dart';

class CounterResepsionisScreen extends ConsumerStatefulWidget {
  const CounterResepsionisScreen({super.key});

  @override
  ConsumerState<CounterResepsionisScreen> createState() =>
      _CounterResepsionisScreenState();
}

class _CounterResepsionisScreenState
    extends ConsumerState<CounterResepsionisScreen> {
  // Search & Filter
  final TextEditingController _searchCtrl = TextEditingController();
  String _searchQuery = '';

  // Timer Jam Digital WIB
  late Timer _clockTimer;
  DateTime _currentTime = DateTime.now();

  @override
  void initState() {
    super.initState();
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
    _searchCtrl.dispose();
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

  int _getCurrentSession() {
    final hour = _currentTime.hour;
    final minute = _currentTime.minute;
    final totalMinutes = hour * 60 + minute;

    if (totalMinutes >= 7 * 60 + 30 && totalMinutes < 8 * 60 + 20) return 1;
    if (totalMinutes >= 8 * 60 + 20 && totalMinutes < 9 * 60 + 10) return 2;
    if (totalMinutes >= 9 * 60 + 10 && totalMinutes < 10 * 60 + 0) return 3;
    if (totalMinutes >= 10 * 60 + 15 && totalMinutes < 11 * 60 + 5) return 4;
    if (totalMinutes >= 11 * 60 + 5 && totalMinutes < 11 * 60 + 55) return 5;
    if (totalMinutes >= 11 * 60 + 55 && totalMinutes < 12 * 60 + 45) return 6;
    if (totalMinutes >= 13 * 60 + 30 && totalMinutes < 14 * 60 + 20) return 7;
    if (totalMinutes >= 14 * 60 + 20 && totalMinutes < 15 * 60 + 10) return 8;
    if (totalMinutes >= 15 * 60 + 30 && totalMinutes < 16 * 60 + 20) return 9;
    if (totalMinutes >= 16 * 60 + 20 && totalMinutes < 17 * 60 + 10) return 10;
    if (totalMinutes >= 17 * 60 + 10 && totalMinutes < 18 * 60 + 0) return 11;

    return 1; // Default sesi pagi
  }

  void _showOfficerSwitchModal(OfficersState officersState) {
    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return AlertDialog(
            backgroundColor: AppTokens.bgDarkCard,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
              side: BorderSide(color: AppTokens.glassBorderColor),
            ),
            title: Row(
              children: [
                const Icon(Icons.badge_rounded, color: AppTokens.accentGold),
                const SizedBox(width: 8),
                const Text(
                  'Dosen / Petugas Piket Jaga Resepsionis (Nama & NIP)',
                  style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                TextButton.icon(
                  style: TextButton.styleFrom(foregroundColor: AppTokens.primaryPurpleGlow),
                  icon: const Icon(Icons.person_add_rounded, size: 16),
                  label: const Text('+ Tambah Dosen Jaga Baru', style: TextStyle(fontSize: 11)),
                  onPressed: () {
                    _showAddEditOfficerDialog((newOfficer) {
                      ref.read(officersProvider.notifier).addOfficer(newOfficer);
                      setDialogState(() {});
                    });
                  },
                ),
              ],
            ),
            content: SizedBox(
              width: 540,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: officersState.officers.map((officer) {
                  final isSelected = officer.id == officersState.activeOfficer.id;
                  return Container(
                    margin: const EdgeInsets.only(bottom: 8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTokens.primaryPurple.withValues(alpha: 0.25)
                          : AppTokens.bgDarkSurface,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected ? AppTokens.primaryPurpleGlow : Colors.white12,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTokens.accentGold.withValues(alpha: 0.2),
                        child: Text(
                          officer.avatarInitials,
                          style: const TextStyle(color: AppTokens.accentGold, fontWeight: FontWeight.bold),
                        ),
                      ),
                      title: Row(
                        children: [
                          Text(
                            officer.name,
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                          ),
                          const SizedBox(width: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1.5),
                            decoration: BoxDecoration(
                              color: AppTokens.accentGold.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'NIP: ${officer.nip}',
                              style: const TextStyle(color: AppTokens.accentGold, fontSize: 9.5, fontWeight: FontWeight.bold),
                            ),
                          ),
                        ],
                      ),
                      subtitle: Text(
                        '${officer.roleTitle} • ${officer.shiftName} (${officer.shiftHours})',
                        style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                      ),
                      trailing: isSelected
                          ? const Icon(Icons.check_circle_rounded, color: AppTokens.success, size: 20)
                          : null,
                      onTap: () {
                        ref.read(officersProvider.notifier).setActiveOfficer(officer);
                        Navigator.of(ctx).pop();
                      },
                    ),
                  );
                }).toList(),
              ),
            ),
          );
        },
      ),
    );
  }

  void _showAddEditOfficerDialog(Function(ReceptionistOfficerModel) onSave) {
    final nameCtrl = TextEditingController();
    final nipCtrl = TextEditingController();
    String shiftName = 'Shift Pagi';
    String shiftHours = '07:30 - 13:00 WIB';
    String roleTitle = 'Dosen Piket / Pengawas PBM';

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTokens.bgDarkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
          side: BorderSide(color: AppTokens.glassBorderColor),
        ),
        title: const Text('Input Data Dosen / Petugas Piket Jaga Baru', style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
        content: SizedBox(
          width: 420,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(labelText: 'Nama Lengkap & Gelar Dosen / Petugas', hintText: 'Contoh: Safriadi, S.T., M.Kom.'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: nipCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(labelText: 'NIP Dosen / Petugas', hintText: 'Contoh: 19850214 201404 1 002'),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                initialValue: shiftName,
                dropdownColor: AppTokens.bgDarkSurface,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: const InputDecoration(labelText: 'Pilihan Shift Piket'),
                items: const [
                  DropdownMenuItem(value: 'Shift Pagi', child: Text('Shift Pagi (07:30 - 13:00 WIB)')),
                  DropdownMenuItem(value: 'Shift Siang', child: Text('Shift Siang (13:00 - 18:00 WIB)')),
                  DropdownMenuItem(value: 'Shift Penuh', child: Text('Shift Penuh Harian (07:30 - 18:00 WIB)')),
                ],
                onChanged: (val) {
                  if (val != null) {
                    shiftName = val;
                    if (val == 'Shift Pagi') shiftHours = '07:30 - 13:00 WIB';
                    if (val == 'Shift Siang') shiftHours = '13:00 - 18:00 WIB';
                    if (val == 'Shift Penuh') shiftHours = '07:30 - 18:00 WIB';
                  }
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Batal', style: TextStyle(color: Colors.white54)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppTokens.primaryPurple),
            onPressed: () {
              if (nameCtrl.text.trim().isEmpty || nipCtrl.text.trim().isEmpty) return;
              final initials = nameCtrl.text.trim().split(' ').map((s) => s.isNotEmpty ? s[0] : '').take(2).join();
              final newOfficer = ReceptionistOfficerModel(
                id: 'OFFICER-${DateTime.now().millisecondsSinceEpoch}',
                name: nameCtrl.text.trim(),
                nip: nipCtrl.text.trim(),
                roleTitle: roleTitle,
                shiftName: shiftName,
                shiftHours: shiftHours,
                counterName: 'MEJA PELAYANAN 1 (LOKET UTAMA)',
                avatarInitials: initials.isNotEmpty ? initials : 'DS',
                department: 'Jurusan Teknologi Informasi & Komputer',
                contactPhone: '0812-0000-0000',
              );
              onSave(newOfficer);
              Navigator.pop(ctx);
            },
            child: const Text('Simpan & Pasang Piket', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final officersState = ref.watch(officersProvider);
    final activeOfficer = officersState.activeOfficer;
    final allBookings = ref.watch(bookingListProvider);
    final allRooms = ref.watch(roomsProvider);
    final allSchedules = ref.watch(allRosterSchedulesProvider);

    final todayDay = _getTodayDayName();
    final currentSession = _getCurrentSession();

    final filteredBookings = allBookings.where((b) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return b.bookingCode.toLowerCase().contains(q) ||
          b.userName.toLowerCase().contains(q) ||
          b.userNimNip.toLowerCase().contains(q) ||
          b.roomCode.toLowerCase().contains(q) ||
          b.purpose.toLowerCase().contains(q);
    }).toList();

    final incomingRequests = allBookings.where((b) => b.status == BookingStatus.approved || b.status == BookingStatus.pending).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Column(
        children: [
          // ── 1. TOP DIGITAL NAMEPLATE DOSEN PIKET RESEPSIONIS (PC 1) ──
          _buildOfficerNameplateHeader(activeOfficer, officersState),

          // ── 2. QUICK SEARCH & KIOSK STATUS BAR ──────────────────────
          _buildQuickSearchBar(),

          // ── 3. WORKSTATION 3-SPLIT PANEL ─────────────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Panel Kiri: Permohonan Kunci Kelas Masuk (dari PC 2 & 3)
                Expanded(
                  flex: 3,
                  child: _buildBorrowerQueuePanel(filteredBookings, incomingRequests, activeOfficer),
                ),

                // Panel Tengah: Rak Gantungan Kunci Fisik 43 Ruangan + Live Roster
                Expanded(
                  flex: 4,
                  child: _buildPhysicalKeyRackPanel(allRooms, allBookings, allSchedules, todayDay, currentSession, activeOfficer),
                ),

                // Panel Kanan: Pengembalian Kunci & Cek Video Selesai Kuliah
                Expanded(
                  flex: 3,
                  child: _buildCheckoutReturnPanel(allBookings, activeOfficer),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER DIGITAL NAMEPLATE DOSEN PIKET RESEPSIONIS ────────────────
  Widget _buildOfficerNameplateHeader(ReceptionistOfficerModel activeOfficer, OfficersState officersState) {
    final timeStr = DateFormat('HH:mm:ss').format(_currentTime);
    final dateStr = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_currentTime);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: const BoxDecoration(
        color: Color(0xFF0D1322),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 1.5)),
      ),
      child: Row(
        children: [
          // Logo & Title
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7C3AED), Color(0xFF4F46E5)],
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Center(
              child: Icon(Icons.account_balance_rounded, color: Colors.white, size: 24),
            ),
          ),
          const SizedBox(width: 14),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Row(
                children: [
                  Text(
                    'SIM-LAB & RUANG PBM TIK PNL',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                      letterSpacing: 0.5,
                    ),
                  ),
                  SizedBox(width: 8),
                  Text('• KOMPUTER 1 (MEJA RESEPSIONIS)', style: TextStyle(color: AppTokens.accentGold, fontSize: 11, fontWeight: FontWeight.bold)),
                ],
              ),
              Text(
                'Pusat Serah-Terima Kunci Fisik Laboratorium & Ruang Kelas Perkuliahan Roster',
                style: TextStyle(color: Colors.white.withValues(alpha: 0.6), fontSize: 11),
              ),
            ],
          ),
          const Spacer(),

          // ── Digital Nameplate Dosen Piket Jaga ──
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTokens.accentGold, width: 1.2),
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 18,
                  backgroundColor: AppTokens.accentGold,
                  child: Text(
                    activeOfficer.avatarInitials,
                    style: const TextStyle(color: Color(0xFF0F172A), fontWeight: FontWeight.w900, fontSize: 12),
                  ),
                ),
                const SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Text(
                          activeOfficer.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w900,
                            fontSize: 12.5,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                          decoration: BoxDecoration(
                            color: AppTokens.success.withValues(alpha: 0.2),
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text('DOSEN PIKET AKTIF', style: TextStyle(color: AppTokens.success, fontSize: 8.5, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                    Text(
                      'NIP: ${activeOfficer.nip} • ${activeOfficer.shiftName} (${activeOfficer.shiftHours})',
                      style: const TextStyle(color: AppTokens.accentGold, fontSize: 10, fontWeight: FontWeight.w600),
                    ),
                  ],
                ),
                const SizedBox(width: 12),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white38),
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    minimumSize: Size.zero,
                  ),
                  icon: const Icon(Icons.swap_horiz_rounded, size: 14),
                  label: const Text('Ganti / Tambah Dosen', style: TextStyle(fontSize: 10)),
                  onPressed: () => _showOfficerSwitchModal(officersState),
                ),
              ],
            ),
          ),
          // Live Clock WIB with Monospace Glow
          DigitalClockWidget(
            time: timeStr,
            dateStr: dateStr,
          ),
          const SizedBox(width: 12),

          // Tombol Buka Kiosk Mandiri (PC 2 & 3)
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            icon: const Icon(Icons.touch_app_rounded, size: 16),
            label: const Text('Buka Kiosk (PC 2/3)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
            onPressed: () => context.push('/kiosk'),
          ),
        ],
      ),
    );
  }

  // ── QUICK SEARCH BAR ────────────────────────────────────────────────
  Widget _buildQuickSearchBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF090D1A),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: const Color(0xFF1E293B),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: const Row(
              children: [
                Icon(Icons.desktop_windows_rounded, color: AppTokens.accentGold, size: 16),
                SizedBox(width: 8),
                Text('TERINTEGRASI DENGAN KIOSK MAHASISWA (PC 2 & PC 3)', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Search Field Cepat Kelas / Ruang / Komti
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Cari cepat Kelas (misal TRKJ 1A), Ruangan (TIK.101), atau Nama Komti/Mahasiswa...',
                  hintStyle: const TextStyle(color: Colors.white38, fontSize: 11),
                  prefixIcon: const Icon(Icons.search_rounded, color: Colors.white54, size: 18),
                  suffixIcon: _searchCtrl.text.isNotEmpty
                      ? IconButton(
                          icon: const Icon(Icons.clear_rounded, size: 16, color: Colors.white54),
                          onPressed: () {
                            _searchCtrl.clear();
                            setState(() => _searchQuery = '');
                          },
                        )
                      : null,
                  filled: true,
                  fillColor: const Color(0xFF1E293B),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 0),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide.none,
                  ),
                ),
                onChanged: (val) => setState(() => _searchQuery = val),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ── PANEL KIRI: PERMOHONAN KUNCI KELAS PBM MASUK ─────────────────────
  Widget _buildBorrowerQueuePanel(
    List<BookingModel> filteredBookings,
    List<BookingModel> incomingRequests,
    ReceptionistOfficerModel activeOfficer,
  ) {
    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_rounded, color: AppTokens.accentGold, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Permohonan Kunci Kelas Masuk',
                style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTokens.primaryPurpleGlow.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${incomingRequests.length} Siap Diserahkan',
                  style: const TextStyle(color: AppTokens.primaryPurpleGlow, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 10),

          // List Permohonan
          Expanded(
            child: filteredBookings.isEmpty
                ? const Center(
                    child: Text(
                      'Belum ada permohonan kunci kelas dari Kiosk PC 2/3.',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  )
                : ListView.builder(
                    itemCount: filteredBookings.length,
                    itemBuilder: (ctx, idx) {
                      final b = filteredBookings[idx];
                      final isReadyToPickup = b.status == BookingStatus.approved || b.status == BookingStatus.pending;
                      final isActive = b.status == BookingStatus.active;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: isReadyToPickup
                              ? const Color(0xFF1E1B4B).withValues(alpha: 0.6)
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isReadyToPickup ? AppTokens.primaryPurpleGlow : Colors.white10,
                            width: isReadyToPickup ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: AppTokens.accentGold.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    b.roomCode,
                                    style: const TextStyle(color: AppTokens.accentGold, fontWeight: FontWeight.w900, fontSize: 11),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    b.userName,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                                  decoration: BoxDecoration(
                                    color: isReadyToPickup ? AppTokens.success.withValues(alpha: 0.2) : (isActive ? AppTokens.info.withValues(alpha: 0.2) : Colors.white10),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    isReadyToPickup ? 'SIAP DISERAHKAN' : (isActive ? 'KUNCI DIBAWA' : 'SELESAI'),
                                    style: TextStyle(
                                      color: isReadyToPickup ? AppTokens.success : (isActive ? AppTokens.info : Colors.white60),
                                      fontSize: 8.5,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Komti/Mahasiswa: NIM ${b.userNimNip} • HP: ${b.userPhone}',
                              style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                            ),
                            Text(
                              b.purpose,
                              style: const TextStyle(color: Colors.white70, fontSize: 10.5, fontWeight: FontWeight.w600),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),

                            // Actions: Serah Kunci & Cetak Slip PBM
                            Row(
                              children: [
                                if (isReadyToPickup)
                                  Expanded(
                                    child: ElevatedButton.icon(
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: AppTokens.success,
                                        foregroundColor: Colors.white,
                                        padding: const EdgeInsets.symmetric(vertical: 6),
                                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                      ),
                                      icon: const Icon(Icons.key_rounded, size: 14),
                                      label: const Text('Serahkan Kunci ke Komti', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      onPressed: () async {
                                        await ref.read(bookingListProvider.notifier).updateStatus(
                                              b.id,
                                              BookingStatus.active,
                                              approvedBy: '${activeOfficer.name} (NIP: ${activeOfficer.nip})',
                                            );
                                        if (!mounted) return;
                                        SlipTandaTerimaDialog.show(
                                          context,
                                          booking: b.copyWith(status: BookingStatus.active),
                                          officer: activeOfficer,
                                        );
                                      },
                                    ),
                                  )
                                else ...[
                                  Expanded(
                                    child: OutlinedButton.icon(
                                      style: OutlinedButton.styleFrom(
                                        side: const BorderSide(color: Colors.white24),
                                        padding: const EdgeInsets.symmetric(vertical: 4),
                                      ),
                                      icon: const Icon(Icons.receipt_long_rounded, size: 14, color: AppTokens.accentGold),
                                      label: const Text('Cetak Slip PBM', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                                      onPressed: () {
                                        SlipTandaTerimaDialog.show(
                                          context,
                                          booking: b,
                                          officer: activeOfficer,
                                        );
                                      },
                                    ),
                                  ),
                                ],
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  // ── PANEL TENGAH: RAK GANTUNGAN KUNCI FISIK 43 RUANGAN ─────────────
  Widget _buildPhysicalKeyRackPanel(
    List<RoomModel> allRooms,
    List<BookingModel> allBookings,
    List<RosterItemModel> allSchedules,
    String todayDay,
    int currentSession,
    ReceptionistOfficerModel activeOfficer,
  ) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.vpn_key_rounded, color: AppTokens.accentGold, size: 18),
              const SizedBox(width: 8),
              Text(
                'Rak Kunci 43 Ruangan • Live $todayDay (Sesi $currentSession)',
                style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              _buildKeyLegend('Di Rak', AppTokens.success),
              const SizedBox(width: 8),
              _buildKeyLegend('Kuliah PBM', const Color(0xFFA855F7)),
              const SizedBox(width: 8),
              _buildKeyLegend('Dibawa Komti', AppTokens.error),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 10),

          // Grid Kunci Fisik
          Expanded(
            child: GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 4,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 1.2,
              ),
              itemCount: allRooms.length,
              itemBuilder: (ctx, idx) {
                final room = allRooms[idx];

                // Cek apakah ada jadwal kuliah PBM hari ini pada sesi aktif
                final activeClass = allSchedules.where((s) {
                  return s.roomCode == room.id &&
                      s.day.toLowerCase() == todayDay.toLowerCase() &&
                      s.startSession <= currentSession &&
                      s.endSession >= currentSession;
                }).firstOrNull;

                // Cek apakah ada peminjaman aktif saat ini
                final activeBooking = allBookings.where((b) {
                  return b.roomCode == room.id && b.status == BookingStatus.active;
                }).firstOrNull;

                final isClassActive = activeClass != null;
                final isKeyBorrowed = activeBooking != null;

                Color cardBorderColor;
                Color statusColor;
                String statusText;
                IconData keyIcon;

                if (isKeyBorrowed) {
                  cardBorderColor = AppTokens.error;
                  statusColor = AppTokens.error;
                  statusText = 'Dibawa: ${activeBooking.userName}';
                  keyIcon = Icons.key_rounded;
                } else if (isClassActive) {
                  cardBorderColor = const Color(0xFFA855F7);
                  statusColor = const Color(0xFFA855F7);
                  statusText = 'Kuliah: ${activeClass.courseName} (${activeClass.className})';
                  keyIcon = Icons.school_rounded;
                } else {
                  cardBorderColor = const Color(0xFF334155);
                  statusColor = AppTokens.success;
                  statusText = 'Tersedia di Rak';
                  keyIcon = Icons.key_rounded;
                }

                return InkWell(
                  onTap: () {
                    if (isKeyBorrowed) {
                      SlipTandaTerimaDialog.show(
                        context,
                        booking: activeBooking,
                        officer: activeOfficer,
                      );
                    } else if (isClassActive) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          backgroundColor: const Color(0xFF1E1B4B),
                          content: Text('📚 Ruang ${room.id} dijadwalkan PBM: ${activeClass.courseName} - Dosen: ${activeClass.lecturerName}'),
                        ),
                      );
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(7),
                    decoration: BoxDecoration(
                      color: isKeyBorrowed
                          ? AppTokens.error.withValues(alpha: 0.12)
                          : isClassActive
                              ? const Color(0xFFA855F7).withValues(alpha: 0.12)
                              : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: cardBorderColor,
                        width: isKeyBorrowed || isClassActive ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(keyIcon, size: 13, color: statusColor),
                            const SizedBox(width: 4),
                            Text(
                              room.id,
                              style: TextStyle(
                                color: isKeyBorrowed ? AppTokens.error : (isClassActive ? const Color(0xFFA855F7) : Colors.white),
                                fontWeight: FontWeight.w900,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          room.name,
                          style: const TextStyle(color: Colors.white70, fontSize: 8.5),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          statusText,
                          style: TextStyle(
                            color: statusColor,
                            fontSize: 8,
                            fontWeight: FontWeight.bold,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // ── PANEL KANAN: PENGEMBALIAN KUNCI & INSPEKSI SELESAI KULIAH ────────
  Widget _buildCheckoutReturnPanel(List<BookingModel> allBookings, ReceptionistOfficerModel activeOfficer) {
    final activeBookings = allBookings.where((b) => b.status == BookingStatus.active).toList();

    return Container(
      margin: const EdgeInsets.all(12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: const Color(0xFF1E293B)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.assignment_turned_in_rounded, color: AppTokens.accentGold, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Pengembalian Kunci Selesai Kuliah',
                style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                decoration: BoxDecoration(
                  color: AppTokens.info.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '${activeBookings.length} Kunci di Kelas',
                  style: const TextStyle(color: AppTokens.info, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 10),

          // List Kunci yang Sedang Dipinjam
          Expanded(
            child: activeBookings.isEmpty
                ? const Center(
                    child: Text(
                      'Semua kunci 43 ruangan berada di rak.',
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  )
                : ListView.builder(
                    itemCount: activeBookings.length,
                    itemBuilder: (ctx, idx) {
                      final b = activeBookings[idx];

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: const Color(0xFF334155)),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  b.roomCode,
                                  style: const TextStyle(color: AppTokens.accentGold, fontWeight: FontWeight.w900, fontSize: 12),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    b.userName,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11.5),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Kuliah: ${b.purpose}',
                              style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Text(
                              'Pukul: ${b.startTime} - ${b.endTime} WIB',
                              style: const TextStyle(color: Colors.white54, fontSize: 10),
                            ),
                            const SizedBox(height: 8),

                            // Tombol Terima Kunci
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF0D9488),
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 6),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                ),
                                icon: const Icon(Icons.download_done_rounded, size: 14),
                                label: const Text('Terima Kunci & Simpan ke Rak', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                                onPressed: () async {
                                  await ref.read(bookingListProvider.notifier).updateStatus(
                                        b.id,
                                        BookingStatus.completed,
                                        laboranReviewNotes: 'Kunci fisik diterima di meja resepsionis oleh ${activeOfficer.name} (NIP: ${activeOfficer.nip})',
                                      );
                                  if (!mounted) return;
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      backgroundColor: AppTokens.success,
                                      content: Text('✅ Kunci ${b.roomCode} berhasil diterima kembali ke rak kunci oleh ${activeOfficer.name}.'),
                                    ),
                                  );
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }

  Widget _buildKeyLegend(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 4),
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 9.5)),
      ],
    );
  }
}
