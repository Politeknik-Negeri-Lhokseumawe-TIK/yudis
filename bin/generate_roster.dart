import 'dart:io';

void main() {
  final buffer = StringBuffer();
  buffer.writeln("import '../../domain/models/roster_item_model.dart';");
  buffer.writeln();
  buffer.writeln("/// Dataset Lengkap Roster Jadwal PBM Semester Gasal TA 2026-2027");
  buffer.writeln("/// Jurusan Teknologi Informasi & Komputer (TIK) Politeknik Negeri Lhokseumawe");
  buffer.writeln("/// Hasil ekstraksi dan sinkronisasi 100% lengkap dari Roster Jadwal PBM 48 Halaman.");
  buffer.writeln("class RosterDataSource {");
  buffer.writeln("  static List<RosterItemModel> getAllSchedules() {");
  buffer.writeln("    return const [");

  // Helper to add item
  void add({
    required String id,
    required String prodi,
    required String className,
    required String day,
    required int startSession,
    required int endSession,
    required String startTime,
    required String endTime,
    required String courseName,
    required String lecturerName,
    required String roomCode,
    bool isPracticum = false,
  }) {
    buffer.writeln("      RosterItemModel(");
    buffer.writeln("        id: '$id',");
    buffer.writeln("        studyProgram: '$prodi',");
    buffer.writeln("        className: '$className',");
    buffer.writeln("        day: '$day',");
    buffer.writeln("        startSession: $startSession,");
    buffer.writeln("        endSession: $endSession,");
    buffer.writeln("        startTime: '$startTime',");
    buffer.writeln("        endTime: '$endTime',");
    buffer.writeln("        courseName: '${courseName.replaceAll("'", r"\'")}',");
    buffer.writeln("        lecturerName: '${lecturerName.replaceAll("'", r"\'")}',");
    buffer.writeln("        roomCode: '$roomCode',");
    if (isPracticum) {
      buffer.writeln("        isPracticum: true,");
    }
    buffer.writeln("      ),");
  }

  // ==========================================
  // PRODI TRMM
  // ==========================================

  // TRMM 1A (Page 1)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRMM 1A (Halaman 1)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRMM1A-1', prodi: 'TRMM', className: 'TRMM 1A', day: 'Senin', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Pancasila', lecturerName: 'Hosea Sitepu, M.Pd', roomCode: 'TIK.309');
  add(id: 'TRMM1A-2', prodi: 'TRMM', className: 'TRMM 1A', day: 'Senin', startSession: 7, endSession: 10, startTime: '13:30', endTime: '17:10', courseName: 'Pengembangan Cerita', lecturerName: 'Novira Dwina, SST., M.T.', roomCode: 'TIK.202');
  add(id: 'TRMM1A-3', prodi: 'TRMM', className: 'TRMM 1A', day: 'Selasa', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Matematika Terapan bidang TI', lecturerName: 'Muhammad Hari Hasibuan, M.Kom.', roomCode: 'TIK.306');
  add(id: 'TRMM1A-4', prodi: 'TRMM', className: 'TRMM 1A', day: 'Selasa', startSession: 5, endSession: 8, startTime: '11:10', endTime: '15:10', courseName: 'Menyimak dan Berbicara Academik', lecturerName: 'Mahlil, S.Pd., M.A', roomCode: 'TIK.212');
  add(id: 'TRMM1A-5', prodi: 'TRMM', className: 'TRMM 1A', day: 'Rabu', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Algorithma dan Struktur Data', lecturerName: 'Safriadi ST, M.Kom.', roomCode: 'TIK.204');
  add(id: 'TRMM1A-6', prodi: 'TRMM', className: 'TRMM 1A', day: 'Rabu', startSession: 5, endSession: 8, startTime: '11:10', endTime: '15:10', courseName: 'Pengantar Teknologi Multimedia', lecturerName: 'Nanda Saputri, SST., M.T.', roomCode: 'TIK.205');
  add(id: 'TRMM1A-7', prodi: 'TRMM', className: 'TRMM 1A', day: 'Kamis', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktik Menggambar Digital', lecturerName: 'Ahmad Afif, M. Kom.', roomCode: 'TDC-308', isPracticum: true);
  add(id: 'TRMM1A-8', prodi: 'TRMM', className: 'TRMM 1A', day: 'Kamis', startSession: 7, endSession: 8, startTime: '13:30', endTime: '15:10', courseName: 'Pemikiran Kritis dan Kreatif', lecturerName: 'Dr. Hilmi, SE., MM., CBA., CTAM.', roomCode: 'TIK.312');
  add(id: 'TRMM1A-9', prodi: 'TRMM', className: 'TRMM 1A', day: 'Jumat', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktik Grafika dan Pengolahan Citra', lecturerName: 'Novira Dwina, SST., M.T.', roomCode: 'TIK.204', isPracticum: true);
  add(id: 'TRMM1A-10', prodi: 'TRMM', className: 'TRMM 1A', day: 'Jumat', startSession: 7, endSession: 10, startTime: '13:30', endTime: '17:10', courseName: 'Ide Kreatif', lecturerName: 'Umri Erdiansyah, S.Kom., M.Kom.', roomCode: 'TIK.203');

  // TRMM 1B (Page 2)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRMM 1B (Halaman 2)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRMM1B-1', prodi: 'TRMM', className: 'TRMM 1B', day: 'Senin', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Pengembangan Cerita', lecturerName: 'Novira Dwina, SST., M.T.', roomCode: 'TIK.202');
  add(id: 'TRMM1B-2', prodi: 'TRMM', className: 'TRMM 1B', day: 'Senin', startSession: 5, endSession: 8, startTime: '11:10', endTime: '15:10', courseName: 'Menyimak dan Berbicara Academik', lecturerName: 'Mahlil, S.Pd., M.A', roomCode: 'TIK.310');
  add(id: 'TRMM1B-3', prodi: 'TRMM', className: 'TRMM 1B', day: 'Selasa', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Ide Kreatif', lecturerName: 'Umri Erdiansyah, S.Kom., M.Kom.', roomCode: 'TIK.203');
  add(id: 'TRMM1B-4', prodi: 'TRMM', className: 'TRMM 1B', day: 'Selasa', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Pemikiran Kritis dan Kreatif', lecturerName: 'Dr. Hilmi, SE., MM., CBA., CTAM.', roomCode: 'TIK.309');
  add(id: 'TRMM1B-5', prodi: 'TRMM', className: 'TRMM 1B', day: 'Rabu', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Pengantar Teknologi Multimedia', lecturerName: 'Nanda Saputri, SST., M.T.', roomCode: 'TIK.205');
  add(id: 'TRMM1B-6', prodi: 'TRMM', className: 'TRMM 1B', day: 'Rabu', startSession: 5, endSession: 8, startTime: '11:10', endTime: '15:10', courseName: 'Algorithma dan Struktur Data', lecturerName: 'Safriadi ST, M.Kom.', roomCode: 'TIK.204');
  add(id: 'TRMM1B-7', prodi: 'TRMM', className: 'TRMM 1B', day: 'Kamis', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Matematika Terapan bidang TI', lecturerName: 'Muhammad Hari Hasibuan, M.Kom.', roomCode: 'TIK.306');
  add(id: 'TRMM1B-8', prodi: 'TRMM', className: 'TRMM 1B', day: 'Kamis', startSession: 7, endSession: 8, startTime: '13:30', endTime: '15:10', courseName: 'Pancasila', lecturerName: 'Hosea Sitepu, M.Pd', roomCode: 'TIK.306');
  add(id: 'TRMM1B-9', prodi: 'TRMM', className: 'TRMM 1B', day: 'Jumat', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktik Menggambar Digital', lecturerName: 'Ahmad Afif, M. Kom.', roomCode: 'TDC-308', isPracticum: true);
  add(id: 'TRMM1B-10', prodi: 'TRMM', className: 'TRMM 1B', day: 'Jumat', startSession: 7, endSession: 10, startTime: '13:30', endTime: '17:10', courseName: 'Praktik Grafika dan Pengolahan Citra', lecturerName: 'Novira Dwina, SST., M.T.', roomCode: 'TIK.206', isPracticum: true);

  // TRMM 1C (Page 3)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRMM 1C (Halaman 3)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRMM1C-1', prodi: 'TRMM', className: 'TRMM 1C', day: 'Senin', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Menyimak dan Berbicara Academik', lecturerName: 'Mahlil, S.Pd., M.A', roomCode: 'TIK.213');
  add(id: 'TRMM1C-2', prodi: 'TRMM', className: 'TRMM 1C', day: 'Senin', startSession: 5, endSession: 9, startTime: '11:10', endTime: '16:00', courseName: 'Praktik Grafika dan Pengolahan Citra', lecturerName: 'Ahmad Afif, M. Kom.', roomCode: 'TIK.204', isPracticum: true);
  add(id: 'TRMM1C-3', prodi: 'TRMM', className: 'TRMM 1C', day: 'Selasa', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Algorithma dan Struktur Data', lecturerName: 'Safriadi ST, M.Kom.', roomCode: 'TIK.204');
  add(id: 'TRMM1C-4', prodi: 'TRMM', className: 'TRMM 1C', day: 'Selasa', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Pancasila', lecturerName: 'Hosea Sitepu, M.Pd', roomCode: 'TIK.313');
  add(id: 'TRMM1C-5', prodi: 'TRMM', className: 'TRMM 1C', day: 'Selasa', startSession: 7, endSession: 10, startTime: '13:30', endTime: '17:10', courseName: 'Pengembangan Cerita', lecturerName: 'Novira Dwina, SST., M.T.', roomCode: 'TIK.203');
  add(id: 'TRMM1C-6', prodi: 'TRMM', className: 'TRMM 1C', day: 'Rabu', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktik Menggambar Digital', lecturerName: 'Ahmad Afif, M. Kom.', roomCode: 'TDC-308', isPracticum: true);
  add(id: 'TRMM1C-7', prodi: 'TRMM', className: 'TRMM 1C', day: 'Rabu', startSession: 6, endSession: 9, startTime: '12:00', endTime: '16:00', courseName: 'Ide Kreatif', lecturerName: 'Muhammad Hari Hasibuan, M.Kom.', roomCode: 'TIK.203');
  add(id: 'TRMM1C-8', prodi: 'TRMM', className: 'TRMM 1C', day: 'Kamis', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Pemikiran Kritis dan Kreatif', lecturerName: 'Zulkarnaini, SE.,M.Si.Ak.CA', roomCode: 'TIK.301');
  add(id: 'TRMM1C-9', prodi: 'TRMM', className: 'TRMM 1C', day: 'Kamis', startSession: 7, endSession: 8, startTime: '13:30', endTime: '15:10', courseName: 'Matematika Terapan bidang TI', lecturerName: 'Ir. T. Dany Dhaifullah, S.T., M.T.', roomCode: 'TIK.307');
  add(id: 'TRMM1C-10', prodi: 'TRMM', className: 'TRMM 1C', day: 'Jumat', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Pengantar Teknologi Multimedia', lecturerName: 'Nanda Saputri, SST., M.T.', roomCode: 'TIK.205');

  // TRMM 2A (Page 4)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRMM 2A (Halaman 4)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRMM2A-1', prodi: 'TRMM', className: 'TRMM 2A', day: 'Senin', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Aljabar Linear Dasar', lecturerName: 'Nazira Suha Al Bakri, S.T., M.T.', roomCode: 'TIK.307');
  add(id: 'TRMM2A-2', prodi: 'TRMM', className: 'TRMM 2A', day: 'Senin', startSession: 5, endSession: 9, startTime: '11:10', endTime: '16:00', courseName: 'Pengantar Proyek', lecturerName: 'Muhammad Nasir, ST. MT.', roomCode: 'TIK.314');
  add(id: 'TRMM2A-3', prodi: 'TRMM', className: 'TRMM 2A', day: 'Selasa', startSession: 1, endSession: 3, startTime: '07:30', endTime: '10:00', courseName: 'Praktik Photografi', lecturerName: 'Fachri Yanuar Rudi F, S.ST., M.T.', roomCode: 'TDC-203', isPracticum: true);
  add(id: 'TRMM2A-4', prodi: 'TRMM', className: 'TRMM 2A', day: 'Selasa', startSession: 4, endSession: 6, startTime: '10:20', endTime: '12:50', courseName: 'Praktik Database dan Aplikasi', lecturerName: 'Muhammad Hari Hasibuan, M.Kom.', roomCode: 'TIK.206', isPracticum: true);
  add(id: 'TRMM2A-5', prodi: 'TRMM', className: 'TRMM 2A', day: 'Selasa', startSession: 7, endSession: 10, startTime: '13:30', endTime: '17:10', courseName: 'Rekayasa Video dan Audio', lecturerName: 'Riwanul Nasron, S.T.,M.T.', roomCode: 'TIK.202');
  add(id: 'TRMM2A-6', prodi: 'TRMM', className: 'TRMM 2A', day: 'Rabu', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Desain Komunikasi Visual', lecturerName: 'Muhammad Hari Hasibuan, M.Kom.', roomCode: 'TDC-306');
  add(id: 'TRMM2A-7', prodi: 'TRMM', className: 'TRMM 2A', day: 'Rabu', startSession: 7, endSession: 10, startTime: '13:30', endTime: '17:10', courseName: 'Desain Pengembangan Game', lecturerName: 'Fachri Yanuar Rudi F, S.ST., M.T.', roomCode: 'TIK.206');
  add(id: 'TRMM2A-8', prodi: 'TRMM', className: 'TRMM 2A', day: 'Kamis', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Bahasa Inggris untuk Karir Akademik', lecturerName: 'Mahlil, S.Pd., M.A', roomCode: 'TIK.314');
  add(id: 'TRMM2A-9', prodi: 'TRMM', className: 'TRMM 2A', day: 'Kamis', startSession: 7, endSession: 10, startTime: '13:30', endTime: '17:10', courseName: 'Pembuat Aset 2D', lecturerName: 'Ilham Safar, SST., M.Kom', roomCode: 'TDC-308');
  add(id: 'TRMM2A-10', prodi: 'TRMM', className: 'TRMM 2A', day: 'Jumat', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Bahasa Indonesia', lecturerName: 'Dra. Jamilah, M.Pd', roomCode: 'TIK.211');
  add(id: 'TRMM2A-11', prodi: 'TRMM', className: 'TRMM 2A', day: 'Jumat', startSession: 7, endSession: 10, startTime: '13:30', endTime: '17:10', courseName: 'Pembuat Aset 3D', lecturerName: 'Nanda Saputri, SST., M.T.', roomCode: 'TDC-308');

  // TRMM 2B (Page 5)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRMM 2B (Halaman 5)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRMM2B-1', prodi: 'TRMM', className: 'TRMM 2B', day: 'Senin', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Desain Komunikasi Visual', lecturerName: 'Muhammad Hari Hasibuan, M.Kom.', roomCode: 'TDC-306');
  add(id: 'TRMM2B-2', prodi: 'TRMM', className: 'TRMM 2B', day: 'Senin', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Aljabar Linear Dasar', lecturerName: 'Nazira Suha Al Bakri, S.T., M.T.', roomCode: 'TIK.309');
  add(id: 'TRMM2B-3', prodi: 'TRMM', className: 'TRMM 2B', day: 'Senin', startSession: 7, endSession: 10, startTime: '13:30', endTime: '17:10', courseName: 'Pembuat Aset 3D', lecturerName: 'Nanda Saputri, SST., M.T.', roomCode: 'TDC-308');
  add(id: 'TRMM2B-4', prodi: 'TRMM', className: 'TRMM 2B', day: 'Selasa', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Pengantar Proyek', lecturerName: 'Mursyidah, S.S.T., M.T.', roomCode: 'TIK.304');
  add(id: 'TRMM2B-5', prodi: 'TRMM', className: 'TRMM 2B', day: 'Selasa', startSession: 6, endSession: 8, startTime: '12:00', endTime: '15:10', courseName: 'Praktik Photografi', lecturerName: 'Fachri Yanuar Rudi F, S.ST., M.T.', roomCode: 'TDC-203', isPracticum: true);
  add(id: 'TRMM2B-6', prodi: 'TRMM', className: 'TRMM 2B', day: 'Rabu', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Bahasa Inggris untuk Karir Akademik', lecturerName: 'Mahlil, S.Pd., M.A', roomCode: 'TIK.316');
  add(id: 'TRMM2B-7', prodi: 'TRMM', className: 'TRMM 2B', day: 'Rabu', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Bahasa Indonesia', lecturerName: 'Dra. Jamilah, M.Pd', roomCode: 'TIK.209');
  add(id: 'TRMM2B-8', prodi: 'TRMM', className: 'TRMM 2B', day: 'Rabu', startSession: 7, endSession: 10, startTime: '13:30', endTime: '17:10', courseName: 'Pembuat Aset 2D', lecturerName: 'Ilham Safar, SST., M.Kom', roomCode: 'TDC-308');
  add(id: 'TRMM2B-9', prodi: 'TRMM', className: 'TRMM 2B', day: 'Kamis', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Rekayasa Video dan Audio', lecturerName: 'Riwanul Nasron, S.T.,M.T.', roomCode: 'TIK.203');
  add(id: 'TRMM2B-10', prodi: 'TRMM', className: 'TRMM 2B', day: 'Kamis', startSession: 7, endSession: 10, startTime: '13:30', endTime: '17:10', courseName: 'Desain Pengembangan Game', lecturerName: 'Fachri Yanuar Rudi F, S.ST., M.T.', roomCode: 'TIK.206');
  add(id: 'TRMM2B-11', prodi: 'TRMM', className: 'TRMM 2B', day: 'Jumat', startSession: 1, endSession: 3, startTime: '07:30', endTime: '10:00', courseName: 'Praktik Database dan Aplikasi', lecturerName: 'Muhammad Hari Hasibuan, M.Kom.', roomCode: 'TIK.206', isPracticum: true);

  // TRMM 2C (Page 6)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRMM 2C (Halaman 6)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRMM2C-1', prodi: 'TRMM', className: 'TRMM 2C', day: 'Senin', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Pembuat Aset 2D', lecturerName: 'Ilham Safar, SST., M.Kom', roomCode: 'TDC-308');
  add(id: 'TRMM2C-2', prodi: 'TRMM', className: 'TRMM 2C', day: 'Senin', startSession: 7, endSession: 10, startTime: '13:30', endTime: '17:10', courseName: 'Rekayasa Video dan Audio', lecturerName: 'Riwanul Nasron, S.T.,M.T.', roomCode: 'TIK.205');
  add(id: 'TRMM2C-3', prodi: 'TRMM', className: 'TRMM 2C', day: 'Selasa', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Pembuat Aset 3D', lecturerName: 'Nanda Saputri, SST., M.T.', roomCode: 'TDC-308');
  add(id: 'TRMM2C-4', prodi: 'TRMM', className: 'TRMM 2C', day: 'Selasa', startSession: 7, endSession: 10, startTime: '13:30', endTime: '17:10', courseName: 'Desain Komunikasi Visual', lecturerName: 'Muhammad Hari Hasibuan, M.Kom.', roomCode: 'TDC-306');
  add(id: 'TRMM2C-5', prodi: 'TRMM', className: 'TRMM 2C', day: 'Rabu', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Bahasa Indonesia', lecturerName: 'Dra. Jamilah, M.Pd', roomCode: 'TIK.213');
  add(id: 'TRMM2C-6', prodi: 'TRMM', className: 'TRMM 2C', day: 'Rabu', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Aljabar Linear Dasar', lecturerName: 'Nazira Suha Al Bakri, S.T., M.T.', roomCode: 'TIK.301');
  add(id: 'TRMM2C-7', prodi: 'TRMM', className: 'TRMM 2C', day: 'Rabu', startSession: 7, endSession: 10, startTime: '13:30', endTime: '17:10', courseName: 'Bahasa Inggris untuk Karir Akademik', lecturerName: 'Mahlil, S.Pd., M.A', roomCode: 'TIK.305');
  add(id: 'TRMM2C-8', prodi: 'TRMM', className: 'TRMM 2C', day: 'Kamis', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Desain Pengembangan Game', lecturerName: 'Fachri Yanuar Rudi F, S.ST., M.T.', roomCode: 'TIK.206');
  add(id: 'TRMM2C-9', prodi: 'TRMM', className: 'TRMM 2C', day: 'Kamis', startSession: 7, endSession: 10, startTime: '13:30', endTime: '17:10', courseName: 'Praktik Database dan Aplikasi', lecturerName: 'Ahmad Afif, M. Kom.', roomCode: 'TIK.204', isPracticum: true);
  add(id: 'TRMM2C-10', prodi: 'TRMM', className: 'TRMM 2C', day: 'Jumat', startSession: 1, endSession: 3, startTime: '07:30', endTime: '10:00', courseName: 'Praktik Photografi', lecturerName: 'Fachri Yanuar Rudi F, S.ST., M.T.', roomCode: 'TDC-203', isPracticum: true);
  add(id: 'TRMM2C-11', prodi: 'TRMM', className: 'TRMM 2C', day: 'Jumat', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Pengantar Proyek', lecturerName: 'Muhammad Hari Hasibuan, M.Kom.', roomCode: 'TIK.312');

  // TRMM 3A (Page 7)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRMM 3A (Halaman 7)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRMM3A-1', prodi: 'TRMM', className: 'TRMM 3A', day: 'Senin', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Dasar-dasar Jaringan', lecturerName: 'Guntur Syahputra, S. Kom., M. Kom.', roomCode: 'TIK.204');
  add(id: 'TRMM3A-2', prodi: 'TRMM', className: 'TRMM 3A', day: 'Senin', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktik Produksi Pasca Animasi', lecturerName: 'FYR / AND', roomCode: 'TIK.206', isPracticum: true);
  add(id: 'TRMM3A-3', prodi: 'TRMM', className: 'TRMM 3A', day: 'Selasa', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Multimedia Digital dan Interaktif', lecturerName: 'Novira Dwina, SST., M.T.', roomCode: 'TIK.202');
  add(id: 'TRMM3A-4', prodi: 'TRMM', className: 'TRMM 3A', day: 'Rabu', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Proyek Inovasi Produk', lecturerName: 'FYR / NDW', roomCode: 'TIK.203');
  add(id: 'TRMM3A-5', prodi: 'TRMM', className: 'TRMM 3A', day: 'Kamis', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Paradigma Sistem di Bidang IT', lecturerName: 'Ilham Safar, SST., M.Kom', roomCode: 'TIK.316');
  add(id: 'TRMM3A-6', prodi: 'TRMM', className: 'TRMM 3A', day: 'Kamis', startSession: 5, endSession: 8, startTime: '11:10', endTime: '15:10', courseName: 'Praktik Produksi Podcast', lecturerName: 'UME / FSB', roomCode: 'TDC-202', isPracticum: true);
  add(id: 'TRMM3A-7', prodi: 'TRMM', className: 'TRMM 3A', day: 'Kamis', startSession: 8, endSession: 11, startTime: '14:20', endTime: '18:00', courseName: 'Pengembangan Multimedia Seluler', lecturerName: 'Safriadi ST, M.Kom.', roomCode: 'TIK.211');
  add(id: 'TRMM3A-8', prodi: 'TRMM', className: 'TRMM 3A', day: 'Jumat', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Tata Kelola IT', lecturerName: 'Riwanul Nasron, S.T.,M.T.', roomCode: 'TIK.310');
  add(id: 'TRMM3A-9', prodi: 'TRMM', className: 'TRMM 3A', day: 'Jumat', startSession: 7, endSession: 10, startTime: '13:30', endTime: '17:10', courseName: 'Gamifikasi', lecturerName: 'Mursyidah, S.S.T., M.T.', roomCode: 'TIK.205');

  // TRMM 3B (Page 8)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRMM 3B (Halaman 8)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRMM3B-1', prodi: 'TRMM', className: 'TRMM 3B', day: 'Senin', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktik Produksi Pasca Animasi', lecturerName: 'FYR / AND', roomCode: 'TIK.206', isPracticum: true);
  add(id: 'TRMM3B-2', prodi: 'TRMM', className: 'TRMM 3B', day: 'Senin', startSession: 7, endSession: 10, startTime: '13:30', endTime: '17:10', courseName: 'Dasar-dasar Jaringan', lecturerName: 'Guntur Syahputra, S. Kom., M. Kom.', roomCode: 'TIK.109');
  add(id: 'TRMM3B-3', prodi: 'TRMM', className: 'TRMM 3B', day: 'Selasa', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Tata Kelola IT', lecturerName: 'Riwanul Nasron, S.T.,M.T.', roomCode: 'TIK.213');
  add(id: 'TRMM3B-4', prodi: 'TRMM', className: 'TRMM 3B', day: 'Selasa', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Gamifikasi', lecturerName: 'Mursyidah, S.S.T., M.T.', roomCode: 'TIK.205');
  add(id: 'TRMM3B-5', prodi: 'TRMM', className: 'TRMM 3B', day: 'Rabu', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Paradigma Sistem di Bidang IT', lecturerName: 'Ilham Safar, SST., M.Kom', roomCode: 'TIK.314');
  add(id: 'TRMM3B-6', prodi: 'TRMM', className: 'TRMM 3B', day: 'Rabu', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Multimedia Digital dan Interaktif', lecturerName: 'Novira Dwina, SST., M.T.', roomCode: 'TIK.202');
  add(id: 'TRMM3B-7', prodi: 'TRMM', className: 'TRMM 3B', day: 'Kamis', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktik Produksi Podcast', lecturerName: 'UME / FSB', roomCode: 'TDC-202', isPracticum: true);
  add(id: 'TRMM3B-8', prodi: 'TRMM', className: 'TRMM 3B', day: 'Kamis', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Proyek Inovasi Produk', lecturerName: 'MSD / NSP', roomCode: 'TIK.203');
  add(id: 'TRMM3B-9', prodi: 'TRMM', className: 'TRMM 3B', day: 'Jumat', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Pengembangan Multimedia Seluler', lecturerName: 'Safriadi ST, M.Kom.', roomCode: 'TIK.212');

  // TRMM 3C (Page 9)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRMM 3C (Halaman 9)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRMM3C-1', prodi: 'TRMM', className: 'TRMM 3C', day: 'Senin', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Gamifikasi', lecturerName: 'Mursyidah, S.S.T., M.T.', roomCode: 'TIK.205');
  add(id: 'TRMM3C-2', prodi: 'TRMM', className: 'TRMM 3C', day: 'Senin', startSession: 6, endSession: 7, startTime: '12:00', endTime: '14:20', courseName: 'Tata Kelola IT', lecturerName: 'Dr.Rahmad Hidayat, S.Kom., M.Cs', roomCode: 'TIK.308');
  add(id: 'TRMM3C-3', prodi: 'TRMM', className: 'TRMM 3C', day: 'Selasa', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Paradigma Sistem di Bidang IT', lecturerName: 'Ilham Safar, SST., M.Kom', roomCode: 'TIK.314');
  add(id: 'TRMM3C-4', prodi: 'TRMM', className: 'TRMM 3C', day: 'Selasa', startSession: 5, endSession: 8, startTime: '11:10', endTime: '15:10', courseName: 'Pengembangan Multimedia Seluler', lecturerName: 'Safriadi ST, M.Kom.', roomCode: 'TIK.305');
  add(id: 'TRMM3C-5', prodi: 'TRMM', className: 'TRMM 3C', day: 'Rabu', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktik Produksi Pasca Animasi', lecturerName: 'UME / AND', roomCode: 'TIK.206', isPracticum: true);
  add(id: 'TRMM3C-6', prodi: 'TRMM', className: 'TRMM 3C', day: 'Rabu', startSession: 8, endSession: 11, startTime: '14:20', endTime: '18:00', courseName: 'Praktik Produksi Podcast', lecturerName: 'UME / MUN', roomCode: 'TDC-202', isPracticum: true);
  add(id: 'TRMM3C-7', prodi: 'TRMM', className: 'TRMM 3C', day: 'Kamis', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Multimedia Digital dan Interaktif', lecturerName: 'Riwanul Nasron, S.T.,M.T.', roomCode: 'TIK.209');
  add(id: 'TRMM3C-8', prodi: 'TRMM', className: 'TRMM 3C', day: 'Jumat', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Proyek Inovasi Produk', lecturerName: 'UME / ASW', roomCode: 'TIK.203');
  add(id: 'TRMM3C-9', prodi: 'TRMM', className: 'TRMM 3C', day: 'Jumat', startSession: 8, endSession: 11, startTime: '14:20', endTime: '18:00', courseName: 'Dasar-dasar Jaringan', lecturerName: 'Guntur Syahputra, S. Kom., M. Kom.', roomCode: 'TIK.202');

  // TRMM 4A (Page 10)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRMM 4A (Halaman 10)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRMM4A-1', prodi: 'TRMM', className: 'TRMM 4A', day: 'Senin', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Edit Video dan Audio', lecturerName: 'Muhammad Nasir, ST. MT.', roomCode: 'TIK.203');
  add(id: 'TRMM4A-2', prodi: 'TRMM', className: 'TRMM 4A', day: 'Senin', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Periklanan', lecturerName: 'Umri Erdiansyah, S.Kom., M.Kom.', roomCode: 'TIK.203');
  add(id: 'TRMM4A-3', prodi: 'TRMM', className: 'TRMM 4A', day: 'Selasa', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Pengembangan Web Berbasis Multimedia', lecturerName: 'Guntur Syahputra, S. Kom., M. Kom.', roomCode: 'TIK.205');
  add(id: 'TRMM4A-4', prodi: 'TRMM', className: 'TRMM 4A', day: 'Selasa', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Etika profesional di bidang TIK', lecturerName: 'Riwanul Nasron, S.T.,M.T.', roomCode: 'TIK.312');
  add(id: 'TRMM4A-5', prodi: 'TRMM', className: 'TRMM 4A', day: 'Rabu', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Proyek Industri', lecturerName: 'ASW / MIL', roomCode: 'TIK.211');
  add(id: 'TRMM4A-6', prodi: 'TRMM', className: 'TRMM 4A', day: 'Kamis', startSession: 1, endSession: 3, startTime: '07:30', endTime: '10:00', courseName: 'Praktik Game Cerdas', lecturerName: 'Mursyidah, S.S.T., M.T.', roomCode: 'TIK.104', isPracticum: true);
  add(id: 'TRMM4A-7', prodi: 'TRMM', className: 'TRMM 4A', day: 'Kamis', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Sinematografi', lecturerName: 'Umri Erdiansyah, S.Kom., M.Kom.', roomCode: 'TIK.202');
  add(id: 'TRMM4A-8', prodi: 'TRMM', className: 'TRMM 4A', day: 'Jumat', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Game Cerdas', lecturerName: 'Mursyidah, S.S.T., M.T.', roomCode: 'TIK.303');
  add(id: 'TRMM4A-9', prodi: 'TRMM', className: 'TRMM 4A', day: 'Jumat', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Teknologi Sistem Terintegrasi', lecturerName: 'Guntur Syahputra, S. Kom., M. Kom.', roomCode: 'TIK.308');
  add(id: 'TRMM4A-10', prodi: 'TRMM', className: 'TRMM 4A', day: 'Jumat', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Pengembangan Konten Digital', lecturerName: 'Ilham Safar, SST., M.Kom', roomCode: 'TIK.103');

  // TRMM 4B (Page 11)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRMM 4B (Halaman 11)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRMM4B-1', prodi: 'TRMM', className: 'TRMM 4B', day: 'Senin', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Sinematografi', lecturerName: 'Umri Erdiansyah, S.Kom., M.Kom.', roomCode: 'TDC-203');
  add(id: 'TRMM4B-2', prodi: 'TRMM', className: 'TRMM 4B', day: 'Senin', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Game Cerdas', lecturerName: 'Mursyidah, S.S.T., M.T.', roomCode: 'TIK.301');
  add(id: 'TRMM4B-3', prodi: 'TRMM', className: 'TRMM 4B', day: 'Selasa', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Periklanan', lecturerName: 'Umri Erdiansyah, S.Kom., M.Kom.', roomCode: 'TDC-308');
  add(id: 'TRMM4B-4', prodi: 'TRMM', className: 'TRMM 4B', day: 'Rabu', startSession: 1, endSession: 3, startTime: '07:30', endTime: '10:00', courseName: 'Praktik Game Cerdas', lecturerName: 'Mursyidah, S.S.T., M.T.', roomCode: 'TIK.103', isPracticum: true);
  add(id: 'TRMM4B-5', prodi: 'TRMM', className: 'TRMM 4B', day: 'Rabu', startSession: 4, endSession: 8, startTime: '10:20', endTime: '15:10', courseName: 'Proyek Industri', lecturerName: 'ASW / MIL', roomCode: 'TIK.312');
  add(id: 'TRMM4B-6', prodi: 'TRMM', className: 'TRMM 4B', day: 'Rabu', startSession: 9, endSession: 11, startTime: '15:10', endTime: '18:00', courseName: 'Teknologi Sistem Terintegrasi', lecturerName: 'Guntur Syahputra, S. Kom., M. Kom.', roomCode: 'TIK.209');
  add(id: 'TRMM4B-7', prodi: 'TRMM', className: 'TRMM 4B', day: 'Kamis', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Pengembangan Web Berbasis Multimedia', lecturerName: 'Guntur Syahputra, S. Kom., M. Kom.', roomCode: 'TIK.205');
  add(id: 'TRMM4B-8', prodi: 'TRMM', className: 'TRMM 4B', day: 'Kamis', startSession: 8, endSession: 11, startTime: '14:20', endTime: '18:00', courseName: 'Edit Video dan Audio', lecturerName: 'Muhammad Nasir, ST. MT.', roomCode: 'TDC-202');
  add(id: 'TRMM4B-9', prodi: 'TRMM', className: 'TRMM 4B', day: 'Jumat', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Pengembangan Konten Digital', lecturerName: 'Ilham Safar, SST., M.Kom', roomCode: 'TIK.202');
  add(id: 'TRMM4B-10', prodi: 'TRMM', className: 'TRMM 4B', day: 'Jumat', startSession: 8, endSession: 9, startTime: '14:20', endTime: '16:00', courseName: 'Etika profesional di bidang TIK', lecturerName: 'Riwanul Nasron, S.T.,M.T.', roomCode: 'TIK.310');

  // ==========================================
  // PRODI TRKJ
  // ==========================================

  // TRKJ 1A (Page 12)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRKJ 1A (Halaman 12)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRKJ1A-1', prodi: 'TRKJ', className: 'TRKJ 1A', day: 'Senin', startSession: 4, endSession: 8, startTime: '10:20', endTime: '15:10', courseName: 'Praktik Algorithma dan Struktur Data', lecturerName: 'Indrawati, SST., MT.', roomCode: 'TIK.106', isPracticum: true);
  add(id: 'TRKJ1A-2', prodi: 'TRKJ', className: 'TRKJ 1A', day: 'Selasa', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Menyimak dan Berbicara Academik', lecturerName: 'Mahlil, S.Pd., M.A', roomCode: 'TIK.313');
  add(id: 'TRKJ1A-3', prodi: 'TRKJ', className: 'TRKJ 1A', day: 'Selasa', startSession: 5, endSession: 8, startTime: '11:10', endTime: '15:10', courseName: 'Pengantar Teknologi Informasi', lecturerName: 'Nanda Saputri, SST., M.T.', roomCode: 'TIK.209');
  add(id: 'TRKJ1A-4', prodi: 'TRKJ', className: 'TRKJ 1A', day: 'Rabu', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktik Dasar-dasar Jaringan', lecturerName: 'Afla Nevrisa, S.Kom., M.Kom.', roomCode: 'TIK.107', isPracticum: true);
  add(id: 'TRKJ1A-5', prodi: 'TRKJ', className: 'TRKJ 1A', day: 'Rabu', startSession: 7, endSession: 8, startTime: '13:30', endTime: '15:10', courseName: 'Dasar-dasar Jaringan', lecturerName: 'Afla Nevrisa, S.Kom., M.Kom.', roomCode: 'TIK.308');
  add(id: 'TRKJ1A-6', prodi: 'TRKJ', className: 'TRKJ 1A', day: 'Kamis', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Algorithma dan Struktur Data', lecturerName: 'Indrawati, SST., MT.', roomCode: 'TIK.209');
  add(id: 'TRKJ1A-7', prodi: 'TRKJ', className: 'TRKJ 1A', day: 'Kamis', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Matematika Terapan Untuk TIK', lecturerName: 'Erika Fahmi Br Ginting, S. Kom., M,Kom', roomCode: 'TIK.301');
  add(id: 'TRKJ1A-8', prodi: 'TRKJ', className: 'TRKJ 1A', day: 'Kamis', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Pendidikan Pancasila', lecturerName: 'Hosea Sitepu, M.Pd', roomCode: 'TIK.315');
  add(id: 'TRKJ1A-9', prodi: 'TRKJ', className: 'TRKJ 1A', day: 'Jumat', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktik Sistem Operasi', lecturerName: 'Firdaus Muttaqin, S.T., M.T.', roomCode: 'TIK.101', isPracticum: true);
  add(id: 'TRKJ1A-10', prodi: 'TRKJ', className: 'TRKJ 1A', day: 'Jumat', startSession: 8, endSession: 11, startTime: '14:20', endTime: '18:00', courseName: 'Dasar-dasar Elektronik untuk IoT', lecturerName: 'Ir. Muhammad Azzahari, SST., MT.', roomCode: 'TIK.111');

  // TRKJ 1B (Page 13)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRKJ 1B (Halaman 13)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRKJ1B-1', prodi: 'TRKJ', className: 'TRKJ 1B', day: 'Senin', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Matematika Terapan Untuk TIK', lecturerName: 'Husaini, S.Si., M.IT', roomCode: 'TIK.305');
  add(id: 'TRKJ1B-2', prodi: 'TRKJ', className: 'TRKJ 1B', day: 'Senin', startSession: 3, endSession: 5, startTime: '09:10', endTime: '12:00', courseName: 'Pendidikan Pancasila', lecturerName: 'Hosea Sitepu, M.Pd', roomCode: 'TIK.305');
  add(id: 'TRKJ1B-3', prodi: 'TRKJ', className: 'TRKJ 1B', day: 'Senin', startSession: 7, endSession: 8, startTime: '13:30', endTime: '15:10', courseName: 'Algorithma dan Struktur Data', lecturerName: 'Safriadi ST, M.Kom.', roomCode: 'TIK.211');
  add(id: 'TRKJ1B-4', prodi: 'TRKJ', className: 'TRKJ 1B', day: 'Selasa', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktik Sistem Operasi', lecturerName: 'Firdaus Muttaqin, S.T., M.T.', roomCode: 'TIK.302', isPracticum: true);
  add(id: 'TRKJ1B-5', prodi: 'TRKJ', className: 'TRKJ 1B', day: 'Selasa', startSession: 6, endSession: 7, startTime: '12:00', endTime: '14:20', courseName: 'Dasar-dasar Jaringan', lecturerName: 'Afla Nevrisa, S.Kom., M.Kom.', roomCode: 'TIK.301');
  add(id: 'TRKJ1B-6', prodi: 'TRKJ', className: 'TRKJ 1B', day: 'Selasa', startSession: 8, endSession: 11, startTime: '14:20', endTime: '18:00', courseName: 'Pengantar Teknologi Informasi', lecturerName: 'Afla Nevrisa, S.Kom., M.Kom.', roomCode: 'TIK.301');
  add(id: 'TRKJ1B-7', prodi: 'TRKJ', className: 'TRKJ 1B', day: 'Rabu', startSession: 4, endSession: 7, startTime: '10:20', endTime: '14:20', courseName: 'Menyimak dan Berbicara Academik', lecturerName: 'Rizqina Barophon, S.Pd., M.Pd.', roomCode: 'TIK.304');
  add(id: 'TRKJ1B-8', prodi: 'TRKJ', className: 'TRKJ 1B', day: 'Kamis', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktik Dasar-dasar Jaringan', lecturerName: 'Afla Nevrisa, S.Kom., M.Kom.', roomCode: 'TIK.107', isPracticum: true);
  add(id: 'TRKJ1B-9', prodi: 'TRKJ', className: 'TRKJ 1B', day: 'Kamis', startSession: 7, endSession: 10, startTime: '13:30', endTime: '17:10', courseName: 'Dasar-dasar Elektronik untuk IoT', lecturerName: 'Ir. Muhammad Azzahari, SST., MT.', roomCode: 'TIK.112');
  add(id: 'TRKJ1B-10', prodi: 'TRKJ', className: 'TRKJ 1B', day: 'Jumat', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktik Algorithma dan Struktur Data', lecturerName: 'Rika Rahmawati, M.Kom.', roomCode: 'TIK.106', isPracticum: true);

  // TRKJ 1C (Page 14)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRKJ 1C (Halaman 14)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRKJ1C-1', prodi: 'TRKJ', className: 'TRKJ 1C', day: 'Senin', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Pengantar Teknologi Informasi', lecturerName: 'Afla Nevrisa, S.Kom., M.Kom.', roomCode: 'TIK.209');
  add(id: 'TRKJ1C-2', prodi: 'TRKJ', className: 'TRKJ 1C', day: 'Senin', startSession: 5, endSession: 8, startTime: '11:10', endTime: '15:10', courseName: 'Menyimak dan Berbicara Academik', lecturerName: 'Rizqina Barophon, S.Pd., M.Pd.', roomCode: 'TIK.306');
  add(id: 'TRKJ1C-3', prodi: 'TRKJ', className: 'TRKJ 1C', day: 'Selasa', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktik Dasar-dasar Jaringan', lecturerName: 'Ir. Muhammad Azzahari, SST., MT.', roomCode: 'TIK.107', isPracticum: true);
  add(id: 'TRKJ1C-4', prodi: 'TRKJ', className: 'TRKJ 1C', day: 'Selasa', startSession: 6, endSession: 7, startTime: '12:00', endTime: '14:20', courseName: 'Matematika Terapan Untuk TIK', lecturerName: 'Erika Fahmi Br Ginting, S. Kom., M,Kom', roomCode: 'TIK.211');
  add(id: 'TRKJ1C-5', prodi: 'TRKJ', className: 'TRKJ 1C', day: 'Rabu', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktik Sistem Operasi', lecturerName: 'Firdaus Muttaqin, S.T., M.T.', roomCode: 'TIK.109', isPracticum: true);
  add(id: 'TRKJ1C-6', prodi: 'TRKJ', className: 'TRKJ 1C', day: 'Kamis', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Pendidikan Pancasila', lecturerName: 'Hosea Sitepu, M.Pd', roomCode: 'TIK.304');
  add(id: 'TRKJ1C-7', prodi: 'TRKJ', className: 'TRKJ 1C', day: 'Kamis', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Dasar-dasar Jaringan', lecturerName: 'Ir. Muhammad Azzahari, SST., MT.', roomCode: 'TIK.309');
  add(id: 'TRKJ1C-8', prodi: 'TRKJ', className: 'TRKJ 1C', day: 'Kamis', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Algorithma dan Struktur Data', lecturerName: 'Zulfan Khairil S. ST., M.Eng.', roomCode: 'TIK.209');
  add(id: 'TRKJ1C-9', prodi: 'TRKJ', className: 'TRKJ 1C', day: 'Jumat', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Dasar-dasar Elektronik untuk IoT', lecturerName: 'Rika Rahmawati, M.Kom.', roomCode: 'TIK.112');
  add(id: 'TRKJ1C-10', prodi: 'TRKJ', className: 'TRKJ 1C', day: 'Jumat', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktik Algorithma dan Struktur Data', lecturerName: 'Zulfan Khairil S. ST., M.Eng.', roomCode: 'TIK.209', isPracticum: true);

  // TRKJ 1D (Page 15)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRKJ 1D (Halaman 15)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRKJ1D-1', prodi: 'TRKJ', className: 'TRKJ 1D', day: 'Senin', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Algorithma dan Struktur Data', lecturerName: 'Indrawati, SST., MT.', roomCode: 'TIK.212');
  add(id: 'TRKJ1D-2', prodi: 'TRKJ', className: 'TRKJ 1D', day: 'Senin', startSession: 5, endSession: 8, startTime: '11:10', endTime: '15:10', courseName: 'Pengantar Teknologi Informasi', lecturerName: 'Afla Nevrisa, S.Kom., M.Kom.', roomCode: 'TIK.209');
  add(id: 'TRKJ1D-3', prodi: 'TRKJ', className: 'TRKJ 1D', day: 'Selasa', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Matematika Terapan Untuk TIK', lecturerName: 'Erika Fahmi Br Ginting, S. Kom., M,Kom', roomCode: 'TIK.209');
  add(id: 'TRKJ1D-4', prodi: 'TRKJ', className: 'TRKJ 1D', day: 'Selasa', startSession: 6, endSession: 7, startTime: '12:00', endTime: '14:20', courseName: 'Dasar-dasar Jaringan', lecturerName: 'Ir. Muhammad Azzahari, SST., MT.', roomCode: 'TIK.308');
  add(id: 'TRKJ1D-5', prodi: 'TRKJ', className: 'TRKJ 1D', day: 'Selasa', startSession: 8, endSession: 11, startTime: '14:20', endTime: '18:00', courseName: 'Dasar-dasar Elektronik untuk IoT', lecturerName: 'Rika Rahmawati, M.Kom.', roomCode: 'TIK.112');
  add(id: 'TRKJ1D-6', prodi: 'TRKJ', className: 'TRKJ 1D', day: 'Rabu', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Pendidikan Pancasila', lecturerName: 'Hosea Sitepu, M.Pd', roomCode: 'TIK.307');
  add(id: 'TRKJ1D-7', prodi: 'TRKJ', className: 'TRKJ 1D', day: 'Rabu', startSession: 3, endSession: 6, startTime: '09:10', endTime: '12:50', courseName: 'Menyimak dan Berbicara Academik', lecturerName: 'Nurul Kamaliah, S.Pd, M.Pd', roomCode: 'TIK.306');
  add(id: 'TRKJ1D-8', prodi: 'TRKJ', className: 'TRKJ 1D', day: 'Rabu', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktik Dasar-dasar Jaringan', lecturerName: 'Ir. Muhammad Azzahari, SST., MT.', roomCode: 'TIK.107', isPracticum: true);
  add(id: 'TRKJ1D-9', prodi: 'TRKJ', className: 'TRKJ 1D', day: 'Kamis', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktik Sistem Operasi', lecturerName: 'Firdaus Muttaqin, S.T., M.T.', roomCode: 'TIK.108', isPracticum: true);
  add(id: 'TRKJ1D-10', prodi: 'TRKJ', className: 'TRKJ 1D', day: 'Jumat', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktik Algorithma dan Struktur Data', lecturerName: 'Indrawati, SST., MT.', roomCode: 'TIK.103', isPracticum: true);

  // TRKJ 2A (Page 16)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRKJ 2A (Halaman 16)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRKJ2A-1', prodi: 'TRKJ', className: 'TRKJ 2A', day: 'Senin', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Aljabar Linear', lecturerName: 'Nazaruddin, ST., MT', roomCode: 'TIK.306');
  add(id: 'TRKJ2A-2', prodi: 'TRKJ', className: 'TRKJ 2A', day: 'Senin', startSession: 3, endSession: 7, startTime: '09:10', endTime: '14:20', courseName: 'Praktik Penskalaan Jaringan', lecturerName: 'Ir. Muhammad Azzahari, SST., MT.', roomCode: 'TIK.107', isPracticum: true);
  add(id: 'TRKJ2A-3', prodi: 'TRKJ', className: 'TRKJ 2A', day: 'Selasa', startSession: 1, endSession: 3, startTime: '07:30', endTime: '10:00', courseName: 'Praktik Sistem Operasi Jaringan', lecturerName: 'Rika Rahmawati, M.Kom.', roomCode: 'TIK.212', isPracticum: true);
  add(id: 'TRKJ2A-4', prodi: 'TRKJ', className: 'TRKJ 2A', day: 'Selasa', startSession: 5, endSession: 7, startTime: '11:10', endTime: '14:20', courseName: 'Dasar-dasar Desain UI / UX', lecturerName: 'Indrawati, SST., MT.', roomCode: 'TIK.204');
  add(id: 'TRKJ2A-5', prodi: 'TRKJ', className: 'TRKJ 2A', day: 'Rabu', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Kemampuan Interpersonal', lecturerName: 'Zulkarnaini, SE.,M.Si.Ak.CA', roomCode: 'TIK.303');
  add(id: 'TRKJ2A-6', prodi: 'TRKJ', className: 'TRKJ 2A', day: 'Rabu', startSession: 5, endSession: 8, startTime: '11:10', endTime: '15:10', courseName: 'Internet of Things', lecturerName: 'Muhammad Nasir, ST. MT.', roomCode: 'TIK.112');
  add(id: 'TRKJ2A-7', prodi: 'TRKJ', className: 'TRKJ 2A', day: 'Kamis', startSession: 1, endSession: 6, startTime: '07:30', endTime: '12:50', courseName: 'Etika Peretasan', lecturerName: 'Aswandi, S.Kom., M.Kom', roomCode: 'TIK.109');
  add(id: 'TRKJ2A-8', prodi: 'TRKJ', className: 'TRKJ 2A', day: 'Kamis', startSession: 7, endSession: 8, startTime: '13:30', endTime: '15:10', courseName: 'Pendidikan Agama', lecturerName: 'Nazar Fadli, M.Ag., Ph.D.', roomCode: 'TIK.310');
  add(id: 'TRKJ2A-9', prodi: 'TRKJ', className: 'TRKJ 2A', day: 'Jumat', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Teknologi Sistem Terintegrasi', lecturerName: 'Hari Toha Hidayat, S.Si., M.Cs', roomCode: 'TIK.105');
  add(id: 'TRKJ2A-10', prodi: 'TRKJ', className: 'TRKJ 2A', day: 'Jumat', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Pengantar Proyek', lecturerName: 'Nanang Prihatin, S.Kom., M.Cs.', roomCode: 'TIK.211');

  // TRKJ 2B (Page 17)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRKJ 2B (Halaman 17)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRKJ2B-1', prodi: 'TRKJ', className: 'TRKJ 2B', day: 'Senin', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Aljabar Linear', lecturerName: 'Nazaruddin, ST., MT', roomCode: 'TIK.303');
  add(id: 'TRKJ2B-2', prodi: 'TRKJ', className: 'TRKJ 2B', day: 'Senin', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Etika Peretasan', lecturerName: 'Nanang Prihatin, S.Kom., M.Cs.', roomCode: 'TIK.304');
  add(id: 'TRKJ2B-3', prodi: 'TRKJ', className: 'TRKJ 2B', day: 'Selasa', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Pengantar Proyek', lecturerName: 'Afla Nevrisa, S.Kom., M.Kom.', roomCode: 'TIK.211');
  add(id: 'TRKJ2B-4', prodi: 'TRKJ', className: 'TRKJ 2B', day: 'Selasa', startSession: 7, endSession: 8, startTime: '13:30', endTime: '15:10', courseName: 'Pendidikan Agama', lecturerName: 'Nazar Fadli, M.Ag., Ph.D.', roomCode: 'TIK.304');
  add(id: 'TRKJ2B-5', prodi: 'TRKJ', className: 'TRKJ 2B', day: 'Rabu', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Kemampuan Interpersonal', lecturerName: 'Maulizar, S.E, M.Si', roomCode: 'TIK.302');
  add(id: 'TRKJ2B-6', prodi: 'TRKJ', className: 'TRKJ 2B', day: 'Rabu', startSession: 5, endSession: 8, startTime: '11:10', endTime: '15:10', courseName: 'Teknologi Sistem Terintegrasi', lecturerName: 'Muhammad Davi, S.Kom., M.Cs.', roomCode: 'TIK.111');
  add(id: 'TRKJ2B-7', prodi: 'TRKJ', className: 'TRKJ 2B', day: 'Kamis', startSession: 5, endSession: 7, startTime: '11:10', endTime: '14:20', courseName: 'Praktik Sistem Operasi Jaringan', lecturerName: 'Rika Rahmawati, M.Kom.', roomCode: 'TIK.302', isPracticum: true);
  add(id: 'TRKJ2B-8', prodi: 'TRKJ', className: 'TRKJ 2B', day: 'Kamis', startSession: 8, endSession: 11, startTime: '14:20', endTime: '18:00', courseName: 'Dasar-dasar Desain UI / UX', lecturerName: 'Indrawati, SST., MT.', roomCode: 'TIK.103');
  add(id: 'TRKJ2B-9', prodi: 'TRKJ', className: 'TRKJ 2B', day: 'Jumat', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktik Penskalaan Jaringan', lecturerName: 'Ir. Muhammad Azzahari, SST., MT.', roomCode: 'TIK.110', isPracticum: true);
  add(id: 'TRKJ2B-10', prodi: 'TRKJ', className: 'TRKJ 2B', day: 'Jumat', startSession: 8, endSession: 11, startTime: '14:20', endTime: '18:00', courseName: 'Internet of Things', lecturerName: 'Atthariq, SST., MT.', roomCode: 'TIK.112');

  // TRKJ 2C (Page 18)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRKJ 2C (Halaman 18)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRKJ2C-1', prodi: 'TRKJ', className: 'TRKJ 2C', day: 'Senin', startSession: 1, endSession: 6, startTime: '07:30', endTime: '12:50', courseName: 'Etika Peretasan', lecturerName: 'Aswandi, S.Kom., M.Kom', roomCode: 'TIK.111');
  add(id: 'TRKJ2C-2', prodi: 'TRKJ', className: 'TRKJ 2C', day: 'Senin', startSession: 8, endSession: 11, startTime: '14:20', endTime: '18:00', courseName: 'Internet of Things', lecturerName: 'Atthariq, SST., MT.', roomCode: 'TIK.112');
  add(id: 'TRKJ2C-3', prodi: 'TRKJ', className: 'TRKJ 2C', day: 'Selasa', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktik Penskalaan Jaringan', lecturerName: 'Aswandi, S.Kom., M.Kom', roomCode: 'TIK.109', isPracticum: true);
  add(id: 'TRKJ2C-4', prodi: 'TRKJ', className: 'TRKJ 2C', day: 'Selasa', startSession: 8, endSession: 11, startTime: '14:20', endTime: '18:00', courseName: 'Pengantar Proyek', lecturerName: 'Indrawati, SST., MT.', roomCode: 'TIK.211');
  add(id: 'TRKJ2C-5', prodi: 'TRKJ', className: 'TRKJ 2C', day: 'Rabu', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Dasar-dasar Desain UI / UX', lecturerName: 'Muhammad Davi, S.Kom., M.Cs.', roomCode: 'TIK.111');
  add(id: 'TRKJ2C-6', prodi: 'TRKJ', className: 'TRKJ 2C', day: 'Rabu', startSession: 5, endSession: 7, startTime: '11:10', endTime: '14:20', courseName: 'Praktik Sistem Operasi Jaringan', lecturerName: 'Rika Rahmawati, M.Kom.', roomCode: 'TIK.303', isPracticum: true);
  add(id: 'TRKJ2C-7', prodi: 'TRKJ', className: 'TRKJ 2C', day: 'Kamis', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Aljabar Linear', lecturerName: 'Erna Yusniyanti, S.Si., M.Si.', roomCode: 'TIK.303');
  add(id: 'TRKJ2C-8', prodi: 'TRKJ', className: 'TRKJ 2C', day: 'Kamis', startSession: 5, endSession: 8, startTime: '11:10', endTime: '15:10', courseName: 'Teknologi Sistem Terintegrasi', lecturerName: 'Hari Toha Hidayat, S.Si., M.Cs', roomCode: 'TIK.106');
  add(id: 'TRKJ2C-9', prodi: 'TRKJ', className: 'TRKJ 2C', day: 'Jumat', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Kemampuan Interpersonal', lecturerName: 'Halimatus Sakdiah, S.E, M.M', roomCode: 'TIK.306');
  add(id: 'TRKJ2C-10', prodi: 'TRKJ', className: 'TRKJ 2C', day: 'Jumat', startSession: 7, endSession: 8, startTime: '13:30', endTime: '15:10', courseName: 'Pendidikan Agama', lecturerName: 'Nazar Fadli, M.Ag., Ph.D.', roomCode: 'TIK.301');

  // TRKJ 2D (Page 19)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRKJ 2D (Halaman 19)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRKJ2D-1', prodi: 'TRKJ', className: 'TRKJ 2D', day: 'Senin', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Dasar-dasar Desain UI / UX', lecturerName: 'Mutiara S. Simanjuntak, S.Kom., M. Kom', roomCode: 'TIK.110');
  add(id: 'TRKJ2D-2', prodi: 'TRKJ', className: 'TRKJ 2D', day: 'Senin', startSession: 5, endSession: 7, startTime: '11:10', endTime: '14:20', courseName: 'Praktik Sistem Operasi Jaringan', lecturerName: 'Rika Rahmawati, M.Kom.', roomCode: 'TIK.311', isPracticum: true);
  add(id: 'TRKJ2D-3', prodi: 'TRKJ', className: 'TRKJ 2D', day: 'Senin', startSession: 8, endSession: 9, startTime: '14:20', endTime: '16:00', courseName: 'Aljabar Linear', lecturerName: 'Nazaruddin, ST., MT', roomCode: 'TIK.212');
  add(id: 'TRKJ2D-4', prodi: 'TRKJ', className: 'TRKJ 2D', day: 'Selasa', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Pengantar Proyek', lecturerName: 'Atthariq, SST., MT.', roomCode: 'TIK.111');
  add(id: 'TRKJ2D-5', prodi: 'TRKJ', className: 'TRKJ 2D', day: 'Selasa', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktik Penskalaan Jaringan', lecturerName: 'Aswandi, S.Kom., M.Kom', roomCode: 'TIK.206', isPracticum: true);
  add(id: 'TRKJ2D-6', prodi: 'TRKJ', className: 'TRKJ 2D', day: 'Rabu', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Internet of Things', lecturerName: 'Muhammad Nasir, ST. MT.', roomCode: 'TIK.112');
  add(id: 'TRKJ2D-7', prodi: 'TRKJ', className: 'TRKJ 2D', day: 'Rabu', startSession: 7, endSession: 8, startTime: '13:30', endTime: '15:10', courseName: 'Pendidikan Agama', lecturerName: 'Nazar Fadli, M.Ag., Ph.D.', roomCode: 'TIK.209');
  add(id: 'TRKJ2D-8', prodi: 'TRKJ', className: 'TRKJ 2D', day: 'Kamis', startSession: 1, endSession: 6, startTime: '07:30', endTime: '12:50', courseName: 'Etika Peretasan', lecturerName: 'Nanang Prihatin, S.Kom., M.Cs.', roomCode: 'TIK.111');
  add(id: 'TRKJ2D-9', prodi: 'TRKJ', className: 'TRKJ 2D', day: 'Kamis', startSession: 7, endSession: 8, startTime: '13:30', endTime: '15:10', courseName: 'Kemampuan Interpersonal', lecturerName: 'Diana, SE.,Ak.,M.Si.', roomCode: 'TIK.315');
  add(id: 'TRKJ2D-10', prodi: 'TRKJ', className: 'TRKJ 2D', day: 'Jumat', startSession: 8, endSession: 11, startTime: '14:20', endTime: '18:00', courseName: 'Teknologi Sistem Terintegrasi', lecturerName: 'Hari Toha Hidayat, S.Si., M.Cs', roomCode: 'TIK.102');

  // TRKJ 3A (Page 20)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRKJ 3A (Halaman 20)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRKJ3A-1', prodi: 'TRKJ', className: 'TRKJ 3A', day: 'Senin', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Manajemen dan Penyimpanan Jaringan', lecturerName: 'Anwar, S.Si., M.Cs.', roomCode: 'TIK.109');
  add(id: 'TRKJ3A-2', prodi: 'TRKJ', className: 'TRKJ 3A', day: 'Senin', startSession: 6, endSession: 7, startTime: '12:00', endTime: '14:20', courseName: 'Manajemen Risiko Keamanan Siber', lecturerName: 'Atthariq, SST., MT.', roomCode: 'TIK.312');
  add(id: 'TRKJ3A-3', prodi: 'TRKJ', className: 'TRKJ 3A', day: 'Senin', startSession: 8, endSession: 9, startTime: '14:20', endTime: '16:00', courseName: 'Tata Kelola IT', lecturerName: 'Firdaus Muttaqin, S.T., M.T.', roomCode: 'TIK.301');
  add(id: 'TRKJ3A-4', prodi: 'TRKJ', className: 'TRKJ 3A', day: 'Selasa', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Pengembangan dan Manajemen Perangkat Lunak', lecturerName: 'Husaini, S.Si., M.IT', roomCode: 'TIK.310');
  add(id: 'TRKJ3A-5', prodi: 'TRKJ', className: 'TRKJ 3A', day: 'Selasa', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Paradigma Sistem untuk IT', lecturerName: 'Husaini, S.Si., M.IT', roomCode: 'TIK.306');
  add(id: 'TRKJ3A-6', prodi: 'TRKJ', className: 'TRKJ 3A', day: 'Rabu', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Komputasi Seluler', lecturerName: 'Hari Toha Hidayat, S.Si., M.Cs', roomCode: 'TIK.315');
  add(id: 'TRKJ3A-7', prodi: 'TRKJ', className: 'TRKJ 3A', day: 'Rabu', startSession: 8, endSession: 11, startTime: '14:20', endTime: '18:00', courseName: 'Praktik Manajemen Risiko Keamanan Siber', lecturerName: 'Atthariq, SST., MT.', roomCode: 'TIK.306', isPracticum: true);
  add(id: 'TRKJ3A-8', prodi: 'TRKJ', className: 'TRKJ 3A', day: 'Kamis', startSession: 4, endSession: 8, startTime: '10:20', endTime: '15:10', courseName: 'Praktik Website dan Sistem Mobile', lecturerName: 'Muhammad Davi, S.Kom., M.Cs.', roomCode: 'TIK.101', isPracticum: true);
  add(id: 'TRKJ3A-9', prodi: 'TRKJ', className: 'TRKJ 3A', day: 'Jumat', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Proyek Inovasi Produk', lecturerName: 'RHD / HSN', roomCode: 'TIK.209');

  // TRKJ 3B (Page 21)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRKJ 3B (Halaman 21)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRKJ3B-1', prodi: 'TRKJ', className: 'TRKJ 3B', day: 'Senin', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Komputasi Seluler', lecturerName: 'Hari Toha Hidayat, S.Si., M.Cs', roomCode: 'TIK.316');
  add(id: 'TRKJ3B-2', prodi: 'TRKJ', className: 'TRKJ 3B', day: 'Selasa', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktik Website dan Sistem Mobile', lecturerName: 'Muhammad Davi, S.Kom., M.Cs.', roomCode: 'TIK.101', isPracticum: true);
  add(id: 'TRKJ3B-3', prodi: 'TRKJ', className: 'TRKJ 3B', day: 'Selasa', startSession: 6, endSession: 8, startTime: '12:00', endTime: '15:10', courseName: 'Praktik Manajemen Risiko Keamanan Siber', lecturerName: 'Firdaus Muttaqin, S.T., M.T.', roomCode: 'TIK.111', isPracticum: true);
  add(id: 'TRKJ3B-4', prodi: 'TRKJ', className: 'TRKJ 3B', day: 'Rabu', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Tata Kelola IT', lecturerName: 'Firdaus Muttaqin, S.T., M.T.', roomCode: 'TIK.209');
  add(id: 'TRKJ3B-5', prodi: 'TRKJ', className: 'TRKJ 3B', day: 'Rabu', startSession: 3, endSession: 7, startTime: '09:10', endTime: '14:20', courseName: 'Proyek Inovasi Produk', lecturerName: 'ATQ / IDR', roomCode: 'TIK.213');
  add(id: 'TRKJ3B-6', prodi: 'TRKJ', className: 'TRKJ 3B', day: 'Kamis', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Pengembangan dan Manajemen Perangkat Lunak', lecturerName: 'Husaini, S.Si., M.IT', roomCode: 'TIK.313');
  add(id: 'TRKJ3B-7', prodi: 'TRKJ', className: 'TRKJ 3B', day: 'Kamis', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Paradigma Sistem untuk IT', lecturerName: 'Husaini, S.Si., M.IT', roomCode: 'TIK.304');
  add(id: 'TRKJ3B-8', prodi: 'TRKJ', className: 'TRKJ 3B', day: 'Kamis', startSession: 7, endSession: 8, startTime: '13:30', endTime: '15:10', courseName: 'Manajemen Risiko Keamanan Siber', lecturerName: 'Firdaus Muttaqin, S.T., M.T.', roomCode: 'TIK.212');
  add(id: 'TRKJ3B-9', prodi: 'TRKJ', className: 'TRKJ 3B', day: 'Jumat', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Manajemen dan Penyimpanan Jaringan', lecturerName: 'Anwar, S.Si., M.Cs.', roomCode: 'TIK.214');

  // TRKJ 3C (Page 22)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRKJ 3C (Halaman 22)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRKJ3C-1', prodi: 'TRKJ', className: 'TRKJ 3C', day: 'Senin', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Paradigma Sistem untuk IT', lecturerName: 'M.Reza Zulman, SST., M.Sc.', roomCode: 'TIK.304');
  add(id: 'TRKJ3C-2', prodi: 'TRKJ', className: 'TRKJ 3C', day: 'Senin', startSession: 3, endSession: 6, startTime: '09:10', endTime: '12:50', courseName: 'Pengembangan dan Manajemen Perangkat Lunak', lecturerName: 'Husaini, S.Si., M.IT', roomCode: 'TIK.307');
  add(id: 'TRKJ3C-3', prodi: 'TRKJ', className: 'TRKJ 3C', day: 'Selasa', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Komputasi Seluler', lecturerName: 'Arwin Putra, M.Kom', roomCode: 'TIK.308');
  add(id: 'TRKJ3C-4', prodi: 'TRKJ', className: 'TRKJ 3C', day: 'Selasa', startSession: 6, endSession: 8, startTime: '12:00', endTime: '15:10', courseName: 'Praktik Manajemen Risiko Keamanan Siber', lecturerName: 'Atthariq, SST., MT.', roomCode: 'TIK.107', isPracticum: true);
  add(id: 'TRKJ3C-5', prodi: 'TRKJ', className: 'TRKJ 3C', day: 'Rabu', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Manajemen Risiko Keamanan Siber', lecturerName: 'Atthariq, SST., MT.', roomCode: 'TIK.311');
  add(id: 'TRKJ3C-6', prodi: 'TRKJ', className: 'TRKJ 3C', day: 'Rabu', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Proyek Inovasi Produk', lecturerName: 'NSP / HSN', roomCode: 'TIK.214');
  add(id: 'TRKJ3C-7', prodi: 'TRKJ', className: 'TRKJ 3C', day: 'Kamis', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Tata Kelola IT', lecturerName: 'Amri, SST., MT', roomCode: 'TIK.214');
  add(id: 'TRKJ3C-8', prodi: 'TRKJ', className: 'TRKJ 3C', day: 'Kamis', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Manajemen dan Penyimpanan Jaringan', lecturerName: 'Anwar, S.Si., M.Cs.', roomCode: 'TIK.108');
  add(id: 'TRKJ3C-9', prodi: 'TRKJ', className: 'TRKJ 3C', day: 'Jumat', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktik Website dan Sistem Mobile', lecturerName: 'Muhammad Davi, S.Kom., M.Cs.', roomCode: 'TIK.301', isPracticum: true);

  // TRKJ 3D (Page 23)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRKJ 3D (Halaman 23)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRKJ3D-1', prodi: 'TRKJ', className: 'TRKJ 3D', day: 'Senin', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Komputasi Seluler', lecturerName: 'Arwin Putra, M.Kom', roomCode: 'TIK.312');
  add(id: 'TRKJ3D-2', prodi: 'TRKJ', className: 'TRKJ 3D', day: 'Selasa', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Manajemen dan Penyimpanan Jaringan', lecturerName: 'Anwar, S.Si., M.Cs.', roomCode: 'TIK.108');
  add(id: 'TRKJ3D-3', prodi: 'TRKJ', className: 'TRKJ 3D', day: 'Rabu', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Pengembangan dan Manajemen Perangkat Lunak', lecturerName: 'Husaini, S.Si., M.IT', roomCode: 'TIK.211');
  add(id: 'TRKJ3D-4', prodi: 'TRKJ', className: 'TRKJ 3D', day: 'Rabu', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Tata Kelola IT', lecturerName: 'Amri, SST., MT', roomCode: 'TIK.214');
  add(id: 'TRKJ3D-5', prodi: 'TRKJ', className: 'TRKJ 3D', day: 'Rabu', startSession: 9, endSession: 11, startTime: '15:10', endTime: '18:00', courseName: 'Paradigma Sistem untuk IT', lecturerName: 'M.Reza Zulman, SST., M.Sc.', roomCode: 'TIK.301');
  add(id: 'TRKJ3D-6', prodi: 'TRKJ', className: 'TRKJ 3D', day: 'Kamis', startSession: 3, endSession: 7, startTime: '09:10', endTime: '14:20', courseName: 'Proyek Inovasi Produk', lecturerName: 'IDR / NDW', roomCode: 'TIK.211');
  add(id: 'TRKJ3D-7', prodi: 'TRKJ', className: 'TRKJ 3D', day: 'Jumat', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Manajemen Risiko Keamanan Siber', lecturerName: 'Atthariq, SST., MT.', roomCode: 'TIK.308');
  add(id: 'TRKJ3D-8', prodi: 'TRKJ', className: 'TRKJ 3D', day: 'Jumat', startSession: 3, endSession: 5, startTime: '09:10', endTime: '12:00', courseName: 'Praktik Manajemen Risiko Keamanan Siber', lecturerName: 'Atthariq, SST., MT.', roomCode: 'TIK.107', isPracticum: true);
  add(id: 'TRKJ3D-9', prodi: 'TRKJ', className: 'TRKJ 3D', day: 'Jumat', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktik Website dan Sistem Mobile', lecturerName: 'Muhammad Davi, S.Kom., M.Cs.', roomCode: 'TIK.104', isPracticum: true);

  // TRKJ 4A (Page 24)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRKJ 4A (Halaman 24)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRKJ4A-1', prodi: 'TRKJ', className: 'TRKJ 4A', day: 'Senin', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Robotika, Jaringan Cerdas & Otomasi', lecturerName: 'Mustainul Abdi, SST., M.Kom.', roomCode: 'TIK.112');
  add(id: 'TRKJ4A-2', prodi: 'TRKJ', className: 'TRKJ 4A', day: 'Selasa', startSession: 1, endSession: 3, startTime: '07:30', endTime: '10:00', courseName: 'Praktik Sistem Administrator dan Layanan Infrastruktur IT', lecturerName: 'Anwar, S.Si., M.Cs.', roomCode: 'TIK.108', isPracticum: true);
  add(id: 'TRKJ4A-3', prodi: 'TRKJ', className: 'TRKJ 4A', day: 'Selasa', startSession: 4, endSession: 7, startTime: '10:20', endTime: '14:20', courseName: 'Audit Keamanan Siber', lecturerName: 'Nanang Prihatin, S.Kom., M.Cs.', roomCode: 'TIK.311');
  add(id: 'TRKJ4A-4', prodi: 'TRKJ', className: 'TRKJ 4A', day: 'Rabu', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Arsitektur Sistem Enterprise', lecturerName: 'Rika Rahmawati, M.Kom.', roomCode: 'TIK.313');
  add(id: 'TRKJ4A-5', prodi: 'TRKJ', className: 'TRKJ 4A', day: 'Rabu', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Sistem Administrator dan Layanan Infrastruktur IT', lecturerName: 'Muhammad Rizka, SST., M. Kom.', roomCode: 'TIK.212');
  add(id: 'TRKJ4A-6', prodi: 'TRKJ', className: 'TRKJ 4A', day: 'Rabu', startSession: 7, endSession: 9, startTime: '13:30', endTime: '16:00', courseName: 'Praktik Sistem dan Layanan Virtual', lecturerName: 'Amri, SST., MT', roomCode: 'TIK.110', isPracticum: true);
  add(id: 'TRKJ4A-7', prodi: 'TRKJ', className: 'TRKJ 4A', day: 'Kamis', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Audit Infrastruktur Jaringan', lecturerName: 'Hari Toha Hidayat, S.Si., M.Cs', roomCode: 'TIK.110');
  add(id: 'TRKJ4A-8', prodi: 'TRKJ', className: 'TRKJ 4A', day: 'Jumat', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Proyek Industri Jaringan', lecturerName: 'Amri, SST., MT', roomCode: 'TIK.108');

  // TRKJ 4B (Page 25)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRKJ 4B (Halaman 25)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRKJ4B-1', prodi: 'TRKJ', className: 'TRKJ 4B', day: 'Senin', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Arsitektur Sistem Enterprise', lecturerName: 'Rika Rahmawati, M.Kom.', roomCode: 'TIK.310');
  add(id: 'TRKJ4B-2', prodi: 'TRKJ', className: 'TRKJ 4B', day: 'Senin', startSession: 5, endSession: 7, startTime: '11:10', endTime: '14:20', courseName: 'Praktik Sistem dan Layanan Virtual', lecturerName: 'Firdaus Muttaqin, S.T., M.T.', roomCode: 'TIK.110', isPracticum: true);
  add(id: 'TRKJ4B-3', prodi: 'TRKJ', className: 'TRKJ 4B', day: 'Selasa', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Aplikasi Layanan Jaringan', lecturerName: 'Amri, SST., MT', roomCode: 'TIK.110');
  add(id: 'TRKJ4B-4', prodi: 'TRKJ', className: 'TRKJ 4B', day: 'Selasa', startSession: 5, endSession: 8, startTime: '11:10', endTime: '15:10', courseName: 'Audit Infrastruktur Jaringan', lecturerName: 'Hari Toha Hidayat, S.Si., M.Cs', roomCode: 'TIK.110');
  add(id: 'TRKJ4B-5', prodi: 'TRKJ', className: 'TRKJ 4B', day: 'Rabu', startSession: 1, endSession: 3, startTime: '07:30', endTime: '10:00', courseName: 'Praktik Sistem Administrator dan Layanan Infrastruktur IT', lecturerName: 'Aswandi, S.Kom., M.Kom', roomCode: 'TIK.108', isPracticum: true);
  add(id: 'TRKJ4B-6', prodi: 'TRKJ', className: 'TRKJ 4B', day: 'Rabu', startSession: 4, endSession: 8, startTime: '10:20', endTime: '15:10', courseName: 'Proyek Industri Jaringan', lecturerName: 'Anwar, S.Si., M.Cs.', roomCode: 'TIK.108');
  add(id: 'TRKJ4B-7', prodi: 'TRKJ', className: 'TRKJ 4B', day: 'Kamis', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Robotika, Jaringan Cerdas & Otomasi', lecturerName: 'Muhammad Nasir, ST. MT.', roomCode: 'TIK.112');
  add(id: 'TRKJ4B-8', prodi: 'TRKJ', className: 'TRKJ 4B', day: 'Jumat', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Audit Keamanan Siber', lecturerName: 'Nanang Prihatin, S.Kom., M.Cs.', roomCode: 'TIK.315');
  add(id: 'TRKJ4B-9', prodi: 'TRKJ', className: 'TRKJ 4B', day: 'Jumat', startSession: 8, endSession: 9, startTime: '14:20', endTime: '16:00', courseName: 'Sistem Administrator dan Layanan Infrastruktur IT', lecturerName: 'Aswandi, S.Kom., M.Kom', roomCode: 'TIK.309');

  // TRKJ 4C (Page 26)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRKJ 4C (Halaman 26)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRKJ4C-1', prodi: 'TRKJ', className: 'TRKJ 4C', day: 'Senin', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Proyek Industri Jaringan', lecturerName: 'Nanang Prihatin, S.Kom., M.Cs.', roomCode: 'TIK.108');
  add(id: 'TRKJ4C-2', prodi: 'TRKJ', className: 'TRKJ 4C', day: 'Senin', startSession: 6, endSession: 8, startTime: '12:00', endTime: '15:10', courseName: 'Praktik Sistem Administrator dan Layanan Infrastruktur IT', lecturerName: 'Anwar, S.Si., M.Cs.', roomCode: 'TIK.108', isPracticum: true);
  add(id: 'TRKJ4C-3', prodi: 'TRKJ', className: 'TRKJ 4C', day: 'Selasa', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Robotika, Jaringan Cerdas & Otomasi', lecturerName: 'Muhammad Nasir, ST. MT.', roomCode: 'TIK.112');
  add(id: 'TRKJ4C-4', prodi: 'TRKJ', className: 'TRKJ 4C', day: 'Selasa', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Aplikasi Layanan Jaringan', lecturerName: 'Amri, SST., MT', roomCode: 'TIK.303');
  add(id: 'TRKJ4C-5', prodi: 'TRKJ', className: 'TRKJ 4C', day: 'Rabu', startSession: 1, endSession: 3, startTime: '07:30', endTime: '10:00', courseName: 'Praktik Sistem dan Layanan Virtual', lecturerName: 'Amri, SST., MT', roomCode: 'TIK.110', isPracticum: true);
  add(id: 'TRKJ4C-6', prodi: 'TRKJ', className: 'TRKJ 4C', day: 'Rabu', startSession: 4, endSession: 7, startTime: '10:20', endTime: '14:20', courseName: 'Audit Keamanan Siber', lecturerName: 'Nanang Prihatin, S.Kom., M.Cs.', roomCode: 'TIK.310');
  add(id: 'TRKJ4C-7', prodi: 'TRKJ', className: 'TRKJ 4C', day: 'Rabu', startSession: 8, endSession: 11, startTime: '14:20', endTime: '18:00', courseName: 'Audit Infrastruktur Jaringan', lecturerName: 'Hari Toha Hidayat, S.Si., M.Cs', roomCode: 'TIK.213');
  add(id: 'TRKJ4C-8', prodi: 'TRKJ', className: 'TRKJ 4C', day: 'Kamis', startSession: 1, endSession: 4, startTime: '07:30', endTime: '11:10', courseName: 'Arsitektur Sistem Enterprise', lecturerName: 'Rika Rahmawati, M.Kom.', roomCode: 'TIK.307');
  add(id: 'TRKJ4C-9', prodi: 'TRKJ', className: 'TRKJ 4C', day: 'Kamis', startSession: 5, endSession: 8, startTime: '11:10', endTime: '15:10', courseName: 'Aplikasi Layanan Jaringan', lecturerName: 'Amri, SST., MT', roomCode: 'TIK.110');
  add(id: 'TRKJ4C-10', prodi: 'TRKJ', className: 'TRKJ 4C', day: 'Jumat', startSession: 7, endSession: 8, startTime: '13:30', endTime: '15:10', courseName: 'Sistem Administrator dan Layanan Infrastruktur IT', lecturerName: 'Anwar, S.Si., M.Cs.', roomCode: 'TIK.212');

  // ==========================================
  // PRODI TEKNIK INFORMATIKA (TI)
  // ==========================================

  // TI 1A (Page 27)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TI 1A (Halaman 27)");
  buffer.writeln("      // ==========================================");
  add(id: 'TI1A-1', prodi: 'TI', className: 'TI 1A', day: 'Senin', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Pengantar Teknik Informatika dan Orkom', lecturerName: 'Mulyadi, ST., M.Eng.', roomCode: 'TIK.314');
  add(id: 'TI1A-2', prodi: 'TI', className: 'TI 1A', day: 'Senin', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Konsep Pemrograman', lecturerName: 'Hendrawaty, ST., MT', roomCode: 'TIK.314');
  add(id: 'TI1A-3', prodi: 'TI', className: 'TI 1A', day: 'Senin', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Konsep Basis Data', lecturerName: 'Salahuddin, ST., M.Cs.', roomCode: 'TIK.103', isPracticum: true);
  add(id: 'TI1A-4', prodi: 'TI', className: 'TI 1A', day: 'Selasa', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktikum Konsep Pemrograman', lecturerName: 'Muhammad Arhami, S.Si., M.Kom', roomCode: 'TIK.104', isPracticum: true);
  add(id: 'TI1A-5', prodi: 'TI', className: 'TI 1A', day: 'Rabu', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Konsep Basis Data', lecturerName: 'Salahuddin, ST., M.Cs.', roomCode: 'TIK.303');
  add(id: 'TI1A-6', prodi: 'TI', className: 'TI 1A', day: 'Rabu', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Logika dan Algoritma', lecturerName: 'Hendrawaty, ST., MT', roomCode: 'TIK.303');
  add(id: 'TI1A-7', prodi: 'TI', className: 'TI 1A', day: 'Rabu', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'English for Listening', lecturerName: 'Drs. Teuku Mustaqim, M.Pd.', roomCode: 'TIK.305');
  add(id: 'TI1A-8', prodi: 'TI', className: 'TI 1A', day: 'Kamis', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Matematika Diskrit', lecturerName: 'Cut Dwita Rahma, S.T., M.T.', roomCode: 'TIK.310');
  add(id: 'TI1A-9', prodi: 'TI', className: 'TI 1A', day: 'Kamis', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Konsep Teknologi Informasi', lecturerName: 'Huzaeni, S.ST., M.IT', roomCode: 'TIK.310');
  add(id: 'TI1A-10', prodi: 'TI', className: 'TI 1A', day: 'Jumat', startSession: 10, endSession: 11, startTime: '16:20', endTime: '18:00', courseName: 'Agama', lecturerName: 'Taufiqul Hadi, Lc, MA', roomCode: 'TIK.302');

  // TI 1B (Page 28)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TI 1B (Halaman 28)");
  buffer.writeln("      // ==========================================");
  add(id: 'TI1B-1', prodi: 'TI', className: 'TI 1B', day: 'Senin', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Konsep Basis Data', lecturerName: 'Salahuddin, ST., M.Cs.', roomCode: 'TIK.308');
  add(id: 'TI1B-2', prodi: 'TI', className: 'TI 1B', day: 'Selasa', startSession: 4, endSession: 5, startTime: '10:20', endTime: '12:00', courseName: 'English for Listening', lecturerName: 'Drs. Teuku Mustaqim, M.Pd.', roomCode: 'TIK.303');
  add(id: 'TI1B-3', prodi: 'TI', className: 'TI 1B', day: 'Rabu', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Logika dan Algoritma', lecturerName: 'Suci Andriani, M.Kom.', roomCode: 'TIK.302');
  add(id: 'TI1B-4', prodi: 'TI', className: 'TI 1B', day: 'Rabu', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Konsep Pemrograman', lecturerName: 'Muhammad Arhami, S.Si., M.Kom', roomCode: 'TIK.104', isPracticum: true);
  add(id: 'TI1B-5', prodi: 'TI', className: 'TI 1B', day: 'Kamis', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Konsep Teknologi Informasi', lecturerName: 'Huzaeni, S.ST., M.IT', roomCode: 'TIK.308');
  add(id: 'TI1B-6', prodi: 'TI', className: 'TI 1B', day: 'Kamis', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Konsep Pemrograman', lecturerName: 'Huzaeni, S.ST., M.IT', roomCode: 'TIK.308');
  add(id: 'TI1B-7', prodi: 'TI', className: 'TI 1B', day: 'Jumat', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Matematika Diskrit', lecturerName: 'Suci Andriani, M.Kom.', roomCode: 'TIK.313');
  add(id: 'TI1B-8', prodi: 'TI', className: 'TI 1B', day: 'Jumat', startSession: 4, endSession: 5, startTime: '10:20', endTime: '12:00', courseName: 'Agama', lecturerName: 'Taufiqul Hadi, Lc, MA', roomCode: 'TIK.304');
  add(id: 'TI1B-9', prodi: 'TI', className: 'TI 1B', day: 'Jumat', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Konsep Basis Data', lecturerName: 'Huzaeni, S.ST., M.IT', roomCode: 'TIK.105', isPracticum: true);

  // TI 1C (Page 29)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TI 1C (Halaman 29)");
  buffer.writeln("      // ==========================================");
  add(id: 'TI1C-1', prodi: 'TI', className: 'TI 1C', day: 'Senin', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Konsep Teknologi Informasi', lecturerName: 'Huzaeni, S.ST., M.IT', roomCode: 'TIK.313');
  add(id: 'TI1C-2', prodi: 'TI', className: 'TI 1C', day: 'Senin', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Matematika Diskrit', lecturerName: 'Erika Fahmi Br Ginting, S. Kom., M,Kom', roomCode: 'TIK.313');
  add(id: 'TI1C-3', prodi: 'TI', className: 'TI 1C', day: 'Selasa', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Logika dan Algoritma', lecturerName: 'Hendrawaty, ST., MT', roomCode: 'TIK.301');
  add(id: 'TI1C-4', prodi: 'TI', className: 'TI 1C', day: 'Rabu', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktikum Konsep Pemrograman', lecturerName: 'Muhammad Arhami, S.Si., M.Kom', roomCode: 'TIK.202', isPracticum: true);
  add(id: 'TI1C-5', prodi: 'TI', className: 'TI 1C', day: 'Rabu', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Konsep Basis Data', lecturerName: 'Mahdi, ST., M.Cs', roomCode: 'TIK.101', isPracticum: true);
  add(id: 'TI1C-6', prodi: 'TI', className: 'TI 1C', day: 'Kamis', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Konsep Pemrograman', lecturerName: 'Arwin Putra, M.Kom', roomCode: 'TIK.302');
  add(id: 'TI1C-7', prodi: 'TI', className: 'TI 1C', day: 'Jumat', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Konsep Basis Data', lecturerName: 'Mahdi, ST., M.Cs', roomCode: 'TIK.307');
  add(id: 'TI1C-8', prodi: 'TI', className: 'TI 1C', day: 'Jumat', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'English for Listening', lecturerName: 'Rizqina Barophon, S.Pd., M.Pd.', roomCode: 'TIK.307');
  add(id: 'TI1C-9', prodi: 'TI', className: 'TI 1C', day: 'Jumat', startSession: 8, endSession: 9, startTime: '14:20', endTime: '16:00', courseName: 'Agama', lecturerName: 'Taufiqul Hadi, Lc, MA', roomCode: 'TIK.313');

  // TI 1D (Page 30)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TI 1D (Halaman 30)");
  buffer.writeln("      // ==========================================");
  add(id: 'TI1D-1', prodi: 'TI', className: 'TI 1D', day: 'Senin', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Logika dan Algoritma', lecturerName: 'Husna Gemasih, S.Inf., M.Cs', roomCode: 'TIK.302');
  add(id: 'TI1D-2', prodi: 'TI', className: 'TI 1D', day: 'Senin', startSession: 4, endSession: 5, startTime: '10:20', endTime: '12:00', courseName: 'Pengantar Teknik Informatika dan Orkom', lecturerName: 'Zulfan Khairil S. ST., M.Eng.', roomCode: 'TIK.315');
  add(id: 'TI1D-3', prodi: 'TI', className: 'TI 1D', day: 'Senin', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Konsep Pemrograman', lecturerName: 'Muhammad Arhami, S.Si., M.Kom', roomCode: 'TIK.111', isPracticum: true);
  add(id: 'TI1D-4', prodi: 'TI', className: 'TI 1D', day: 'Selasa', startSession: 4, endSession: 5, startTime: '10:20', endTime: '12:00', courseName: 'Konsep Teknologi Informasi', lecturerName: 'Radhiyatammardhiyah, SST., M.Sc.', roomCode: 'TIK.307');
  add(id: 'TI1D-5', prodi: 'TI', className: 'TI 1D', day: 'Selasa', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Konsep Basis Data', lecturerName: 'Mahdi, ST., M.Cs', roomCode: 'TIK.101', isPracticum: true);
  add(id: 'TI1D-6', prodi: 'TI', className: 'TI 1D', day: 'Rabu', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'English for Listening', lecturerName: 'Rizqina Barophon, S.Pd., M.Pd.', roomCode: 'TIK.305');
  add(id: 'TI1D-7', prodi: 'TI', className: 'TI 1D', day: 'Rabu', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Matematika Diskrit', lecturerName: 'Husna Gemasih, S.Inf., M.Cs', roomCode: 'TIK.311');
  add(id: 'TI1D-8', prodi: 'TI', className: 'TI 1D', day: 'Kamis', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Konsep Pemrograman', lecturerName: 'Hendrawaty, ST., MT', roomCode: 'TIK.212');
  add(id: 'TI1D-9', prodi: 'TI', className: 'TI 1D', day: 'Jumat', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Agama', lecturerName: 'Taufiqul Hadi, Lc, MA', roomCode: 'TIK.304');
  add(id: 'TI1D-10', prodi: 'TI', className: 'TI 1D', day: 'Jumat', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Konsep Basis Data', lecturerName: 'Mahdi, ST., M.Cs', roomCode: 'TIK.304');

  // TI 1E (Page 31)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TI 1E (Halaman 31)");
  buffer.writeln("      // ==========================================");
  add(id: 'TI1E-1', prodi: 'TI', className: 'TI 1E', day: 'Senin', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Konsep Basis Data', lecturerName: 'Huzaeni, S.ST., M.IT', roomCode: 'TIK.302');
  add(id: 'TI1E-2', prodi: 'TI', className: 'TI 1E', day: 'Senin', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Konsep Pemrograman', lecturerName: 'Hendrawaty, ST., MT', roomCode: 'TIK.302');
  add(id: 'TI1E-3', prodi: 'TI', className: 'TI 1E', day: 'Selasa', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Logika dan Algoritma', lecturerName: 'Suci Andriani, M.Kom.', roomCode: 'TIK.312');
  add(id: 'TI1E-4', prodi: 'TI', className: 'TI 1E', day: 'Selasa', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Matematika Diskrit', lecturerName: 'Cut Dwita Rahma, S.T., M.T.', roomCode: 'TIK.312');
  add(id: 'TI1E-5', prodi: 'TI', className: 'TI 1E', day: 'Selasa', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'English for Listening', lecturerName: 'Rizqina Barophon, S.Pd., M.Pd.', roomCode: 'TIK.314');
  add(id: 'TI1E-6', prodi: 'TI', className: 'TI 1E', day: 'Rabu', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Konsep Teknologi Informasi', lecturerName: 'Huzaeni, S.ST., M.IT', roomCode: 'TIK.308');
  add(id: 'TI1E-7', prodi: 'TI', className: 'TI 1E', day: 'Kamis', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Pengantar Teknik Informatika dan Orkom', lecturerName: 'Zulfan Khairil S. ST., M.Eng.', roomCode: 'TIK.311');
  add(id: 'TI1E-8', prodi: 'TI', className: 'TI 1E', day: 'Kamis', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Konsep Basis Data', lecturerName: 'Salahuddin, ST., M.Cs.', roomCode: 'TIK.104', isPracticum: true);
  add(id: 'TI1E-9', prodi: 'TI', className: 'TI 1E', day: 'Jumat', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktikum Konsep Pemrograman', lecturerName: 'Muhammad Arhami, S.Si., M.Kom', roomCode: 'TIK.111', isPracticum: true);
  add(id: 'TI1E-10', prodi: 'TI', className: 'TI 1E', day: 'Jumat', startSession: 6, endSession: 7, startTime: '12:00', endTime: '14:20', courseName: 'Agama', lecturerName: 'Taufiqul Hadi, Lc, MA', roomCode: 'TIK.302');

  // TI 2A (Page 32)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TI 2A (Halaman 32)");
  buffer.writeln("      // ==========================================");
  add(id: 'TI2A-1', prodi: 'TI', className: 'TI 2A', day: 'Senin', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktikum Administrasi Basis Data', lecturerName: 'Dr.Rahmad Hidayat, S.Kom., M.Cs', roomCode: 'TIK.101', isPracticum: true);
  add(id: 'TI2A-2', prodi: 'TI', className: 'TI 2A', day: 'Senin', startSession: 6, endSession: 7, startTime: '12:00', endTime: '14:20', courseName: 'Rekayasa Perangkat Lunak', lecturerName: 'Huzaeni, S.ST., M.IT', roomCode: 'TIK.212');
  add(id: 'TI2A-3', prodi: 'TI', className: 'TI 2A', day: 'Selasa', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktikum Pemrograman Berorientasi Objek', lecturerName: 'M.Reza Zulman, SST., M.Sc.', roomCode: 'TIK.103', isPracticum: true);
  add(id: 'TI2A-4', prodi: 'TI', className: 'TI 2A', day: 'Selasa', startSession: 6, endSession: 7, startTime: '12:00', endTime: '14:20', courseName: 'Konsep Jaringan Komputer', lecturerName: 'Azhar, ST., MT', roomCode: 'TIK.213');
  add(id: 'TI2A-5', prodi: 'TI', className: 'TI 2A', day: 'Selasa', startSession: 8, endSession: 9, startTime: '14:20', endTime: '16:00', courseName: 'Pengolahan Citra Digital (OBE)', lecturerName: 'Zulfan Khairil S. ST., M.Eng.', roomCode: 'TIK.307');
  add(id: 'TI2A-6', prodi: 'TI', className: 'TI 2A', day: 'Rabu', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktikum Konsep Jaringan Komputer', lecturerName: 'Azhar, ST., MT', roomCode: 'TIK.104', isPracticum: true);
  add(id: 'TI2A-7', prodi: 'TI', className: 'TI 2A', day: 'Rabu', startSession: 6, endSession: 7, startTime: '12:00', endTime: '14:20', courseName: 'Pemrograman Berorientasi Objek', lecturerName: 'Ahmad Afif, M. Kom.', roomCode: 'TIK.313');
  add(id: 'TI2A-8', prodi: 'TI', className: 'TI 2A', day: 'Kamis', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Workshop Web Enterprise (MVC, Framework)', lecturerName: 'Dr.Rahmad Hidayat, S.Kom., M.Cs', roomCode: 'TIK.202', isPracticum: true);
  add(id: 'TI2A-9', prodi: 'TI', className: 'TI 2A', day: 'Kamis', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'English for Academic Writing', lecturerName: 'Rizqina Barophon, S.Pd., M.Pd.', roomCode: 'TIK.311');
  add(id: 'TI2A-10', prodi: 'TI', className: 'TI 2A', day: 'Kamis', startSession: 7, endSession: 8, startTime: '13:30', endTime: '15:10', courseName: 'Aljabar Linier', lecturerName: 'M. Arif Nugraha, S.T., M.T.', roomCode: 'TIK.309');
  add(id: 'TI2A-11', prodi: 'TI', className: 'TI 2A', day: 'Jumat', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktikum Pengolahan Citra Digital (OBE)', lecturerName: 'Mustainul Abdi, SST., M.Kom.', roomCode: 'TIK.102', isPracticum: true);

  // TI 2B (Page 33)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TI 2B (Halaman 33)");
  buffer.writeln("      // ==========================================");
  add(id: 'TI2B-1', prodi: 'TI', className: 'TI 2B', day: 'Senin', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktikum Konsep Jaringan Komputer', lecturerName: 'Azhar, ST., MT', roomCode: 'TIK.103', isPracticum: true);
  add(id: 'TI2B-2', prodi: 'TI', className: 'TI 2B', day: 'Senin', startSession: 6, endSession: 7, startTime: '12:00', endTime: '14:20', courseName: 'Pemrograman Berorientasi Objek', lecturerName: 'Suci Andriani, M.Kom.', roomCode: 'TIK.316');
  add(id: 'TI2B-3', prodi: 'TI', className: 'TI 2B', day: 'Selasa', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktikum Pengolahan Citra Digital (OBE)', lecturerName: 'Mutiara S. Simanjuntak, S.Kom., M. Kom', roomCode: 'TIK.106', isPracticum: true);
  add(id: 'TI2B-4', prodi: 'TI', className: 'TI 2B', day: 'Selasa', startSession: 6, endSession: 7, startTime: '12:00', endTime: '14:20', courseName: 'Rekayasa Perangkat Lunak', lecturerName: 'M.Reza Zulman, SST., M.Sc.', roomCode: 'TIK.302');
  add(id: 'TI2B-5', prodi: 'TI', className: 'TI 2B', day: 'Selasa', startSession: 9, endSession: 10, startTime: '15:10', endTime: '17:10', courseName: 'Konsep Jaringan Komputer', lecturerName: 'Azhar, ST., MT', roomCode: 'TIK.213');
  add(id: 'TI2B-6', prodi: 'TI', className: 'TI 2B', day: 'Rabu', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Pengolahan Citra Digital (OBE)', lecturerName: 'Zulfan Khairil S. ST., M.Eng.', roomCode: 'TIK.309');
  add(id: 'TI2B-7', prodi: 'TI', className: 'TI 2B', day: 'Rabu', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Aljabar Linier', lecturerName: 'Erika Fahmi Br Ginting, S. Kom., M,Kom', roomCode: 'TIK.309');
  add(id: 'TI2B-8', prodi: 'TI', className: 'TI 2B', day: 'Rabu', startSession: 5, endSession: 8, startTime: '11:10', endTime: '15:10', courseName: 'Workshop Web Enterprise (MVC, Framework)', lecturerName: 'Arwin Putra, M.Kom', roomCode: 'TIK.105', isPracticum: true);
  add(id: 'TI2B-9', prodi: 'TI', className: 'TI 2B', day: 'Kamis', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'English for Academic Writing', lecturerName: 'Rizqina Barophon, S.Pd., M.Pd.', roomCode: 'TIK.312');
  add(id: 'TI2B-10', prodi: 'TI', className: 'TI 2B', day: 'Kamis', startSession: 3, endSession: 7, startTime: '09:10', endTime: '14:20', courseName: 'Praktikum Pemrograman Berorientasi Objek', lecturerName: 'Suci Andriani, M.Kom.', roomCode: 'TIK.105', isPracticum: true);
  add(id: 'TI2B-11', prodi: 'TI', className: 'TI 2B', day: 'Jumat', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktikum Administrasi Basis Data', lecturerName: 'Zulfan Khairil S. ST., M.Eng.', roomCode: 'TIK.305', isPracticum: true);

  // TI 2C (Page 34)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TI 2C (Halaman 34)");
  buffer.writeln("      // ==========================================");
  add(id: 'TI2C-1', prodi: 'TI', className: 'TI 2C', day: 'Senin', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktikum Pemrograman Berorientasi Objek', lecturerName: 'Suci Andriani, M.Kom.', roomCode: 'TIK.102', isPracticum: true);
  add(id: 'TI2C-2', prodi: 'TI', className: 'TI 2C', day: 'Senin', startSession: 6, endSession: 7, startTime: '12:00', endTime: '14:20', courseName: 'Pengolahan Citra Digital (OBE)', lecturerName: 'Mulyadi, ST., M.Eng.', roomCode: 'TIK.303');
  add(id: 'TI2C-3', prodi: 'TI', className: 'TI 2C', day: 'Selasa', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'English for Academic Writing', lecturerName: 'Rizqina Barophon, S.Pd., M.Pd.', roomCode: 'TIK.311');
  add(id: 'TI2C-4', prodi: 'TI', className: 'TI 2C', day: 'Selasa', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Administrasi Basis Data', lecturerName: 'Dr.Rahmad Hidayat, S.Kom., M.Cs', roomCode: 'TIK.103', isPracticum: true);
  add(id: 'TI2C-5', prodi: 'TI', className: 'TI 2C', day: 'Rabu', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Workshop Web Enterprise (MVC, Framework)', lecturerName: 'Arwin Putra, M.Kom', roomCode: 'TIK.106', isPracticum: true);
  add(id: 'TI2C-6', prodi: 'TI', className: 'TI 2C', day: 'Rabu', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Aljabar Linier', lecturerName: 'Erika Fahmi Br Ginting, S. Kom., M,Kom', roomCode: 'TIK.309');
  add(id: 'TI2C-7', prodi: 'TI', className: 'TI 2C', day: 'Rabu', startSession: 7, endSession: 8, startTime: '13:30', endTime: '15:10', courseName: 'Rekayasa Perangkat Lunak', lecturerName: 'M.Reza Zulman, SST., M.Sc.', roomCode: 'TIK.302');
  add(id: 'TI2C-8', prodi: 'TI', className: 'TI 2C', day: 'Kamis', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Konsep Jaringan Komputer', lecturerName: 'M. Khadafi, ST., M.T', roomCode: 'TIK.213');
  add(id: 'TI2C-9', prodi: 'TI', className: 'TI 2C', day: 'Kamis', startSession: 3, endSession: 7, startTime: '09:10', endTime: '14:20', courseName: 'Praktikum Pengolahan Citra Digital (OBE)', lecturerName: 'Mutiara S. Simanjuntak, S.Kom., M. Kom', roomCode: 'TIK.103', isPracticum: true);
  add(id: 'TI2C-10', prodi: 'TI', className: 'TI 2C', day: 'Jumat', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktikum Konsep Jaringan Komputer', lecturerName: 'Azhar, ST., MT', roomCode: 'TIK.104', isPracticum: true);
  add(id: 'TI2C-11', prodi: 'TI', className: 'TI 2C', day: 'Jumat', startSession: 8, endSession: 9, startTime: '14:20', endTime: '16:00', courseName: 'Pemrograman Berorientasi Objek', lecturerName: 'Ahmad Afif, M. Kom.', roomCode: 'TIK.316');

  // TI 2D (Page 35)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TI 2D (Halaman 35)");
  buffer.writeln("      // ==========================================");
  add(id: 'TI2D-1', prodi: 'TI', className: 'TI 2D', day: 'Senin', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Pengolahan Citra Digital (OBE)', lecturerName: 'Zulfan Khairil S. ST., M.Eng.', roomCode: 'TIK.303');
  add(id: 'TI2D-2', prodi: 'TI', className: 'TI 2D', day: 'Senin', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'English for Academic Writing', lecturerName: 'Nurul Kamaliah, S.Pd, M.Pd', roomCode: 'TIK.311');
  add(id: 'TI2D-3', prodi: 'TI', className: 'TI 2D', day: 'Senin', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Rekayasa Perangkat Lunak', lecturerName: 'Mutiara S. Simanjuntak, S.Kom., M. Kom', roomCode: 'TIK.213');
  add(id: 'TI2D-4', prodi: 'TI', className: 'TI 2D', day: 'Senin', startSession: 8, endSession: 11, startTime: '14:20', endTime: '18:00', courseName: 'Workshop Web Enterprise (MVC, Framework)', lecturerName: 'Husna Gemasih, S.Inf., M.Cs', roomCode: 'TIK.105', isPracticum: true);
  add(id: 'TI2D-5', prodi: 'TI', className: 'TI 2D', day: 'Selasa', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Pemrograman Berorientasi Objek', lecturerName: 'Radhiyatammardhiyah, SST., M.Sc.', roomCode: 'TIK.316');
  add(id: 'TI2D-6', prodi: 'TI', className: 'TI 2D', day: 'Selasa', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Konsep Jaringan Komputer', lecturerName: 'M. Khadafi, ST., M.T', roomCode: 'TIK.209');
  add(id: 'TI2D-7', prodi: 'TI', className: 'TI 2D', day: 'Selasa', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Pemrograman Berorientasi Objek', lecturerName: 'Suci Andriani, M.Kom.', roomCode: 'TIK.105', isPracticum: true);
  add(id: 'TI2D-8', prodi: 'TI', className: 'TI 2D', day: 'Rabu', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Pengolahan Citra Digital (OBE)', lecturerName: 'Mutiara S. Simanjuntak, S.Kom., M. Kom', roomCode: 'TIK.103', isPracticum: true);
  add(id: 'TI2D-9', prodi: 'TI', className: 'TI 2D', day: 'Kamis', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Konsep Jaringan Komputer', lecturerName: 'Azhar, ST., MT', roomCode: 'TIK.102', isPracticum: true);
  add(id: 'TI2D-10', prodi: 'TI', className: 'TI 2D', day: 'Jumat', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Aljabar Linier', lecturerName: 'Erika Fahmi Br Ginting, S. Kom., M,Kom', roomCode: 'TIK.309');
  add(id: 'TI2D-11', prodi: 'TI', className: 'TI 2D', day: 'Jumat', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Administrasi Basis Data', lecturerName: 'Dr.Rahmad Hidayat, S.Kom., M.Cs', roomCode: 'TIK.101', isPracticum: true);

  // TI 2E (Page 36)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TI 2E (Halaman 36)");
  buffer.writeln("      // ==========================================");
  add(id: 'TI2E-1', prodi: 'TI', className: 'TI 2E', day: 'Senin', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Aljabar Linier', lecturerName: 'Erika Fahmi Br Ginting, S. Kom., M,Kom', roomCode: 'TIK.308');
  add(id: 'TI2E-2', prodi: 'TI', className: 'TI 2E', day: 'Senin', startSession: 3, endSession: 7, startTime: '09:10', endTime: '14:20', courseName: 'Praktikum Pemrograman Berorientasi Objek', lecturerName: 'M.Reza Zulman, SST., M.Sc.', roomCode: 'TIK.105', isPracticum: true);
  add(id: 'TI2E-3', prodi: 'TI', className: 'TI 2E', day: 'Selasa', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktikum Konsep Jaringan Komputer', lecturerName: 'Azhar, ST., MT', roomCode: 'TIK.315', isPracticum: true);
  add(id: 'TI2E-4', prodi: 'TI', className: 'TI 2E', day: 'Selasa', startSession: 6, endSession: 7, startTime: '12:00', endTime: '14:20', courseName: 'Pengolahan Citra Digital (OBE)', lecturerName: 'Ahmad Afif, M. Kom.', roomCode: 'TIK.307');
  add(id: 'TI2E-5', prodi: 'TI', className: 'TI 2E', day: 'Selasa', startSession: 8, endSession: 9, startTime: '14:20', endTime: '16:00', courseName: 'Konsep Jaringan Komputer', lecturerName: 'M. Khadafi, ST., M.T', roomCode: 'TIK.214');
  add(id: 'TI2E-6', prodi: 'TI', className: 'TI 2E', day: 'Rabu', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktikum Administrasi Basis Data', lecturerName: 'Dr.Rahmad Hidayat, S.Kom., M.Cs', roomCode: 'TIK.102', isPracticum: true);
  add(id: 'TI2E-7', prodi: 'TI', className: 'TI 2E', day: 'Rabu', startSession: 8, endSession: 9, startTime: '14:20', endTime: '16:00', courseName: 'Rekayasa Perangkat Lunak', lecturerName: 'Azhar, ST., MT', roomCode: 'TIK.212');
  add(id: 'TI2E-8', prodi: 'TI', className: 'TI 2E', day: 'Kamis', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Workshop Web Enterprise (MVC, Framework)', lecturerName: 'Husna Gemasih, S.Inf., M.Cs', roomCode: 'TIK.106', isPracticum: true);
  add(id: 'TI2E-9', prodi: 'TI', className: 'TI 2E', day: 'Kamis', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Pemrograman Berorientasi Objek', lecturerName: 'M.Reza Zulman, SST., M.Sc.', roomCode: 'TIK.316');
  add(id: 'TI2E-10', prodi: 'TI', className: 'TI 2E', day: 'Kamis', startSession: 7, endSession: 8, startTime: '13:30', endTime: '15:10', courseName: 'English for Academic Writing', lecturerName: 'Nurul Kamaliah, S.Pd, M.Pd', roomCode: 'TIK.311');
  add(id: 'TI2E-11', prodi: 'TI', className: 'TI 2E', day: 'Jumat', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktikum Pengolahan Citra Digital (OBE)', lecturerName: 'Mutiara S. Simanjuntak, S.Kom., M. Kom', roomCode: 'TIK.106', isPracticum: true);

  // TI 3A (Page 37)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TI 3A (Halaman 37)");
  buffer.writeln("      // ==========================================");
  add(id: 'TI3A-1', prodi: 'TI', className: 'TI 3A', day: 'Senin', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Bahasa Indonesia', lecturerName: 'Dra. Jamilah, M.Pd', roomCode: 'TIK.211');
  add(id: 'TI3A-2', prodi: 'TI', className: 'TI 3A', day: 'Senin', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Keamanan Jaringan Komputer', lecturerName: 'Radhiyatammardhiyah, SST., M.Sc.', roomCode: 'TIK.315', isPracticum: true);
  add(id: 'TI3A-3', prodi: 'TI', className: 'TI 3A', day: 'Selasa', startSession: 1, endSession: 3, startTime: '07:30', endTime: '10:00', courseName: 'Praktikum Pengolahan Citra Digital', lecturerName: 'Ahmad Afif, M. Kom.', roomCode: 'TIK.102', isPracticum: true);
  add(id: 'TI3A-4', prodi: 'TI', className: 'TI 3A', day: 'Selasa', startSession: 6, endSession: 7, startTime: '12:00', endTime: '14:20', courseName: 'Keamanan Jaringan Komputer', lecturerName: 'M. Khadafi, ST., M.T', roomCode: 'TIK.214');
  add(id: 'TI3A-5', prodi: 'TI', className: 'TI 3A', day: 'Rabu', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Pengolahan Citra Digital', lecturerName: 'Mutiara S. Simanjuntak, S.Kom., M. Kom', roomCode: 'TIK.304');
  add(id: 'TI3A-6', prodi: 'TI', className: 'TI 3A', day: 'Rabu', startSession: 4, endSession: 6, startTime: '10:20', endTime: '12:50', courseName: 'Workshop Pengembangan Perangkat Lunak', lecturerName: 'Salahuddin, ST., M.Cs.', roomCode: 'TIK.103', isPracticum: true);
  add(id: 'TI3A-7', prodi: 'TI', className: 'TI 3A', day: 'Rabu', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Pemrograman Mobile', lecturerName: 'Muhammad Rizka, SST., M. Kom.', roomCode: 'TIK.106', isPracticum: true);
  add(id: 'TI3A-8', prodi: 'TI', className: 'TI 3A', day: 'Kamis', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Pemrograman Mobile', lecturerName: 'Arwin Putra, M.Kom', roomCode: 'TIK.301');
  add(id: 'TI3A-9', prodi: 'TI', className: 'TI 3A', day: 'Kamis', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Sistem Pengambilan Keputusan Dan SIM-SIG', lecturerName: 'Mahdi, ST., M.Cs', roomCode: 'TIK.315');
  add(id: 'TI3A-10', prodi: 'TI', className: 'TI 3A', day: 'Jumat', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Statistik dan Probabilitas', lecturerName: 'Syukri, ST, MT', roomCode: 'TIK.213');
  add(id: 'TI3A-11', prodi: 'TI', className: 'TI 3A', day: 'Jumat', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Rancangan Analisa Algoritma', lecturerName: 'Husna Gemasih, S.Inf., M.Cs', roomCode: 'TIK.303');

  // TI 3B (Page 38)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TI 3B (Halaman 38)");
  buffer.writeln("      // ==========================================");
  add(id: 'TI3B-1', prodi: 'TI', className: 'TI 3B', day: 'Senin', startSession: 1, endSession: 3, startTime: '07:30', endTime: '10:00', courseName: 'Workshop Pengembangan Perangkat Lunak', lecturerName: 'Radhiyatammardhiyah, SST., M.Sc.', roomCode: 'TIK.106', isPracticum: true);
  add(id: 'TI3B-2', prodi: 'TI', className: 'TI 3B', day: 'Senin', startSession: 4, endSession: 5, startTime: '10:20', endTime: '12:00', courseName: 'Keamanan Jaringan Komputer', lecturerName: 'M. Khadafi, ST., M.T', roomCode: 'TIK.214');
  add(id: 'TI3B-3', prodi: 'TI', className: 'TI 3B', day: 'Senin', startSession: 6, endSession: 7, startTime: '12:00', endTime: '14:20', courseName: 'Pemrograman Mobile', lecturerName: 'Muhammad Rizka, SST., M. Kom.', roomCode: 'TIK.214');
  add(id: 'TI3B-4', prodi: 'TI', className: 'TI 3B', day: 'Selasa', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Pengolahan Citra Digital', lecturerName: 'Dr.Rahmad Hidayat, S.Kom., M.Cs', roomCode: 'TIK.214');
  add(id: 'TI3B-5', prodi: 'TI', className: 'TI 3B', day: 'Selasa', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Bahasa Indonesia', lecturerName: 'Dra. Jamilah, M.Pd', roomCode: 'TIK.214');
  add(id: 'TI3B-6', prodi: 'TI', className: 'TI 3B', day: 'Selasa', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Sistem Pengambilan Keputusan Dan SIM-SIG', lecturerName: 'Mahdi, ST., M.Cs', roomCode: 'TIK.316');
  add(id: 'TI3B-7', prodi: 'TI', className: 'TI 3B', day: 'Rabu', startSession: 1, endSession: 3, startTime: '07:30', endTime: '10:00', courseName: 'Praktikum Keamanan Jaringan Komputer', lecturerName: 'Radhiyatammardhiyah, SST., M.Sc.', roomCode: 'TIK.109', isPracticum: true);
  add(id: 'TI3B-8', prodi: 'TI', className: 'TI 3B', day: 'Rabu', startSession: 7, endSession: 9, startTime: '13:30', endTime: '16:00', courseName: 'Praktikum Pengolahan Citra Digital', lecturerName: 'Dr.Rahmad Hidayat, S.Kom., M.Cs', roomCode: 'TIK.102', isPracticum: true);
  add(id: 'TI3B-9', prodi: 'TI', className: 'TI 3B', day: 'Kamis', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Pengantar Teknik Informatika dan Orkom', lecturerName: 'Mulyadi, ST., M.Eng.', roomCode: 'TIK.315');
  add(id: 'TI3B-10', prodi: 'TI', className: 'TI 3B', day: 'Jumat', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Rancangan Analisa Algoritma', lecturerName: 'Husna Gemasih, S.Inf., M.Cs', roomCode: 'TIK.302');
  add(id: 'TI3B-11', prodi: 'TI', className: 'TI 3B', day: 'Jumat', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Statistik dan Probabilitas', lecturerName: 'Syukri, ST, MT', roomCode: 'TIK.213');
  add(id: 'TI3B-12', prodi: 'TI', className: 'TI 3B', day: 'Jumat', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Pemrograman Mobile', lecturerName: 'Muhammad Rizka, SST., M. Kom.', roomCode: 'TIK.213', isPracticum: true);

  // TI 3C (Page 39)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TI 3C (Halaman 39)");
  buffer.writeln("      // ==========================================");
  add(id: 'TI3C-1', prodi: 'TI', className: 'TI 3C', day: 'Senin', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Bahasa Indonesia', lecturerName: 'Dra. Jamilah, M.Pd', roomCode: 'TIK.211');
  add(id: 'TI3C-2', prodi: 'TI', className: 'TI 3C', day: 'Senin', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Pengantar Teknik Informatika dan Orkom', lecturerName: 'Mulyadi, ST., M.Eng.', roomCode: 'TIK.306');
  add(id: 'TI3C-3', prodi: 'TI', className: 'TI 3C', day: 'Senin', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Rancangan Analisa Algoritma', lecturerName: 'Muhammad Arhami, S.Si., M.Kom', roomCode: 'TIK.305');
  add(id: 'TI3C-4', prodi: 'TI', className: 'TI 3C', day: 'Selasa', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Sistem Pengambilan Keputusan Dan SIM-SIG', lecturerName: 'Salahuddin, ST., M.Cs.', roomCode: 'TIK.309');
  add(id: 'TI3C-5', prodi: 'TI', className: 'TI 3C', day: 'Selasa', startSession: 6, endSession: 8, startTime: '12:00', endTime: '15:10', courseName: 'Praktikum Pengolahan Citra Digital', lecturerName: 'Mustainul Abdi, SST., M.Kom.', roomCode: 'TIK.104', isPracticum: true);
  add(id: 'TI3C-6', prodi: 'TI', className: 'TI 3C', day: 'Rabu', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Pemrograman Mobile', lecturerName: 'Muhammad Rizka, SST., M. Kom.', roomCode: 'TIK.214');
  add(id: 'TI3C-7', prodi: 'TI', className: 'TI 3C', day: 'Rabu', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Statistik dan Probabilitas', lecturerName: 'Dr. Ir. Rizal Syahyadi, ST, M.Eng.Sc', roomCode: 'TIK.212');
  add(id: 'TI3C-8', prodi: 'TI', className: 'TI 3C', day: 'Rabu', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Keamanan Jaringan Komputer', lecturerName: 'M. Khadafi, ST., M.T', roomCode: 'TIK.211');
  add(id: 'TI3C-9', prodi: 'TI', className: 'TI 3C', day: 'Kamis', startSession: 1, endSession: 3, startTime: '07:30', endTime: '10:00', courseName: 'Workshop Pengembangan Perangkat Lunak', lecturerName: 'Salahuddin, ST., M.Cs.', roomCode: 'TIK.101', isPracticum: true);
  add(id: 'TI3C-10', prodi: 'TI', className: 'TI 3C', day: 'Kamis', startSession: 4, endSession: 5, startTime: '10:20', endTime: '12:00', courseName: 'Pengolahan Citra Digital', lecturerName: 'Mustainul Abdi, SST., M.Kom.', roomCode: 'TIK.305');
  add(id: 'TI3C-11', prodi: 'TI', className: 'TI 3C', day: 'Kamis', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Pemrograman Mobile', lecturerName: 'Muhammad Rizka, SST., M. Kom.', roomCode: 'TIK.303', isPracticum: true);
  add(id: 'TI3C-12', prodi: 'TI', className: 'TI 3C', day: 'Jumat', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktikum Keamanan Jaringan Komputer', lecturerName: 'Radhiyatammardhiyah, SST., M.Sc.', roomCode: 'TIK.109', isPracticum: true);

  // TI 3D (Page 40)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TI 3D (Halaman 40)");
  buffer.writeln("      // ==========================================");
  add(id: 'TI3D-1', prodi: 'TI', className: 'TI 3D', day: 'Senin', startSession: 1, endSession: 5, startTime: '07:30', endTime: '12:00', courseName: 'Praktikum Pemrograman Mobile', lecturerName: 'Muhammad Rizka, SST., M. Kom.', roomCode: 'TIK.104', isPracticum: true);
  add(id: 'TI3D-2', prodi: 'TI', className: 'TI 3D', day: 'Senin', startSession: 7, endSession: 9, startTime: '13:30', endTime: '16:00', courseName: 'Praktikum Pengolahan Citra Digital', lecturerName: 'Mustainul Abdi, SST., M.Kom.', roomCode: 'TIK.101', isPracticum: true);
  add(id: 'TI3D-3', prodi: 'TI', className: 'TI 3D', day: 'Selasa', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Pemrograman Mobile', lecturerName: 'Muhammad Rizka, SST., M. Kom.', roomCode: 'TIK.305');
  add(id: 'TI3D-4', prodi: 'TI', className: 'TI 3D', day: 'Selasa', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Rancangan Analisa Algoritma', lecturerName: 'Husna Gemasih, S.Inf., M.Cs', roomCode: 'TIK.305');
  add(id: 'TI3D-5', prodi: 'TI', className: 'TI 3D', day: 'Selasa', startSession: 5, endSession: 7, startTime: '11:10', endTime: '14:20', courseName: 'Workshop Pengembangan Perangkat Lunak', lecturerName: 'Arsy Febrina Dewi, SST., M.T', roomCode: 'TIK.102', isPracticum: true);
  add(id: 'TI3D-6', prodi: 'TI', className: 'TI 3D', day: 'Rabu', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Statistik dan Probabilitas', lecturerName: 'Dr. Ir. Rizal Syahyadi, ST, M.Eng.Sc', roomCode: 'TIK.212');
  add(id: 'TI3D-7', prodi: 'TI', className: 'TI 3D', day: 'Rabu', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Bahasa Indonesia', lecturerName: 'Dra. Jamilah, M.Pd', roomCode: 'TIK.209');
  add(id: 'TI3D-8', prodi: 'TI', className: 'TI 3D', day: 'Kamis', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Pengolahan Citra Digital', lecturerName: 'Mustainul Abdi, SST., M.Kom.', roomCode: 'TIK.305');
  add(id: 'TI3D-9', prodi: 'TI', className: 'TI 3D', day: 'Kamis', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Keamanan Jaringan Komputer', lecturerName: 'M. Khadafi, ST., M.T', roomCode: 'TIK.214');
  add(id: 'TI3D-10', prodi: 'TI', className: 'TI 3D', day: 'Jumat', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Sistem Pengambilan Keputusan Dan SIM-SIG', lecturerName: 'Mahdi, ST., M.Cs', roomCode: 'TIK.316');
  add(id: 'TI3D-11', prodi: 'TI', className: 'TI 3D', day: 'Jumat', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Keamanan Jaringan Komputer', lecturerName: 'Radhiyatammardhiyah, SST., M.Sc.', roomCode: 'TIK.109', isPracticum: true);

  // TI 3E (Page 41)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TI 3E (Halaman 41)");
  buffer.writeln("      // ==========================================");
  add(id: 'TI3E-1', prodi: 'TI', className: 'TI 3E', day: 'Senin', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Keamanan Jaringan Komputer', lecturerName: 'M. Khadafi, ST., M.T', roomCode: 'TIK.214');
  add(id: 'TI3E-2', prodi: 'TI', className: 'TI 3E', day: 'Senin', startSession: 4, endSession: 5, startTime: '10:20', endTime: '12:00', courseName: 'Sistem Pengambilan Keputusan Dan SIM-SIG', lecturerName: 'Mahdi, ST., M.Cs', roomCode: 'TIK.308');
  add(id: 'TI3E-3', prodi: 'TI', className: 'TI 3E', day: 'Senin', startSession: 7, endSession: 8, startTime: '13:30', endTime: '15:10', courseName: 'Pemrograman Mobile', lecturerName: 'Arwin Putra, M.Kom', roomCode: 'TIK.305');
  add(id: 'TI3E-4', prodi: 'TI', className: 'TI 3E', day: 'Selasa', startSession: 4, endSession: 5, startTime: '10:20', endTime: '12:00', courseName: 'Pengolahan Citra Digital', lecturerName: 'Mustainul Abdi, SST., M.Kom.', roomCode: 'TIK.301');
  add(id: 'TI3E-5', prodi: 'TI', className: 'TI 3E', day: 'Selasa', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Pemrograman Mobile', lecturerName: 'Arwin Putra, M.Kom', roomCode: 'TIK.106', isPracticum: true);
  add(id: 'TI3E-6', prodi: 'TI', className: 'TI 3E', day: 'Rabu', startSession: 1, endSession: 3, startTime: '07:30', endTime: '10:00', courseName: 'Praktikum Pengolahan Citra Digital', lecturerName: 'Mustainul Abdi, SST., M.Kom.', roomCode: 'TIK.101', isPracticum: true);
  add(id: 'TI3E-7', prodi: 'TI', className: 'TI 3E', day: 'Rabu', startSession: 4, endSession: 8, startTime: '10:20', endTime: '15:10', courseName: 'Praktikum Keamanan Jaringan Komputer', lecturerName: 'Radhiyatammardhiyah, SST., M.Sc.', roomCode: 'TIK.307', isPracticum: true);
  add(id: 'TI3E-8', prodi: 'TI', className: 'TI 3E', day: 'Kamis', startSession: 1, endSession: 3, startTime: '07:30', endTime: '10:00', courseName: 'Workshop Pengembangan Perangkat Lunak', lecturerName: 'Ghiyalti Novilia, SST, MT', roomCode: 'TIK.102', isPracticum: true);
  add(id: 'TI3E-9', prodi: 'TI', className: 'TI 3E', day: 'Kamis', startSession: 4, endSession: 5, startTime: '10:20', endTime: '12:00', courseName: 'Rancangan Analisa Algoritma', lecturerName: 'Ghiyalti Novilia, SST, MT', roomCode: 'TIK.303');
  add(id: 'TI3E-10', prodi: 'TI', className: 'TI 3E', day: 'Kamis', startSession: 6, endSession: 7, startTime: '12:00', endTime: '14:20', courseName: 'Statistik dan Probabilitas', lecturerName: 'Muhammad A Rifai , SE AK, Msc', roomCode: 'TIK.213');
  add(id: 'TI3E-11', prodi: 'TI', className: 'TI 3E', day: 'Jumat', startSession: 3, endSession: 4, startTime: '09:10', endTime: '11:10', courseName: 'Bahasa Indonesia', lecturerName: 'Dra. Jamilah, M.Pd', roomCode: 'TIK.211');

  // ==========================================
  // PRODI TEKNIK REKAYASA PERANGKAT LUNAK (TRPL)
  // ==========================================

  // TRPL 1A (Page 42)
  buffer.writeln("      // ==========================================");
  buffer.writeln("      // TRPL 1A (Halaman 42)");
  buffer.writeln("      // ==========================================");
  add(id: 'TRPL1A-1', prodi: 'TRPL', className: 'TRPL 1A', day: 'Senin', startSession: 7, endSession: 8, startTime: '13:30', endTime: '15:10', courseName: 'Pendidikan Agama', lecturerName: 'Nazar Fadli, M.Ag., Ph.D.', roomCode: 'TIK.213');
  add(id: 'TRPL1A-2', prodi: 'TRPL', className: 'TRPL 1A', day: 'Selasa', startSession: 1, endSession: 3, startTime: '07:30', endTime: '10:00', courseName: 'Workshop Pemograman Dasar', lecturerName: 'Mustainul Abdi, SST., M.Kom.', roomCode: 'TIK.105', isPracticum: true);
  add(id: 'TRPL1A-3', prodi: 'TRPL', className: 'TRPL 1A', day: 'Selasa', startSession: 4, endSession: 5, startTime: '10:20', endTime: '12:00', courseName: 'Interaksi Manusia dan Komputer', lecturerName: 'Fachri Yanuar Rudi F, S.ST., M.T.', roomCode: 'TIK.213');
  add(id: 'TRPL1A-4', prodi: 'TRPL', className: 'TRPL 1A', day: 'Selasa', startSession: 7, endSession: 11, startTime: '13:30', endTime: '18:00', courseName: 'Praktikum Dasar Jaringan Komputer', lecturerName: 'Muhammad Davi, S.Kom., M.Cs.', roomCode: 'TIK.109', isPracticum: true);
  add(id: 'TRPL1A-5', prodi: 'TRPL', className: 'TRPL 1A', day: 'Rabu', startSession: 1, endSession: 3, startTime: '07:30', endTime: '10:00', courseName: 'Pengantar Rekayasa Perangkat Lunak', lecturerName: 'M.Reza Zulman, SST., M.Sc.', roomCode: 'TIK.105');
  add(id: 'TRPL1A-6', prodi: 'TRPL', className: 'TRPL 1A', day: 'Rabu', startSession: 5, endSession: 6, startTime: '11:10', endTime: '12:50', courseName: 'Pendidikan Pancasila', lecturerName: 'Hosea Sitepu, M.Pd', roomCode: 'TIK.316');
  add(id: 'TRPL1A-7', prodi: 'TRPL', className: 'TRPL 1A', day: 'Rabu', startSession: 9, endSession: 10, startTime: '15:10', endTime: '17:10', courseName: 'Analisis dan Spesifikasi Kebutuhan Perangkat Lunak', lecturerName: 'Safriadi ST, M.Kom.', roomCode: 'TIK.310');
  add(id: 'TRPL1A-8', prodi: 'TRPL', className: 'TRPL 1A', day: 'Kamis', startSession: 1, endSession: 2, startTime: '07:30', endTime: '09:10', courseName: 'Konsep Dasar Jaringan Komputer', lecturerName: 'Muhammad Davi, S.Kom., M.Cs.', roomCode: 'TIK.309');
  add(id: 'TRPL1A-9', prodi: 'TRPL', className: 'TRPL 1A', day: 'Kamis', startSession: 5, endSession: 7, startTime: '11:10', endTime: '14:20', courseName: 'Bahasa Inggris Umum', lecturerName: 'Mahlil, S.Pd., M.A', roomCode: 'TIK.313');
  add(id: 'TRPL1A-10', prodi: 'TRPL', className: 'TRPL 1A', day: 'Kamis', startSession: 8, endSession: 10, startTime: '14:20', endTime: '17:10', courseName: 'Basis Data', lecturerName: 'Guntur Syahputra, S. Kom., M. Kom.', roomCode: 'TIK.105');

  buffer.writeln("    ];");
  buffer.writeln("  }");
  buffer.writeln("}");

  File('lib/features/peminjaman_ruang/data/datasources/roster_data_source.dart')
      .writeAsStringSync(buffer.toString());
  print('Successfully wrote roster_data_source.dart!');
}
