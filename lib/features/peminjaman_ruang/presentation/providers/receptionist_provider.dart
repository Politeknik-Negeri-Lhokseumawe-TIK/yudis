import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/receptionist_officer_model.dart';

/// State Petugas / Dosen Piket Jaga Resepsionis yang Terintegrasi di Seluruh Komputer
class OfficersState {
  final List<ReceptionistOfficerModel> officers;
  final ReceptionistOfficerModel activeOfficer;

  const OfficersState({
    required this.officers,
    required this.activeOfficer,
  });

  OfficersState copyWith({
    List<ReceptionistOfficerModel>? officers,
    ReceptionistOfficerModel? activeOfficer,
  }) {
    return OfficersState(
      officers: officers ?? this.officers,
      activeOfficer: activeOfficer ?? this.activeOfficer,
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
        );

  /// Ganti Dosen/Petugas yang sedang aktif jaga loket
  void setActiveOfficer(ReceptionistOfficerModel officer) {
    state = state.copyWith(activeOfficer: officer);
  }

  /// Tambah Dosen/Petugas piket baru
  void addOfficer(ReceptionistOfficerModel newOfficer) {
    final updatedList = List<ReceptionistOfficerModel>.from(state.officers)
      ..add(newOfficer);
    state = state.copyWith(
      officers: updatedList,
      activeOfficer: newOfficer,
    );
  }

  /// Update data Dosen/Petugas (Nama / NIP / Shift)
  void updateOfficer(ReceptionistOfficerModel updated) {
    final updatedList = state.officers.map((o) {
      return o.id == updated.id ? updated : o;
    }).toList();

    state = state.copyWith(
      officers: updatedList,
      activeOfficer: state.activeOfficer.id == updated.id ? updated : state.activeOfficer,
    );
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
