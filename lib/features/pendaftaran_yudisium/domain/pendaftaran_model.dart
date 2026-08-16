// Domain models untuk fitur Pendaftaran Yudisium
import '../../auth/domain/user_model.dart';

// ── Periode Yudisium ──────────────────────────────────────────
class PeriodeYudisium {
  const PeriodeYudisium({
    required this.id,
    required this.nama,
    required this.tanggalMulai,
    required this.tanggalSelesai,
    required this.isAktif,
    this.deskripsi,
  });

  final String id;
  final String nama;
  final DateTime tanggalMulai;
  final DateTime tanggalSelesai;
  final bool isAktif;
  final String? deskripsi;
}

// ── Status Pendaftaran ────────────────────────────────────────
enum StatusPendaftaran {
  draft('draft', 'Draft'),
  submitted('submitted', 'Diajukan'),
  diverifikasi('diverifikasi', 'Sedang Diverifikasi'),
  revisi('revisi', 'Perlu Revisi'),
  disetujui('disetujui', 'Disetujui'),
  ditolak('ditolak', 'Ditolak');

  const StatusPendaftaran(this.value, this.label);
  final String value;
  final String label;

  int get step => switch (this) {
        StatusPendaftaran.draft       => 0,
        StatusPendaftaran.submitted   => 1,
        StatusPendaftaran.diverifikasi => 2,
        StatusPendaftaran.revisi      => 2,
        StatusPendaftaran.disetujui   => 3,
        StatusPendaftaran.ditolak     => 3,
      };
}

// ── Status Dokumen ────────────────────────────────────────────
enum StatusDokumen {
  belumUpload('belum_upload', 'Belum Upload'),
  menunggu('menunggu', 'Menunggu Verifikasi'),
  valid('valid', 'Valid'),
  tidakValid('tidak_valid', 'Tidak Valid');

  const StatusDokumen(this.value, this.label);
  final String value;
  final String label;
}

// ── Jenjang Pendidikan ────────────────────────────────────────
enum Jenjang {
  d3('D3', 'Diploma 3'),
  d4('D4', 'Diploma 4 / Sarjana Terapan');

  const Jenjang(this.value, this.label);
  final String value;
  final String label;
}

// ── Dokumen Syarat ────────────────────────────────────────────
class DokumenSyarat {
  DokumenSyarat({
    required this.id,
    required this.kode,
    required this.nama,
    required this.deskripsi,
    this.isWajib = true,
    this.kondisiJenjang,
    this.kondisiAsrama,
    this.status = StatusDokumen.belumUpload,
    this.filePath,
    this.fileName,
    this.fileSize,
    this.catatanAdmin,
    this.ada = true,
    this.maxSizeBytes = 2097152, // Default 2 MB (2 * 1024 * 1024)
  });

  final String id;
  final String kode;
  final String nama;
  final String deskripsi;
  final bool isWajib;
  /// null = berlaku semua jenjang, atau spesifik D3/D4
  final Jenjang? kondisiJenjang;
  /// null = berlaku semua, true = hanya asrama, false = hanya non-asrama
  final bool? kondisiAsrama;
  final int maxSizeBytes;

  StatusDokumen status;
  String? filePath;
  String? fileName;
  int? fileSize; // in bytes
  String? catatanAdmin;
  bool ada; // checkbox ADA/TIDAK ADA

  bool get isUploaded =>
      status != StatusDokumen.belumUpload && filePath != null;

  String get maxSizeFormatted {
    if (maxSizeBytes >= 1048576) {
      final mb = maxSizeBytes / 1048576;
      return '${mb == mb.roundToDouble() ? mb.toInt() : mb.toStringAsFixed(1)} MB';
    }
    return '${(maxSizeBytes / 1024).round()} KB';
  }

  String get fileSizeFormatted {
    if (fileSize == null || fileSize! <= 0) return '';
    if (fileSize! < 1024) return '$fileSize B';
    if (fileSize! < 1024 * 1024) return '${(fileSize! / 1024).toStringAsFixed(1)} KB';
    return '${(fileSize! / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  DokumenSyarat copyWith({
    StatusDokumen? status,
    String? filePath,
    String? fileName,
    int? fileSize,
    String? catatanAdmin,
    bool? ada,
    int? maxSizeBytes,
  }) {
    return DokumenSyarat(
      id: id,
      kode: kode,
      nama: nama,
      deskripsi: deskripsi,
      isWajib: isWajib,
      kondisiJenjang: kondisiJenjang,
      kondisiAsrama: kondisiAsrama,
      status: status ?? this.status,
      filePath: filePath ?? this.filePath,
      fileName: fileName ?? this.fileName,
      fileSize: fileSize ?? this.fileSize,
      catatanAdmin: catatanAdmin ?? this.catatanAdmin,
      ada: ada ?? this.ada,
      maxSizeBytes: maxSizeBytes ?? this.maxSizeBytes,
    );
  }
}

// ── Biodata Calon Yudisium ────────────────────────────────────
class BiodataCalon {
  const BiodataCalon({
    this.tempatLahir,
    this.tanggalLahir,
    this.jenisKelamin,
    this.agama,
    this.alamat,
    this.namaAyah,
    this.namaIbu,
    this.pekerjaanAyah,
    this.pekerjaanIbu,
    this.judulTga,
    this.pembimbing1,
    this.pembimbing2,
    this.noPembimbing1,
    this.noPembimbing2,
  });

  final String? tempatLahir;
  final DateTime? tanggalLahir;
  final String? jenisKelamin;
  final String? agama;
  final String? alamat;
  final String? namaAyah;
  final String? namaIbu;
  final String? pekerjaanAyah;
  final String? pekerjaanIbu;
  final String? judulTga;
  final String? pembimbing1;
  final String? pembimbing2;
  final String? noPembimbing1;
  final String? noPembimbing2;

  BiodataCalon copyWith({
    String? tempatLahir,
    DateTime? tanggalLahir,
    String? jenisKelamin,
    String? agama,
    String? alamat,
    String? namaAyah,
    String? namaIbu,
    String? pekerjaanAyah,
    String? pekerjaanIbu,
    String? judulTga,
    String? pembimbing1,
    String? pembimbing2,
    String? noPembimbing1,
    String? noPembimbing2,
  }) {
    return BiodataCalon(
      tempatLahir: tempatLahir ?? this.tempatLahir,
      tanggalLahir: tanggalLahir ?? this.tanggalLahir,
      jenisKelamin: jenisKelamin ?? this.jenisKelamin,
      agama: agama ?? this.agama,
      alamat: alamat ?? this.alamat,
      namaAyah: namaAyah ?? this.namaAyah,
      namaIbu: namaIbu ?? this.namaIbu,
      pekerjaanAyah: pekerjaanAyah ?? this.pekerjaanAyah,
      pekerjaanIbu: pekerjaanIbu ?? this.pekerjaanIbu,
      judulTga: judulTga ?? this.judulTga,
      pembimbing1: pembimbing1 ?? this.pembimbing1,
      pembimbing2: pembimbing2 ?? this.pembimbing2,
      noPembimbing1: noPembimbing1 ?? this.noPembimbing1,
      noPembimbing2: noPembimbing2 ?? this.noPembimbing2,
    );
  }
}

// ── Pendaftaran Yudisium (main model) ────────────────────────
class PendaftaranYudisium {
  PendaftaranYudisium({
    required this.id,
    required this.userId,
    required this.periodeId,
    required this.programStudi,
    required this.jenjang,
    required this.ipk,
    required this.totalSks,
    required this.semester,
    required this.tinggalDiAsrama,
    required this.dokumen,
    required this.biodata,
    this.status = StatusPendaftaran.draft,
    this.catatanAdmin,
    this.submittedAt,
    this.verifiedAt,
  });

  final String id;
  final String userId;
  final String periodeId;
  final ProgramStudi programStudi;
  final Jenjang jenjang;
  final double ipk;
  final int totalSks;
  final int semester;
  final bool tinggalDiAsrama;
  final List<DokumenSyarat> dokumen;
  final BiodataCalon biodata;
  StatusPendaftaran status;
  String? catatanAdmin;
  DateTime? submittedAt;
  DateTime? verifiedAt;

  int get totalDokumenWajib =>
      dokumen.where((d) => d.isWajib && _isApplicable(d)).length;

  int get dokumenTerUpload =>
      dokumen.where((d) => _isApplicable(d) && d.isUploaded).length;

  double get uploadProgress {
    final total = totalDokumenWajib;
    if (total == 0) return 1.0;
    return dokumenTerUpload / total;
  }

  bool _isApplicable(DokumenSyarat d) {
    if (d.kondisiJenjang != null && d.kondisiJenjang != jenjang) return false;
    if (d.kondisiAsrama != null && d.kondisiAsrama != tinggalDiAsrama) return false;
    return true;
  }

  List<DokumenSyarat> get dokumenApplicable =>
      dokumen.where(_isApplicable).toList();
}
