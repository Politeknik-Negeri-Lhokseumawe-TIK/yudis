import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/booking_model.dart';
import '../../domain/models/room_model.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/supabase_booking_repository.dart';
import '../../data/services/excel_export_service.dart';

final supabaseBookingRepoProvider = Provider<SupabaseBookingRepository>((ref) {
  return SupabaseBookingRepository();
});

class BookingListNotifier extends StateNotifier<List<BookingModel>> {
  final SupabaseBookingRepository _repository;

  BookingListNotifier(this._repository) : super([]) {
    loadBookings();
  }

  Future<void> loadBookings() async {
    final list = await _repository.getAllBookings();
    state = list;
  }

  /// Memeriksa potensi bentrok jadwal
  ConflictCheckResult checkConflict({
    required String roomCode,
    required String day,
    required int startSession,
    required int endSession,
    required DateTime date,
    String? excludeBookingId,
  }) {
    return _repository.checkConflict(
      roomCode: roomCode,
      day: day,
      startSession: startSession,
      endSession: endSession,
      date: date,
      excludeBookingId: excludeBookingId,
    );
  }

  /// Membuat pengajuan peminjaman baru
  Future<BookingModel> createBooking(BookingModel booking) async {
    final created = await _repository.createBooking(booking);
    await loadBookings();
    return created;
  }

  /// Update status oleh laboran / admin
  Future<void> updateStatus(
    String bookingId,
    BookingStatus status, {
    String? approvedBy,
    String? rejectionReason,
    String? laboranReviewNotes,
  }) async {
    await _repository.updateBookingStatus(
      bookingId,
      status,
      approvedBy: approvedBy,
      rejectionReason: rejectionReason,
      laboranReviewNotes: laboranReviewNotes,
    );
    await loadBookings();
  }

  /// Submit pengembalian ruangan beserta bukti video kebersihan & AC
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
    await _repository.submitRoomCheckout(
      bookingId: bookingId,
      isClean: isClean,
      isAcOff: isAcOff,
      isLightsOff: isLightsOff,
      isPcOff: isPcOff,
      isDoorsLocked: isDoorsLocked,
      videoName: videoName,
      videoUrl: videoUrl,
      notes: notes,
    );
    await loadBookings();
  }

  /// Ekspor laporan transaksi ke berkas Excel (.xlsx)
  Future<bool> exportToExcel(List<RoomModel> rooms) async {
    try {
      final bytes = await ExcelExportService.generateBookingReportExcel(
        bookings: state,
        rooms: rooms,
      );
      final fileName =
          'Laporan_Peminjaman_Lab_TIK_${DateTime.now().millisecondsSinceEpoch}.xlsx';
      return await ExcelExportService.downloadOrShareExcel(
        fileBytes: bytes,
        fileName: fileName,
      );
    } catch (e) {
      return false;
    }
  }
}

final bookingListProvider =
    StateNotifierProvider<BookingListNotifier, List<BookingModel>>((ref) {
  final repo = ref.watch(supabaseBookingRepoProvider);
  return BookingListNotifier(repo);
});

/// Provider filter status untuk admin/laboran
final adminBookingFilterStatusProvider = StateProvider<BookingStatus?>((ref) => null);

/// Provider filtered bookings untuk admin
final filteredAdminBookingsProvider = Provider<List<BookingModel>>((ref) {
  final bookings = ref.watch(bookingListProvider);
  final statusFilter = ref.watch(adminBookingFilterStatusProvider);

  if (statusFilter == null) return bookings;
  return bookings.where((b) => b.status == statusFilter).toList();
});
