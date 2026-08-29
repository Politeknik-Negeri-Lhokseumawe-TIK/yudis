import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/admin_repository.dart';
import '../../domain/activity_log_model.dart';

// ── Repository Provider ───────────────────────────────────────
final adminRepoProvider = Provider<AdminRepository>((ref) => AdminRepository());

// ── Admin State ───────────────────────────────────────────────
class AdminState {
  const AdminState({
    this.activityLogs = const [],
    this.stats = const {},
    this.isLoading = false,
    this.lastUpdated,
    this.error,
  });

  final List<ActivityLog> activityLogs;
  final Map<String, int> stats;
  final bool isLoading;
  final DateTime? lastUpdated;
  final String? error;

  AdminState copyWith({
    List<ActivityLog>? activityLogs,
    Map<String, int>? stats,
    bool? isLoading,
    DateTime? lastUpdated,
    String? error,
    bool clearError = false,
  }) {
    return AdminState(
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
  StreamSubscription<List<ActivityLog>>? _logsSub;

  void _startRealtimeStreams() {
    _logsSub = _repo.activityLogsStream().listen((newLogs) {
      state = state.copyWith(activityLogs: newLogs);
    });
  }

  Future<void> loadAll() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final results = await Future.wait([
        _repo.getStats(),
        _repo.getActivityLogs(),
      ]);
      state = AdminState(
        stats: results[0] as Map<String, int>,
        activityLogs: results[1] as List<ActivityLog>,
        lastUpdated: DateTime.now(),
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e.toString());
    }
  }

  Future<void> refresh() async {
    final logs = await _repo.getActivityLogs();
    final stats = await _repo.getStats();
    state = state.copyWith(activityLogs: logs, stats: stats, lastUpdated: DateTime.now());
  }

  @override
  void dispose() {
    _logsSub?.cancel();
    super.dispose();
  }
}

// ── Provider ──────────────────────────────────────────────────
final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  return AdminNotifier(ref.watch(adminRepoProvider));
});
