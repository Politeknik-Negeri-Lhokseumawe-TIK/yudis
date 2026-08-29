import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../features/auth/presentation/providers/auth_provider.dart';
import '../features/auth/presentation/screens/splash_screen.dart';
import '../features/auth/presentation/screens/login_screen.dart';
import '../features/auth/presentation/screens/register_screen.dart';
import '../features/auth/presentation/screens/pending_screen.dart';
import '../features/peminjaman_ruang/presentation/screens/dashboard_peminjam_screen.dart';
import '../features/peminjaman_ruang/presentation/screens/roster_digital_screen.dart';
import '../features/peminjaman_ruang/presentation/screens/ketersediaan_ruang_screen.dart';
import '../features/peminjaman_ruang/presentation/screens/form_peminjaman_screen.dart';
import '../features/peminjaman_ruang/presentation/screens/pengembalian_ruang_screen.dart';
import '../features/peminjaman_ruang/presentation/screens/detail_peminjaman_screen.dart';
import '../features/admin_verifikasi/presentation/screens/admin_peminjaman_dashboard_screen.dart';
import '../features/notifikasi/presentation/screens/notifikasi_screen.dart';
import '../features/peminjaman_ruang/presentation/screens/counter_resepsionis_screen.dart';
import '../features/peminjaman_ruang/presentation/screens/kiosk_mahasiswa_screen.dart';

/// GoRouter config untuk Sistem Manajemen Peminjaman Lab & Ruang Kelas (SIM-LAB TIK PNL)
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

      final publicPaths = ['/splash', '/login', '/register', '/kiosk', '/resepsionis'];
      final isPublicPath = publicPaths.contains(location);

      if (!isAuth && !isPublicPath) {
        return '/login';
      }

      if (isAuth && (location == '/login' || location == '/splash')) {
        if (authState.isAdmin) return '/resepsionis';
        return '/kiosk';
      }

      return null;
    },
    routes: [
      // ── Root / redirect ─────────────────────────────────────────────
      GoRoute(
        path: '/',
        redirect: (context, state) => '/splash',
      ),

      // ── Auth pages ──────────────────────────────────────────────────
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

      // ── Roster & Availability (Public / Authenticated) ──────────────
      GoRoute(
        path: '/roster-digital',
        pageBuilder: (context, state) => _slideTransition(
          key: state.pageKey,
          child: const RosterDigitalScreen(),
        ),
      ),
      GoRoute(
        path: '/ketersediaan-ruangan',
        pageBuilder: (context, state) {
          final roomCode = state.uri.queryParameters['roomCode'];
          return _slideTransition(
            key: state.pageKey,
            child: KetersediaanRuangScreen(initialRoomCode: roomCode),
          );
        },
      ),

      // ── Peminjaman & Checkout Workflow ──────────────────────────────
      GoRoute(
        path: '/form-peminjaman',
        pageBuilder: (context, state) {
          final room = state.uri.queryParameters['prefillRoom'];
          final day = state.uri.queryParameters['prefillDay'];
          final sessionStr = state.uri.queryParameters['prefillSession'];
          final session = sessionStr != null ? int.tryParse(sessionStr) : null;
          return _slideTransition(
            key: state.pageKey,
            child: FormPeminjamanScreen(
              prefillRoom: room,
              prefillDay: day,
              prefillSession: session,
            ),
          );
        },
      ),
      GoRoute(
        path: '/pengembalian-ruang',
        pageBuilder: (context, state) {
          final bookingId = state.uri.queryParameters['bookingId'] ?? '';
          return _slideTransition(
            key: state.pageKey,
            child: PengembalianRuangScreen(bookingId: bookingId),
          );
        },
      ),
      GoRoute(
        path: '/detail-peminjaman',
        pageBuilder: (context, state) {
          final bookingId = state.uri.queryParameters['bookingId'] ?? '';
          return _slideTransition(
            key: state.pageKey,
            child: DetailPeminjamanScreen(bookingId: bookingId),
          );
        },
      ),

      // ── Mahasiswa Dashboard & Notifikasi ─────────────────────────────
      GoRoute(
        path: '/mahasiswa/dashboard',
        pageBuilder: (context, state) => _fadeTransition(
          key: state.pageKey,
          child: const DashboardPeminjamScreen(),
        ),
      ),
      GoRoute(
        path: '/notifikasi',
        pageBuilder: (context, state) => _slideTransition(
          key: state.pageKey,
          child: const NotifikasiScreen(),
        ),
      ),

      // ── Admin / Laboran Dashboard ────────────────────────────────────
      GoRoute(
        path: '/admin/dashboard',
        pageBuilder: (context, state) => _fadeTransition(
          key: state.pageKey,
          child: const AdminPeminjamanDashboardScreen(),
        ),
      ),

      // ── Komputer 1: Meja Resepsionis / Front Desk Counter ──────────
      GoRoute(
        path: '/resepsionis',
        pageBuilder: (context, state) => _fadeTransition(
          key: state.pageKey,
          child: const CounterResepsionisScreen(),
        ),
      ),

      // ── Komputer 2 & Komputer 3: Kiosk Mandiri Kelas Roster PBM ─────
      GoRoute(
        path: '/kiosk',
        pageBuilder: (context, state) => _fadeTransition(
          key: state.pageKey,
          child: const KioskMahasiswaScreen(),
        ),
      ),
    ],
    errorBuilder: (context, state) => Scaffold(
      backgroundColor: const Color(0xFF070410),
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
                child: const Icon(Icons.broken_image_outlined, color: Colors.white60, size: 40),
              ),
              const SizedBox(height: 20),
              const Text(
                'Halaman Tidak Ditemukan (404)',
                style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Text(
                'Rute "${state.uri}" tidak tersedia atau telah dipindahkan.',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white54, fontSize: 14),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: () => context.go('/'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF7C3AED),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
