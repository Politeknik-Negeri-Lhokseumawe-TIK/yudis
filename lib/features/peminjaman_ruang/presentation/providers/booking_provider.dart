import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/supabase/supabase_config.dart';
import '../../domain/models/booking_model.dart';
import '../../domain/models/room_model.dart';
import '../../data/repositories/booking_repository.dart';
import '../../data/repositories/supabase_booking_repository.dart';
import '../../data/services/excel_export_service.dart';

final supabaseBookingRepoProvider = Provider<SupabaseBookingRepository>((ref) {
  return SupabaseBookingRepository();
});

/// Provider notifikasi ketika ada peminjaman baru yang baru masuk ke sistem secara real-time
final newBookingEventProvider = StateProvider<BookingModel?>((ref) => null);

class BookingListNotifier extends StateNotifier<List<BookingModel>> {
  final SupabaseBookingRepository _repository;
  final void Function(BookingModel newBooking)? _onNewBooking;
  RealtimeChannel? _realtimeChannel;
  Timer? _pollingTimer;

  BookingListNotifier(this._repository, [this._onNewBooking]) : super([]) {
    loadBookings();
    _initRealtimeSync();
  }

  void _initRealtimeSync() {
    try {
      final client = Supabase.instance.client;
      _realtimeChannel = client
          .channel('public:${SupabaseTables.bookings}')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: SupabaseTables.bookings,
            callback: (payload) {
              debugPrint('⚡ [Realtime Supabase] Booking event: ${payload.eventType}');
              loadBookings();
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('⚠️ [Realtime Supabase] Gagal inisialisasi Realtime Channel: $e');
    }

    // Polling auto-sync interval 5 detik untuk menjamin sinkronisasi cross-browser/PC
    _pollingTimer = Timer.periodic(const Duration(seconds: 5), (_) {
      loadBookings();
    });
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    if (_realtimeChannel != null) {
      Supabase.instance.client.removeChannel(_realtimeChannel!);
    }
    super.dispose();
  }

  Future<void> loadBookings() async {
    final oldList = state;
    final list = await _repository.getAllBookings();

    // Deteksi record baru yang belum pernah tercatat sebelumnya di state
    if (oldList.isNotEmpty && list.length > oldList.length) {
      final oldIds = oldList.map((b) => b.id).toSet();
      final oldCodes = oldList.map((b) => b.bookingCode).toSet();
      final newItems = list
          .where((b) => !oldIds.contains(b.id) && !oldCodes.contains(b.bookingCode))
          .toList();
      if (newItems.isNotEmpty && _onNewBooking != null) {
        _onNewBooking(newItems.first);
      }
    }

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
  return BookingListNotifier(repo, (newBooking) {
    ref.read(newBookingEventProvider.notifier).state = newBooking;
  });
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
