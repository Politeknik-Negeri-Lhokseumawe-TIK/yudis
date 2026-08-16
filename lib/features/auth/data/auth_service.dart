import 'dart:async';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../domain/user_model.dart';
import '../../admin_verifikasi/data/admin_repository.dart';
import '../../../core/security/crypto_security_service.dart';

/// Auth service — mock implementation dengan enkripsi & real-time sync
class AuthService {
  AuthService({FlutterSecureStorage? secureStorage})
      : _secureStorage = secureStorage ??
            const FlutterSecureStorage(
              // Web: gunakan localStorage sebagai fallback
              webOptions: WebOptions(dbName: 'yudis_secure', publicKey: 'yudis'),
              // Android: gunakan EncryptedSharedPreferences
              aOptions: AndroidOptions(encryptedSharedPreferences: true),
            );

  final FlutterSecureStorage _secureStorage;

  static const _keyToken = 'auth_token';
  static const _keyUser = 'cached_user';

  // ── Mock data ─────────────────────────────────────────────────
  static final List<_MockAccount> _mockAccounts = [
    _MockAccount(
      user: const User(
        id: 'u001',
        nim: '2021903430045',
        nama: 'Ahmad Fauzi',
        email: 'ahmad.fauzi@gmail.com',
        role: UserRole.mahasiswa,
        statusAkun: StatusAkun.aktif,
        programStudi: ProgramStudi.trkj,
        noHp: '085712345678',
      ),
      password: 'password123',
      token: 'mock-token-mahasiswa-aktif',
    ),
    _MockAccount(
      user: const User(
        id: 'u002',
        nim: '2021903430088',
        nama: 'Siti Rahmi',
        email: 'siti.rahmi@gmail.com',
        role: UserRole.mahasiswa,
        statusAkun: StatusAkun.pendingVerifikasi,
        programStudi: ProgramStudi.trkj,
        noHp: '089876543210',
      ),
      password: 'password123',
      token: 'mock-token-mahasiswa-pending',
    ),
    _MockAccount(
      user: const User(
        id: 'a001',
        nim: 'ADM001',
        nama: 'Admin Yudisium',
        email: 'admin@pnl.ac.id',
        role: UserRole.admin,
        statusAkun: StatusAkun.aktif,
        programStudi: ProgramStudi.ti,
      ),
      password: 'admin123',
      token: 'mock-token-admin',
    ),
  ];

  /// Update status akun pengguna secara real-time (dipanggil oleh Admin saat verifikasi)
  static void updateUserStatus(String userId, StatusAkun newStatus) {
    final idx = _mockAccounts.indexWhere((a) => a.user.id == userId);
    if (idx != -1) {
      final old = _mockAccounts[idx];
      _mockAccounts[idx] = _MockAccount(
        user: old.user.copyWith(statusAkun: newStatus),
        password: old.password,
        token: old.token,
      );
    }
  }

  /// Reset password mandiri oleh mahasiswa (Fitur Lupa Password)
  static bool resetPassword({
    required String nimOrEmail,
    required String newPassword,
  }) {
    final clean = nimOrEmail.trim().toLowerCase();
    final idx = _mockAccounts.indexWhere(
      (a) => a.user.nim.toLowerCase() == clean || a.user.email.toLowerCase() == clean,
    );
    if (idx == -1) return false;

    final old = _mockAccounts[idx];
    _mockAccounts[idx] = _MockAccount(
      user: old.user,
      password: newPassword,
      token: old.token,
    );
    return true;
  }

  /// Admin mengubah password akun mahasiswa secara langsung
  static bool adminChangePassword({
    required String userId,
    required String newPassword,
  }) {
    final idx = _mockAccounts.indexWhere((a) => a.user.id == userId);
    if (idx == -1) return false;

    final old = _mockAccounts[idx];
    _mockAccounts[idx] = _MockAccount(
      user: old.user,
      password: newPassword,
      token: old.token,
    );
    return true;
  }

  /// Dapatkan daftar seluruh mahasiswa untuk dikelola oleh Admin
  static List<User> getAllMahasiswaUsers() {
    return _mockAccounts
        .where((a) => a.user.role == UserRole.mahasiswa)
        .map((a) => a.user)
        .toList();
  }

  /// Cek apakah akun mahasiswa terdaftar berdasarkan NIM atau Email
  static User? findMahasiswaByNimOrEmail(String nimOrEmail) {
    final clean = nimOrEmail.trim().toLowerCase();
    return _mockAccounts
        .where((a) => a.user.role == UserRole.mahasiswa)
        .map((a) => a.user)
        .where((u) => u.nim.toLowerCase() == clean || u.email.toLowerCase() == clean)
        .firstOrNull;
  }

  // ── Token Management ──────────────────────────────────────────
  Future<String?> getToken() async {
    return await _secureStorage.read(key: _keyToken);
  }

  Future<void> saveToken(String token) async {
    await _secureStorage.write(key: _keyToken, value: token);
  }

  Future<void> clearToken() async {
    await _secureStorage.delete(key: _keyToken);
  }

  // ── User Cache ────────────────────────────────────────────────
  Future<User?> getCachedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyUser);
    if (json == null) return null;
    try {
      return User.fromJson(jsonDecode(json) as Map<String, dynamic>);
    } catch (_) {
      return null;
    }
  }

  Future<void> cacheUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyUser, jsonEncode(user.toJson()));
  }

  Future<void> clearCache() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_keyUser);
  }

  // ── Auth Operations ───────────────────────────────────────────

  /// Login dengan NIM/email + password
  Future<AuthResult> login({
    required String nimOrEmail,
    required String password,
  }) async {
    // Simulate network delay
    await Future.delayed(const Duration(milliseconds: 800));

    final hashedInput = CryptoSecurityService.hashSha256(password);

    final account = _mockAccounts.where((a) {
      final matchNim = a.user.nim == nimOrEmail.trim();
      final matchEmail = a.user.email == nimOrEmail.trim().toLowerCase();
      final matchPassword = a.password == password || a.password == hashedInput;
      return (matchNim || matchEmail) && matchPassword;
    }).firstOrNull;

    if (account == null) {
      return AuthResult.failure('NIM/email atau password salah.');
    }

    await saveToken(account.token);
    await cacheUser(account.user);
    return AuthResult.success(account.user, account.token);
  }

  /// Registrasi mahasiswa baru
  Future<AuthResult> register({
    required String nim,
    required String nama,
    required String email,
    required String password,
    required ProgramStudi programStudi,
    required String noHp,
  }) async {
    await Future.delayed(const Duration(milliseconds: 1000));

    // Cek duplikasi NIM
    final existing = _mockAccounts.where((a) => a.user.nim == nim.trim());
    if (existing.isNotEmpty) {
      return AuthResult.failure('NIM $nim sudah terdaftar.');
    }

    final newUser = User(
      id: 'u${DateTime.now().millisecondsSinceEpoch}',
      nim: nim.trim(),
      nama: nama.trim(),
      email: email.trim().toLowerCase(),
      role: UserRole.mahasiswa,
      statusAkun: StatusAkun.pendingVerifikasi,
      programStudi: programStudi,
      noHp: noHp.trim(),
      createdAt: DateTime.now(),
    );

    final token = 'mock-token-${newUser.id}';
    _mockAccounts.add(_MockAccount(
      user: newUser,
      password: CryptoSecurityService.hashSha256(password),
      token: token,
    ));

    // Sinkronisasi real-time ke antrean verifikasi Admin
    AdminRepository.addPendingAccount(newUser);

    await saveToken(token);
    await cacheUser(newUser);
    return AuthResult.success(newUser, token);
  }

  /// Get current user dari token (mock)
  Future<AuthResult> getMe() async {
    final token = await getToken();
    if (token == null) return AuthResult.failure('Tidak ada sesi aktif.');

    await Future.delayed(const Duration(milliseconds: 300));

    final account = _mockAccounts.where((a) => a.token == token).firstOrNull;
    if (account == null) {
      await clearToken();
      await clearCache();
      return AuthResult.failure('Sesi tidak valid.');
    }

    await cacheUser(account.user);
    return AuthResult.success(account.user, token);
  }

  /// Logout
  Future<void> logout() async {
    await clearToken();
    await clearCache();
  }
}

// ── Result type ───────────────────────────────────────────────
class AuthResult {
  const AuthResult._({this.user, this.token, this.error});

  factory AuthResult.success(User user, String token) =>
      AuthResult._(user: user, token: token);

  factory AuthResult.failure(String error) => AuthResult._(error: error);

  final User? user;
  final String? token;
  final String? error;

  bool get isSuccess => user != null && error == null;
}

class _MockAccount {
  const _MockAccount({
    required this.user,
    required this.password,
    required this.token,
  });
  final User user;
  final String password;
  final String token;
}
