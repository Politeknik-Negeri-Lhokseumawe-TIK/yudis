import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_tokens.dart';
import '../../../../shared/widgets/cyber_card.dart';
import '../../../../shared/widgets/cyber_status_badge.dart';
import '../../domain/models/booking_model.dart';
import '../../domain/models/room_model.dart';
import '../../domain/models/roster_item_model.dart';
import '../providers/booking_provider.dart';
import '../providers/roster_provider.dart';

class KetersediaanRuangScreen extends ConsumerStatefulWidget {
  final String? initialRoomCode;

  const KetersediaanRuangScreen({super.key, this.initialRoomCode});

  @override
  ConsumerState<KetersediaanRuangScreen> createState() =>
      _KetersediaanRuangScreenState();
}

class _KetersediaanRuangScreenState
    extends ConsumerState<KetersediaanRuangScreen> {
  String _selectedDay = 'Senin';
  String _categoryFilter = 'Semua'; // Semua, Lab, Teori, Studio
  String _searchQuery = '';
  bool _isGridView = false;

  @override
  void initState() {
    super.initState();
    // Default to current weekday if Mon-Fri
    final now = DateTime.now();
    final dayIndex = now.weekday; // 1=Mon, 5=Fri
    if (dayIndex >= 1 && dayIndex <= 5) {
      _selectedDay = AppConstants.operationalDays[dayIndex - 1];
    }
  }

  @override
  Widget build(BuildContext context) {
    final allRooms = ref.watch(roomsProvider);
    final allSchedules = ref.watch(allRosterSchedulesProvider);
    final allBookings = ref.watch(bookingListProvider);

    // Filter rooms
    final filteredRooms = allRooms.where((room) {
      if (widget.initialRoomCode != null &&
          widget.initialRoomCode!.isNotEmpty &&
          _searchQuery.isEmpty) {
        if (room.id != widget.initialRoomCode) return false;
      }

      if (_categoryFilter == 'Lab' && room.type != RoomType.lab) return false;
      if (_categoryFilter == 'Teori' && room.type != RoomType.theoryClass) return false;
      if (_categoryFilter == 'Studio' && room.type != RoomType.studio) return false;

      if (_searchQuery.trim().isNotEmpty) {
        final q = _searchQuery.toLowerCase();
        return room.id.toLowerCase().contains(q) ||
            room.name.toLowerCase().contains(q) ||
            room.building.toLowerCase().contains(q);
      }
      return true;
    }).toList();

    return Scaffold(
      backgroundColor: AppTokens.bgDark,
      appBar: AppBar(
        backgroundColor: AppTokens.bgDarkSurface,
        title: const Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Matriks Ketersediaan Ruangan',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
            ),
            Text(
              'Status Okupansi PBM & Peminjaman Real-Time',
              style: TextStyle(fontSize: 11, color: Colors.white60),
            ),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        actions: [
          IconButton(
            tooltip: _isGridView ? 'Tampilan List Detail' : 'Tampilan Grid Kiosk',
            icon: Icon(
              _isGridView ? Icons.view_list_rounded : Icons.grid_view_rounded,
              color: AppTokens.primaryPurpleGlow,
            ),
            onPressed: () => setState(() => _isGridView = !_isGridView),
          ),
          IconButton(
            tooltip: 'Roster Digital Lengkap',
            icon: const Icon(Icons.calendar_month_rounded, color: AppTokens.accentGold),
            onPressed: () => context.push('/roster-digital'),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // ── Controls Header ─────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTokens.bgDarkSurface,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Day selector chips
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: AppConstants.operationalDays.map((day) {
                      final isSelected = _selectedDay == day;
                      return Padding(
                        padding: const EdgeInsets.only(right: 8.0),
                        child: ChoiceChip(
                          label: Text(day),
                          selected: isSelected,
                          onSelected: (selected) {
                            if (selected) setState(() => _selectedDay = day);
                          },
                          selectedColor: AppTokens.primaryPurple,
                          backgroundColor: AppTokens.bgDarkCard,
                          labelStyle: TextStyle(
                            color: isSelected ? Colors.white : Colors.white70,
                            fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                            fontSize: 13,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                            side: BorderSide(
                              color: isSelected
                                  ? AppTokens.primaryPurpleGlow
                                  : AppTokens.glassBorderColor,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ),
                const SizedBox(height: 12),

                // Category & Search
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        height: 40,
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: AppTokens.bgDarkCard,
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: AppTokens.glassBorderColor),
                        ),
                        child: TextField(
                          style: const TextStyle(color: Colors.white, fontSize: 13),
                          onChanged: (val) => setState(() => _searchQuery = val),
                          decoration: const InputDecoration(
                            hintText: 'Cari Kode / Nama Ruangan...',
                            hintStyle: TextStyle(color: Colors.white38, fontSize: 12),
                            prefixIcon: Icon(Icons.search_rounded, size: 18, color: Colors.white54),
                            border: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.symmetric(vertical: 10),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),

                    // Filter Category Segment
                    Container(
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: AppTokens.bgDarkCard,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppTokens.glassBorderColor),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: ['Semua', 'Lab', 'Studio', 'Teori'].map((cat) {
                          final isSelected = _categoryFilter == cat;
                          return InkWell(
                            onTap: () => setState(() => _categoryFilter = cat),
                            borderRadius: BorderRadius.circular(8),
                            child: Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: isSelected
                                    ? AppTokens.primaryPurple.withValues(alpha: 0.4)
                                    : Colors.transparent,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                cat,
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight:
                                      isSelected ? FontWeight.bold : FontWeight.normal,
                                  color: isSelected ? Colors.white : Colors.white60,
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),

                // Legend
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      _buildLegendItem('Kosong (Tersedia)', const Color(0xFF10B981)),
                      const SizedBox(width: 14),
                      _buildLegendItem('Terisi PBM Reguler', Colors.redAccent),
                      const SizedBox(width: 14),
                      _buildLegendItem('Dipinjam (Booking)', Colors.amber),
                      const SizedBox(width: 14),
                      _buildLegendItem('Istirahat', Colors.grey.shade700),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // ── Rooms Matrix / Grid List ───────────────────────────────
          Expanded(
            child: _isGridView
                ? SingleChildScrollView(
                    padding: const EdgeInsets.all(16),
                    child: RoomStatusGrid(
                      crossAxisCount: MediaQuery.of(context).size.width > 900 ? 6 : (MediaQuery.of(context).size.width > 600 ? 4 : 2),
                      spacing: 12,
                      tiles: filteredRooms.map((room) {
                        final daySchedules = allSchedules.where((s) => s.roomCode == room.id && s.day.toLowerCase() == _selectedDay.toLowerCase()).toList();
                        final dayBookings = allBookings.where((b) => b.roomCode == room.id && b.day.toLowerCase() == _selectedDay.toLowerCase() && (b.status == BookingStatus.approved || b.status == BookingStatus.active)).toList();
                        
                        RoomTileStatus status = RoomTileStatus.available;
                        String sessionLabel = 'Tersedia';
                        if (daySchedules.isNotEmpty) {
                          status = RoomTileStatus.classPBM;
                          sessionLabel = '${daySchedules.length} Sesi PBM';
                        } else if (dayBookings.isNotEmpty) {
                          status = RoomTileStatus.borrowed;
                          sessionLabel = 'Dipinjam';
                        }

                        return RoomStatusTile(
                          roomCode: room.id,
                          roomName: room.name,
                          status: status,
                          sessionLabel: sessionLabel,
                          onTap: () => context.push('/form-peminjaman'),
                        );
                      }).toList(),
                    ),
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: filteredRooms.length,
                    itemBuilder: (context, index) {
                      final room = filteredRooms[index];
                      return _buildRoomAvailabilityCard(
                        context,
                        room,
                        allSchedules,
                        allBookings,
                        index,
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: AppTokens.primaryPurple,
        icon: const Icon(Icons.add_rounded, color: Colors.white),
        label: const Text('Buat Peminjaman', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        onPressed: () => context.push('/form-peminjaman'),
      ),
    );
  }

  Widget _buildLegendItem(String label, Color color) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(3),
          ),
        ),
        const SizedBox(width: 5),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 11),
        ),
      ],
    );
  }

  Widget _buildRoomAvailabilityCard(
    BuildContext context,
    RoomModel room,
    List<RosterItemModel> allSchedules,
    List<BookingModel> allBookings,
    int index,
  ) {
    // Schedules in this room for selected day
    final daySchedules = allSchedules
        .where((s) => s.roomCode == room.id && s.day.toLowerCase() == _selectedDay.toLowerCase())
        .toList();

    // Bookings in this room for selected day
    final dayBookings = allBookings
        .where((b) =>
            b.roomCode == room.id &&
            b.day.toLowerCase() == _selectedDay.toLowerCase() &&
            (b.status == BookingStatus.approved ||
                b.status == BookingStatus.active ||
                b.status == BookingStatus.pending))
        .toList();

    // Total active sessions occupied
    int occupiedCount = 0;
    for (int s = 1; s <= 11; s++) {
      final hasRoster = daySchedules.any((item) => s >= item.startSession && s <= item.endSession);
      final hasBooking = dayBookings.any((item) => s >= item.startSession && s <= item.endSession);
      if (hasRoster || hasBooking) occupiedCount++;
    }

    final isFullyBooked = occupiedCount >= 11;
    final isCompletelyFree = occupiedCount == 0;

    return CyberCard(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Top: Room code, Type, Capacity & Quick Book Button
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: room.isLab
                        ? AppTokens.primaryPurple.withValues(alpha: 0.25)
                        : Colors.blueGrey.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: room.isLab ? AppTokens.primaryPurpleGlow : Colors.white30,
                    ),
                  ),
                  child: Text(
                    room.id,
                    style: TextStyle(
                      color: room.isLab ? AppTokens.primaryPurpleGlow : Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        room.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Row(
                        children: [
                          Icon(Icons.people_outline_rounded, size: 12, color: Colors.white54),
                          const SizedBox(width: 4),
                          Text(
                            'Kapasitas: ${room.capacity} Orang • Lt. ${room.floor}',
                            style: const TextStyle(color: Colors.white54, fontSize: 11),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                InkWell(
                  onTap: () {
                    context.push('/form-peminjaman?prefillRoom=${room.id}&prefillDay=$_selectedDay');
                  },
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTokens.primaryPurple,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_circle_outline_rounded, size: 14, color: Colors.white),
                        SizedBox(width: 4),
                        Text('Pinjam', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),

            // Sessions Timeline Bar (Sesi 1 to 11)
            const Text(
              'Timeline Sesi Perkuliahan (07:30 - 18:00):',
              style: TextStyle(color: Colors.white60, fontSize: 11, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),

            // Grid of 11 sessions
            Row(
              children: List.generate(11, (i) {
                final sessionNum = i + 1;
                final rosterMatch = daySchedules.firstWhere(
                  (s) => sessionNum >= s.startSession && sessionNum <= s.endSession,
                  orElse: () => const RosterItemModel(
                    id: '',
                    studyProgram: '',
                    className: '',
                    day: '',
                    startSession: 0,
                    endSession: 0,
                    startTime: '',
                    endTime: '',
                    courseName: '',
                    lecturerName: '',
                    roomCode: '',
                  ),
                );

                final bookingMatch = dayBookings.firstWhere(
                  (b) => sessionNum >= b.startSession && sessionNum <= b.endSession,
                  orElse: () => BookingModel(
                    id: '',
                    bookingCode: '',
                    userId: '',
                    userName: '',
                    userNimNip: '',
                    userPhone: '',
                    userRole: '',
                    roomCode: '',
                    roomName: '',
                    bookingDate: DateTime.now(),
                    day: '',
                    startSession: 0,
                    endSession: 0,
                    startTime: '',
                    endTime: '',
                    purpose: '',
                    description: '',
                    supervisorLecturer: '',
                    createdAt: DateTime.now(),
                  ),
                );

                final isRoster = rosterMatch.id.isNotEmpty;
                final isBooking = bookingMatch.id.isNotEmpty;

                Color slotColor = const Color(0xFF10B981); // Green (Available)
                if (isRoster) slotColor = AppTokens.error;
                if (isBooking && !isRoster) slotColor = AppTokens.accentGold;

                return Expanded(
                  child: Tooltip(
                    message: isRoster
                        ? 'Sesi $sessionNum: ${rosterMatch.courseName} (${rosterMatch.className})'
                        : (isBooking
                            ? 'Sesi $sessionNum: Dipinjam oleh ${bookingMatch.userName} (${bookingMatch.purpose})'
                            : 'Sesi $sessionNum: Kosong / Tersedia'),
                    child: InkWell(
                      onTap: () {
                        if (!isRoster && !isBooking) {
                          context.push(
                            '/form-peminjaman?prefillRoom=${room.id}&prefillDay=$_selectedDay&prefillSession=$sessionNum',
                          );
                        } else {
                          _showSlotDetailModal(
                            context,
                            room,
                            sessionNum,
                            isRoster ? rosterMatch : null,
                            isBooking ? bookingMatch : null,
                          );
                        }
                      },
                      child: Container(
                        height: 38,
                        margin: const EdgeInsets.symmetric(horizontal: 1.5),
                        decoration: BoxDecoration(
                          color: slotColor.withValues(alpha: 0.85),
                          borderRadius: BorderRadius.circular(6),
                          border: Border.all(
                            color: slotColor.withValues(alpha: 0.9),
                            width: 1,
                          ),
                        ),
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                '$sessionNum',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                              Icon(
                                isRoster
                                    ? Icons.lock_rounded
                                    : (isBooking ? Icons.event_seat_rounded : Icons.check_rounded),
                                size: 10,
                                color: Colors.white70,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 10),

            // Summary Footer
            Row(
              children: [
                if (isCompletelyFree)
                  const Text(
                    '✨ Kosong Seharian (Semua Sesi Tersedia)',
                    style: TextStyle(color: AppTokens.success, fontSize: 11, fontWeight: FontWeight.bold),
                  )
                else if (isFullyBooked)
                  const Text(
                    '⛔ Terisi Penuh Sepanjang Hari',
                    style: TextStyle(color: AppTokens.error, fontSize: 11, fontWeight: FontWeight.bold),
                  )
                else
                  Text(
                    '${11 - occupiedCount} Sesi Kosong • $occupiedCount Sesi Terisi',
                    style: const TextStyle(color: Colors.white70, fontSize: 11),
                  ),
                const Spacer(),
                Text(
                  'PJ: ${room.picName}',
                  style: const TextStyle(color: Colors.white38, fontSize: 10),
                ),
              ],
            ),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 200.ms, delay: (index * 25).ms);
  }

  void _showSlotDetailModal(
    BuildContext context,
    RoomModel room,
    int sessionNum,
    RosterItemModel? roster,
    BookingModel? booking,
  ) {
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
              Icon(
                roster != null ? Icons.school_rounded : Icons.event_note_rounded,
                color: roster != null ? AppTokens.error : AppTokens.accentGold,
              ),
              const SizedBox(width: 8),
              Text(
                'Detail Sesi $sessionNum (${room.id})',
                style: const TextStyle(color: Colors.white, fontSize: 16),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (roster != null) ...[
                const Text(
                  'TERISI PERKULIAHAN REGULER (ROSTER):',
                  style: TextStyle(color: AppTokens.error, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text('Mata Kuliah: ${roster.courseName}', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Kelas: ${roster.className} (${roster.studyProgram})', style: const TextStyle(color: Colors.white70)),
                Text('Dosen: ${roster.lecturerName}', style: const TextStyle(color: Colors.white70)),
                Text('Waktu: ${roster.sessionRangeLabel}', style: const TextStyle(color: AppTokens.accentGold, fontSize: 12)),
              ] else if (booking != null) ...[
                const Text(
                  'DIPINJAM (BOOKING APPROVED):',
                  style: TextStyle(color: AppTokens.accentGold, fontSize: 11, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 6),
                Text('Peminjam: ${booking.userName} (${booking.userNimNip})', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                Text('Keperluan: ${booking.purpose}', style: const TextStyle(color: Colors.white70)),
                Text('PJ Dosen: ${booking.supervisorLecturer}', style: const TextStyle(color: Colors.white70)),
                Text('Status: ${booking.statusLabel}', style: const TextStyle(color: AppTokens.info)),
              ],
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
