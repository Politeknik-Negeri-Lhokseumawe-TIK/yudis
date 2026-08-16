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
}

enum NotifikasiType {
  info,
  success,
  warning,
  error,
}

/// Mock notifikasi data
final List<Notifikasi> mockNotifikasi = [
  Notifikasi(
    id: 'n1',
    judul: 'Akun Diverifikasi',
    pesan: 'Selamat! Akun Anda telah diverifikasi oleh admin. Anda dapat mulai mendaftar yudisium.',
    waktu: DateTime.now().subtract(const Duration(hours: 2)),
    isRead: false,
    type: NotifikasiType.success,
  ),
  Notifikasi(
    id: 'n2',
    judul: 'Periode Yudisium Dibuka',
    pesan: 'Periode yudisium Semester Genap 2025/2026 telah dibuka. Batas akhir pendaftaran: 26 Agustus 2026. Segera lengkapi berkas!',
    waktu: DateTime.now().subtract(const Duration(days: 1)),
    isRead: true,
    type: NotifikasiType.info,
  ),
  Notifikasi(
    id: 'n3',
    judul: 'Dokumen Perlu Revisi',
    pesan: 'Dokumen "Surat Bebas Perpustakaan" ditandai tidak valid oleh admin. Silakan upload ulang.',
    waktu: DateTime.now().subtract(const Duration(days: 2)),
    isRead: true,
    type: NotifikasiType.warning,
  ),
  Notifikasi(
    id: 'n4',
    judul: 'Pendaftaran Diterima',
    pesan: 'Pendaftaran yudisium Anda telah disetujui. Silakan unduh kartu peserta yudisium.',
    waktu: DateTime.now().subtract(const Duration(days: 5)),
    isRead: true,
    type: NotifikasiType.success,
  ),
];
