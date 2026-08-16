import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/admin_repository.dart';
import '../../domain/admin_models.dart';
import '../../domain/activity_log_model.dart';
import '../../../pendaftaran_yudisium/domain/pendaftaran_model.dart';
import '../../../auth/data/auth_service.dart';
import '../../../auth/domain/user_model.dart';

// ── Repository Provider ───────────────────────────────────────
final adminRepoProvider = Provider<AdminRepository>((ref) => AdminRepository());

// ── Admin State ───────────────────────────────────────────────
class AdminState {
  const AdminState({
    this.pendingAccounts = const [],
    this.pendaftaranList = const [],
    this.activityLogs = const [],
    this.stats = const {},
    this.isLoading = false,
    this.lastUpdated,
    this.error,
  });

  final List<PendingAccount> pendingAccounts;
  final List<PendaftaranAdmin> pendaftaranList;
  final List<ActivityLog> activityLogs;
  final Map<String, int> stats;
  final bool isLoading;
  final DateTime? lastUpdated;
  final String? error;

  AdminState copyWith({
    List<PendingAccount>? pendingAccounts,
    List<PendaftaranAdmin>? pendaftaranList,
    List<ActivityLog>? activityLogs,
    Map<String, int>? stats,
    bool? isLoading,
    DateTime? lastUpdated,
    String? error,
    bool clearError = false,
  }) {
    return AdminState(
      pendingAccounts: pendingAccounts ?? this.pendingAccounts,
      pendaftaranList: pendaftaranList ?? this.pendaftaranList,
      activityLogs: activityLogs ?? this.activityLogs,
      stats: stats ?? this.stats,
      isLoading: isLoading ?? this.isLoading,
      lastUpdated: lastUpdated ?? this.lastUpdated,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

// ── Admin Notifier ────────────────────────────────────────────
class AdminNotifier extends StateNotifier<AdminState> {
  AdminNotifier(this._repo) : super(const AdminState()) {
    loadAll();
    _startRealtimeStreams();
  }

  final AdminRepository _repo;
  StreamSubscription<Map<String, int>>? _statsSub;
  StreamSubscription<List<ActivityLog>>? _logsSub;

  void _startRealtimeStreams() {
    _statsSub = _repo.statsStream().listen((newStats) {
      state = state.copyWith(stats: newStats, lastUpdated: DateTime.now());
    });
    _logsSub = _repo.activityLogsStream().listen((newLogs) {
      state = state.copyWith(activityLogs: newLogs);
    });
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repo.getPendingAccounts(),
        _repo.getPendaftaranList(),
        _repo.getStats(),
        _repo.getActivityLogs(),
      ]);
      state = AdminState(
        pendingAccounts: results[0] as List<PendingAccount>,
        pendaftaranList: results[1] as List<PendaftaranAdmin>,
        stats: results[2] as Map<String, int>,
        activityLogs: results[3] as List<ActivityLog>,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> verifikasiAkun(String userId, bool approve, {String? alasan}) async {
    await _repo.verifikasiAkun(userId, approve, alasan: alasan);
    AuthService.updateUserStatus(
      userId,
      approve ? StatusAkun.aktif : StatusAkun.ditolak,
    );
    final logs = await _repo.getActivityLogs();
    state = state.copyWith(
      pendingAccounts:
          state.pendingAccounts.where((a) => a.user.id != userId).toList(),
      activityLogs: logs,
      stats: {
        ...state.stats,
        'pending_akun': (state.stats['pending_akun'] ?? 1) - 1,
      },
    );
  }

  Future<void> verifikasiDokumen({
    required String pendaftaranId,
    required String dokumenId,
    required StatusDokumen status,
    String? catatan,
  }) async {
    await _repo.verifikasiDokumen(
      pendaftaranId: pendaftaranId,
      dokumenId: dokumenId,
      status: status,
      catatan: catatan,
    );
    final updated = await _repo.getPendaftaranList();
    final logs = await _repo.getActivityLogs();
    final stats = await _repo.getStats();
    state = state.copyWith(
      pendaftaranList: updated,
      activityLogs: logs,
      stats: stats,
    );
  }

  @override
  void dispose() {
    _statsSub?.cancel();
    _logsSub?.cancel();
    super.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────
final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref.watch(adminRepoProvider));
});
