import 'package:supabase_flutter/supabase_flutter.dart';

/// Model notifikasi in-app
class Notifikasi {
  const Notifikasi({
    required this.id,
    required this.judul,
    required this.pesan,
    required this.waktu,
    this.isRead = false,
    this.type = NotifikasiType.info,
  });

  final String id;
  final String judul;
  final String pesan;
  final DateTime waktu;
  final bool isRead;
  final NotifikasiType type;

  factory Notifikasi.fromRow(Map<String, dynamic> row) {
    return Notifikasi(
      id: row['id'] as String,
      judul: row['judul'] as String,
      pesan: row['pesan'] as String,
      waktu: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
      isRead: row['is_read'] as bool? ?? false,
      type: NotifikasiType.values.firstWhere(
        (t) => t.name == (row['type'] ?? 'info'),
        orElse: () => NotifikasiType.info,
      ),
    );
  }
}

enum NotifikasiType {
  info,
  success,
  warning,
  error,
}

/// Repository untuk mengambil notifikasi real-time dari Supabase
class NotifikasiRepository {
  static SupabaseClient get _supabase => Supabase.instance.client;

  /// Ambil semua notifikasi milik user
  static Future<List<Notifikasi>> getNotifikasi(String userId) async {
    final rows = await _supabase
        .from('notifikasi')
        .select()
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50);

    return (rows as List)
        .map((r) => Notifikasi.fromRow(r as Map<String, dynamic>))
        .toList();
  }

  /// Stream notifikasi real-time (Supabase Realtime)
  static Stream<List<Notifikasi>> notifikasiStream(String userId) {
    return _supabase
        .from('notifikasi')
        .stream(primaryKey: ['id'])
        .eq('user_id', userId)
        .order('created_at', ascending: false)
        .limit(50)
        .map((rows) => rows
            .map((r) => Notifikasi.fromRow(r))
            .toList());
  }

  /// Tandai notifikasi sebagai sudah dibaca
  static Future<void> markAsRead(String notifId) async {
    await _supabase
        .from('notifikasi')
        .update({'is_read': true})
        .eq('id', notifId);
  }

  /// Tandai semua notifikasi user sebagai sudah dibaca
  static Future<void> markAllAsRead(String userId) async {
    await _supabase
        .from('notifikasi')
        .update({'is_read': true})
        .eq('user_id', userId)
        .eq('is_read', false);
  }

  /// Hitung jumlah notifikasi yang belum dibaca
  static Future<int> getUnreadCount(String userId) async {
    final result = await _supabase
        .from('notifikasi')
        .select('id')
        .eq('user_id', userId)
        .eq('is_read', false)
        .count(CountOption.exact);
    return result.count;
  }
}
