import 'dart:async';
import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import '../../domain/models/receptionist_officer_model.dart';

/// State Petugas / Dosen Piket Jaga Resepsionis yang Terintegrasi di Seluruh Komputer
class OfficersState {
  final List<ReceptionistOfficerModel> officers;
  final ReceptionistOfficerModel activeOfficer;
  final bool isLoading;

  const OfficersState({
    required this.officers,
    required this.activeOfficer,
    this.isLoading = false,
  });

  OfficersState copyWith({
    List<ReceptionistOfficerModel>? officers,
    ReceptionistOfficerModel? activeOfficer,
    bool? isLoading,
  }) {
    return OfficersState(
      officers: officers ?? this.officers,
      activeOfficer: activeOfficer ?? this.activeOfficer,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class OfficersNotifier extends StateNotifier<OfficersState> {
  OfficersNotifier()
      : super(
          OfficersState(
            officers: List.from(ReceptionistOfficerModel.defaultOfficers),
            activeOfficer: ReceptionistOfficerModel.defaultOfficers[0],
          ),
        ) {
    _initSync();
  }

  static SupabaseClient get _supabase => Supabase.instance.client;
  RealtimeChannel? _realtimeChannel;
  Timer? _pollingTimer;
  static const String _prefActiveKey = 'simlab_active_officer_id';
  static const String _prefCustomListKey = 'simlab_custom_officers_list';

  Future<void> _initSync() async {
    // 1. Load dari LocalStorage terlebih dahulu agar instan
    try {
      final prefs = await SharedPreferences.getInstance();
      final customListJson = prefs.getString(_prefCustomListKey);
      List<ReceptionistOfficerModel> list = List.from(ReceptionistOfficerModel.defaultOfficers);

      if (customListJson != null) {
        final decoded = jsonDecode(customListJson) as List;
        final customList = decoded.map((m) => ReceptionistOfficerModel.fromRow(m as Map<String, dynamic>)).toList();
        for (final c in customList) {
          if (!list.any((o) => o.id == c.id)) {
            list.add(c);
          }
        }
      }

      final activeId = prefs.getString(_prefActiveKey);
      final active = list.firstWhere(
        (o) => o.id == activeId,
        orElse: () => list[0],
      );

      state = state.copyWith(officers: list, activeOfficer: active);
    } catch (_) {}

    // 2. Fetch awal dari Supabase Cloud
    await _fetchFromCloud();

    // 3. Realtime Listener Channel
    try {
      _realtimeChannel = _supabase
          .channel('public:receptionist_officers')
          .onPostgresChanges(
            event: PostgresChangeEvent.all,
            schema: 'public',
            table: 'receptionist_officers',
            callback: (payload) {
              debugPrint('⚡ [Realtime Officers] Officer event: ${payload.eventType}');
              _fetchFromCloud();
            },
          )
          .subscribe();
    } catch (e) {
      debugPrint('⚠️ [Realtime Officers] Listener error: $e');
    }

    // 4. Polling sinkronisasi berkala (interval 4 detik)
    _pollingTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      _fetchFromCloud();
    });
  }

  Future<void> _fetchFromCloud() async {
    try {
      final rows = await _supabase
          .from('receptionist_officers')
          .select()
          .order('created_at', ascending: true);

      if (rows.isNotEmpty) {
        final dbOfficers = rows.map((r) => ReceptionistOfficerModel.fromRow(r)).toList();
        final activeDb = dbOfficers.firstWhere(
          (o) => o.isOnDuty,
          orElse: () => dbOfficers.first,
        );

        state = state.copyWith(officers: dbOfficers, activeOfficer: activeDb);
      } else {
        // Jika tabel cloud masih kosong, seed petugas default
        _seedDefaultOfficersToCloud();
      }
    } catch (e) {
      debugPrint('⚠️ [OfficersNotifier] Fetch cloud error: $e');
    }
  }

  Future<void> _seedDefaultOfficersToCloud() async {
    try {
      for (final officer in ReceptionistOfficerModel.defaultOfficers) {
        await _supabase.from('receptionist_officers').upsert(officer.toMap());
      }
    } catch (_) {}
  }

  /// Ganti Dosen/Petugas yang sedang aktif jaga loket
  Future<void> setActiveOfficer(ReceptionistOfficerModel officer) async {
    // Update local state instan
    final updatedList = state.officers.map((o) {
      return o.copyWith(isOnDuty: o.id == officer.id);
    }).toList();

    final newActive = officer.copyWith(isOnDuty: true);
    state = state.copyWith(officers: updatedList, activeOfficer: newActive);

    // Simpan ke SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefActiveKey, officer.id);
    } catch (_) {}

    // Simpan ke Supabase Database Real-time agar PC 2, PC 3 & Mahasiswa otomatis berubah
    try {
      // Nonaktifkan semua petugas lain
      await _supabase.from('receptionist_officers').update({'is_active': false}).neq('id', officer.id);
      // Aktifkan petugas yang dipilih
      await _supabase.from('receptionist_officers').upsert({
        'id': officer.id,
        'name': officer.name,
        'nip': officer.nip,
        'role': officer.roleTitle,
        'shift_name': officer.shiftName,
        'shift_hours': officer.shiftHours,
        'is_active': true,
      });
      debugPrint('✅ [OfficersNotifier] Petugas aktif berhasil diupdate di cloud: ${officer.name}');
    } catch (e) {
      debugPrint('⚠️ [OfficersNotifier] Gagal update petugas aktif ke cloud: $e');
    }
  }

  /// Tambah Dosen/Petugas piket baru
  Future<void> addOfficer(ReceptionistOfficerModel newOfficer) async {
    final officerWithDuty = newOfficer.copyWith(isOnDuty: true);
    final updatedList = state.officers.map((o) => o.copyWith(isOnDuty: false)).toList()
      ..add(officerWithDuty);

    state = state.copyWith(
      officers: updatedList,
      activeOfficer: officerWithDuty,
    );

    // Simpan ke SharedPreferences
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_prefActiveKey, newOfficer.id);
      final jsonList = jsonEncode(updatedList.map((o) => o.toMap()).toList());
      await prefs.setString(_prefCustomListKey, jsonList);
    } catch (_) {}

    // Simpan ke Supabase
    try {
      await _supabase.from('receptionist_officers').update({'is_active': false}).neq('id', newOfficer.id);
      await _supabase.from('receptionist_officers').upsert(officerWithDuty.toMap());
      debugPrint('✅ [OfficersNotifier] Petugas baru berhasil disimpan ke cloud: ${newOfficer.name}');
    } catch (e) {
      debugPrint('⚠️ [OfficersNotifier] Gagal simpan petugas baru ke cloud: $e');
    }
  }

  @override
  void dispose() {
    _pollingTimer?.cancel();
    if (_realtimeChannel != null) {
      _supabase.removeChannel(_realtimeChannel!);
    }
    super.dispose();
  }
}

/// Provider Global Petugas Resepsionis (Terhubung ke Komputer 1, 2, dan 3)
final officersProvider =
    StateNotifierProvider<OfficersNotifier, OfficersState>((ref) {
  return OfficersNotifier();
});

/// Provider Dosen/Petugas Jaga Aktif
final activeOfficerProvider = Provider<ReceptionistOfficerModel>((ref) {
  return ref.watch(officersProvider).activeOfficer;
});
