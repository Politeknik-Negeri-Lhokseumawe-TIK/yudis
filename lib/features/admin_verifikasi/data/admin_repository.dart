import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../auth/domain/user_model.dart';
import '../domain/activity_log_model.dart';

/// Admin Repository — SIM-LAB & Ruang PBM TIK PNL
/// Hanya berisi operasi yang dibutuhkan oleh sistem peminjaman lab & ruang kelas.
class AdminRepository {
  static SupabaseClient get _supabase => Supabase.instance.client;

  // ── Logging Activity ──────────────────────────────────────────
  static Future<void> logActivity({
    required String type,
    required String actorName,
    required String targetName,
    required String description,
  }) async {
    try {
      await _supabase.from('activity_logs').insert({
        'type': type,
        'actor_name': actorName,
        'target_name': targetName,
        'description': description,
      });
    } catch (_) {
      // Log gagal tidak menghentikan flow utama
    }
  }

  // ── Activity Logs ─────────────────────────────────────────────
  Future<List<ActivityLog>> getActivityLogs() async {
    try {
      final rows = await _supabase
          .from('activity_logs')
          .select()
          .order('created_at', ascending: false)
          .limit(30);

      return (rows as List).map((row) {
        final r = row as Map<String, dynamic>;
        final typeStr = r['type'] as String? ?? 'info';
        return ActivityLog(
          id: r['id'].toString(),
          type: ActivityType.values.firstWhere(
            (t) => t.name == typeStr,
            orElse: () => ActivityType.pendaftaranBaru,
          ),
          actorName: r['actor_name'] as String? ?? '-',
          targetName: r['target_name'] as String? ?? '-',
          timestamp: DateTime.tryParse(r['created_at'] as String? ?? '') ?? DateTime.now(),
          description: r['description'] as String? ?? '',
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Stream<List<ActivityLog>> activityLogsStream() {
    try {
      return _supabase
          .from('activity_logs')
          .stream(primaryKey: ['id'])
          .order('created_at', ascending: false)
          .limit(20)
          .map((rows) => rows.map((row) {
                final typeStr = row['type'] as String? ?? 'info';
                return ActivityLog(
                  id: row['id'].toString(),
                  type: ActivityType.values.firstWhere(
                    (t) => t.name == typeStr,
                    orElse: () => ActivityType.pendaftaranBaru,
                  ),
                  actorName: row['actor_name'] as String? ?? '-',
                  targetName: row['target_name'] as String? ?? '-',
                  timestamp:
                      DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
                  description: row['description'] as String? ?? '',
                );
              }).toList());
    } catch (_) {
      return const Stream.empty();
    }
  }

  // ── Daftar User/Profil (untuk keperluan admin SIM-LAB) ───────
  Future<List<User>> getAllUsers() async {
    try {
      final rows = await _supabase
          .from('profiles')
          .select()
          .order('created_at', ascending: false);
      return (rows as List).map((r) => _rowToUser(r as Map<String, dynamic>)).toList();
    } catch (_) {
      return [];
    }
  }

  // ── Statistik Ringkasan ───────────────────────────────────────
  Future<Map<String, int>> getStats() async {
    try {
      final bookings = await _supabase.from('bookings').select('status');
      final list = bookings as List;
      return {
        'total': list.length,
        'pending': list.where((r) => r['status'] == 'pending').length,
        'approved': list.where((r) => r['status'] == 'approved').length,
        'active': list.where((r) => r['status'] == 'active').length,
        'completed': list.where((r) => r['status'] == 'completed').length,
        'rejected': list.where((r) => r['status'] == 'rejected').length,
      };
    } catch (_) {
      return {
        'total': 0, 'pending': 0, 'approved': 0,
        'active': 0, 'completed': 0, 'rejected': 0,
      };
    }
  }

  // ── Helper ────────────────────────────────────────────────────
  static User _rowToUser(Map<String, dynamic> r) {
    final roleStr = (r['role'] ?? 'mahasiswa').toString().toLowerCase();
    final isAdmin = roleStr == 'admin' || roleStr == 'laboran' || roleStr == 'super_admin';
    return User(
      id: (r['id'] ?? '').toString(),
      nim: (r['nim'] ?? r['nip'] ?? '-').toString(),
      nama: (r['nama'] ?? 'Pengguna TIK').toString(),
      email: (r['email'] ?? '').toString(),
      role: isAdmin ? UserRole.admin : UserRole.mahasiswa,
      statusAkun: (r['is_active'] == true) ? StatusAkun.aktif : StatusAkun.pendingVerifikasi,
      programStudi: ProgramStudi.values.firstWhere(
        (e) => e.value.toLowerCase() ==
            (r['prodi'] ?? r['program_studi'] ?? 'trkj').toString().toLowerCase(),
        orElse: () => ProgramStudi.trkj,
      ),
      noHp: r['no_hp'] as String?,
      avatarUrl: r['avatar_url'] as String?,
      createdAt: r['created_at'] != null
          ? DateTime.tryParse(r['created_at'].toString())
          : null,
    );
  }
}
