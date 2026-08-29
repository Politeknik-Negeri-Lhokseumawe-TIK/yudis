import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../../auth/domain/user_model.dart';
import '../../pendaftaran_yudisium/domain/pendaftaran_model.dart';
import '../../pendaftaran_yudisium/domain/template_syarat_model.dart';
import '../domain/admin_models.dart';
import '../domain/activity_log_model.dart';
import '../domain/auto_verification_service.dart';

/// Admin Repository — Supabase Real-Time Implementation
class AdminRepository {
  static SupabaseClient get _supabase => Supabase.instance.client;

  // ── Logging Activity (dipanggil dari mana saja) ─────────────
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
      // Log gagal tidak harus menghentikan flow utama
    }
  }

  // ── Pending Accounts ─────────────────────────────────────────
  Future<List<PendingAccount>> getPendingAccounts() async {
    try {
      final rows = await _supabase
          .from('profiles')
          .select()
          .eq('is_active', false)
          .order('created_at', ascending: false);

      return (rows as List).map((row) {
        final r = row as Map<String, dynamic>;
        return PendingAccount(
          user: _rowToUser(r),
          registeredAt: DateTime.tryParse(r['created_at'] as String? ?? '') ?? DateTime.now(),
        );
      }).toList();
    } catch (_) {
      return [];
    }
  }

  Future<bool> verifikasiAkun(String userId, bool approve, {String? alasan}) async {
    try {
      await _supabase
          .from('profiles')
          .update({'is_active': approve})
          .eq('id', userId);
    } catch (_) {}

    // Cari nama mahasiswa untuk log
    String nama = 'Mahasiswa';
    try {
      final userRow = await _supabase
          .from('profiles')
          .select('nama')
          .eq('id', userId)
          .maybeSingle();
      nama = userRow?['nama'] as String? ?? 'Mahasiswa';
    } catch (_) {}

    await logActivity(
      type: 'verifikasiAkun',
      actorName: 'Admin TIK',
      targetName: nama,
      description: approve
          ? 'Menyetujui pendaftaran akun mahasiswa'
          : 'Menolak akun: ${alasan ?? "-"}',
    );

    // Kirim notifikasi ke mahasiswa
    await _supabase.from('notifikasi').insert({
      'user_id': userId,
      'judul': approve ? 'Akun Diverifikasi ✅' : 'Akun Ditolak ❌',
      'pesan': approve
          ? 'Selamat! Akun Anda telah diverifikasi. Silakan login dan mulai mendaftar yudisium.'
          : 'Pendaftaran akun Anda ditolak. Alasan: ${alasan ?? "-"}. Hubungi admin untuk info lebih lanjut.',
      'type': approve ? 'success' : 'error',
    });

    return true;
  }

  // ── Pendaftaran List ──────────────────────────────────────────
  Future<List<PendaftaranAdmin>> getPendaftaranList() async {
    final rows = await _supabase
        .from('pendaftaran')
        .select('*, users(*), dokumen_pendaftaran(*)')
        .order('submitted_at', ascending: false);

    return (rows as List)
        .map((row) => _rowToPendaftaranAdmin(row as Map<String, dynamic>))
        .toList();
  }

  Future<PendaftaranAdmin?> getPendaftaranDetail(String id) async {
    final row = await _supabase
        .from('pendaftaran')
        .select('*, users(*), dokumen_pendaftaran(*)')
        .eq('id', id)
        .maybeSingle();
    if (row == null) return null;
    return _rowToPendaftaranAdmin(row);
  }

  Future<bool> verifikasiDokumen({
    required String pendaftaranId,
    required String dokumenId,
    required StatusDokumen status,
    String? catatan,
  }) async {
    await _supabase.from('dokumen_pendaftaran').update({
      'status': status.value,
      'catatan_admin': catatan,
      'verified_at': DateTime.now().toIso8601String(),
    }).eq('id', dokumenId);

    // Cari nama dokumen dan mahasiswa untuk log & notif
    final dokRow = await _supabase
        .from('dokumen_pendaftaran')
        .select('nama, pendaftaran_id')
        .eq('id', dokumenId)
        .maybeSingle();
    final namaDok = dokRow?['nama'] as String? ?? 'Dokumen';

    final pendRow = await _supabase
        .from('pendaftaran')
        .select('user_id, users(nama)')
        .eq('id', pendaftaranId)
        .maybeSingle();
    final userId = pendRow?['user_id'] as String?;
    final namaMhs = (pendRow?['users'] as Map?)?.entries
            .firstWhere((e) => e.key == 'nama', orElse: () => const MapEntry('nama', 'Mahasiswa'))
            .value as String? ??
        'Mahasiswa';

    await logActivity(
      type: 'verifikasiDokumen',
      actorName: 'Admin TIK',
      targetName: '$namaMhs ($namaDok)',
      description: 'Status dokumen diubah menjadi: ${status.label}',
    );

    // Kirim notifikasi ke mahasiswa
    if (userId != null) {
      final pesanNotif = status == StatusDokumen.valid
          ? 'Dokumen "$namaDok" Anda telah diverifikasi dan dinyatakan valid.'
          : 'Dokumen "$namaDok" Anda tidak valid. ${catatan != null ? "Catatan: $catatan" : ""} Silakan upload ulang.';
      await _supabase.from('notifikasi').insert({
        'user_id': userId,
        'judul': status == StatusDokumen.valid ? 'Dokumen Valid ✅' : 'Dokumen Perlu Revisi ⚠️',
        'pesan': pesanNotif,
        'type': status == StatusDokumen.valid ? 'success' : 'warning',
      });
    }

    return true;
  }

  /// Menyetujui pendaftaran yudisium secara final
  Future<bool> setujuiPendaftaran({
    required String pendaftaranId,
    required String userId,
    required String namaMahasiswa,
  }) async {
    await _supabase.from('pendaftaran').update({
      'status': 'disetujui',
    }).eq('id', pendaftaranId);

    await logActivity(
      type: 'pendaftaranDisetujui',
      actorName: 'Admin TIK',
      targetName: namaMahasiswa,
      description: 'Pendaftaran Yudisium $namaMahasiswa telah DISETUJUI / LULUS verifikasi berkas.',
    );

    await _supabase.from('notifikasi').insert({
      'user_id': userId,
      'judul': 'Selamat! Pendaftaran Yudisium Disetujui 🎉',
      'pesan': 'Seluruh dokumen persyaratan yudisium Anda telah diverifikasi dan DISETUJUI oleh Admin Jurusan TIK PNL.',
      'type': 'success',
    });

    return true;
  }

  /// Meminta revisi berkas pendaftaran yudisium
  Future<bool> mintaRevisiPendaftaran({
    required String pendaftaranId,
    required String userId,
    required String namaMahasiswa,
    String? catatan,
  }) async {
    await _supabase.from('pendaftaran').update({
      'status': 'revisi',
    }).eq('id', pendaftaranId);

    await logActivity(
      type: 'revisiDiminta',
      actorName: 'Admin TIK',
      targetName: namaMahasiswa,
      description: 'Permintaan revisi berkas pendaftaran yudisium untuk $namaMahasiswa.',
    );

    await _supabase.from('notifikasi').insert({
      'user_id': userId,
      'judul': 'Berkas Yudisium Perlu Revisi ⚠️',
      'pesan': 'Terdapat berkas persyaratan yudisium yang perlu diperbaiki. ${catatan != null ? "Catatan: $catatan" : "Silakan periksa detail berkas Anda dan upload ulang."}',
      'type': 'warning',
    });

    return true;
  }

  /// ── Sistem Otomasi Verifikasi Dokumen ──────────────────────────

  /// Jalankan auto-verifikasi untuk satu mahasiswa
  Future<PendaftaranAutoVerificationSummary> autoVerifyRegistration(
      PendaftaranAdmin pAdmin) async {
    final summary = AutoVerificationService.verifyRegistration(pAdmin);
    final pendaftaran = pAdmin.pendaftaran;
    final mahasiswa = pAdmin.mahasiswa;

    for (final doc in pendaftaran.dokumen) {
      final res = summary.documentResults[doc.id];
      if (res != null && doc.isUploaded) {
        // Terapkan auto approval jika skor >= 75%
        if (res.isAutoApproved) {
          await _supabase.from('dokumen_pendaftaran').update({
            'status': 'valid',
            'catatan_admin': 'Terverifikasi otomatis oleh sistem (Skor: ${res.confidenceScore}%)',
            'verified_at': DateTime.now().toIso8601String(),
          }).eq('id', doc.id);
        } else if (res.autoDraftedNote != null) {
          // Rekam catatan draf sistem
          await _supabase.from('dokumen_pendaftaran').update({
            'catatan_admin': res.autoDraftedNote,
          }).eq('id', doc.id);
        }
      }
    }

    if (summary.canAutoApproveEntireRegistration) {
      await _supabase.from('pendaftaran').update({
        'status': 'disetujui',
      }).eq('id', pendaftaran.id);

      await _supabase.from('notifikasi').insert({
        'user_id': pendaftaran.userId,
        'judul': 'Pendaftaran Yudisium Terverifikasi Otomatis 🎉',
        'pesan': 'Seluruh dokumen persyaratan yudisium Anda telah diperiksa dan DISETUJUI otomatis oleh Sistem Verifikasi TIK PNL.',
        'type': 'success',
      });
    }

    await logActivity(
      type: 'autoVerification',
      actorName: 'Sistem Otomatis TIK',
      targetName: mahasiswa.nama,
      description: 'Auto-verifikasi selesai (Skor Kelayakan: ${summary.overallScore}%). Status: ${summary.canAutoApproveEntireRegistration ? "Disetujui Otomatis" : "Perlu Peninjauan"}',
    );

    return summary;
  }

  /// Jalankan auto-verifikasi massal untuk seluruh mahasiswa yang masuk
  Future<Map<String, dynamic>> batchAutoVerifyAll() async {
    final list = await getPendaftaranList();
    int autoApprovedCount = 0;
    int flaggedCount = 0;

    for (final p in list) {
      final summary = await autoVerifyRegistration(p);
      if (summary.canAutoApproveEntireRegistration) {
        autoApprovedCount++;
      } else {
        flaggedCount++;
      }
    }

    return {
      'total': list.length,
      'auto_approved': autoApprovedCount,
      'flagged': flaggedCount,
    };
  }

  // ── Statistik ─────────────────────────────────────────────────
  Future<Map<String, int>> getStats() async {
    try {
      final allPendaftaran = await _supabase
          .from('pendaftaran')
          .select('status, program_studi');

      final list = allPendaftaran as List;
      return {
        'pending_akun': 0,
        'total_pendaftaran': list.length,
        'submitted': list.where((r) => r['status'] == 'submitted').length,
        'disetujui': list.where((r) => r['status'] == 'disetujui').length,
        'ditolak': list.where((r) => r['status'] == 'ditolak').length,
        'trkj': list.where((r) => r['program_studi'] == 'TRKJ').length,
        'trmm': list.where((r) => r['program_studi'] == 'TRMM').length,
        'ti': list.where((r) => r['program_studi'] == 'TI').length,
      };
    } catch (_) {
      return {
        'pending_akun': 0, 'total_pendaftaran': 0,
        'submitted': 0, 'disetujui': 0, 'ditolak': 0,
        'trkj': 0, 'trmm': 0, 'ti': 0,
      };
    }
  }

  Future<List<ActivityLog>> getActivityLogs() async {
    final rows = await _supabase
        .from('activity_logs')
        .select()
        .order('created_at', ascending: false)
        .limit(20);

    return (rows as List).map((row) {
      final r = row as Map<String, dynamic>;
      final typeStr = r['type'] as String? ?? 'pendaftaranBaru';
      return ActivityLog(
        id: r['id'] as String,
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
  }

  // ── Real-Time Streams (Supabase Realtime) ─────────────────────

  /// Stream statistik — update otomatis saat ada perubahan di tabel pendaftaran
  Stream<Map<String, int>> statsStream() {
    return _supabase
        .from('pendaftaran')
        .stream(primaryKey: ['id'])
        .asyncMap((_) => getStats());
  }

  /// Stream activity logs — update otomatis saat ada log baru
  Stream<List<ActivityLog>> activityLogsStream() {
    return _supabase
        .from('activity_logs')
        .stream(primaryKey: ['id'])
        .order('created_at', ascending: false)
        .limit(20)
        .asyncMap((rows) async {
          return rows.map((row) {
            final typeStr = row['type'] as String? ?? 'pendaftaranBaru';
            return ActivityLog(
              id: row['id'] as String,
              type: ActivityType.values.firstWhere(
                (t) => t.name == typeStr,
                orElse: () => ActivityType.pendaftaranBaru,
              ),
              actorName: row['actor_name'] as String? ?? '-',
              targetName: row['target_name'] as String? ?? '-',
              timestamp: DateTime.tryParse(row['created_at'] as String? ?? '') ?? DateTime.now(),
              description: row['description'] as String? ?? '',
            );
          }).toList();
        });
  }

  /// Stream pending accounts — update otomatis saat ada akun baru
  Stream<List<PendingAccount>> pendingAccountsStream() {
    try {
      return _supabase
          .from('profiles')
          .stream(primaryKey: ['id'])
          .eq('is_active', false)
          .order('created_at', ascending: false)
          .map((rows) => rows.map((r) => PendingAccount(
                user: _rowToUser(r),
                registeredAt: DateTime.tryParse(r['created_at'] as String? ?? '') ?? DateTime.now(),
              )).toList());
    } catch (_) {
      return const Stream.empty();
    }
  }

  // ── Template Dokumen ──────────────────────────────────────────
  Future<List<TemplateSyaratDokumen>> getTemplateDokumen() async {
    final rows = await _supabase
        .from('template_dokumen')
        .select()
        .order('urutan');

    return (rows as List).map((row) {
      final r = row as Map<String, dynamic>;
      return TemplateSyaratDokumen(
        id: r['id'] as String,
        kode: r['kode'] as String,
        nama: r['nama'] as String,
        deskripsi: r['deskripsi'] as String? ?? '',
        isWajib: r['is_wajib'] as bool? ?? true,
        kondisiJenjang: r['kondisi_jenjang'] != null
            ? Jenjang.values.firstWhere(
                (j) => j.value == r['kondisi_jenjang'],
                orElse: () => Jenjang.d4,
              )
            : null,
        kondisiAsrama: r['kondisi_asrama'] as bool?,
        urutan: r['urutan'] as int? ?? 0,
      );
    }).toList();
  }

  // ── Helpers ───────────────────────────────────────────────────
  static User _rowToUser(Map<String, dynamic> r) {
    final roleStr = (r['role'] ?? 'mahasiswa').toString().toLowerCase();
    final isAdmin = roleStr == 'admin' || roleStr == 'laboran' || roleStr == 'super_admin';
    return User(
      id: (r['id'] ?? '').toString(),
      nim: (r['nim'] ?? r['nip'] ?? '-').toString(),
      nama: (r['nama'] ?? 'Mahasiswa TIK').toString(),
      email: (r['email'] ?? '').toString(),
      role: isAdmin ? UserRole.admin : UserRole.mahasiswa,
      statusAkun: (r['is_active'] == true) ? StatusAkun.aktif : StatusAkun.pendingVerifikasi,
      programStudi: ProgramStudi.values.firstWhere(
        (e) => e.value.toLowerCase() == (r['prodi'] ?? r['program_studi'] ?? 'trkj').toString().toLowerCase(),
        orElse: () => ProgramStudi.trkj,
      ),
      noHp: r['no_hp'] as String?,
      avatarUrl: r['avatar_url'] as String?,
      createdAt: r['created_at'] != null
          ? DateTime.tryParse(r['created_at'].toString())
          : null,
    );
  }

  static PendaftaranAdmin _rowToPendaftaranAdmin(Map<String, dynamic> r) {
    final userMap = r['users'] as Map<String, dynamic>? ?? {};
    final dokumenRows = r['dokumen_pendaftaran'] as List? ?? [];

    final dokumen = dokumenRows.map((d) {
      final dm = d as Map<String, dynamic>;
      return DokumenSyarat(
        id: dm['id'] as String,
        kode: dm['kode'] as String,
        nama: dm['nama'] as String,
        deskripsi: dm['deskripsi'] as String? ?? '',
        isWajib: dm['is_wajib'] as bool? ?? true,
        status: StatusDokumen.values.firstWhere(
          (s) => s.value == (dm['status'] ?? 'belum_upload'),
          orElse: () => StatusDokumen.belumUpload,
        ),
        filePath: dm['file_url'] as String?,
        fileName: dm['file_name'] as String?,
        fileSize: dm['file_size'] as int?,
        catatanAdmin: dm['catatan_admin'] as String?,
        maxSizeBytes: _resolveMaxSizeBytes(dm['kode'] as String? ?? ''),
      );
    }).toList();

    final pendaftaran = PendaftaranYudisium(
      id: r['id'] as String,
      userId: r['user_id'] as String,
      periodeId: r['periode_id'] as String? ?? '',
      programStudi: ProgramStudi.values.firstWhere(
        (e) => e.value == r['program_studi'],
        orElse: () => ProgramStudi.ti,
      ),
      jenjang: Jenjang.values.firstWhere(
        (e) => e.value == r['jenjang'],
        orElse: () => Jenjang.d4,
      ),
      ipk: (r['ipk'] as num?)?.toDouble() ?? 0.0,
      totalSks: r['total_sks'] as int? ?? 0,
      semester: r['semester'] as int? ?? 0,
      tinggalDiAsrama: r['tinggal_di_asrama'] as bool? ?? false,
      dokumen: dokumen,
      biodata: _mapToBiodata(r['biodata'] as Map<String, dynamic>?),
      status: StatusPendaftaran.values.firstWhere(
        (s) => s.value == (r['status'] ?? 'draft'),
        orElse: () => StatusPendaftaran.draft,
      ),
      submittedAt: r['submitted_at'] != null
          ? DateTime.tryParse(r['submitted_at'] as String)
          : null,
    );

    return PendaftaranAdmin(
      mahasiswa: _rowToUser(userMap),
      pendaftaran: pendaftaran,
    );
  }

  static BiodataCalon _mapToBiodata(Map<String, dynamic>? data) {
    if (data == null) return const BiodataCalon();
    return BiodataCalon(
      tempatLahir: data['tempat_lahir'] as String?,
      tanggalLahir: data['tanggal_lahir'] != null
          ? DateTime.tryParse(data['tanggal_lahir'] as String)
          : null,
      jenisKelamin: data['jenis_kelamin'] as String?,
      namaAyah: data['nama_ayah'] as String?,
      pembimbing1: data['pembimbing_1'] as String?,
      pembimbing2: data['pembimbing_2'] as String?,
    );
  }

  static int _resolveMaxSizeBytes(String kode) {
    final upper = kode.toUpperCase();
    if (upper.contains('FOTO')) return 1048576; // 1 MB
    if (upper.contains('TGA') || upper.contains('SERTIFIKAT')) return 3145728; // 3 MB
    return 2097152; // 2 MB Default
  }
}
