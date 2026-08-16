import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/auth_service.dart';
import '../../domain/user_model.dart';

// ── Service Provider ──────────────────────────────────────────
final authServiceProvider = Provider<AuthService>((ref) => AuthService());

// ── Auth State ────────────────────────────────────────────────
class AuthState {
  const AuthState({
    this.user,
    this.isLoading = false,
    this.error,
    this.isInitialized = false,
  });

  final User? user;
  final bool isLoading;
  final String? error;
  final bool isInitialized;

  bool get isAuthenticated => user != null;
  bool get isPendingVerifikasi =>
      user?.statusAkun == StatusAkun.pendingVerifikasi;
  bool get isAdmin =>
      user?.role == UserRole.admin || user?.role == UserRole.superAdmin;

  AuthState copyWith({
    User? user,
    bool? isLoading,
    String? error,
    bool? isInitialized,
    bool clearUser = false,
    bool clearError = false,
  }) {
    return AuthState(
      user: clearUser ? null : (user ?? this.user),
      isLoading: isLoading ?? this.isLoading,
      error: clearError ? null : (error ?? this.error),
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

// ── Auth Notifier ─────────────────────────────────────────────
class AuthNotifier extends StateNotifier<AuthState> {
  AuthNotifier(this._authService) : super(const AuthState()) {
    _initialize();
  }

  final AuthService _authService;

  Future<void> _initialize() async {
    final result = await _authService.getMe();
    if (result.isSuccess) {
      state = AuthState(user: result.user, isInitialized: true);
    } else {
      state = const AuthState(isInitialized: true);
    }
  }

  Future<bool> login({
    required String nimOrEmail,
    required String password,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _authService.login(
      nimOrEmail: nimOrEmail,
      password: password,
    );
    if (result.isSuccess) {
      state = AuthState(user: result.user, isInitialized: true);
      return true;
    } else {
      state = state.copyWith(
        isLoading: false,
        error: result.error,
        isInitialized: true,
      );
      return false;
    }
  }

  Future<bool> register({
    required String nim,
    required String nama,
    required String email,
    required String password,
    required ProgramStudi programStudi,
    required String noHp,
  }) async {
    state = state.copyWith(isLoading: true, clearError: true);
    final result = await _authService.register(
      nim: nim,
      nama: nama,
      email: email,
      password: password,
      programStudi: programStudi,
      noHp: noHp,
    );
    if (result.isSuccess) {
      state = AuthState(user: result.user, isInitialized: true);
      return true;
    } else {
      state = state.copyWith(isLoading: false, error: result.error);
      return false;
    }
  }

  Future<void> logout() async {
    await _authService.logout();
    state = const AuthState(isInitialized: true);
  }

  void clearError() => state = state.copyWith(clearError: true);
}

// ── Provider ──────────────────────────────────────────────────
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.watch(authServiceProvider));
});

// ── Convenience Providers ─────────────────────────────────────
final currentUserProvider = Provider<User?>((ref) {
  return ref.watch(authProvider).user;
});

final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});
