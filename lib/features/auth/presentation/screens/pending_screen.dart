import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/auth_provider.dart';
import '../../../../shared/widgets/animated_background.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../../../shared/widgets/glass_button.dart';
import '../../../../core/theme/app_tokens.dart';

class PendingScreen extends ConsumerWidget {
  const PendingScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authProvider).user;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        body: AnimatedBackground(
          blobCount: 2,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(AppTokens.spaceLG),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated icon
                  _buildWaitingIcon(context),
                  const SizedBox(height: AppTokens.spaceXL),

                  // Title
                  Text(
                    'Akun Sedang\nDiverifikasi',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                          height: 1.2,
                        ),
                  ).animate().fadeIn(delay: 300.ms).slideY(begin: 0.2, end: 0),
                  const SizedBox(height: AppTokens.spaceMD),

                  Text(
                    'Admin akan memverifikasi akunmu dalam 1×24 jam. '
                    'Kamu akan mendapat notifikasi setelah akun disetujui.',
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Colors.white60,
                          height: 1.5,
                        ),
                  ).animate().fadeIn(delay: 500.ms),
                  const SizedBox(height: AppTokens.spaceXL),

                  // Info card
                  if (user != null) _buildInfoCard(context, user.nim, user.nama),
                  const SizedBox(height: AppTokens.spaceXL),

                  // Logout button
                  GlassButton(
                    label: 'Keluar',
                    icon: Icons.logout_rounded,
                    variant: GlassButtonVariant.outlined,
                    isFullWidth: false,
                    onPressed: () async {
                      await ref.read(authProvider.notifier).logout();
                      if (context.mounted) context.go('/login');
                    },
                  ).animate().fadeIn(delay: 700.ms),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWaitingIcon(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Pulsing outer ring
        Container(
          width: 130,
          height: 130,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTokens.warning.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
        )
            .animate(onPlay: (c) => c.repeat())
            .scaleXY(
              begin: 0.9,
              end: 1.1,
              duration: 1500.ms,
              curve: Curves.easeInOut,
            )
            .fadeOut(begin: 0.8, duration: 1500.ms),

        // Icon container
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppTokens.warning.withValues(alpha: 0.15),
            border: Border.all(color: AppTokens.warning.withValues(alpha: 0.4)),
          ),
          child: const Icon(
            Icons.hourglass_top_rounded,
            color: AppTokens.warning,
            size: 48,
          ),
        )
            .animate(onPlay: (c) => c.repeat(reverse: true))
            .moveY(begin: -4, end: 4, duration: 1500.ms, curve: Curves.easeInOut),
      ],
    ).animate().fadeIn(duration: 600.ms).scale(
          begin: const Offset(0.8, 0.8),
          end: const Offset(1, 1),
          duration: 600.ms,
          curve: Curves.elasticOut,
        );
  }

  Widget _buildInfoCard(BuildContext context, String nim, String nama) {
    return GlassCard(
      borderColor: AppTokens.warning.withValues(alpha: 0.3),
      padding: const EdgeInsets.all(AppTokens.spaceMD),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(AppTokens.spaceXS),
            decoration: BoxDecoration(
              color: AppTokens.warning.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppTokens.radiusSM),
            ),
            child: const Icon(Icons.person_outline_rounded,
                color: AppTokens.warning, size: 20),
          ),
          const SizedBox(width: AppTokens.spaceMD),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                nama,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                'NIM: $nim',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Colors.white54,
                    ),
              ),
            ],
          ),
          const Spacer(),
          Chip(
            label: Text(
              'Pending',
              style: TextStyle(
                color: AppTokens.warning,
                fontSize: AppTokens.textXS,
                fontWeight: FontWeight.w600,
              ),
            ),
            backgroundColor: AppTokens.warning.withValues(alpha: 0.15),
            side: BorderSide(color: AppTokens.warning.withValues(alpha: 0.4)),
          ),
        ],
      ),
    ).animate().fadeIn(delay: 600.ms).slideY(begin: 0.2, end: 0);
  }
}
