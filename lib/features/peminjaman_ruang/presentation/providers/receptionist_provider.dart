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
  StreamSubscription? _streamSub;
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

    // 2. Sinkronisasi dari Supabase Database (Real-Time antar komputer)
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
      }
    } catch (_) {}

    // 3. Realtime Listener (Jika ada pergantian di PC 1, PC 2 & 3 otomatis update)
    try {
      _streamSub = _supabase
          .from('receptionist_officers')
          .stream(primaryKey: ['id'])
          .listen((rows) {
        if (rows.isNotEmpty) {
          final dbOfficers = rows.map((r) => ReceptionistOfficerModel.fromRow(r)).toList();
          final activeDb = dbOfficers.firstWhere(
            (o) => o.isOnDuty,
            orElse: () => dbOfficers.first,
          );
          state = state.copyWith(officers: dbOfficers, activeOfficer: activeDb);
        }
      });
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

    // Simpan ke Supabase Database Real-time agar PC 2 & 3 otomatis berubah
    try {
      await _supabase.from('receptionist_officers').update({'is_active': false}).neq('id', officer.id);
      await _supabase.from('receptionist_officers').upsert(officer.toMap()..['is_active'] = true);
    } catch (_) {}
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
    } catch (_) {}
  }

  @override
  void dispose() {
    _streamSub?.cancel();
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
