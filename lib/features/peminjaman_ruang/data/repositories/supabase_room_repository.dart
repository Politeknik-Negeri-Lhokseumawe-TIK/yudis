import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../../../core/supabase/supabase_config.dart';
import '../../domain/models/room_model.dart';
import '../datasources/room_data_source.dart';

class SupabaseRoomRepository {
  final SupabaseClient _client = Supabase.instance.client;

  /// Mengambil daftar semua ruangan dan laboratorium dari Supabase (dengan fallback lokal)
  Future<List<RoomModel>> getRooms() async {
    try {
      final response = await _client
          .from(SupabaseTables.rooms)
          .select()
          .order('id', ascending: true);

      final List<dynamic> data = response as List<dynamic>;
      if (data.isNotEmpty) {
        return data.map((json) => RoomModel.fromJson(json as Map<String, dynamic>)).toList();
      }
    } catch (e) {
      debugPrint('⚠️ [SupabaseRoomRepository] Menggunakan local fallback: $e');
    }

    // Fallback ke Master Data Lokal jika offline / tabel belum di-seed
    return RoomDataSource.getAllRooms();
  }

  /// Sinkronisasi / Seed Master Data Ruangan ke Supabase jika tabel masih kosong
  Future<bool> seedRoomsToSupabase() async {
    try {
      final localRooms = RoomDataSource.getAllRooms();
      final payload = localRooms.map((r) => r.toJson()).toList();
      await _client.from(SupabaseTables.rooms).upsert(payload);
      return true;
    } catch (e) {
      debugPrint('❌ [SupabaseRoomRepository] Gagal seed rooms: $e');
      return false;
    }
  }
}
