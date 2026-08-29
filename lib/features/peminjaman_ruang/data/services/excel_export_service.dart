import 'dart:convert';
import 'package:excel/excel.dart';
import 'package:flutter/foundation.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';
import '../../domain/models/booking_model.dart';
import '../../domain/models/room_model.dart';

// ignore: avoid_web_libraries_in_flutter, deprecated_member_use
import 'dart:html' as html;

class ExcelExportService {
  /// Generate file Excel .xlsx komprehensif berisi data transaksi peminjaman & statistik ruang
  static Future<Uint8List> generateBookingReportExcel({
    required List<BookingModel> bookings,
    required List<RoomModel> rooms,
  }) async {
    final excel = Excel.createExcel();
    const sheetName = 'Laporan Peminjaman';
    final Sheet sheet = excel[sheetName];
    excel.setDefaultSheet(sheetName);
    if (excel.sheets.containsKey('Sheet1')) {
      excel.delete('Sheet1');
    }

    // ── STYLES ──────────────────────────────────────────────────
    final headerCellStyle = CellStyle(
      bold: true,
      fontColorHex: ExcelColor.white,
      backgroundColorHex: ExcelColor.fromHexString('#5B21B6'), // Purple Dark
      horizontalAlign: HorizontalAlign.Center,
      verticalAlign: VerticalAlign.Center,
    );

    // ── HEADER LAPORAN ──────────────────────────────────────────
    sheet.appendRow([
      TextCellValue('LAPORAN MANAJEMEN PEMINJAMAN LABORATORIUM & RUANG KELAS'),
    ]);
    sheet.appendRow([
      TextCellValue('JURUSAN TEKNOLOGI INFORMASI DAN KOMPUTER - POLITEKNIK NEGERI LHOKSEUMAWE'),
    ]);
    sheet.appendRow([
      TextCellValue('Periode: Semester Gasal TA 2026/2027 | Dicetak pada: ${DateFormat('dd MMMM yyyy HH:mm', 'id_ID').format(DateTime.now())} WIB'),
    ]);
    sheet.appendRow([TextCellValue('')]); // Spacer

    // ── TABEL DATA TRANSAKSI ────────────────────────────────────
    final headers = [
      'No',
      'Kode Booking',
      'Tanggal Pinjam',
      'Hari',
      'Sesi Jam',
      'Kode Ruang',
      'Nama Ruangan / Lab',
      'Nama Peminjam',
      'NIM / NIP',
      'No. WhatsApp',
      'Peran',
      'Keperluan',
      'Dosen Pembimbing',
      'Status Peminjaman',
      'Verifikator',
      'Status AC Mati',
      'Status Kebersihan',
      'Bukti Video Checkout',
      'Waktu Selesai',
      'Catatan Review',
    ];

    sheet.appendRow(headers.map((h) => TextCellValue(h)).toList());

    // Beri styling untuk row header
    const headerRowIndex = 4;
    for (var col = 0; col < headers.length; col++) {
      final cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: headerRowIndex));
      cell.cellStyle = headerCellStyle;
    }

    // ── ISI DATA PEMINJAMAN ─────────────────────────────────────
    final dateFormat = DateFormat('dd/MM/yyyy');
    final timeFormat = DateFormat('dd/MM/yyyy HH:mm');

    for (var i = 0; i < bookings.length; i++) {
      final b = bookings[i];
      final rowData = [
        IntCellValue(i + 1),
        TextCellValue(b.bookingCode),
        TextCellValue(dateFormat.format(b.bookingDate)),
        TextCellValue(b.day),
        TextCellValue(b.sessionRangeLabel),
        TextCellValue(b.roomCode),
        TextCellValue(b.roomName),
        TextCellValue(b.userName),
        TextCellValue(b.userNimNip),
        TextCellValue(b.userPhone),
        TextCellValue(b.userRole),
        TextCellValue(b.purpose),
        TextCellValue(b.supervisorLecturer),
        TextCellValue(b.statusLabel),
        TextCellValue(b.approvedBy ?? '-'),
        TextCellValue(b.checkoutAcOffStatus ? 'SUDAH MATI (OFF)' : (b.isCheckoutDone ? 'BELUM' : '-')),
        TextCellValue(b.checkoutCleanlinessStatus ? 'BERSIH' : (b.isCheckoutDone ? 'BELUM' : '-')),
        TextCellValue(b.checkoutVideoName != null || b.checkoutVideoUrl != null
            ? 'TERSEDIA (${b.checkoutVideoName ?? "Video MP4"})'
            : 'TIDAK ADA'),
        TextCellValue(b.checkoutSubmittedAt != null ? timeFormat.format(b.checkoutSubmittedAt!) : '-'),
        TextCellValue(b.laboranReviewNotes ?? b.checkoutNotes ?? '-'),
      ];

      sheet.appendRow(rowData);
    }

    // ── SHEET 2: REKAP STATISTIK PENGGUNAAN RUANG ──────────────
    const statsSheetName = 'Statistik Penggunaan Ruang';
    final Sheet statSheet = excel[statsSheetName];

    statSheet.appendRow([
      TextCellValue('REKAPITULASI FREKUENSI PEMINJAMAN RUANG & LABORATORIUM'),
    ]);
    statSheet.appendRow([TextCellValue('')]);

    final statHeaders = [
      'No',
      'Kode Ruang',
      'Nama Ruangan',
      'Kategori',
      'Lantai',
      'Kapasitas (Orang)',
      'Total Frekuensi Peminjaman',
      'Peminjaman Selesai (Valid)',
      'Status Ruangan',
    ];

    statSheet.appendRow(statHeaders.map((h) => TextCellValue(h)).toList());

    for (var col = 0; col < statHeaders.length; col++) {
      final cell = statSheet.cell(CellIndex.indexByColumnRow(columnIndex: col, rowIndex: 2));
      cell.cellStyle = headerCellStyle;
    }

    for (var i = 0; i < rooms.length; i++) {
      final r = rooms[i];
      final totalBookings = bookings.where((b) => b.roomCode == r.id).length;
      final completedBookings = bookings
          .where((b) => b.roomCode == r.id && b.status == BookingStatus.completed)
          .length;

      statSheet.appendRow([
        IntCellValue(i + 1),
        TextCellValue(r.id),
        TextCellValue(r.name),
        TextCellValue(r.typeLabel),
        IntCellValue(r.floor),
        IntCellValue(r.capacity),
        IntCellValue(totalBookings),
        IntCellValue(completedBookings),
        TextCellValue(r.statusLabel),
      ]);
    }

    final bytes = excel.encode();
    return Uint8List.fromList(bytes ?? []);
  }

  /// Download atau share file Excel ke perangkat pengguna
  static Future<bool> downloadOrShareExcel({
    required Uint8List fileBytes,
    required String fileName,
  }) async {
    try {
      if (kIsWeb) {
        // Web download
        final base64Data = base64Encode(fileBytes);
        html.AnchorElement(
          href: 'data:application/vnd.openxmlformats-officedocument.spreadsheetml.sheet;base64,$base64Data',
        )
          ..setAttribute('download', fileName)
          ..click();
        return true;
      } else {
        // Mobile / Desktop: Share / Save
        final xfile = XFile.fromData(
          fileBytes,
          name: fileName,
          mimeType: 'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
        );
        await Share.shareXFiles(
          [xfile],
          subject: 'Laporan Peminjaman Laboratorium & Ruang PBM TIK PNL',
          text: 'Berikut terlampir berkas spreadsheet Laporan Peminjaman Ruang Jurusan TIK TA 2026/2027.',
        );
        return true;
      }
    } catch (e) {
      debugPrint('Error saving excel file: $e');
      return false;
    }
  }
}
