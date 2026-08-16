import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/pendaftaran_model.dart';
import '../../domain/template_syarat_model.dart';
import '../../../auth/domain/user_model.dart';

// ── Mock Periode ──────────────────────────────────────────────
final mockPeriode = PeriodeYudisium(
  id: 'p2025-2',
  nama: 'Yudisium Semester Genap 2025/2026',
  tanggalMulai: DateTime(2026, 8, 1),
  tanggalSelesai: DateTime(2026, 8, 26),
  isAktif: true,
  deskripsi: 'Periode yudisium semester genap TA 2025/2026',
);

// ── Pendaftaran State ─────────────────────────────────────────
class PendaftaranState {
  const PendaftaranState({
    this.pendaftaran,
    this.periode,
    this.isLoading = false,
    this.error,
    this.currentStep = 0,
    this.isSubmitting = false,
    this.submitSuccess = false,
  });

  final PendaftaranYudisium? pendaftaran;
  final PeriodeYudisium? periode;
  final bool isLoading;
  final String? error;
  final int currentStep;
  final bool isSubmitting;
  final bool submitSuccess;

  PendaftaranState copyWith({
    PendaftaranYudisium? pendaftaran,
    PeriodeYudisium? periode,
    bool? isLoading,
    String? error,
    int? currentStep,
    bool? isSubmitting,
    bool? submitSuccess,
    bool clearError = false,
  }) {
    return PendaftaranState(
      pendaftaran: pendaftaran ?? this.pendaftaran,
      periode: periode ?? this.periode,
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      currentStep: currentStep ?? this.currentStep,
      isSubmitting: isSubmitting ?? this.isSubmitting,
      submitSuccess: submitSuccess ?? this.submitSuccess,
    );
  }
}

// ── Notifier ──────────────────────────────────────────────────
class PendaftaranNotifier extends StateNotifier<PendaftaranState> {
  PendaftaranNotifier() : super(const PendaftaranState()) {
    _loadPeriode();
  }

  void _loadPeriode() {
    state = state.copyWith(periode: mockPeriode);
  }

  /// Inisialisasi pendaftaran baru
  PendaftaranYudisium _buatPendaftaranBaru({
    required String userId,
    required ProgramStudi programStudi,
    required Jenjang jenjang,
    required double ipk,
    required int totalSks,
    required int semester,
    required bool tinggalDiAsrama,
  }) {
    final dokumen = mockTemplateDokumen.map((t) => t.toDokumenSyarat()).toList();
    return PendaftaranYudisium(
      id: 'pend_${DateTime.now().millisecondsSinceEpoch}',
      userId: userId,
      periodeId: mockPeriode.id,
      programStudi: programStudi,
      jenjang: jenjang,
      ipk: ipk,
      totalSks: totalSks,
      semester: semester,
      tinggalDiAsrama: tinggalDiAsrama,
      dokumen: dokumen,
      biodata: const BiodataCalon(),
    );
  }

  void mulaiPendaftaran({
    required String userId,
    required ProgramStudi programStudi,
    required Jenjang jenjang,
    required double ipk,
    required int totalSks,
    required int semester,
    required bool tinggalDiAsrama,
  }) {
    final pendaftaran = _buatPendaftaranBaru(
      userId: userId,
      programStudi: programStudi,
      jenjang: jenjang,
      ipk: ipk,
      totalSks: totalSks,
      semester: semester,
      tinggalDiAsrama: tinggalDiAsrama,
    );
    state = state.copyWith(pendaftaran: pendaftaran, currentStep: 1);
  }

  /// Upload dokumen (mock)
  Future<void> uploadDokumen({
    required String dokumenId,
    required String filePath,
    required String fileName,
    required int fileSize,
  }) async {
    final pendaftaran = state.pendaftaran;
    if (pendaftaran == null) return;

    // Simulate upload
    await Future.delayed(const Duration(milliseconds: 500));

    final updatedDokumen = pendaftaran.dokumen.map((d) {
      if (d.id == dokumenId) {
        return d.copyWith(
          status: StatusDokumen.menunggu,
          filePath: filePath,
          fileName: fileName,
          fileSize: fileSize,
        );
      }
      return d;
    }).toList();

    final updated = PendaftaranYudisium(
      id: pendaftaran.id,
      userId: pendaftaran.userId,
      periodeId: pendaftaran.periodeId,
      programStudi: pendaftaran.programStudi,
      jenjang: pendaftaran.jenjang,
      ipk: pendaftaran.ipk,
      totalSks: pendaftaran.totalSks,
      semester: pendaftaran.semester,
      tinggalDiAsrama: pendaftaran.tinggalDiAsrama,
      dokumen: updatedDokumen,
      biodata: pendaftaran.biodata,
      status: pendaftaran.status,
    );
    state = state.copyWith(pendaftaran: updated);
  }

  void updateBiodata(BiodataCalon biodata) {
    final p = state.pendaftaran;
    if (p == null) return;
    final updated = PendaftaranYudisium(
      id: p.id,
      userId: p.userId,
      periodeId: p.periodeId,
      programStudi: p.programStudi,
      jenjang: p.jenjang,
      ipk: p.ipk,
      totalSks: p.totalSks,
      semester: p.semester,
      tinggalDiAsrama: p.tinggalDiAsrama,
      dokumen: p.dokumen,
      biodata: biodata,
      status: p.status,
    );
    state = state.copyWith(pendaftaran: updated);
  }

  void setStep(int step) => state = state.copyWith(currentStep: step);

  Future<bool> submit() async {
    final p = state.pendaftaran;
    if (p == null) return false;

    state = state.copyWith(isSubmitting: true, clearError: true);
    await Future.delayed(const Duration(milliseconds: 1200));

    p.status = StatusPendaftaran.submitted;
    p.submittedAt = DateTime.now();

    state = state.copyWith(
      isSubmitting: false,
      submitSuccess: true,
      pendaftaran: p,
    );
    return true;
  }

  void reset() {
    state = const PendaftaranState();
    _loadPeriode();
  }
}

// ── Providers ─────────────────────────────────────────────────
final pendaftaranProvider =
    StateNotifierProvider<PendaftaranNotifier, PendaftaranState>((ref) {
  return PendaftaranNotifier();
});

final periodeAktifProvider = Provider<PeriodeYudisium?>((ref) {
  return ref.watch(pendaftaranProvider).periode;
});
