/// Konstanta Aplikasi Sistem Manajemen Peminjaman Lab & Ruang Kelas Belajar (SIPENJOL TIK PNL)
class AppConstants {
  static const String appName = 'SIM-LAB & RUANG PBM';
  static const String appFullName =
      'Sistem Manajemen Peminjaman Laboratorium & Ruang Kelas';
  static const String appInstitution =
      'Jurusan Teknologi Informasi & Komputer - Politeknik Negeri Lhokseumawe';
  static const String academicYear = 'Semester Gasal TA 2026/2027';

  // ── Sesi Jam Perkuliahan Resmi ─────────────────────────────────
  static const List<Map<String, dynamic>> timeSlots = [
    {'session': 1, 'start': '07:30', 'end': '08:20', 'label': 'Sesi 1 (07:30 - 08:20)'},
    {'session': 2, 'start': '08:20', 'end': '09:10', 'label': 'Sesi 2 (08:20 - 09:10)'},
    {'session': 3, 'start': '09:10', 'end': '10:00', 'label': 'Sesi 3 (09:10 - 10:00)'},
    {'session': 0, 'start': '10:00', 'end': '10:20', 'label': 'Istirahat 1 (10:00 - 10:20)', 'isBreak': true},
    {'session': 4, 'start': '10:20', 'end': '11:10', 'label': 'Sesi 4 (10:20 - 11:10)'},
    {'session': 5, 'start': '11:10', 'end': '12:00', 'label': 'Sesi 5 (11:10 - 12:00)'},
    {'session': 6, 'start': '12:00', 'end': '12:50', 'label': 'Sesi 6 (12:00 - 12:50)'},
    {'session': 0, 'start': '12:50', 'end': '13:30', 'label': 'Istirahat 2 (12:50 - 13:30)', 'isBreak': true},
    {'session': 7, 'start': '13:30', 'end': '14:20', 'label': 'Sesi 7 (13:30 - 14:20)'},
    {'session': 8, 'start': '14:20', 'end': '15:10', 'label': 'Sesi 8 (14:20 - 15:10)'},
    {'session': 9, 'start': '15:10', 'end': '16:00', 'label': 'Sesi 9 (15:10 - 16:00)'},
    {'session': 0, 'start': '16:00', 'end': '16:20', 'label': 'Istirahat 3 (16:00 - 16:20)', 'isBreak': true},
    {'session': 10, 'start': '16:20', 'end': '17:10', 'label': 'Sesi 10 (16:20 - 17:10)'},
    {'session': 11, 'start': '17:10', 'end': '18:00', 'label': 'Sesi 11 (17:10 - 18:00)'},
  ];

  // ── Hari Operasional ──────────────────────────────────────────
  static const List<String> operationalDays = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
  ];

  // ── Program Studi ─────────────────────────────────────────────
  static const List<String> studyPrograms = [
    'Semua Prodi',
    'TRMM',
    'TRKJ',
    'TI',
    'Kelas Kerjasama',
  ];

  // ── Daftar Kelas Roster ───────────────────────────────────────
  static const List<String> rosterClasses = [
    // TRMM
    'TRMM 1A', 'TRMM 1B', 'TRMM 1C',
    'TRMM 2A', 'TRMM 2B', 'TRMM 2C',
    'TRMM 3A', 'TRMM 3B', 'TRMM 3C',
    'TRMM 4A', 'TRMM 4B',
    // TRKJ
    'TRKJ 1A', 'TRKJ 1B', 'TRKJ 1C', 'TRKJ 1D',
    'TRKJ 2A', 'TRKJ 2B', 'TRKJ 2C', 'TRKJ 2D',
    'TRKJ 3A', 'TRKJ 3B', 'TRKJ 3C', 'TRKJ 3D',
    'TRKJ 4A', 'TRKJ 4B', 'TRKJ 4C',
    // TI
    'TI 1A', 'TI 1B', 'TI 1C', 'TI 1D', 'TI 1E',
    'TI 2A', 'TI 2B', 'TI 2C', 'TI 2D', 'TI 2E',
    'TI 3A', 'TI 3B', 'TI 3C', 'TI 3D', 'TI 3E',
    'TI 4A', 'TI 4B', 'TI 4C', 'TI 4D', 'TI 4E',
    'Kelas Sawit',
  ];

  // ── Kategori Keperluan Peminjaman ─────────────────────────────
  static const List<String> bookingPurposes = [
    'Kuliah Pengganti / Tambahan',
    'Praktikum Mandiri & Tugas',
    'Riset / Tugas Akhir / Skripsi',
    'Kegiatan Organisasi / Event Kemahasiswaan',
    'Workshop / Pelatihan / Sertifikasi',
    'Ujian Susulan / Remedi Praktikum',
  ];

  // ── Fasilitas Tambahan yang Bisa Dipinjam ─────────────────────
  static const List<String> additionalFacilities = [
    'Proyektor Portable + Pointer',
    'Mikrofon Wireless / Sound Podcast',
    'Toolkit Jaringan & Crimping Kit',
    'IoT Development Board (ESP32/Arduino/Sensor)',
    'Kamera DSLR & Tripod Studio',
    'Kabel Converter HDMI / VGA / Type-C',
    'Terminal Listrik / Stop Kontak Ekstra',
  ];

  // ── Checklist Pengembalian Ruangan (SOP Kebersihan & Energi) ──
  static const List<String> returnChecklistItems = [
    'Seluruh Unit AC telah dimatikan (Power OFF)',
    'Semua lampu penerangan ruangan telah dipadamkan',
    'Semua komputer, monitor & perangkat lab telah dimatikan (Shut Down)',
    'Meja, kursi dan lantai dalam keadaan rapi dan bebas sampah',
    'Papan tulis telah dibersihkan',
    'Pintu dan jendela telah terkunci dengan aman',
  ];
}
