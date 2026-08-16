import 'dart:async';
import '../../auth/domain/user_model.dart';
import '../../pendaftaran_yudisium/domain/pendaftaran_model.dart';
import '../../pendaftaran_yudisium/domain/template_syarat_model.dart';
import '../domain/admin_models.dart';
import '../domain/activity_log_model.dart';

/// Mock admin repository dengan Real-time Streaming
class AdminRepository {
  // ── Mock pending accounts ───────────────────────────────────
  static final List<PendingAccount> _pendingAccounts = [
    PendingAccount(
      user: const User(
        id: 'p001',
        nim: '2024110010',
        nama: 'Muhammad Rizki',
        email: 'rizki@students.pnl.ac.id',
        role: UserRole.mahasiswa,
        statusAkun: StatusAkun.pendingVerifikasi,
        programStudi: ProgramStudi.ti,
        noHp: '08111222333',
      ),
      registeredAt: DateTime.now().subtract(const Duration(hours: 3)),
    ),
    PendingAccount(
      user: const User(
        id: 'p002',
        nim: '2024120005',
        nama: 'Cut Nadira',
        email: 'nadira@students.pnl.ac.id',
        role: UserRole.mahasiswa,
        statusAkun: StatusAkun.pendingVerifikasi,
        programStudi: ProgramStudi.trkj,
        noHp: '08222333444',
      ),
      registeredAt: DateTime.now().subtract(const Duration(hours: 6)),
    ),
    PendingAccount(
      user: const User(
        id: 'p003',
        nim: '2024130008',
        nama: 'Teuku Faisal',
        email: 'faisal@students.pnl.ac.id',
        role: UserRole.mahasiswa,
        statusAkun: StatusAkun.pendingVerifikasi,
        programStudi: ProgramStudi.trmm,
        noHp: '08333444555',
      ),
      registeredAt: DateTime.now().subtract(const Duration(days: 1)),
    ),
  ];

  // ── Mock pendaftaran for admin review ───────────────────────
  static final List<PendaftaranAdmin> _pendaftaranList = [
    PendaftaranAdmin(
      mahasiswa: const User(
        id: 'u001',
        nim: '2021903430045',
        nama: 'Ahmad Fauzi',
        email: 'ahmad.fauzi@gmail.com',
        role: UserRole.mahasiswa,
        statusAkun: StatusAkun.aktif,
        programStudi: ProgramStudi.trkj,
      ),
      pendaftaran: PendaftaranYudisium(
        id: 'pend_001',
        userId: 'u001',
        periodeId: 'p2025-2',
        programStudi: ProgramStudi.trkj,
        jenjang: Jenjang.d4,
        ipk: 3.65,
        totalSks: 144,
        semester: 8,
        tinggalDiAsrama: true,
        dokumen: mockTemplateDokumen.map((t) {
          final dok = t.toDokumenSyarat();
          dok.status = StatusDokumen.valid;
          dok.filePath = '/mock/${t.kode.toLowerCase()}.pdf';
          dok.fileName = '${t.kode.toLowerCase()}.pdf';
          dok.fileSize = 1024 * 500;
          return dok;
        }).toList(),
        biodata: const BiodataCalon(
          tempatLahir: 'Lhokseumawe',
          jenisKelamin: 'Laki-laki',
          namaAyah: 'Bapak Andi',
          namaIbu: 'Ibu Andi',
          judulTga: 'Implementasi Sistem Informasi Yudisium Berbasis Web',
          pembimbing1: 'Dr. Ahmad, M.T.',
          pembimbing2: 'Ir. Budi, M.Kom.',
        ),
        status: StatusPendaftaran.disetujui,
        submittedAt: DateTime.now().subtract(const Duration(hours: 12)),
      ),
    ),
    PendaftaranAdmin(
      mahasiswa: const User(
        id: 'u002',
        nim: '2021903430046',
        nama: 'Siti Nurhaliza',
        email: 'siti.nurhaliza@students.pnl.ac.id',
        role: UserRole.mahasiswa,
        statusAkun: StatusAkun.aktif,
        programStudi: ProgramStudi.trkj,
      ),
      pendaftaran: PendaftaranYudisium(
        id: 'pend_002',
        userId: 'u002',
        periodeId: 'p2025-2',
        programStudi: ProgramStudi.trkj,
        jenjang: Jenjang.d4,
        ipk: 3.82,
        totalSks: 144,
        semester: 8,
        tinggalDiAsrama: false,
        dokumen: mockTemplateDokumen.map((t) => t.toDokumenSyarat()).toList(),
        biodata: const BiodataCalon(),
        status: StatusPendaftaran.submitted,
        submittedAt: DateTime.now().subtract(const Duration(hours: 4)),
      ),
    ),
    PendaftaranAdmin(
      mahasiswa: const User(
        id: 'u003',
        nim: '2021903430070',
        nama: 'Rian Pratama',
        email: 'rian.pratama@students.pnl.ac.id',
        role: UserRole.mahasiswa,
        statusAkun: StatusAkun.aktif,
        programStudi: ProgramStudi.trmm,
      ),
      pendaftaran: PendaftaranYudisium(
        id: 'pend_003',
        userId: 'u003',
        periodeId: 'p2025-2',
        programStudi: ProgramStudi.trmm,
        jenjang: Jenjang.d4,
        ipk: 3.70,
        totalSks: 144,
        semester: 8,
        tinggalDiAsrama: false,
        dokumen: mockTemplateDokumen.map((t) => t.toDokumenSyarat()).toList(),
        biodata: const BiodataCalon(),
        status: StatusPendaftaran.disetujui,
        submittedAt: DateTime.now().subtract(const Duration(days: 1)),
      ),
    ),
    PendaftaranAdmin(
      mahasiswa: const User(
        id: 'u004',
        nim: '2021903430088',
        nama: 'Dina Safitri',
        email: 'dina.safitri@students.pnl.ac.id',
        role: UserRole.mahasiswa,
        statusAkun: StatusAkun.aktif,
        programStudi: ProgramStudi.ti,
      ),
      pendaftaran: PendaftaranYudisium(
        id: 'pend_004',
        userId: 'u004',
        periodeId: 'p2025-2',
        programStudi: ProgramStudi.ti,
        jenjang: Jenjang.d4,
        ipk: 3.90,
        totalSks: 144,
        semester: 8,
        tinggalDiAsrama: true,
        dokumen: mockTemplateDokumen.map((t) => t.toDokumenSyarat()).toList(),
        biodata: const BiodataCalon(),
        status: StatusPendaftaran.submitted,
        submittedAt: DateTime.now().subtract(const Duration(hours: 1)),
      ),
    ),
  ];

  // ── Mock Activity Logs ──────────────────────────────────────
  static final List<ActivityLog> _activityLogs = [
    ActivityLog(
      id: 'act_01',
      type: ActivityType.pendaftaranBaru,
      actorName: 'Dina Safitri',
      targetName: 'Pendaftaran Yudisium TI',
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      description: 'Mengajukan berkas pendaftaran yudisium baru',
    ),
    ActivityLog(
      id: 'act_02',
      type: ActivityType.uploadDokumen,
      actorName: 'Siti Nurhaliza',
      targetName: 'Transkrip_Nilai.pdf',
      timestamp: DateTime.now().subtract(const Duration(minutes: 25)),
      description: 'Mengupload dokumen persyaratan yudisium',
    ),
    ActivityLog(
      id: 'act_03',
      type: ActivityType.verifikasiDokumen,
      actorName: 'Admin TIK',
      targetName: 'Ahmad Fauzi',
      timestamp: DateTime.now().subtract(const Duration(hours: 2)),
      description: 'Menyetujui seluruh dokumen yudisium',
    ),
    ActivityLog(
      id: 'act_04',
      type: ActivityType.verifikasiAkun,
      actorName: 'Admin TIK',
      targetName: 'Rian Pratama',
      timestamp: DateTime.now().subtract(const Duration(hours: 5)),
      description: 'Memverifikasi akun mahasiswa baru TRMM',
    ),
  ];

  static void addPendingAccount(User user) {
    _pendingAccounts.removeWhere((a) => a.user.id == user.id || a.user.nim == user.nim);
    _pendingAccounts.insert(
      0,
      PendingAccount(
        user: user,
        registeredAt: DateTime.now(),
      ),
    );
    _activityLogs.insert(
      0,
      ActivityLog(
        id: 'act_${DateTime.now().millisecondsSinceEpoch}',
        type: ActivityType.pendaftaranBaru,
        actorName: user.nama,
        targetName: user.nim,
        timestamp: DateTime.now(),
        description: 'Mendaftar akun mahasiswa baru (${user.programStudi.value})',
      ),
    );
  }

  Future<List<PendingAccount>> getPendingAccounts() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return List.from(_pendingAccounts);
  }

  Future<bool> verifikasiAkun(String userId, bool approve, {String? alasan}) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final acc = _pendingAccounts.where((a) => a.user.id == userId).firstOrNull;
    _pendingAccounts.removeWhere((a) => a.user.id == userId);
    if (acc != null) {
      _activityLogs.insert(
        0,
        ActivityLog(
          id: 'act_${DateTime.now().millisecondsSinceEpoch}',
          type: ActivityType.verifikasiAkun,
          actorName: 'Admin TIK',
          targetName: acc.user.nama,
          timestamp: DateTime.now(),
          description: approve ? 'Menyetujui pendaftaran akun mahasiswa' : 'Menolak akun: $alasan',
        ),
      );
    }
    return true;
  }

  Future<List<PendaftaranAdmin>> getPendaftaranList() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return List.from(_pendaftaranList);
  }

  Future<PendaftaranAdmin?> getPendaftaranDetail(String id) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _pendaftaranList.where((p) => p.pendaftaran.id == id).firstOrNull;
  }

  Future<bool> verifikasiDokumen({
    required String pendaftaranId,
    required String dokumenId,
    required StatusDokumen status,
    String? catatan,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    final pa = _pendaftaranList.where((p) => p.pendaftaran.id == pendaftaranId).firstOrNull;
    if (pa == null) return false;
    final dok = pa.pendaftaran.dokumen.where((d) => d.id == dokumenId).firstOrNull;
    if (dok == null) return false;
    dok.status = status;
    dok.catatanAdmin = catatan;

    _activityLogs.insert(
      0,
      ActivityLog(
        id: 'act_${DateTime.now().millisecondsSinceEpoch}',
        type: ActivityType.verifikasiDokumen,
        actorName: 'Admin TIK',
        targetName: '${pa.mahasiswa.nama} (${dok.nama})',
        timestamp: DateTime.now(),
        description: 'Status dokumen diubah menjadi: ${status.name}',
      ),
    );
    return true;
  }

  Future<Map<String, int>> getStats() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return {
      'pending_akun': _pendingAccounts.length,
      'total_pendaftaran': _pendaftaranList.length,
      'submitted': _pendaftaranList
          .where((p) => p.pendaftaran.status == StatusPendaftaran.submitted)
          .length,
      'disetujui': _pendaftaranList
          .where((p) => p.pendaftaran.status == StatusPendaftaran.disetujui)
          .length,
      'ditolak': _pendaftaranList
          .where((p) => p.pendaftaran.status == StatusPendaftaran.ditolak)
          .length,
      'trkj': _pendaftaranList
          .where((p) => p.pendaftaran.programStudi == ProgramStudi.trkj)
          .length,
      'trmm': _pendaftaranList
          .where((p) => p.pendaftaran.programStudi == ProgramStudi.trmm)
          .length,
      'ti': _pendaftaranList
          .where((p) => p.pendaftaran.programStudi == ProgramStudi.ti)
          .length,
    };
  }

  Future<List<ActivityLog>> getActivityLogs() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return List.from(_activityLogs);
  }

  /// Real-Time stream stats generator
  Stream<Map<String, int>> statsStream() {
    return Stream.periodic(const Duration(seconds: 5), (_) async {
      return await getStats();
    }).asyncMap((event) => event);
  }

  /// Real-Time stream activity logs
  Stream<List<ActivityLog>> activityLogsStream() {
    return Stream.periodic(const Duration(seconds: 8), (_) async {
      return await getActivityLogs();
    }).asyncMap((event) => event);
  }
}
