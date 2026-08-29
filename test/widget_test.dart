import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:yudis/shared/widgets/glass_card.dart';
import 'package:yudis/shared/widgets/glass_button.dart';
import 'package:yudis/shared/widgets/animated_counter.dart';
import 'package:yudis/features/auth/domain/user_model.dart';
import 'package:yudis/features/notifikasi/domain/notifikasi_model.dart';
import 'package:yudis/features/peminjaman_ruang/domain/models/room_model.dart';
import 'package:yudis/features/peminjaman_ruang/domain/models/booking_model.dart';
import 'package:yudis/features/peminjaman_ruang/domain/models/receptionist_officer_model.dart';

void main() {
  group('SIM-LAB Domain & Model Tests', () {
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

    test('RoomModel parsing & properties test', () {
      const room = RoomModel(
        id: 'TIK.101',
        name: 'Laboratorium Multimedia & Game',
        type: RoomType.lab,
        floor: 1,
        building: 'Gedung TIK',
        capacity: 35,
        facilities: ['AC', 'Smart Screen 75"', 'PC High-End RTX 4070'],
        picName: 'Munawir, S.Kom.',
      );

      expect(room.id, 'TIK.101');
      expect(room.type, RoomType.lab);
      expect(room.capacity, 35);
      expect(room.facilities.length, 3);
    });

    test('BookingModel status & calculation test', () {
      final booking = BookingModel(
        id: 'b-001',
        bookingCode: 'PINJAM-20260829-001',
        userId: 'u001',
        userName: 'Ahmad Mahasiswa',
        userNimNip: '220401012',
        userPhone: '08123456789',
        userRole: 'Mahasiswa',
        roomCode: 'TIK.101',
        roomName: 'Laboratorium Multimedia & Game',
        bookingDate: DateTime(2026, 8, 30),
        day: 'Senin',
        startSession: 1,
        endSession: 3,
        startTime: '07:30',
        endTime: '10:00',
        purpose: 'Praktikum Mandiri Animasi 3D',
        description: 'Praktikum mata kuliah animasi komputer',
        supervisorLecturer: 'Zulham, S.T., M.Kom.',
        status: BookingStatus.active,
        createdAt: DateTime(2026, 8, 29, 8, 0),
        checkoutCleanlinessStatus: true,
        checkoutAcOffStatus: true,
      );

      expect(booking.bookingCode, 'PINJAM-20260829-001');
      expect(booking.status, BookingStatus.active);
      expect(booking.checkoutCleanlinessStatus, isTrue);
      expect(booking.checkoutAcOffStatus, isTrue);
    });

    test('ReceptionistOfficerModel predefined shift test', () {
      final officers = ReceptionistOfficerModel.defaultOfficers;
      expect(officers.isNotEmpty, isTrue);
      expect(officers.first.name, 'Munawir, S.Kom.');
      expect(officers.first.shiftName, 'Shift Pagi');
    });

    test('Notifikasi model deserialization test', () {
      final notif = Notifikasi.fromRow({
        'id': 'n01',
        'judul': 'Peminjaman Disetujui',
        'pesan': 'Kunci ruang TIK.101 siap diambil di Meja Resepsionis.',
        'type': 'success',
        'is_read': false,
        'created_at': DateTime.now().toIso8601String(),
      });
      expect(notif.judul, 'Peminjaman Disetujui');
      expect(notif.isRead, isFalse);
      expect(notif.type, NotifikasiType.success);
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
              label: 'Pinjam Ruang',
              onPressed: () => tapped = true,
            ),
          ),
        ),
      );

      expect(find.text('Pinjam Ruang'), findsOneWidget);
      await tester.tap(find.text('Pinjam Ruang'));
      await tester.pumpAndSettle();
      expect(tapped, isTrue);
    });

    testWidgets('AnimatedCounter renders smoothly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AnimatedCounter(value: 43),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('43'), findsOneWidget);
    });
  });
}
