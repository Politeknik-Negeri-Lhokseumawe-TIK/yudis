import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:yudis/shared/widgets/glass_card.dart';
import 'package:yudis/shared/widgets/glass_button.dart';
import 'package:yudis/features/auth/domain/user_model.dart';
import 'package:yudis/features/pendaftaran_yudisium/domain/pendaftaran_model.dart';
import 'package:yudis/features/notifikasi/domain/notifikasi_model.dart';
import 'package:yudis/features/pendaftaran_yudisium/presentation/widgets/prodi_badge_widget.dart';
import 'package:yudis/shared/widgets/animated_counter.dart';
import 'package:yudis/shared/widgets/countdown_timer_widget.dart';

void main() {
  group('Domain & Token Unit Tests', () {
    test('User model serialization test', () {
      final user = User(
        id: 'u001',
        nim: '2024110001',
        nama: 'Test User',
        email: 'test@students.pnl.ac.id',
        role: UserRole.mahasiswa,
        statusAkun: StatusAkun.aktif,
        programStudi: ProgramStudi.ti,
      );

      final json = user.toJson();
      final fromJson = User.fromJson(json);

      expect(fromJson.nim, '2024110001');
      expect(fromJson.role, UserRole.mahasiswa);
      expect(fromJson.programStudi, ProgramStudi.ti);
    });

    test('Pendaftaran progress calculation test', () {
      final pendaftaran = PendaftaranYudisium(
        id: 'p01',
        userId: 'u001',
        periodeId: 'per01',
        programStudi: ProgramStudi.ti,
        jenjang: Jenjang.d4,
        ipk: 3.80,
        totalSks: 144,
        semester: 8,
        tinggalDiAsrama: false,
        dokumen: [
          DokumenSyarat(
            id: 'd1',
            kode: 'KRS',
            nama: 'KRS',
            deskripsi: 'KRS',
            status: StatusDokumen.valid,
            filePath: '/mock/krs.pdf',
          ),
          DokumenSyarat(
            id: 'd2',
            kode: 'TRANSKRIP',
            nama: 'Transkrip',
            deskripsi: 'Transkrip',
            status: StatusDokumen.belumUpload,
          ),
        ],
        biodata: const BiodataCalon(),
      );

      expect(pendaftaran.totalDokumenWajib, 2);
      expect(pendaftaran.dokumenTerUpload, 1);
      expect(pendaftaran.uploadProgress, 0.5);

      // Test batas ukuran file (File Size Limit)
      final dok1Mb = DokumenSyarat(
        id: 'd_foto',
        kode: 'FOTO_4X6',
        nama: 'Pas Foto',
        deskripsi: 'Foto Formal',
        maxSizeBytes: 1048576,
      );
      final dok3Mb = DokumenSyarat(
        id: 'd_tga',
        kode: 'TGA_ACC',
        nama: 'Lembar TGA',
        deskripsi: 'Lembar Pengesahan',
        maxSizeBytes: 3145728,
      );
      expect(dok1Mb.maxSizeFormatted, '1 MB');
      expect(dok3Mb.maxSizeFormatted, '3 MB');
    });

    test('Notifikasi model deserialization test', () {
      final notif = Notifikasi.fromRow({
        'id': 'n01',
        'judul': 'Yudisium Dibuka',
        'pesan': 'Batas pendaftaran 26 Agustus 2026',
        'type': 'info',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      expect(notif.judul, 'Yudisium Dibuka');
      expect(notif.isRead, isFalse);
      expect(notif.type, NotifikasiType.info);
    });
  });

  group('Widget Tests', () {
    testWidgets('GlassCard widget renders with child', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GlassCard(
              child: Text('Liquid Glass Card Content'),
            ),
          ),
        ),
      );

      expect(find.text('Liquid Glass Card Content'), findsOneWidget);
    });

    testWidgets('GlassButton renders and responds to tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: GlassButton(
              label: 'Daftar',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Daftar'), findsOneWidget);
      await tester.tap(find.text('Daftar'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('ProdiBadgeWidget renders safely inside unbounded Row', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ProdiBadgeWidget(
                    programStudi: 'TI',
                    size: ProdiBadgeSize.large,
                  ),
                ],
              ),
            ),
          ),
        ),
      );

      expect(find.text('TI'), findsOneWidget);
    });

    testWidgets('AnimatedCounter renders smoothly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCounter(value: 42),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('42'), findsOneWidget);
    });

    testWidgets('CountdownTimerWidget renders days remaining', (tester) async {
      final targetDate = DateTime.now().add(const Duration(days: 10));
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CountdownTimerWidget(targetDate: targetDate),
          ),
        ),
      );
      await tester.pump(const Duration(milliseconds: 100));
      expect(find.text('Sisa Waktu Pendaftaran'), findsOneWidget);

      // Clean up timer
      await tester.pumpWidget(const SizedBox());
    });
  });
}
