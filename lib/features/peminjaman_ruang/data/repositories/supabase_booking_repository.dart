import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/security/crypto_security_service.dart';
import '../../../../core/supabase/supabase_config.dart';
import '../../domain/models/booking_model.dart';
import 'booking_repository.dart';

class SupabaseBookingRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final BookingRepository _localRepo = BookingRepository();

  /// Mengambil semua booking dari Supabase (atau fallback lokal jika koneksi terputus)
  Future<List<BookingModel>> getAllBookings({String? userId}) async {
    try {
      var query = _client.from(SupabaseTables.bookings).select();
      if (userId != null && userId.isNotEmpty) {
        query = query.eq('user_id', userId);
      }
      final response = await query.order('created_at', ascending: false);
      final List<dynamic> data = response as List<dynamic>;

      return data
          .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } catch (e) {
      debugPrint('⚠️ [SupabaseBookingRepository] Menggunakan local booking fallback karena error: $e');
      return _localRepo.getAllBookings();
    }
  }

  static bool _isValidUuid(String? str) {
    if (str == null) return false;
    final uuidRegex = RegExp(
      r'^[0-9a-fA-F]{8}-[0-9a-fA-F]{4}-[1-5][0-9a-fA-F]{3}-[89abAB][0-9a-fA-F]{3}-[0-9a-fA-F]{12}$',
    );
    return uuidRegex.hasMatch(str);
  }

  /// Membuat pengajuan peminjaman baru dengan Blockchain Ledger Hash
  Future<BookingModel> createBooking(BookingModel booking) async {
    // 1. Generate cryptographic block hash untuk integritas transaksi
    final ledgerHash = CryptoSecurityService.generateBookingLedgerHash(
      bookingCode: booking.bookingCode,
      roomCode: booking.roomCode,
      userNimNip: booking.userNimNip,
      timestamp: booking.createdAt.toIso8601String(),
    );

    final d = booking.bookingDate;
    final formattedDate =
        '${d.year.toString().padLeft(4, '0')}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

    final payload = <String, dynamic>{
      'booking_code': booking.bookingCode,
      'user_id': _isValidUuid(booking.userId) ? booking.userId : null,
      'user_name': booking.userName,
      'user_nim_nip': booking.userNimNip,
      'user_phone': booking.userPhone,
      'user_role': booking.userRole,
      'room_code': booking.roomCode,
      'room_name': booking.roomName,
      'booking_date': formattedDate,
      'day': booking.day,
      'start_session': booking.startSession,
      'end_session': booking.endSession,
      'start_time': booking.startTime,
      'end_time': booking.endTime,
      'purpose': booking.purpose,
      'description': booking.description,
      'supervisor_lecturer': booking.supervisorLecturer,
      'additional_facilities': booking.additionalFacilities,
      'status': booking.status.name,
      'booking_ledger_hash': ledgerHash,
      'created_at': booking.createdAt.toIso8601String(),
    };

    if (_isValidUuid(booking.id)) {
      payload['id'] = booking.id;
    }

    try {
      final response = await _client
          .from(SupabaseTables.bookings)
          .insert(payload)
          .select();

      final List<dynamic> insertedList = response as List<dynamic>;
      final created = insertedList.isNotEmpty
          ? BookingModel.fromJson(insertedList.first as Map<String, dynamic>)
          : booking;

      _localRepo.createBooking(created);
      debugPrint('✅ [SupabaseBookingRepository] Berhasil simpan booking ${created.bookingCode} ke Supabase Cloud (ID: ${created.id})');
      return created;
    } catch (e) {
      debugPrint('❌ [SupabaseBookingRepository] ERROR INSERT KE SUPABASE: $e');
      // Coba fallback dengan payload paling esensial jika ada kolom yang belum tersedia di database
      try {
        final basicPayload = <String, dynamic>{
          'booking_code': booking.bookingCode,
          'user_name': booking.userName,
          'user_nim_nip': booking.userNimNip,
          'user_phone': booking.userPhone,
          'user_role': booking.userRole,
          'room_code': booking.roomCode,
          'room_name': booking.roomName,
          'booking_date': formattedDate,
          'day': booking.day,
          'start_session': booking.startSession,
          'end_session': booking.endSession,
          'start_time': booking.startTime,
          'end_time': booking.endTime,
          'purpose': booking.purpose,
          'description': booking.description,
          'supervisor_lecturer': booking.supervisorLecturer,
          'status': booking.status.name,
        };
        final response2 = await _client
            .from(SupabaseTables.bookings)
            .insert(basicPayload)
            .select();
        final List<dynamic> list2 = response2 as List<dynamic>;
        final created2 = list2.isNotEmpty
            ? BookingModel.fromJson(list2.first as Map<String, dynamic>)
            : booking;
        _localRepo.createBooking(created2);
        return created2;
      } catch (e2) {
        debugPrint('❌ [SupabaseBookingRepository] RETRY BASIC PAYLOAD GAGAL: $e2');
        rethrow;
      }
    }
  }

  /// Update status persetujuan peminjaman oleh Laboran / Admin
  Future<bool> updateBookingStatus(
    String bookingId,
    BookingStatus status, {
    String? approvedBy,
    String? rejectionReason,
    String? laboranReviewNotes,
  }) async {
    final now = DateTime.now();
    try {
      await _client.from(SupabaseTables.bookings).update({
        'status': status.name,
        'approved_by': approvedBy,
        'approved_at': status == BookingStatus.approved ? now.toIso8601String() : null,
        'rejection_reason': rejectionReason,
        'laboran_review_notes': laboranReviewNotes,
        'updated_at': now.toIso8601String(),
      }).eq('id', bookingId);
    } catch (e) {
      debugPrint('⚠️ [SupabaseBookingRepository] Update cloud gagal, update lokal: $e');
    }

    await _localRepo.updateBookingStatus(
      bookingId,
      status,
      approvedBy: approvedBy,
      rejectionReason: rejectionReason,
      laboranReviewNotes: laboranReviewNotes,
    );
    return true;
  }

  /// Submit pengembalian ruangan beserta unggah video inspeksi ke Supabase Storage
  Future<bool> submitRoomCheckout({
    required String bookingId,
    required bool isClean,
    required bool isAcOff,
    required bool isLightsOff,
    required bool isPcOff,
    required bool isDoorsLocked,
    required String videoName,
    required String videoUrl,
    Uint8List? videoBytes,
    String? notes,
  }) async {
    final now = DateTime.now();
    String finalVideoUrl = videoUrl;

    // 1. Unggah video ke Supabase Storage Bucket jika ada data bytes
    if (videoBytes != null && videoBytes.isNotEmpty) {
      try {
        final filePath = 'checkout_videos/${bookingId}_${now.millisecondsSinceEpoch}.mp4';
        await _client.storage.from(SupabaseBuckets.videoInspeksi).uploadBinary(
              filePath,
              videoBytes,
              fileOptions: const FileOptions(contentType: 'video/mp4', upsert: true),
            );
        finalVideoUrl = _client.storage.from(SupabaseBuckets.videoInspeksi).getPublicUrl(filePath);
      } catch (e) {
        debugPrint('⚠️ [SupabaseStorage] Gagal unggah video ke cloud: $e');
      }
    }

    // 2. Generate Hash Integritas Bukti Video
    final videoHash = CryptoSecurityService.generateVideoInspectionHash(
      bookingCode: bookingId,
      videoName: videoName,
      isAcOff: isAcOff,
      isClean: isClean,
      timestamp: now.toIso8601String(),
    );

    try {
      await _client.from(SupabaseTables.bookings).update({
        'checkout_cleanliness_status': isClean,
        'checkout_ac_off_status': isAcOff,
        'checkout_lights_off_status': isLightsOff,
        'checkout_pc_off_status': isPcOff,
        'checkout_doors_locked_status': isDoorsLocked,
        'checkout_video_url': finalVideoUrl,
        'checkout_video_name': videoName,
        'checkout_submitted_at': now.toIso8601String(),
        'checkout_notes': notes,
        'video_inspection_hash': videoHash,
        'status': BookingStatus.completed.name,
        'updated_at': now.toIso8601String(),
      }).eq('id', bookingId);
    } catch (e) {
      debugPrint('⚠️ [SupabaseBookingRepository] Checkout cloud gagal: $e');
    }

    await _localRepo.submitRoomCheckout(
      bookingId: bookingId,
      isClean: isClean,
      isAcOff: isAcOff,
      isLightsOff: isLightsOff,
      isPcOff: isPcOff,
      isDoorsLocked: isDoorsLocked,
      videoName: videoName,
      videoUrl: finalVideoUrl,
      notes: notes,
    );
    return true;
  }

  /// Pengecekan potensi bentrok jadwal
  ConflictCheckResult checkConflict({
    required String roomCode,
    required String day,
    required int startSession,
    required int endSession,
    required DateTime date,
    String? excludeBookingId,
  }) {
    return _localRepo.checkConflict(
      roomCode: roomCode,
      day: day,
      startSession: startSession,
      endSession: endSession,
      date: date,
      excludeBookingId: excludeBookingId,
    );
  }
}
