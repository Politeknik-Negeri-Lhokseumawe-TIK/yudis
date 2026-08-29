import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/supabase/supabase_config.dart';
import '../../domain/models/roster_item_model.dart';
import '../datasources/roster_data_source.dart';

class SupabaseRosterRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Mengambil daftar seluruh jadwal Roster PBM dari Supabase (dengan filter & local fallback)
  Future<List<RosterItemModel>> getRosterItems({
    String? day,
    String? roomCode,
    String? studyProgram,
    String? className,
    bool? isPracticum,
  }) async {
    try {
      var query = _client.from(SupabaseTables.rosterItems).select();

      if (day != null && day.isNotEmpty && day != 'Semua' && day != 'Semua Hari') {
        query = query.eq('day', day);
      }
      if (roomCode != null && roomCode.isNotEmpty && roomCode != 'Semua' && roomCode != 'Semua Ruangan') {
        query = query.eq('room_code', roomCode);
      }
      if (studyProgram != null && studyProgram.isNotEmpty && studyProgram != 'Semua' && studyProgram != 'Semua Prodi') {
        query = query.eq('study_program', studyProgram);
      }
      if (className != null && className.isNotEmpty && className != 'Semua' && className != 'Semua Kelas') {
        query = query.eq('class_name', className);
      }
      if (isPracticum != null && isPracticum) {
        query = query.eq('is_practicum', true);
      }

      final response = await query.order('start_session', ascending: true);
      final List<dynamic> data = response as List<dynamic>;

      if (data.isNotEmpty) {
        return data
            .map((json) => RosterItemModel.fromJson(json as Map<String, dynamic>))
            .toList();
      }
    } catch (e) {
      debugPrint('⚠️ [SupabaseRosterRepository] Menggunakan local roster fallback: $e');
    }

    // Fallback ke dataset lokal hasil ekstraksi 48 halaman Roster Gasal TA 2026/2027
    final all = RosterDataSource.getAllSchedules();
    return all.where((item) {
      if (day != null && day.isNotEmpty && day != 'Semua' && day != 'Semua Hari' && item.day != day) {
        return false;
      }
      if (roomCode != null && roomCode.isNotEmpty && roomCode != 'Semua' && roomCode != 'Semua Ruangan' && item.roomCode != roomCode) {
        return false;
      }
      if (studyProgram != null && studyProgram.isNotEmpty && studyProgram != 'Semua' && studyProgram != 'Semua Prodi' && item.studyProgram != studyProgram) {
        return false;
      }
      if (className != null && className.isNotEmpty && className != 'Semua' && className != 'Semua Kelas' && item.className != className) {
        return false;
      }
      if (isPracticum != null && isPracticum && !item.isPracticum) {
        return false;
      }
      return true;
    }).toList();
  }

  /// Sinkronisasi / Seed Jadwal Roster ke Supabase
  Future<bool> seedRosterToSupabase() async {
    try {
      final allItems = RosterDataSource.getAllSchedules();
      final payload = allItems.map((item) => item.toJson()).toList();

      // Chunk per 50 rows untuk menghindari limit payload Supabase
      const chunkSize = 50;
      for (var i = 0; i < payload.length; i += chunkSize) {
        final end = (i + chunkSize < payload.length) ? i + chunkSize : payload.length;
        final chunk = payload.sublist(i, end);
        await _client.from(SupabaseTables.rosterItems).upsert(chunk);
      }
      return true;
    } catch (e) {
      debugPrint('❌ [SupabaseRosterRepository] Gagal seed roster: $e');
      return false;
    }
  }
}
