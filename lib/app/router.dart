import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/pending_screen.dart';
import '../features/pendaftaran_yudisium/presentation/screens/dashboard_mahasiswa_screen.dart';
import '../features/pendaftaran_yudisium/presentation/screens/form_pendaftaran_screen.dart';
import '../features/pendaftaran_yudisium/presentation/screens/status_pendaftaran_screen.dart';
import '../features/admin_verifikasi/presentation/screens/admin_dashboard_screen.dart';
import '../features/admin_verifikasi/presentation/screens/verifikasi_akun_screen.dart';
import '../features/admin_verifikasi/presentation/screens/verifikasi_berkas_screen.dart';
import '../features/admin_verifikasi/presentation/screens/kelola_periode_screen.dart';
import '../features/admin_verifikasi/presentation/screens/rekap_screen.dart';
import '../features/notifikasi/presentation/screens/notifikasi_screen.dart';

/// GoRouter config dengan role-based routing dan fade/slide transition.
/// Sidebar ditangani oleh SidebarAwareScaffold di dalam setiap screen —
/// tidak menggunakan ShellRoute agar menghindari nested-Scaffold layout errors.
final routerProvider = Provider<GoRouter>((ref) {
  final authState = ref.watch(authProvider);

  return GoRouter(
    initialLocation: '/splash',
    debugLogDiagnostics: true,
    redirect: (context, state) {
      final isAuth = authState.isAuthenticated;
      final isInitialized = authState.isInitialized;
      final location = state.uri.toString();

      if (!isInitialized) {
        return location == '/splash' ? null : '/splash';
      }

      final publicPaths = ['/splash', '/login', '/register'];
      final isPublicPath = publicPaths.contains(location);

      if (!isAuth) {
        return isPublicPath ? null : '/login';
      }

      if (isAuth && isPublicPath) {
        if (authState.isAdmin) return '/admin/dashboard';
        return '/mahasiswa/dashboard';
      }

      // Jika mahasiswa masih pending verifikasi dan mencoba akses form pendaftaran secara langsung
      if (!authState.isAdmin &&
          authState.isPendingVerifikasi &&
          location == '/mahasiswa/daftar') {
        return '/mahasiswa/dashboard';
      }

      if (authState.isAdmin && location.startsWith('/mahasiswa')) {
        return '/admin/dashboard';
      }
      if (!authState.isAdmin && location.startsWith('/admin')) {
        return '/mahasiswa/dashboard';
      }

      return null;
    },
    routes: [
      // ── Root / redirect ─────────────────────────────────────────────
      GoRoute(
        path: '/',
        redirect: (context, state) => '/splash',
      ),

      // ── Auth pages (tidak perlu sidebar) ────────────────────────────
      GoRoute(
        path: '/splash',
        pageBuilder: (context, state) => _fadeTransition(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: '/login',
        pageBuilder: (context, state) => _fadeTransition(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/register',
        pageBuilder: (context, state) => _fadeTransition(
          key: state.pageKey,
          child: const RegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/pending-verifikasi',
        pageBuilder: (context, state) => _fadeTransition(
          key: state.pageKey,
          child: const PendingScreen(),
        ),
      ),

      // ── Mahasiswa routes ─────────────────────────────────────────────
      GoRoute(
        path: '/mahasiswa/dashboard',
        pageBuilder: (context, state) => _fadeTransition(
          key: state.pageKey,
          child: const DashboardMahasiswaScreen(),
        ),
      ),
      GoRoute(
        path: '/mahasiswa/daftar',
        pageBuilder: (context, state) => _slideTransition(
          key: state.pageKey,
          child: const FormPendaftaranScreen(),
        ),
      ),
      GoRoute(
        path: '/mahasiswa/status',
        pageBuilder: (context, state) => _slideTransition(
          key: state.pageKey,
          child: const StatusPendaftaranScreen(),
        ),
      ),
      GoRoute(
        path: '/mahasiswa/status/:id',
        pageBuilder: (context, state) => _slideTransition(
          key: state.pageKey,
          child: StatusPendaftaranScreen(
            id: state.pathParameters['id'],
          ),
        ),
      ),
      GoRoute(
        path: '/mahasiswa/notifikasi',
        pageBuilder: (context, state) => _slideTransition(
          key: state.pageKey,
          child: const NotifikasiScreen(),
        ),
      ),

      // ── Admin routes ─────────────────────────────────────────────────
      GoRoute(
        path: '/admin/dashboard',
        pageBuilder: (context, state) => _fadeTransition(
          key: state.pageKey,
          child: const AdminDashboardScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/akun/pending',
        pageBuilder: (context, state) => _slideTransition(
          key: state.pageKey,
          child: const VerifikasiAkunScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/yudisium',
        pageBuilder: (context, state) => _slideTransition(
          key: state.pageKey,
          child: const VerifikasiBerkasScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/yudisium/:id',
        pageBuilder: (context, state) => _slideTransition(
          key: state.pageKey,
          child: VerifikasiBerkasScreen(
            pendaftaranId: state.pathParameters['id'],
          ),
        ),
      ),
      GoRoute(
        path: '/admin/periode',
        pageBuilder: (context, state) => _slideTransition(
          key: state.pageKey,
          child: const KelolaPeriodeScreen(),
        ),
      ),
      GoRoute(
        path: '/admin/rekap',
        pageBuilder: (context, state) => _slideTransition(
          key: state.pageKey,
          child: const RekapScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF061A0E),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.05),
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white24),
                ),
                child: const Icon(Icons.broken_image_outlined,
                    color: Colors.white60, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Halaman Tidak Ditemukan (404)',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Rute "${state.uri}" tidak tersedia atau sedang dalam pemeliharaan.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0B5C2E),
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.home_rounded, size: 18),
                label: const Text('Kembali ke Beranda'),
              ),
            ],
          ),
        ),
      ),
    ),
  );
});

// ── Custom transitions ───────────────────────────────────────────────────────
CustomTransitionPage<void> _fadeTransition({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}

CustomTransitionPage<void> _slideTransition({
  required LocalKey key,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final offsetAnim = Tween<Offset>(
        begin: const Offset(0.08, 0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: Curves.easeOut));
      return SlideTransition(
        position: offsetAnim,
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}
