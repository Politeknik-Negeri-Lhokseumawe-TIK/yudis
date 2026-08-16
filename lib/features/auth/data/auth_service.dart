import 'package:supabase_flutter/supabase_flutter.dart' hide User;
import '../domain/user_model.dart';
import '../../admin_verifikasi/data/admin_repository.dart';


/// Auth service — Supabase implementation (real-time, persisten)
class AuthService {
  static SupabaseClient get _supabase => Supabase.instance.client;

  // ── Auth Operations ───────────────────────────────────────────

  /// Login dengan NIM/email + password
  Future<AuthResult> login({
    required String nimOrEmail,
    required String password,
  }) async {
    try {
      String email = nimOrEmail.trim().toLowerCase();

      // Jika input bukan email (tidak ada @), cari email berdasarkan NIM
      if (!email.contains('@')) {
        final nimResult = await _supabase
            .from('users')
            .select('email')
            .eq('nim', nimOrEmail.trim())
            .maybeSingle();
        if (nimResult == null) {
          return AuthResult.failure('NIM $nimOrEmail belum terdaftar.');
        }
        email = nimResult['email'] as String;
      }

      final response = await _supabase.auth.signInWithPassword(
        email: email,
        password: password,
      );

      if (response.user == null) {
        return AuthResult.failure('Login gagal. Periksa email/password Anda.');
      }

      // Ambil profil user dari tabel users
      final userRow = await _supabase
          .from('users')
          .select()
          .eq('id', response.user!.id)
          .maybeSingle();

      if (userRow == null) {
        // Fallback: buat profil jika belum ada di tabel public.users
        final meta = response.user!.userMetadata ?? {};
        final fallbackData = {
          'id': response.user!.id,
          'nim': meta['nim'] ?? nimOrEmail.trim(),
          'nama': meta['nama'] ?? response.user!.email?.split('@').first ?? 'Mahasiswa',
          'email': response.user!.email ?? email,
          'role': meta['role'] ?? 'mahasiswa',
          'status_akun': 'pendingVerifikasi',
          'program_studi': meta['program_studi'] ?? 'TRKJ',
        };
        await _supabase.from('users').upsert(fallbackData);
        final createdRow = await _supabase.from('users').select().eq('id', response.user!.id).single();
        return AuthResult.success(_rowToUser(createdRow), response.session?.accessToken ?? '');
      }

      return AuthResult.success(_rowToUser(userRow), response.session?.accessToken ?? '');
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('Terjadi kesalahan: $e');
    }
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
    try {
      final cleanEmail = email.trim().toLowerCase();
      final cleanNim = nim.trim();

      // Cek duplikasi NIM
      final existingNim = await _supabase
          .from('users')
          .select('nim, email')
          .eq('nim', cleanNim)
          .maybeSingle();

      if (existingNim != null && existingNim['email'] != cleanEmail) {
        return AuthResult.failure('NIM $cleanNim sudah terdaftar dengan email lain.');
      }

      // Buat akun di Supabase Auth dengan metadata
      final response = await _supabase.auth.signUp(
        email: cleanEmail,
        password: password,
        data: {
          'nim': cleanNim,
          'nama': nama.trim(),
          'role': 'mahasiswa',
          'program_studi': programStudi.value,
          'no_hp': noHp.trim(),
        },
      );

      if (response.user == null) {
        return AuthResult.failure('Gagal membuat akun. Silakan periksa kembali email & password Anda.');
      }

      final uid = response.user!.id;

      // Insert/Upsert profil ke tabel users
      final userData = {
        'id': uid,
        'nim': cleanNim,
        'nama': nama.trim(),
        'email': cleanEmail,
        'role': 'mahasiswa',
        'status_akun': 'pendingVerifikasi',
        'program_studi': programStudi.value,
        'no_hp': noHp.trim(),
      };
      await _supabase.from('users').upsert(userData);

      // Log aktivitas untuk admin
      await AdminRepository.logActivity(
        type: 'pendaftaranAkun',
        actorName: nama.trim(),
        targetName: 'Registrasi Akun Baru',
        description: '$nama ($cleanNim) mendaftar akun baru, menunggu verifikasi.',
      );

      final newUser = _rowToUser({...userData, 'created_at': DateTime.now().toIso8601String()});
      return AuthResult.success(newUser, response.session?.accessToken ?? '');
    } on AuthException catch (e) {
      return AuthResult.failure(_mapAuthError(e.message));
    } catch (e) {
      return AuthResult.failure('Gagal mendaftar: $e');
    }
  }

  /// Get current user dari sesi aktif
  Future<AuthResult> getMe() async {
    try {
      final session = _supabase.auth.currentSession;
      if (session == null) {
        return AuthResult.failure('Tidak ada sesi aktif.');
      }

      final userRow = await _supabase
          .from('users')
          .select()
          .eq('id', session.user.id)
          .single();

      return AuthResult.success(_rowToUser(userRow), session.accessToken);
    } catch (_) {
      return AuthResult.failure('Sesi tidak valid.');
    }
  }

  /// Logout
  Future<void> logout() async {
    await _supabase.auth.signOut();
  }

  /// Reset password — kirim email reset ke mahasiswa
  static Future<bool> resetPassword({required String nimOrEmail}) async {
    try {
      String email = nimOrEmail.trim().toLowerCase();
      if (!email.contains('@')) {
        final row = await _supabase
            .from('users')
            .select('email')
            .eq('nim', nimOrEmail.trim())
            .maybeSingle();
        if (row == null) return false;
        email = row['email'] as String;
      }
      await _supabase.auth.resetPasswordForEmail(email);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Admin mengubah status akun mahasiswa
  static Future<void> updateUserStatus(String userId, StatusAkun newStatus) async {
    await _supabase
        .from('users')
        .update({'status_akun': newStatus.value})
        .eq('id', userId);
  }

  /// Admin mengubah password akun mahasiswa (via update user)
  static Future<bool> adminChangePassword({
    required String userId,
    required String newPassword,
  }) async {
    try {
      // Untuk keamanan, perubahan password dilakukan via Supabase Admin SDK
      // di sisi server. Pada web app ini, admin bisa trigger email reset.
      final row = await _supabase
          .from('users')
          .select('email')
          .eq('id', userId)
          .single();
      await _supabase.auth.resetPasswordForEmail(row['email'] as String);
      return true;
    } catch (_) {
      return false;
    }
  }

  /// Dapatkan daftar seluruh mahasiswa untuk dikelola Admin
  static Future<List<User>> getAllMahasiswaUsers() async {
    final rows = await _supabase
        .from('users')
        .select()
        .eq('role', 'mahasiswa')
        .order('created_at', ascending: false);
    return (rows as List).map((r) => _rowToUser(r as Map<String, dynamic>)).toList();
  }

  /// Cek apakah mahasiswa terdaftar berdasarkan NIM atau Email
  static Future<User?> findMahasiswaByNimOrEmail(String nimOrEmail) async {
    final clean = nimOrEmail.trim().toLowerCase();
    final rows = await _supabase
        .from('users')
        .select()
        .eq('role', 'mahasiswa')
        .or('nim.eq.$nimOrEmail,email.eq.$clean')
        .limit(1);
    if ((rows as List).isEmpty) return null;
    return _rowToUser(rows.first);
  }

  // ── Helper: konversi row Supabase → User model ─────────────
  static User _rowToUser(Map<String, dynamic> row) {
    return User(
      id: row['id'] as String,
      nim: row['nim'] as String,
      nama: row['nama'] as String,
      email: row['email'] as String,
      role: UserRole.values.firstWhere(
        (e) => e.value == row['role'],
        orElse: () => UserRole.mahasiswa,
      ),
      statusAkun: StatusAkun.values.firstWhere(
        (e) => e.value == (row['status_akun'] ?? 'pendingVerifikasi'),
        orElse: () => StatusAkun.pendingVerifikasi,
      ),
      programStudi: ProgramStudi.values.firstWhere(
        (e) => e.value == row['program_studi'],
        orElse: () => ProgramStudi.ti,
      ),
      noHp: row['no_hp'] as String?,
      avatarUrl: row['avatar_url'] as String?,
      createdAt: row['created_at'] != null
          ? DateTime.tryParse(row['created_at'] as String)
          : null,
    );
  }

  // ── Helper: mapping pesan error Supabase ke Bahasa Indonesia ───
  static String _mapAuthError(String message) {
    if (message.contains('Invalid login credentials')) {
      return 'Email atau password salah.';
    }
    if (message.contains('Email not confirmed')) {
      return 'Email belum dikonfirmasi. Cek inbox email Anda.';
    }
    if (message.contains('User already registered')) {
      return 'Email ini sudah terdaftar. Gunakan email lain.';
    }
    if (message.contains('Password should be')) {
      return 'Password minimal 6 karakter.';
    }
    return 'Terjadi kesalahan: $message';
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
