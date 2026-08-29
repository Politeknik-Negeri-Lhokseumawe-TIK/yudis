import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/security/crypto_security_service.dart';
import '../../../../core/supabase/supabase_config.dart';
import '../../domain/models/booking_model.dart';
import 'booking_repository.dart';

class SupabaseBookingRepository {
  final SupabaseClient _client = Supabase.instance.client;
  final BookingRepository _localRepo = BookingRepository();

  /// Mengambil semua booking dari Supabase (atau fallback lokal)
  Future<List<BookingModel>> getAllBookings({String? userId}) async {
    try {
      var query = _client.from(SupabaseTables.bookings).select();
      if (userId != null && userId.isNotEmpty) {
        query = query.eq('user_id', userId);
      }
      final response = await query.order('created_at', ascending: false);
      final List<dynamic> data = response as List<dynamic>;

      if (data.isNotEmpty) {
        return data
            .map((json) => BookingModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('⚠️ [SupabaseBookingRepository] Menggunakan local booking fallback: $e');
    }

    // Fallback ke penyimpanan memori lokal
    return _localRepo.getAllBookings();
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

    final payload = booking.toJson();
    payload['booking_ledger_hash'] = ledgerHash;

    try {
      final response = await _client
          .from(SupabaseTables.bookings)
          .insert(payload)
          .select()
          .single();

      final created = BookingModel.fromJson(response);
      _localRepo.createBooking(created);
      return created;
    } catch (e) {
      debugPrint('⚠️ [SupabaseBookingRepository] Gagal simpan ke cloud, simpan ke lokal: $e');
      return await _localRepo.createBooking(booking);
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
