import '../../pendaftaran_yudisium/domain/pendaftaran_model.dart';
import 'admin_models.dart';

/// Hasil analisis dan verifikasi dokumen oleh sistem otomatis
class AutoVerificationResult {
  const AutoVerificationResult({
    required this.confidenceScore,
    required this.isAutoApproved,
    required this.passedChecks,
    required this.warnings,
    required this.recommendedStatus,
    this.autoDraftedNote,
  });

  /// Skor kecocokan berkas (0 - 100%)
  final int confidenceScore;

  /// Apakah berkas memenuhi ambang batas auto-approval (>= 85%)
  final bool isAutoApproved;

  /// Daftar aturan dan pengecekan yang berhasil lolos
  final List<String> passedChecks;

  /// Daftar peringatan atau potensi ketidaksesuaian berkas
  final List<String> warnings;

  /// Rekomendasi status berkas dari sistem
  final StatusDokumen recommendedStatus;

  /// Draf catatan otomatis untuk admin jika terdapat ketidaksesuaian
  final String? autoDraftedNote;
}

/// Hasil analisis pendaftaran yudisium lengkap
class PendaftaranAutoVerificationSummary {
  const PendaftaranAutoVerificationSummary({
    required this.overallScore,
    required this.canAutoApproveEntireRegistration,
    required this.documentResults,
    required this.academicChecksPassed,
    required this.academicWarnings,
  });

  final int overallScore;
  final bool canAutoApproveEntireRegistration;
  final Map<String, AutoVerificationResult> documentResults;
  final List<String> academicChecksPassed;
  final List<String> academicWarnings;
}

/// Mesin Otomasi Pemeriksaan & Verifikasi Dokumen Yudisium
class AutoVerificationService {
  /// Kamus kata kunci yang relevan per jenis berkas
  static const Map<String, List<String>> _documentKeywords = {
    'KRS': [
      'krs',
      'kartu',
      'rencana',
      'studi',
      'semester',
      'akhir',
      'pa',
      'pembimbing',
    ],
    'TRANSKRIP': [
      'transkrip',
      'nilai',
      'sementara',
      'akademik',
      'ipk',
      'sks',
      'baak',
      'kumulatif',
    ],
    'TGA_ACC': [
      'persetujuan',
      'pengesahan',
      'tga',
      'tugas',
      'akhir',
      'skripsi',
      'pembimbing',
      'acc',
    ],
    'TGA_PENGUJI': [
      'penguji',
      'penilaian',
      'sidang',
      'tga',
      'dewan',
      'penguji',
      'nilai',
    ],
    'BEBAS_PUST': [
      'perpustakaan',
      'pustaka',
      'bebas',
      'pinjaman',
      'buku',
      'upt',
    ],
    'BEBAS_LAB': [
      'laboratorium',
      'lab',
      'bebas',
      'jurusan',
      'tik',
      'alat',
    ],
    'BEBAS_KEU': [
      'keuangan',
      'bebas',
      'ukt',
      'spp',
      'lunas',
      'bendahara',
      'kwitansi',
    ],
    'FOTO_FORMAL': [
      'foto',
      'pasfoto',
      'formal',
      'merah',
      '4x6',
      'jas',
    ],
    'KTP_KK': [
      'ktp',
      'kk',
      'keluarga',
      'penduduk',
      'identitas',
      'nik',
    ],
    'IJAZAH_SMA': [
      'ijazah',
      'sma',
      'smk',
      'sederajat',
      'sttb',
      'sekolah',
      'pendidikan',
    ],
    'SERTIFIKAT': [
      'sertifikat',
      'toeic',
      'kompetensi',
      'certificate',
      'score',
      'english',
      'training',
      'bnsp',
    ],
    'SURAT_ASRAMA': [
      'asrama',
      'bebas',
      'surat',
      'dormitory',
      'upt',
      'asrama',
    ],
  };

  /// Analisis verifikasi berkas individual
  static AutoVerificationResult verifyDocument({
    required DokumenSyarat doc,
    required String nim,
    required String namaMahasiswa,
    required Jenjang jenjang,
    required bool tinggalDiAsrama,
  }) {
    if (!doc.isUploaded || doc.fileName == null) {
      return AutoVerificationResult(
        confidenceScore: 0,
        isAutoApproved: false,
        passedChecks: [],
        warnings: ['Berkas belum diunggah oleh mahasiswa.'],
        recommendedStatus: StatusDokumen.belumUpload,
        autoDraftedNote: 'Mahasiswa belum mengunggah berkas ini.',
      );
    }

    final passedChecks = <String>[];
    final warnings = <String>[];
    int score = 0;

    final fileName = doc.fileName!.toLowerCase();
    final fileExt = fileName.contains('.') ? fileName.split('.').last : '';

    // ── Tier 1: Format & Binary Integrity Check ──
    if (['pdf', 'jpg', 'jpeg', 'png'].contains(fileExt)) {
      score += 25;
      passedChecks.add('Format berkas sesuai ($fileExt.toUpperCase())');
    } else {
      warnings.add('Format berkas .$fileExt tidak disarankan (gunakan PDF/JPG/PNG)');
    }

    // Ukuran File
    if (doc.fileSize != null && doc.fileSize! > 0) {
      if (doc.fileSize! <= doc.maxSizeBytes) {
        score += 15;
        passedChecks.add('Ukuran berkas aman (${doc.fileSizeFormatted} <= ${doc.maxSizeFormatted})');
      } else {
        warnings.add('Ukuran berkas melebihi batas (${doc.fileSizeFormatted} > ${doc.maxSizeFormatted})');
      }
    } else {
      score += 10;
      passedChecks.add('Ukuran berkas valid');
    }

    // ── Tier 2: Academic & Requirement Rule Check ──
    if (doc.kode == 'SURAT_ASRAMA' && !tinggalDiAsrama) {
      // Tidak wajib jika tidak asrama
      score += 20;
      passedChecks.add('Dokumen asrama opsional untuk mahasiswa non-asrama');
    } else {
      score += 20;
      passedChecks.add('Dokumen memenuhi kriteria wajib kurikulum $jenjang');
    }

    // ── Tier 3: Pattern & Keyword Matching Check ──
    final expectedKeywords = _documentKeywords[doc.kode] ?? [];
    int matchedKeywords = 0;

    for (final kw in expectedKeywords) {
      if (fileName.contains(kw)) {
        matchedKeywords++;
      }
    }

    // Cek kecocokan NIM / Nama pada nama file
    final cleanNim = nim.replaceAll(RegExp(r'[^0-9]'), '');
    if (cleanNim.isNotEmpty && fileName.contains(cleanNim)) {
      score += 15;
      passedChecks.add('Nama berkas mencantumkan NIM Mahasiswa ($cleanNim)');
    }

    if (matchedKeywords > 0) {
      final keywordPoints = (matchedKeywords * 10).clamp(0, 25);
      score += keywordPoints;
      passedChecks.add('Nama berkas cocok dengan kata kunci dokumen ($matchedKeywords kata kunci terdeteksi)');
    } else {
      // Cek apakah ada indikasi salah slot (misal file berisi kata kunci berkas lain)
      final otherKeywordsMatched = _detectOtherDocumentKeywords(fileName, doc.kode);
      if (otherKeywordsMatched.isNotEmpty) {
        warnings.add('Peringatan: Nama berkas terdeteksi mengandung kata kunci "$otherKeywordsMatched" (kemungkinan salah slot dokumen)');
        score = (score - 20).clamp(0, 100);
      } else {
        warnings.add('Nama berkas tidak memuat kata kunci standar ${doc.nama}');
      }
    }

    final finalScore = score.clamp(0, 100);
    final isApproved = finalScore >= 75 && warnings.isEmpty;

    String? draftedNote;
    StatusDokumen recommendedStatus;

    if (finalScore >= 75) {
      recommendedStatus = StatusDokumen.valid;
    } else if (finalScore >= 45) {
      recommendedStatus = StatusDokumen.menunggu;
      draftedNote = warnings.isNotEmpty
          ? 'Perhatian: ${warnings.join(". ")}. Mohon periksa kembali kesesuaian berkas.'
          : null;
    } else {
      recommendedStatus = StatusDokumen.tidakValid;
      draftedNote = 'Berkas "${doc.fileName}" tidak memenuhi persyaratan verifikasi: ${warnings.join(", ")}. Silakan upload ulang berkas yang tepat.';
    }

    return AutoVerificationResult(
      confidenceScore: finalScore,
      isAutoApproved: isApproved,
      passedChecks: passedChecks,
      warnings: warnings,
      recommendedStatus: recommendedStatus,
      autoDraftedNote: draftedNote,
    );
  }

  /// Analisis kelengkapan seluruh berkas & data akademik mahasiswa
  static PendaftaranAutoVerificationSummary verifyRegistration(
      PendaftaranAdmin pAdmin) {
    final pendaftaran = pAdmin.pendaftaran;
    final mahasiswa = pAdmin.mahasiswa;

    final docResults = <String, AutoVerificationResult>{};
    int totalScore = 0;
    int evaluatedDocs = 0;

    final academicChecks = <String>[];
    final academicWarnings = <String>[];

    // 1. Evaluasi Akademik
    if (pendaftaran.ipk >= 2.00) {
      academicChecks.add('IPK memenuhi syarat kelulusan (${pendaftaran.ipk.toStringAsFixed(2)} >= 2.00)');
    } else {
      academicWarnings.add('IPK di bawah standar kelulusan (${pendaftaran.ipk.toStringAsFixed(2)} < 2.00)');
    }

    final minSks = pendaftaran.jenjang == Jenjang.d3 ? 110 : 144;
    if (pendaftaran.totalSks >= minSks) {
      academicChecks.add('Total SKS memenuhi syarat ${pendaftaran.jenjang.value} (${pendaftaran.totalSks} >= $minSks)');
    } else {
      academicWarnings.add('Total SKS kurang (${pendaftaran.totalSks} < $minSks SKS)');
    }

    // 2. Evaluasi Dokumen
    for (final doc in pendaftaran.dokumen) {
      final res = verifyDocument(
        doc: doc,
        nim: mahasiswa.nim,
        namaMahasiswa: mahasiswa.nama,
        jenjang: pendaftaran.jenjang,
        tinggalDiAsrama: pendaftaran.tinggalDiAsrama,
      );
      docResults[doc.id] = res;
      if (doc.isWajib || doc.isUploaded) {
        totalScore += res.confidenceScore;
        evaluatedDocs++;
      }
    }

    final averageScore = evaluatedDocs > 0 ? (totalScore / evaluatedDocs).round() : 0;
    final allMandatoryPassed = pendaftaran.dokumen
        .where((d) => d.isWajib)
        .every((d) => (docResults[d.id]?.confidenceScore ?? 0) >= 70);

    final canAutoApprove = averageScore >= 80 &&
        allMandatoryPassed &&
        academicWarnings.isEmpty;

    return PendaftaranAutoVerificationSummary(
      overallScore: averageScore,
      canAutoApproveEntireRegistration: canAutoApprove,
      documentResults: docResults,
      academicChecksPassed: academicChecks,
      academicWarnings: academicWarnings,
    );
  }

  static String _detectOtherDocumentKeywords(String fileName, String currentKode) {
    for (final entry in _documentKeywords.entries) {
      if (entry.key == currentKode) continue;
      for (final kw in entry.value) {
        if (kw.length >= 4 && fileName.contains(kw)) {
          return kw.toUpperCase();
        }
      }
    }
    return '';
  }
}
