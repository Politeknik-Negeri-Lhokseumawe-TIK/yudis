import 'pendaftaran_model.dart';

/// Template syarat dokumen — dinamis dari API (mock)
class TemplateSyaratDokumen {
  const TemplateSyaratDokumen({
    required this.id,
    required this.kode,
    required this.nama,
    required this.deskripsi,
    this.isWajib = true,
    this.kondisiJenjang,
    this.kondisiAsrama,
    this.urutan = 0,
  });

  final String id;
  final String kode;
  final String nama;
  final String deskripsi;
  final bool isWajib;
  final Jenjang? kondisiJenjang;
  final bool? kondisiAsrama;
  final int urutan;

  DokumenSyarat toDokumenSyarat() => DokumenSyarat(
        id: 'doc_$id',
        kode: kode,
        nama: nama,
        deskripsi: deskripsi,
        isWajib: isWajib,
        kondisiJenjang: kondisiJenjang,
        kondisiAsrama: kondisiAsrama,
      );
}

// Template dokumen tidak lagi hardcoded.
// Data diambil dari Supabase tabel `template_dokumen` via AdminRepository.getTemplateDokumen()
// Lihat: lib/features/admin_verifikasi/data/admin_repository.dart

/// [DEPRECATED] — hanya digunakan sebagai fallback offline jika Supabase belum dikonfigurasi
final List<TemplateSyaratDokumen> mockTemplateDokumen = [
  const TemplateSyaratDokumen(
    id: 't01',
    kode: 'KRS',
    nama: 'Kartu Rencana Studi Semester Akhir',
    deskripsi: 'KRS semester terakhir yang sudah disetujui PA',
    urutan: 1,
  ),
  const TemplateSyaratDokumen(
    id: 't02',
    kode: 'TRANSKRIP',
    nama: 'Transkrip Nilai Sementara',
    deskripsi: 'Transkrip nilai resmi dari bagian akademik',
    urutan: 2,
  ),
  const TemplateSyaratDokumen(
    id: 't03',
    kode: 'TGA_ACC',
    nama: 'Lembar Persetujuan TGA/Skripsi',
    deskripsi: 'Lembar persetujuan dari pembimbing 1 dan 2',
    urutan: 3,
  ),
  const TemplateSyaratDokumen(
    id: 't04',
    kode: 'TGA_PENGUJI',
    nama: 'Lembar Penilaian Penguji TGA',
    deskripsi: 'Nilai dari seluruh penguji sidang TGA',
    urutan: 4,
  ),
  const TemplateSyaratDokumen(
    id: 't05',
    kode: 'BEBAS_PUST',
    nama: 'Surat Bebas Pinjaman Perpustakaan',
    deskripsi: 'Dari perpustakaan PNL (pusat & jurusan)',
    urutan: 5,
  ),
  const TemplateSyaratDokumen(
    id: 't06',
    kode: 'BEBAS_LAB',
    nama: 'Surat Bebas Pinjaman Laboratorium',
    deskripsi: 'Dari seluruh lab jurusan TIK',
    urutan: 6,
  ),
  const TemplateSyaratDokumen(
    id: 't07',
    kode: 'BEBAS_KEU',
    nama: 'Surat Keterangan Bebas Keuangan',
    deskripsi: 'Dari bagian keuangan PNL',
    urutan: 7,
  ),
  const TemplateSyaratDokumen(
    id: 't08',
    kode: 'BEBAS_ASRAMA',
    nama: 'Surat Bebas Asrama',
    deskripsi: 'Dari pengelola asrama mahasiswa PNL',
    kondisiAsrama: true, // hanya untuk yang tinggal di asrama
    urutan: 8,
  ),
  const TemplateSyaratDokumen(
    id: 't09',
    kode: 'FOTO_4X6',
    nama: 'Foto Formal 4×6 (4 lembar)',
    deskripsi: 'Background merah, pakaian formal, softcopy JPG min 1MB',
    urutan: 9,
  ),
  const TemplateSyaratDokumen(
    id: 't10',
    kode: 'KTP',
    nama: 'Fotokopi KTP / KK',
    deskripsi: 'KTP mahasiswa yang masih berlaku',
    urutan: 10,
  ),
  const TemplateSyaratDokumen(
    id: 't11',
    kode: 'IJAZAH_SMA',
    nama: 'Fotokopi Ijazah SMA/SMK/MA',
    deskripsi: 'Ijazah legalisir atau asli untuk verifikasi',
    urutan: 11,
  ),
  const TemplateSyaratDokumen(
    id: 't12',
    kode: 'SERTIFIKAT',
    nama: 'Sertifikat Kompetensi / TOEIC',
    deskripsi: 'Sertifikat kompetensi atau skor TOEIC min 400',
    isWajib: false, // opsional
    urutan: 12,
  ),
];
