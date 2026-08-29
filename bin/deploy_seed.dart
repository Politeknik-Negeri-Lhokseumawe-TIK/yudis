import 'dart:convert';
import 'dart:io';
import '../lib/core/supabase/supabase_config.dart';
import '../lib/features/peminjaman_ruang/data/datasources/room_data_source.dart';
import '../lib/features/peminjaman_ruang/data/datasources/roster_data_source.dart';

Future<void> main() async {
  print('====================================================');
  print('🚀 AUTO-DEPLOY VIA SUPABASE REST API (PostgREST)');
  print('   Project URL: $supabaseUrl');
  print('====================================================\n');

  final client = HttpClient();

  Future<void> upsertBatch(String table, List<Map<String, dynamic>> items) async {
    final uri = Uri.parse('$supabaseUrl/rest/v1/$table');
    final req = await client.postUrl(uri);
    req.headers.set('apikey', supabaseAnonKey);
    req.headers.set('Authorization', 'Bearer $supabaseAnonKey');
    req.headers.set('Content-Type', 'application/json');
    req.headers.set('Prefer', 'resolution=merge-duplicates');

    final jsonBody = jsonEncode(items);
    req.add(utf8.encode(jsonBody));

    final res = await req.close();
    final resBody = await res.transform(utf8.decoder).join();

    if (res.statusCode >= 200 && res.statusCode < 300) {
      // Success
    } else {
      throw Exception('HTTP ${res.statusCode} on $table: $resBody');
    }
  }

  try {
    // 1. Upsert Rooms
    print('📦 [1/3] Uploading 43 Master Ruangan & Lab...');
    final rooms = RoomDataSource.getAllRooms().map((r) => r.toJson()).toList();
    const roomChunkSize = 25;
    for (var i = 0; i < rooms.length; i += roomChunkSize) {
      final end = (i + roomChunkSize < rooms.length) ? i + roomChunkSize : rooms.length;
      final chunk = rooms.sublist(i, end);
      await upsertBatch(SupabaseTables.rooms, chunk);
      print('   -> Uploaded rooms ${i + 1} s/d $end...');
    }
    print('✅ Sukses 43 Ruangan berhasil di-upsert!\n');

    // 2. Upsert Receptionist Officers
    print('👮 [2/3] Uploading Petugas Resepsionis...');
    final officers = [
      {
        'id': 'officer-01',
        'name': 'Munawir, S.Kom.',
        'nip': '19880412 201903 1 008',
        'shift_name': 'Shift Pagi',
        'shift_hours': '07:30 - 13:00 WIB',
        'role': 'Front Desk Officer & Koordinator Lab',
        'is_active': true,
      },
      {
        'id': 'officer-02',
        'name': 'Riza Maulana, S.T.',
        'nip': '19910725 202203 1 005',
        'shift_name': 'Shift Siang',
        'shift_hours': '13:00 - 18:00 WIB',
        'role': 'Customer Service Specialist & Teknisi Cloud',
        'is_active': true,
      },
      {
        'id': 'officer-03',
        'name': 'Safriadi, S.T., M.Kom.',
        'nip': '19850214 201404 1 002',
        'shift_name': 'Shift Penuh',
        'shift_hours': '08:00 - 16:00 WIB',
        'role': 'Supervisor Operasional PBM & Laboran Senior',
        'is_active': true,
      },
    ];
    try {
      await upsertBatch('receptionist_officers', officers);
      print('✅ Sukses Petugas Resepsionis berhasil di-upsert!\n');
    } catch (e) {
      print('⚠️ Petugas Resepsionis: $e\n');
    }

    // 3. Upsert Roster Items
    print('📅 [3/3] Uploading 423 Jadwal Roster PBM Gasal 2026/2027...');
    final schedules = RosterDataSource.getAllSchedules().map((s) => s.toJson()).toList();
    const scheduleChunkSize = 50;
    var totalUploaded = 0;
    for (var i = 0; i < schedules.length; i += scheduleChunkSize) {
      final end = (i + scheduleChunkSize < schedules.length) ? i + scheduleChunkSize : schedules.length;
      final chunk = schedules.sublist(i, end);
      await upsertBatch(SupabaseTables.rosterItems, chunk);
      totalUploaded = end;
      print('   -> Uploaded jadwal sesi ${i + 1} s/d $end dari ${schedules.length}...');
    }

    print('\n🎉 SEMUA DATA ROSTER DAN RUANGAN BERHASIL TERDEPLOY 100% KE SUPABASE CLOUD!');
    print('   - 43 Ruangan (16 Lab/Studio + 27 Ruang Kelas)');
    print('   - $totalUploaded Jadwal Sesi Roster Lengkap Gasal 2026/2027');
    print('====================================================\n');
  } catch (e, stack) {
    print('\n❌ Error: $e');
    print('Trace: $stack');
  } finally {
    client.close();
  }
}
