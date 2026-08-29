import 'dart:math';
import '../../domain/models/booking_model.dart';
import '../../domain/models/roster_item_model.dart';
import '../datasources/roster_data_source.dart';

class BookingRepository {
  final List<BookingModel> _bookings = [];

  BookingRepository() {
    _seedInitialBookings();
  }

  void _seedInitialBookings() {
    final now = DateTime.now();
    _bookings.addAll([
      BookingModel(
        id: 'BKG-001',
        bookingCode: 'BOOK-2026-0829-01',
        userId: 'usr-1',
        userName: 'Ahmad Maulana Al-Fatih',
        userNimNip: '220401012',
        userPhone: '081269871234',
        userRole: 'Mahasiswa',
        roomCode: 'TIK.106',
        roomName: 'Laboratorium Algoritma & Pemrograman Mobile',
        bookingDate: now.subtract(const Duration(days: 1)),
        day: 'Jumat',
        startSession: 8,
        endSession: 11,
        startTime: '14:20',
        endTime: '18:00',
        purpose: 'Riset / Tugas Akhir / Skripsi',
        description: 'Pengujian Model Deep Learning dan Integrasi Flutter App untuk deteksi citra medis.',
        supervisorLecturer: 'Safriadi ST, M.Kom.',
        additionalFacilities: ['Kabel Converter HDMI / VGA / Type-C', 'Stop Kontak Ekstra'],
        status: BookingStatus.completed,
        createdAt: now.subtract(const Duration(days: 3)),
        approvedAt: now.subtract(const Duration(days: 2)),
        approvedBy: 'Munawir, S.Kom. (Laboran)',
        checkoutCleanlinessStatus: true,
        checkoutAcOffStatus: true,
        checkoutLightsOffStatus: true,
        checkoutPcOffStatus: true,
        checkoutDoorsLockedStatus: true,
        checkoutVideoUrl: 'https://sample-videos.com/video123/mp4/720/big_buck_bunny_720p_1mb.mp4',
        checkoutVideoName: 'video_pemeriksaan_tik106_ahmad.mp4',
        checkoutSubmittedAt: now.subtract(const Duration(days: 1, hours: 1)),
        checkoutNotes: 'Semua 30 PC telah dishutdown, AC mati remote diletakkan di meja instruktur, sampah dibawa keluar.',
        laboranReviewNotes: 'Verifikasi video valid: Kondisi lab bersih, AC OFF, kunci diterima di ruang teknisi.',
      ),
      BookingModel(
        id: 'BKG-002',
        bookingCode: 'BOOK-2026-0829-02',
        userId: 'usr-2',
        userName: 'Siti Nurhaliza',
        userNimNip: '210402045',
        userPhone: '085277112233',
        userRole: 'Mahasiswa',
        roomCode: 'TDC-202',
        roomName: 'Studio Produksi Podcast, Audio & Video Editing',
        bookingDate: now,
        day: 'Sabtu',
        startSession: 1,
        endSession: 4,
        startTime: '07:30',
        endTime: '11:10',
        purpose: 'Kegiatan Organisasi / Event Kemahasiswaan',
        description: 'Take rekaman podcast Himpunan Mahasiswa TIK episode 4 bersama narasumber industri.',
        supervisorLecturer: 'Nanda Saputri, SST., M.T.',
        additionalFacilities: ['Mikrofon Wireless / Sound Podcast', 'Kamera DSLR & Tripod Studio'],
        status: BookingStatus.active,
        createdAt: now.subtract(const Duration(days: 2)),
        approvedAt: now.subtract(const Duration(days: 1)),
        approvedBy: 'Fachri Yanuar Rudi F, S.ST., M.T.',
      ),
      BookingModel(
        id: 'BKG-003',
        bookingCode: 'BOOK-2026-0829-03',
        userId: 'usr-3',
        userName: 'Dr. Rahmad Hidayat, S.Kom., M.Cs',
        userNimNip: '198205122008121002',
        userPhone: '081399887766',
        userRole: 'Dosen',
        roomCode: 'TIK.101',
        roomName: 'Laboratorium Sistem Operasi & Basis Data',
        bookingDate: now.add(const Duration(days: 2)),
        day: 'Senin',
        startSession: 8,
        endSession: 11,
        startTime: '14:20',
        endTime: '18:00',
        purpose: 'Kuliah Pengganti / Tambahan',
        description: 'Kuliah Pengganti Praktikum Administrasi Basis Data kelas TI 2A & 2C.',
        supervisorLecturer: 'Dr. Rahmad Hidayat, S.Kom., M.Cs',
        additionalFacilities: ['Proyektor Portable + Pointer'],
        status: BookingStatus.approved,
        createdAt: now.subtract(const Duration(hours: 12)),
        approvedAt: now.subtract(const Duration(hours: 2)),
        approvedBy: 'Kepala Laboratorium Komputer',
      ),
      BookingModel(
        id: 'BKG-004',
        bookingCode: 'BOOK-2026-0829-04',
        userId: 'usr-4',
        userName: 'Bima Satria Perdana',
        userNimNip: '230403019',
        userPhone: '087811224455',
        userRole: 'Mahasiswa',
        roomCode: 'TIK.112',
        roomName: 'Laboratorium Robotika & Otomasi Cerdas',
        bookingDate: now.add(const Duration(days: 3)),
        day: 'Selasa',
        startSession: 7,
        endSession: 10,
        startTime: '13:30',
        endTime: '17:10',
        purpose: 'Riset / Tugas Akhir / Skripsi',
        description: 'Kalibrasi sensor IMU & pengujian tracking robot otonom di lintasan lab.',
        supervisorLecturer: 'Mustainul Abdi, SST., M.Kom.',
        additionalFacilities: ['IoT Development Board (ESP32/Arduino/Sensor)'],
        status: BookingStatus.pending,
        createdAt: now.subtract(const Duration(hours: 3)),
      ),
    ]);
  }

  List<BookingModel> getAllBookings() => List.unmodifiable(_bookings);

  List<BookingModel> getBookingsByUser(String userId) =>
      _bookings.where((b) => b.userId == userId).toList();

  /// Memeriksa apakah terdapat bentrok jadwal antara pengajuan baru dengan
  /// (1) Roster resmi PBM TA 2026-2027 dan (2) Peminjaman lain yang sudah disetujui
  ConflictCheckResult checkConflict({
    required String roomCode,
    required String day,
    required int startSession,
    required int endSession,
    required DateTime date,
    String? excludeBookingId,
  }) {
    // 1. Cek bentrok dengan Roster PBM
    final rosterList = RosterDataSource.getAllSchedules();
    for (final schedule in rosterList) {
      if (schedule.roomCode == roomCode && schedule.day.toLowerCase() == day.toLowerCase()) {
        // Cek overlap sesi jam: max(start1, start2) <= min(end1, end2)
        final isOverlap = max(startSession, schedule.startSession) <=
            min(endSession, schedule.endSession);
        if (isOverlap) {
          return ConflictCheckResult(
            hasConflict: true,
            conflictType: ConflictType.rosterClass,
            message:
                'Ruangan $roomCode terisi perkuliahan reguler: ${schedule.courseName} (${schedule.className}) oleh ${schedule.lecturerName} pada ${schedule.sessionRangeLabel}.',
            conflictingRoster: schedule,
          );
        }
      }
    }

    // 2. Cek bentrok dengan Booking yang sudah Disetujui / Sedang Berjalan pada tanggal tersebut
    for (final booking in _bookings) {
      if (booking.id == excludeBookingId) continue;
      if (booking.roomCode == roomCode &&
          booking.bookingDate.year == date.year &&
          booking.bookingDate.month == date.month &&
          booking.bookingDate.day == date.day) {
        if (booking.status == BookingStatus.approved ||
            booking.status == BookingStatus.active ||
            booking.status == BookingStatus.pending) {
          final isOverlap = max(startSession, booking.startSession) <=
              min(endSession, booking.endSession);
          if (isOverlap) {
            return ConflictCheckResult(
              hasConflict: true,
              conflictType: ConflictType.existingBooking,
              message:
                  'Ruangan $roomCode sudah dipesan oleh ${booking.userName} (${booking.purpose}) pada ${booking.sessionRangeLabel} [Status: ${booking.statusLabel}].',
              conflictingBooking: booking,
            );
          }
        }
      }
    }

    return const ConflictCheckResult(hasConflict: false);
  }

  /// Membuat peminjaman baru
  Future<BookingModel> createBooking(BookingModel booking) async {
    _bookings.insert(0, booking);
    return booking;
  }

  /// Update status peminjaman oleh admin/laboran
  Future<void> updateBookingStatus(
    String bookingId,
    BookingStatus newStatus, {
    String? approvedBy,
    String? rejectionReason,
    String? laboranReviewNotes,
  }) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final current = _bookings[index];
      _bookings[index] = current.copyWith(
        status: newStatus,
        approvedBy: approvedBy ?? current.approvedBy,
        approvedAt: newStatus == BookingStatus.approved ? DateTime.now() : current.approvedAt,
        rejectionReason: rejectionReason ?? current.rejectionReason,
        laboranReviewNotes: laboranReviewNotes ?? current.laboranReviewNotes,
      );
    }
  }

  /// Submit pengembalian ruangan beserta video bukti kebersihan & AC mati
  Future<void> submitRoomCheckout({
    required String bookingId,
    required bool isClean,
    required bool isAcOff,
    required bool isLightsOff,
    required bool isPcOff,
    required bool isDoorsLocked,
    required String videoName,
    required String videoUrl,
    String? notes,
  }) async {
    final index = _bookings.indexWhere((b) => b.id == bookingId);
    if (index != -1) {
      final current = _bookings[index];
      _bookings[index] = current.copyWith(
        status: BookingStatus.completed,
        checkoutCleanlinessStatus: isClean,
        checkoutAcOffStatus: isAcOff,
        checkoutLightsOffStatus: isLightsOff,
        checkoutPcOffStatus: isPcOff,
        checkoutDoorsLockedStatus: isDoorsLocked,
        checkoutVideoName: videoName,
        checkoutVideoUrl: videoUrl,
        checkoutSubmittedAt: DateTime.now(),
        checkoutNotes: notes,
      );
    }
  }
}

enum ConflictType { none, rosterClass, existingBooking }

class ConflictCheckResult {
  final bool hasConflict;
  final ConflictType conflictType;
  final String message;
  final RosterItemModel? conflictingRoster;
  final BookingModel? conflictingBooking;

  const ConflictCheckResult({
    required this.hasConflict,
    this.conflictType = ConflictType.none,
    this.message = '',
    this.conflictingRoster,
    this.conflictingBooking,
  });
}
