import 'dart:math';
import '../../domain/models/booking_model.dart';
import '../../domain/models/roster_item_model.dart';
import '../datasources/roster_data_source.dart';

class BookingRepository {
  final List<BookingModel> _bookings = [];

  BookingRepository();

  // Data peminjaman diisi dari Supabase (lihat supabase_booking_repository.dart)
  // Tidak ada seed data dummy — mode produksi.

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
