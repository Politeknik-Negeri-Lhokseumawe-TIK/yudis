import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../domain/models/booking_model.dart';
import '../../domain/models/receptionist_officer_model.dart';
import '../../domain/models/room_model.dart';
import '../providers/booking_provider.dart';
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
  // Petugas aktif saat ini
  ReceptionistOfficerModel _currentOfficer =
      ReceptionistOfficerModel.defaultOfficers[0];

  // Nomor Antrean Berjalan
  int _currentQueueNumber = 1;
  final String _currentQueuePrefix = 'A';

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

  void _callNextQueue() {
    setState(() {
      _currentQueueNumber++;
    });
    final queueCode = '$_currentQueuePrefix-${_currentQueueNumber.toString().padLeft(2, "0")}';
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: const Color(0xFF0F172A),
        duration: const Duration(seconds: 3),
        content: Row(
          children: [
            const Icon(Icons.volume_up_rounded, color: AppTokens.accentGold),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '🔔 Panggilan Antrean: Nomor $queueCode silahkan menuju ${_currentOfficer.counterName}',
                style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showOfficerSwitchModal() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppTokens.bgDarkCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AppTokens.glassBorderColor),
        ),
        title: const Row(
          children: [
            Icon(Icons.badge_rounded, color: AppTokens.accentGold),
            SizedBox(width: 8),
            Text(
              'Ganti Petugas Meja Pelayanan',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: ReceptionistOfficerModel.defaultOfficers.map((officer) {
            final isSelected = officer.id == _currentOfficer.id;
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
                title: Text(
                  officer.name,
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 13),
                ),
                subtitle: Text(
                  '${officer.roleTitle} • ${officer.shiftName} (${officer.shiftHours})',
                  style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle_rounded, color: AppTokens.success, size: 20)
                    : null,
                onTap: () {
                  setState(() => _currentOfficer = officer);
                  Navigator.of(ctx).pop();
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final allBookings = ref.watch(bookingListProvider);
    final allRooms = ref.watch(roomsProvider);

    final filteredBookings = allBookings.where((b) {
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return b.bookingCode.toLowerCase().contains(q) ||
          b.userName.toLowerCase().contains(q) ||
          b.userNimNip.toLowerCase().contains(q) ||
          b.roomCode.toLowerCase().contains(q);
    }).toList();

    final approvedBookings = allBookings.where((b) => b.status == BookingStatus.approved).toList();

    return Scaffold(
      backgroundColor: const Color(0xFF070B14),
      body: Column(
        children: [
          // ── 1. TOP DIGITAL NAMEPLATE MEJA PELAYANAN ALA BANK ─────────
          _buildOfficerNameplateHeader(),

          // ── 2. QUICK ACTION & QUEUE CALLER BAR ──────────────────────
          _buildQueueAndSearchBar(),

          // ── 3. WORKSTATION 3-SPLIT PANEL ─────────────────────────────
          Expanded(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Panel Kiri: Antrean Peminjam & Serah Kunci
                Expanded(
                  flex: 3,
                  child: _buildBorrowerQueuePanel(filteredBookings, approvedBookings),
                ),

                // Panel Tengah: Rak Gantungan Kunci Fisik 43 Ruangan
                Expanded(
                  flex: 4,
                  child: _buildPhysicalKeyRackPanel(allRooms, allBookings),
                ),

                // Panel Kanan: Pengembalian Kunci & Cek Video AC Mati
                Expanded(
                  flex: 3,
                  child: _buildCheckoutReturnPanel(allBookings),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ── HEADER PAPAN NAMA DIGITAL (NAMEPLATE) ALA TELLER BANK ───────────
  Widget _buildOfficerNameplateHeader() {
    final timeFormatted = DateFormat('HH:mm:ss').format(_currentTime);
    final dateFormatted = DateFormat('EEEE, dd MMMM yyyy', 'id_ID').format(_currentTime);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0F172A),
        border: const Border(bottom: BorderSide(color: Color(0xFF1E293B), width: 2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.5),
            blurRadius: 15,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          // PNL Identity
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF1E1B4B), Color(0xFF312E81)],
              ),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: AppTokens.accentGold.withValues(alpha: 0.5)),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.account_balance_rounded, color: AppTokens.accentGold, size: 24),
                SizedBox(width: 10),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'POLITEKNIK NEGERI LHOKSEUMAWE',
                      style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w900,
                        fontSize: 11.5,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      'FRONT DESK RESEPSIONIS • JURUSAN TIK',
                      style: TextStyle(
                        color: AppTokens.accentGold,
                        fontSize: 9.5,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // Papan Nama Petugas (Officer On Duty Nameplate)
          Expanded(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    const Color(0xFF1E293B),
                    const Color(0xFF0F172A).withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppTokens.accentGold.withValues(alpha: 0.4), width: 1.5),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 20,
                    backgroundColor: AppTokens.accentGold,
                    child: Text(
                      _currentOfficer.avatarInitials,
                      style: const TextStyle(
                        color: Color(0xFF0F172A),
                        fontWeight: FontWeight.w900,
                        fontSize: 14,
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AppTokens.success.withValues(alpha: 0.2),
                                borderRadius: BorderRadius.circular(4),
                                border: Border.all(color: AppTokens.success),
                              ),
                              child: const Text(
                                '● OFFICER ON DUTY',
                                style: TextStyle(color: AppTokens.success, fontSize: 9, fontWeight: FontWeight.bold),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              _currentOfficer.counterName,
                              style: const TextStyle(color: AppTokens.accentGold, fontSize: 10, fontWeight: FontWeight.bold),
                            ),
                          ],
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _currentOfficer.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        Text(
                          'NIP: ${_currentOfficer.nip} • ${_currentOfficer.roleTitle} • ${_currentOfficer.shiftName} (${_currentOfficer.shiftHours})',
                          style: const TextStyle(color: Colors.white60, fontSize: 10),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                  // Ganti Petugas Button
                  OutlinedButton.icon(
                    style: OutlinedButton.styleFrom(
                      side: BorderSide(color: AppTokens.accentGold.withValues(alpha: 0.6)),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                    ),
                    icon: const Icon(Icons.swap_horiz_rounded, size: 14, color: AppTokens.accentGold),
                    label: const Text('Ganti Shift', style: TextStyle(color: AppTokens.accentGold, fontSize: 11)),
                    onPressed: _showOfficerSwitchModal,
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),

          // Live Clock WIB & Home Navigation
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: const Color(0xFF0B1120),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: const Color(0xFF334155)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.access_time_filled_rounded, size: 14, color: AppTokens.accentGold),
                    const SizedBox(width: 6),
                    Text(
                      '$timeFormatted WIB',
                      style: const TextStyle(
                        color: Colors.white,
                        fontFamily: 'monospace',
                        fontWeight: FontWeight.w900,
                        fontSize: 15,
                      ),
                    ),
                  ],
                ),
                Text(
                  dateFormatted,
                  style: const TextStyle(color: Colors.white54, fontSize: 10),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Shortcut to Standard Dashboard
          IconButton(
            tooltip: 'Ke Dashboard Utama',
            icon: const Icon(Icons.dashboard_customize_rounded, color: Colors.white70),
            onPressed: () => context.push('/admin/dashboard'),
          ),
        ],
      ),
    );
  }

  // ── QUICK ACTION & QUEUE CALLER BAR ─────────────────────────────────
  Widget _buildQueueAndSearchBar() {
    final queueCode = '$_currentQueuePrefix-${_currentQueueNumber.toString().padLeft(2, "0")}';

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      decoration: const BoxDecoration(
        color: Color(0xFF090D1A),
        border: Border(bottom: BorderSide(color: Color(0xFF1E293B))),
      ),
      child: Row(
        children: [
          // Display Nomor Antrean Sekarang
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
            decoration: BoxDecoration(
              color: AppTokens.primaryPurple.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTokens.primaryPurpleGlow),
            ),
            child: Row(
              children: [
                const Icon(Icons.confirmation_number_rounded, color: AppTokens.primaryPurpleGlow, size: 18),
                const SizedBox(width: 8),
                const Text('ANTREAN AKTIF: ', style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold)),
                Text(
                  queueCode,
                  style: const TextStyle(color: AppTokens.accentGold, fontSize: 16, fontWeight: FontWeight.w900, fontFamily: 'monospace'),
                ),
              ],
            ),
          ),
          const SizedBox(width: 10),

          // Tombol Panggil Antrean Berikutnya
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTokens.primaryPurple,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.volume_up_rounded, size: 16),
            label: const Text('Panggil Berikutnya', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: _callNextQueue,
          ),
          const SizedBox(width: 16),

          // Search Field Cepat NIM / NIP / Kode Booking
          Expanded(
            child: SizedBox(
              height: 38,
              child: TextField(
                controller: _searchCtrl,
                style: const TextStyle(color: Colors.white, fontSize: 12),
                decoration: InputDecoration(
                  hintText: 'Cari cepat NIM / NIP / Nama Pemohon / Kode Booking (contoh: 220401012 atau TIK.106)...',
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
          const SizedBox(width: 12),

          // Tombol Walk-in Fast Booking
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF0284C7),
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add_task_rounded, size: 16),
            label: const Text('+ Walk-in Peminjaman', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
            onPressed: () => context.push('/form-peminjaman'),
          ),
        ],
      ),
    );
  }

  // ── PANEL KIRI: ANTREAN PEMINJAM & SERAH TERIMA KUNCI ────────────────
  Widget _buildBorrowerQueuePanel(
    List<BookingModel> filteredBookings,
    List<BookingModel> approvedBookings,
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
              const Icon(Icons.people_alt_rounded, color: AppTokens.accentGold, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Antrean Pengambilan Kunci',
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
                  '${approvedBookings.length} Siap Ambil',
                  style: const TextStyle(color: AppTokens.primaryPurpleGlow, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 10),

          // List Booking Approved
          Expanded(
            child: filteredBookings.isEmpty
                ? const Center(
                    child: Text('Tidak ada data peminjaman ditemukan.', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  )
                : ListView.builder(
                    itemCount: filteredBookings.length,
                    itemBuilder: (ctx, idx) {
                      final b = filteredBookings[idx];
                      final isReadyToPickup = b.status == BookingStatus.approved;
                      final isActive = b.status == BookingStatus.active;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: isReadyToPickup
                              ? AppTokens.primaryPurple.withValues(alpha: 0.15)
                              : const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: isReadyToPickup
                                ? AppTokens.primaryPurpleGlow.withValues(alpha: 0.6)
                                : Colors.white10,
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
                                    color: const Color(0xFF0F172A),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Text(
                                    b.roomCode,
                                    style: const TextStyle(color: AppTokens.accentGold, fontSize: 11, fontWeight: FontWeight.bold),
                                  ),
                                ),
                                const SizedBox(width: 6),
                                Expanded(
                                  child: Text(
                                    b.userName,
                                    style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Text(
                                  b.statusLabel,
                                  style: TextStyle(
                                    color: isReadyToPickup ? AppTokens.primaryPurpleGlow : (isActive ? AppTokens.info : Colors.white60),
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'NIM: ${b.userNimNip} • ${b.sessionRangeLabel}',
                              style: const TextStyle(color: Colors.white54, fontSize: 10.5),
                            ),
                            Text(
                              'Keperluan: ${b.purpose}',
                              style: const TextStyle(color: Colors.white70, fontSize: 10.5),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 8),

                            // Actions: Serah Kunci & Cetak Slip
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
                                      label: const Text('Serahkan Kunci', style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold)),
                                      onPressed: () async {
                                        await ref.read(bookingListProvider.notifier).updateStatus(
                                              b.id,
                                              BookingStatus.active,
                                              approvedBy: '${_currentOfficer.name} (Resepsionis)',
                                            );
                                        if (!mounted) return;
                                        SlipTandaTerimaDialog.show(
                                          context,
                                          booking: b.copyWith(status: BookingStatus.active),
                                          officer: _currentOfficer,
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
                                      label: const Text('Slip Struk', style: TextStyle(color: Colors.white70, fontSize: 10.5)),
                                      onPressed: () {
                                        SlipTandaTerimaDialog.show(
                                          context,
                                          booking: b,
                                          officer: _currentOfficer,
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
              const Text(
                'Papan Rak Kunci Fisik Laboratorium & Ruang PBM',
                style: TextStyle(color: Colors.white, fontSize: 13.5, fontWeight: FontWeight.w900),
              ),
              const Spacer(),
              _buildKeyLegend('Di Rak', AppTokens.success),
              const SizedBox(width: 10),
              _buildKeyLegend('Dibawa Peminjam', AppTokens.error),
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
                childAspectRatio: 1.25,
              ),
              itemCount: allRooms.length,
              itemBuilder: (ctx, idx) {
                final room = allRooms[idx];
                final isKeyBorrowed = allBookings.any(
                  (b) => b.roomCode == room.id && b.status == BookingStatus.active,
                );
                final activeBooking = isKeyBorrowed
                    ? allBookings.firstWhere((b) => b.roomCode == room.id && b.status == BookingStatus.active)
                    : null;

                return InkWell(
                  onTap: () {
                    if (isKeyBorrowed && activeBooking != null) {
                      SlipTandaTerimaDialog.show(
                        context,
                        booking: activeBooking,
                        officer: _currentOfficer,
                      );
                    } else {
                      context.push('/form-peminjaman?prefillRoom=${room.id}');
                    }
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isKeyBorrowed
                          ? AppTokens.error.withValues(alpha: 0.15)
                          : const Color(0xFF1E293B),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isKeyBorrowed ? AppTokens.error : const Color(0xFF334155),
                        width: isKeyBorrowed ? 1.5 : 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Icon(
                              Icons.key_rounded,
                              size: 14,
                              color: isKeyBorrowed ? AppTokens.error : AppTokens.success,
                            ),
                            const SizedBox(width: 4),
                            Text(
                              room.id,
                              style: TextStyle(
                                color: isKeyBorrowed ? AppTokens.error : Colors.white,
                                fontWeight: FontWeight.w900,
                                fontSize: 11.5,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 3),
                        Text(
                          room.name,
                          style: const TextStyle(color: Colors.white70, fontSize: 9),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          isKeyBorrowed
                              ? 'Oleh: ${activeBooking?.userName ?? "Peminjam"}'
                              : 'Tersedia di Meja',
                          style: TextStyle(
                            color: isKeyBorrowed ? AppTokens.accentGold : AppTokens.success,
                            fontSize: 8.5,
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
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 10)),
      ],
    );
  }

  // ── PANEL KANAN: PENGEMBALIAN KUNCI & CEK VIDEO AC MATI ────────────
  Widget _buildCheckoutReturnPanel(List<BookingModel> allBookings) {
    final returnPendingList = allBookings
        .where((b) => b.status == BookingStatus.active || (b.isCheckoutDone && b.status != BookingStatus.completed))
        .toList();

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
              const Icon(Icons.fact_check_rounded, color: AppTokens.info, size: 18),
              const SizedBox(width: 8),
              const Text(
                'Pengembalian & Cek Video AC',
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
                  '${returnPendingList.length} Aktif',
                  style: const TextStyle(color: AppTokens.info, fontSize: 10, fontWeight: FontWeight.bold),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          const Divider(color: Colors.white12, height: 1),
          const SizedBox(height: 10),

          Expanded(
            child: returnPendingList.isEmpty
                ? const Center(
                    child: Text('Belum ada pengembalian kunci yang aktif.', style: TextStyle(color: Colors.white38, fontSize: 11)),
                  )
                : ListView.builder(
                    itemCount: returnPendingList.length,
                    itemBuilder: (ctx, idx) {
                      final b = returnPendingList[idx];
                      final hasVideo = b.isCheckoutDone;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: const Color(0xFF1E293B),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(
                            color: hasVideo ? AppTokens.success.withValues(alpha: 0.6) : Colors.white12,
                          ),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Text(
                                  b.roomCode,
                                  style: const TextStyle(color: AppTokens.accentGold, fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    b.userName,
                                    style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Sesi: ${b.sessionRangeLabel} (${b.day})',
                              style: const TextStyle(color: Colors.white60, fontSize: 10.5),
                            ),
                            const SizedBox(height: 6),

                            // Video Status Badge
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                              decoration: BoxDecoration(
                                color: hasVideo
                                    ? AppTokens.success.withValues(alpha: 0.15)
                                    : AppTokens.accentGold.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Row(
                                children: [
                                  Icon(
                                    hasVideo ? Icons.videocam_rounded : Icons.pending_actions_rounded,
                                    size: 13,
                                    color: hasVideo ? AppTokens.success : AppTokens.accentGold,
                                  ),
                                  const SizedBox(width: 6),
                                  Expanded(
                                    child: Text(
                                      hasVideo
                                          ? 'Bukti Video AC Mati: TERSEDIA'
                                          : 'Menunggu Upload Video Mahasiswa',
                                      style: TextStyle(
                                        color: hasVideo ? AppTokens.success : AppTokens.accentGold,
                                        fontSize: 9.5,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 8),

                            // Action: Cek Video & Terima Kunci
                            Row(
                              children: [
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: const Color(0xFF0F172A),
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(6),
                                        side: const BorderSide(color: Color(0xFF334155)),
                                      ),
                                    ),
                                    icon: const Icon(Icons.play_circle_fill_rounded, size: 14, color: AppTokens.accentGold),
                                    label: const Text('Detail & Video', style: TextStyle(fontSize: 10.5)),
                                    onPressed: () {
                                      context.push('/detail-peminjaman?bookingId=${b.id}');
                                    },
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTokens.success,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(vertical: 6),
                                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                                    ),
                                    icon: const Icon(Icons.check_circle_rounded, size: 14),
                                    label: const Text('Terima Kunci', style: TextStyle(fontSize: 10.5, fontWeight: FontWeight.bold)),
                                    onPressed: () async {
                                      await ref.read(bookingListProvider.notifier).updateStatus(
                                            b.id,
                                            BookingStatus.completed,
                                            laboranReviewNotes: 'Kunci fisik diterima di meja resepsionis oleh ${_currentOfficer.name}',
                                          );
                                      if (!mounted) return;
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        SnackBar(
                                          backgroundColor: AppTokens.success,
                                          content: Text('✅ Kunci ${b.roomCode} berhasil diterima kembali ke rak kunci.'),
                                        ),
                                      );
                                    },
                                  ),
                                ),
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
}
