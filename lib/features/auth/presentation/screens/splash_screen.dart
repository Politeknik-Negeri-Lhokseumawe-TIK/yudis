import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../core/theme/app_tokens.dart';
import 'package:flutter_animate/flutter_animate.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _logoController;

  @override
  void initState() {
    super.initState();
    _logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..forward();
  }

  @override
  void dispose() {
    _logoController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Listen untuk auth state change & navigate
    ref.listen<AuthState>(authProvider, (prev, next) {
      if (!next.isInitialized) return;
      _navigate(context, next);
    });

    final authState = ref.watch(authProvider);
    if (authState.isInitialized) {
      // Langsung navigate kalau sudah siap
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) _navigate(context, authState);
      });
    }

    return Scaffold(
      body: AnimatedBackground(
        child: SafeArea(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo PNL
                _buildLogo(context),
                const SizedBox(height: AppTokens.spaceLG),

                // Nama Institusi
                _buildInstitusiText(context),

                const SizedBox(height: AppTokens.spaceXXXL),

                // Loading indicator
                _buildLoadingIndicator(),

                const SizedBox(height: AppTokens.spaceMD),
                Text(
                  'Memuat...',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white54,
                      ),
                ).animate().fadeIn(delay: 800.ms),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLogo(BuildContext context) {
    return Column(
      children: [
        // Ornamen lingkaran
        Stack(
          alignment: Alignment.center,
          children: [
            // Glow ring
            Container(
              width: 140,
              height: 140,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppTokens.primaryGreenLight.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppTokens.primaryGreenLight.withValues(alpha: 0.2),
                    blurRadius: 40,
                    spreadRadius: 10,
                  ),
                ],
              ),
            ).animate().scale(
                  delay: 200.ms,
                  duration: 800.ms,
                  curve: Curves.elasticOut,
                ),

            // Logo container
            Container(
              width: 110,
              height: 110,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withValues(alpha: 0.1),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
              padding: const EdgeInsets.all(12),
              child: ClipOval(
                child: Image.asset(
                  'assets/images/logo_pnl.jpg',
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => Center(
                    child: Text(
                      'PNL',
                      style: TextStyle(
                        color: AppTokens.accentGold,
                        fontWeight: FontWeight.w900,
                        fontSize: 28,
                      ),
                    ),
                  ),
                ),
              ),
            ).animate().fadeIn(delay: 400.ms, duration: 600.ms),
          ],
        ),
      ],
    ).animate().slideY(
          begin: -0.3,
          end: 0,
          delay: 100.ms,
          duration: 700.ms,
          curve: Curves.easeOut,
        );
  }

  Widget _buildInstitusiText(BuildContext context) {
    return Column(
      children: [
        Text(
          'SIM-LAB & RUANG PBM',
          style: Theme.of(context).textTheme.displayMedium?.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 24,
                letterSpacing: -0.5,
              ),
        ),
        const SizedBox(height: AppTokens.spaceXXS),
        Text(
          'Sistem Manajemen Peminjaman Ruang & Lab PBM',
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                color: AppTokens.accentGold,
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
        ),
        const SizedBox(height: AppTokens.spaceXXS),
        Text(
          'Politeknik Negeri Lhokseumawe',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Colors.white60,
              ),
        ),
      ],
    )
        .animate()
        .fadeIn(delay: 600.ms, duration: 600.ms)
        .slideY(begin: 0.2, end: 0, delay: 600.ms, duration: 600.ms);
  }

  Widget _buildLoadingIndicator() {
    return SizedBox(
      width: 32,
      height: 32,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        valueColor: AlwaysStoppedAnimation<Color>(
          AppTokens.primaryGreenLight.withValues(alpha: 0.8),
        ),
      ),
    ).animate().fadeIn(delay: 1000.ms);
  }

  void _navigate(BuildContext context, AuthState state) {
    if (!state.isAuthenticated) {
      context.go('/login');
    } else if (state.isPendingVerifikasi) {
      context.go('/pending-verifikasi');
    } else if (state.isAdmin) {
      context.go('/admin/dashboard');
    } else {
      context.go('/mahasiswa/dashboard');
    }
  }
}
