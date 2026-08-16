import 'dart:typed_data';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/pendaftaran_model.dart';
import '../../../auth/domain/user_model.dart';
import '../../../admin_verifikasi/data/admin_repository.dart';

// ── Pendaftaran State ─────────────────────────────────────────
class PendaftaranState {
  const PendaftaranState({
    this.pendaftaran,
    this.periode,
    this.isLoading = false,
    this.error,
    this.currentStep = 0,
    this.isSubmitting = false,
    this.submitSuccess = false,
  });

  final PendaftaranYudisium? pendaftaran;
  final PeriodeYudisium? periode;
  final bool isLoading;
  final String? error;
  final int currentStep;
  final bool isSubmitting;
  final bool submitSuccess;

  PendaftaranState copyWith({
    PendaftaranYudisium? pendaftaran,
    PeriodeYudisium? periode,
    bool? isLoading,
    String? error,
    int? currentStep,
    bool? isSubmitting,
    bool? submitSuccess,
    bool clearError = false,
  }) {
    return PendaftaranState(
      pendaftaran: pendaftaran ?? this.pendaftaran,
      periode: periode ?? this.periode,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────
class PendaftaranNotifier extends StateNotifier<PendaftaranState> {
  PendaftaranNotifier() : super(const PendaftaranState()) {
    _loadPeriode();
  }

  static SupabaseClient get _supabase => Supabase.instance.client;

  /// Muat periode yudisium aktif dari Supabase
  Future<void> _loadPeriode() async {
    state = state.copyWith(isLoading: true);
    try {
      final row = await _supabase
          .from('periode_yudisium')
          .select()
          .eq('is_aktif', true)
          .order('tanggal_selesai', ascending: false)
          .limit(1)
          .maybeSingle();

      if (row != null) {
        final periode = PeriodeYudisium(
          id: row['id'] as String,
          nama: row['nama'] as String,
          tanggalMulai: DateTime.parse(row['tanggal_mulai'] as String),
          tanggalSelesai: DateTime.parse(row['tanggal_selesai'] as String),
          isAktif: row['is_aktif'] as bool,
          deskripsi: row['deskripsi'] as String?,
        );
        state = state.copyWith(periode: periode, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false, error: 'Tidak ada periode yudisium aktif.');
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat periode: $e');
    }
  }

  /// Muat data pendaftaran yang sudah ada milik user dari Supabase
  Future<void> loadExistingPendaftaran(String userId) async {
    state = state.copyWith(isLoading: true);
    try {
      final row = await _supabase
          .from('pendaftaran')
          .select('*, dokumen_pendaftaran(*)')
          .eq('user_id', userId)
          .order('created_at', ascending: false)
          .limit(1)
          .maybeSingle();

      if (row != null) {
        final dokumenRows = row['dokumen_pendaftaran'] as List? ?? [];
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
          id: row['id'] as String,
          userId: row['user_id'] as String,
          periodeId: row['periode_id'] as String? ?? '',
          programStudi: ProgramStudi.values.firstWhere(
            (e) => e.value == row['program_studi'],
            orElse: () => ProgramStudi.ti,
          ),
          jenjang: Jenjang.values.firstWhere(
            (e) => e.value == row['jenjang'],
            orElse: () => Jenjang.d4,
          ),
          ipk: (row['ipk'] as num?)?.toDouble() ?? 0.0,
          totalSks: row['total_sks'] as int? ?? 0,
          semester: row['semester'] as int? ?? 0,
          tinggalDiAsrama: row['tinggal_di_asrama'] as bool? ?? false,
          dokumen: dokumen,
          biodata: _mapToBiodata(row['biodata'] as Map<String, dynamic>?),
          status: StatusPendaftaran.values.firstWhere(
            (s) => s.value == (row['status'] ?? 'draft'),
            orElse: () => StatusPendaftaran.draft,
          ),
          submittedAt: row['submitted_at'] != null
              ? DateTime.tryParse(row['submitted_at'] as String)
              : null,
        );

        // Bug #3 Fix: pertahankan currentStep yang sedang aktif, jangan reset
        state = state.copyWith(pendaftaran: pendaftaran, isLoading: false);
      } else {
        state = state.copyWith(isLoading: false);
      }
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal memuat pendaftaran: $e');
    }
  }

  /// Inisialisasi pendaftaran baru — insert ke Supabase
  Future<void> mulaiPendaftaran({
    required String userId,
    required ProgramStudi programStudi,
    required Jenjang jenjang,
    required double ipk,
    required int totalSks,
    required int semester,
    required bool tinggalDiAsrama,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      // Ambil template dokumen dari Supabase
      final adminRepo = AdminRepository();
      final templates = await adminRepo.getTemplateDokumen();

      // Filter dokumen berdasarkan kondisi jenjang & asrama
      final filteredTemplates = templates.where((t) {
        if (t.kondisiJenjang != null && t.kondisiJenjang != jenjang) return false;
        if (t.kondisiAsrama != null && t.kondisiAsrama != tinggalDiAsrama) return false;
        return true;
      }).toList();

      final periodeId = state.periode?.id ?? '';

      // Cek apakah user sudah punya record pendaftaran draft
      final existingDraft = await _supabase
          .from('pendaftaran')
          .select('id')
          .eq('user_id', userId)
          .eq('status', 'draft')
          .maybeSingle();

      String pendaftaranId;
      if (existingDraft != null) {
        pendaftaranId = existingDraft['id'] as String;
        // Update draft yang ada
        await _supabase.from('pendaftaran').update({
          'periode_id': periodeId,
          'program_studi': programStudi.value,
          'jenjang': jenjang.value,
          'ipk': ipk,
          'total_sks': totalSks,
          'semester': semester,
          'tinggal_di_asrama': tinggalDiAsrama,
        }).eq('id', pendaftaranId);
      } else {
        // Insert pendaftaran baru ke Supabase
        final insertedRow = await _supabase.from('pendaftaran').insert({
          'user_id': userId,
          'periode_id': periodeId,
          'program_studi': programStudi.value,
          'jenjang': jenjang.value,
          'ipk': ipk,
          'total_sks': totalSks,
          'semester': semester,
          'tinggal_di_asrama': tinggalDiAsrama,
          'status': 'draft',
          'biodata': {},
        }).select().single();

        pendaftaranId = insertedRow['id'] as String;

        // Insert dokumen per template ke tabel dokumen_pendaftaran
        final dokumenInserts = filteredTemplates.map((t) => {
          'pendaftaran_id': pendaftaranId,
          'kode': t.kode,
          'nama': t.nama,
          'deskripsi': t.deskripsi,
          'is_wajib': t.isWajib,
          'status': 'belum_upload',
        }).toList();

        if (dokumenInserts.isNotEmpty) {
          await _supabase.from('dokumen_pendaftaran').insert(dokumenInserts);
        }
      }

      // Reload state & otomatis lanjut ke Step 1 (Upload Dokumen 1-6)
      await loadExistingPendaftaran(userId);
      state = state.copyWith(currentStep: 1, isLoading: false);
    } catch (e) {
      state = state.copyWith(isLoading: false, error: 'Gagal membuat pendaftaran: $e');
    }
  }

  /// Upload dokumen ke Supabase Storage + update record
  /// Returns [true] jika berhasil, [false] jika gagal
  Future<bool> uploadDokumen({
    required String dokumenId,
    required List<int> fileBytes,
    required String fileName,
    required int fileSize,
    required String userId,
  }) async {
    final pendaftaran = state.pendaftaran;
    if (pendaftaran == null) return false;

    // Bug #4 Fix: Optimistic update — langsung tandai dokumen sebagai uploading
    // di state lokal agar UI langsung responsif sebelum Supabase merespons
    final optimisticDokumen = pendaftaran.dokumen.map((d) {
      if (d.id != dokumenId) return d;
      return DokumenSyarat(
        id: d.id,
        kode: d.kode,
        nama: d.nama,
        deskripsi: d.deskripsi,
        isWajib: d.isWajib,
        kondisiJenjang: d.kondisiJenjang,
        kondisiAsrama: d.kondisiAsrama,
        status: StatusDokumen.menunggu,
        filePath: d.filePath,
        fileName: fileName, // tampilkan nama file asli segera
        fileSize: fileSize,
        catatanAdmin: d.catatanAdmin,
        maxSizeBytes: d.maxSizeBytes,
      );
    }).toList();
    state = state.copyWith(
      pendaftaran: PendaftaranYudisium(
        id: pendaftaran.id,
        userId: pendaftaran.userId,
        periodeId: pendaftaran.periodeId,
        programStudi: pendaftaran.programStudi,
        jenjang: pendaftaran.jenjang,
        ipk: pendaftaran.ipk,
        totalSks: pendaftaran.totalSks,
        semester: pendaftaran.semester,
        tinggalDiAsrama: pendaftaran.tinggalDiAsrama,
        dokumen: optimisticDokumen,
        biodata: pendaftaran.biodata,
        status: pendaftaran.status,
        submittedAt: pendaftaran.submittedAt,
      ),
    );

    try {
      // Bug #5 Fix: Path tetap tanpa timestamp agar file lama
      // otomatis tertimpa (upsert) — tidak ada ghost file di storage
      final ext = fileName.contains('.')
          ? fileName.split('.').last.toLowerCase()
          : 'bin';
      final storagePath =
          '$userId/${pendaftaran.id}/$dokumenId/berkas.$ext';

      // Bug #1 Fix: konversi ke Uint8List agar uploadBinary bekerja
      final bytes = Uint8List.fromList(fileBytes);
      await _supabase.storage.from('dokumen').uploadBinary(
        storagePath,
        bytes,
        fileOptions: const FileOptions(upsert: true),
      );

      final fileUrl =
          _supabase.storage.from('dokumen').getPublicUrl(storagePath);

      // Update record di Supabase dengan nama file asli (Bug #5)
      await _supabase.from('dokumen_pendaftaran').update({
        'status': 'menunggu',
        'file_url': fileUrl,
        'file_name': fileName, // nama asli sesuai file yang dipilih user
        'file_size': fileSize,
        'uploaded_at': DateTime.now().toIso8601String(),
      }).eq('id', dokumenId);

      // Log aktivitas
      final dok = pendaftaran.dokumen.firstWhere((d) => d.id == dokumenId);
      await AdminRepository.logActivity(
        type: 'uploadDokumen',
        actorName: '',
        targetName: dok.nama,
        description: 'Mahasiswa mengupload dokumen: $fileName',
      );

      // Refresh state dari Supabase untuk sinkronisasi final
      await loadExistingPendaftaran(userId);
      return true;
    } catch (e) {
      // Bug #2 Fix: kembalikan false agar caller bisa tampilkan error ke UI
      // Rollback optimistic update — kembalikan state ke kondisi sebelum upload
      await loadExistingPendaftaran(userId);
      state = state.copyWith(error: 'Gagal upload dokumen: $e');
      return false;
    }
  }

  void updateBiodata(BiodataCalon biodata) {
    final p = state.pendaftaran;
    if (p == null) return;
    final updated = PendaftaranYudisium(
      id: p.id,
      userId: p.userId,
      periodeId: p.periodeId,
      programStudi: p.programStudi,
      jenjang: p.jenjang,
      ipk: p.ipk,
      totalSks: p.totalSks,
      semester: p.semester,
      tinggalDiAsrama: p.tinggalDiAsrama,
      dokumen: p.dokumen,
      biodata: biodata,
      status: p.status,
    );
    state = state.copyWith(pendaftaran: updated);
  }

  void setStep(int step) => state = state.copyWith(currentStep: step);

  /// Submit pendaftaran — update status di Supabase
  Future<bool> submit() async {
    final p = state.pendaftaran;
    if (p == null) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);
    try {
      final now = DateTime.now();

      // Simpan biodata ke Supabase
      await _supabase.from('pendaftaran').update({
        'status': 'submitted',
        'submitted_at': now.toIso8601String(),
        'biodata': _biodataToMap(p.biodata),
      }).eq('id', p.id);

      // Ambil data user untuk log yang rapi
      final userRow = await _supabase
          .from('users')
          .select('nama, nim')
          .eq('id', p.userId)
          .maybeSingle();
      final namaMhs = userRow?['nama'] as String? ?? 'Mahasiswa';
      final nimMhs = userRow?['nim'] as String? ?? '';

      // Log aktivitas
      await AdminRepository.logActivity(
        type: 'pendaftaranBaru',
        actorName: namaMhs,
        targetName: 'Pengajuan Berkas Yudisium',
        description: '$namaMhs ($nimMhs) telah mengajukan seluruh berkas pendaftaran yudisium untuk diverifikasi.',
      );

      p.status = StatusPendaftaran.submitted;
      p.submittedAt = now;

      state = state.copyWith(
        isSubmitting: false,
        submitSuccess: true,
        pendaftaran: p,
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        isSubmitting: false,
        error: 'Gagal submit pendaftaran: $e',
      );
      return false;
    }
  }

  void reset() {
    state = const PendaftaranState();
    _loadPeriode();
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
      namaIbu: data['nama_ibu'] as String?,
      judulTga: data['judul_tga'] as String?,
      pembimbing1: data['pembimbing_1'] as String?,
      pembimbing2: data['pembimbing_2'] as String?,
    );
  }

  static Map<String, dynamic> _biodataToMap(BiodataCalon b) => {
    'tempat_lahir': b.tempatLahir,
    'tanggal_lahir': b.tanggalLahir?.toIso8601String(),
    'jenis_kelamin': b.jenisKelamin,
    'nama_ayah': b.namaAyah,
    'nama_ibu': b.namaIbu,
    'judul_tga': b.judulTga,
    'pembimbing_1': b.pembimbing1,
    'pembimbing_2': b.pembimbing2,
  };

  static int _resolveMaxSizeBytes(String kode) {
    final upper = kode.toUpperCase();
    if (upper.contains('FOTO')) return 1048576; // 1 MB
    if (upper.contains('TGA') || upper.contains('SERTIFIKAT')) return 3145728; // 3 MB
    return 2097152; // 2 MB Default
  }
}

// ── Providers ─────────────────────────────────────────────────
final pendaftaranProvider =
    StateNotifierProvider<PendaftaranNotifier, PendaftaranState>((ref) {
  return PendaftaranNotifier();
});

final periodeAktifProvider = Provider<PeriodeYudisium?>((ref) {
  return ref.watch(pendaftaranProvider).periode;
});
