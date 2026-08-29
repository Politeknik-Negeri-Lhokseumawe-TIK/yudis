import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_tokens.dart';

/// SkeletonBox — animasi shimmer untuk loading state
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  final double width;
  final double height;
  final double? borderRadius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    )..repeat();
    _anim = Tween<double>(begin: -1.5, end: 1.5).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Container(
        width: widget.width,
        height: widget.height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(widget.borderRadius ?? 8),
          gradient: LinearGradient(
            begin: Alignment(_anim.value - 1, 0),
            end: Alignment(_anim.value, 0),
            colors: [
              AppTokens.bgDarkCard,
              AppTokens.bgDarkCardHover,
              AppTokens.bgDarkCard,
            ],
          ),
        ),
      ),
    );
  }
}

/// SkeletonCard — skeleton card untuk daftar peminjaman
class SkeletonCard extends StatelessWidget {
  const SkeletonCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTokens.bgDarkCard,
        borderRadius: BorderRadius.circular(AppTokens.radiusLG),
        border: Border.all(color: AppTokens.glassBorderColor),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const SkeletonBox(width: 72, height: 24, borderRadius: 6),
              const SizedBox(width: 10),
              Expanded(child: const SkeletonBox(width: double.infinity, height: 16)),
              const SizedBox(width: 10),
              const SkeletonBox(width: 60, height: 20, borderRadius: 10),
            ],
          ),
          const SizedBox(height: 12),
          const SkeletonBox(width: 200, height: 13),
          const SizedBox(height: 6),
          const SkeletonBox(width: 280, height: 13),
          const SizedBox(height: 12),
          const Divider(color: Colors.white10),
          const SizedBox(height: 10),
          Row(
            children: [
              const SkeletonBox(width: 90, height: 30, borderRadius: 8),
              const Spacer(),
              const SkeletonBox(width: 130, height: 30, borderRadius: 8),
            ],
          ),
        ],
      ),
    );
  }
}

/// SkeletonStatRow — skeleton untuk 3 stat cards
class SkeletonStatRow extends StatelessWidget {
  const SkeletonStatRow({super.key, this.count = 3});
  final int count;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < count; i++) ...[
          Expanded(
            child: Container(
              height: 90,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppTokens.bgDarkCard,
                borderRadius: BorderRadius.circular(AppTokens.radiusLG),
                border: Border.all(color: AppTokens.glassBorderColor),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SkeletonBox(width: 36, height: 36, borderRadius: 8),
                      const SkeletonBox(width: 48, height: 20, borderRadius: 4),
                    ],
                  ),
                  const SkeletonBox(width: 80, height: 12),
                ],
              ),
            ),
          ),
          if (i < count - 1) const SizedBox(width: 10),
        ],
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────

/// EmptyStateWidget — ilustrasi + teks untuk daftar kosong
class EmptyStateWidget extends StatelessWidget {
  const EmptyStateWidget({
    super.key,
    required this.title,
    required this.subtitle,
    this.icon,
    this.action,
    this.actionLabel,
  });

  final String title;
  final String subtitle;
  final IconData? icon;
  final VoidCallback? action;
  final String? actionLabel;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _AnimatedEmptyIcon(icon: icon ?? Icons.inbox_rounded),
          const SizedBox(height: AppTokens.spaceLG),
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTokens.spaceXS),
          Text(
            subtitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTokens.textMutedDark,
                ),
            textAlign: TextAlign.center,
          ),
          if (action != null && actionLabel != null) ...[
            const SizedBox(height: AppTokens.spaceLG),
            ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTokens.primaryPurple,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: AppTokens.spaceLG,
                  vertical: AppTokens.spaceSM,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTokens.radiusMD),
                ),
              ),
              onPressed: action,
              icon: const Icon(Icons.add_rounded, size: 18),
              label: Text(actionLabel!),
            ),
          ],
        ],
      ),
    ).animate().fadeIn(duration: AppTokens.durationSlow).slideY(begin: 0.1, end: 0);
  }
}

class _AnimatedEmptyIcon extends StatefulWidget {
  const _AnimatedEmptyIcon({required this.icon});
  final IconData icon;

  @override
  State<_AnimatedEmptyIcon> createState() => _AnimatedEmptyIconState();
}

class _AnimatedEmptyIconState extends State<_AnimatedEmptyIcon>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _float;
  late Animation<double> _glow;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 3))
      ..repeat(reverse: true);
    _float = Tween<double>(begin: 0, end: -12).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
    _glow = Tween<double>(begin: 0.3, end: 0.7).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Transform.translate(
        offset: Offset(0, _float.value),
        child: Container(
          width: 96,
          height: 96,
          decoration: BoxDecoration(
            color: AppTokens.primaryPurple.withValues(alpha: 0.10),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: AppTokens.primaryPurpleLight.withValues(alpha: _glow.value * 0.5),
                blurRadius: 40,
                spreadRadius: -5,
              ),
            ],
            border: Border.all(
              color: AppTokens.primaryPurpleLight.withValues(alpha: _glow.value),
              width: 1.5,
            ),
          ),
          child: Icon(
            widget.icon,
            size: 48,
            color: AppTokens.primaryPurpleLight.withValues(alpha: 0.7),
          ),
        ),
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────

/// PageTransitionWrapper — animasi transisi halaman konsisten
class PageTransitionWrapper extends StatelessWidget {
  const PageTransitionWrapper({
    super.key,
    required this.child,
    this.delay = Duration.zero,
  });

  final Widget child;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    return child
        .animate(delay: delay)
        .fadeIn(duration: AppTokens.durationNormal)
        .slideX(begin: 0.04, end: 0, duration: AppTokens.durationSlow, curve: Curves.easeOutCubic);
  }
}

// ─────────────────────────────────────────────────────────────────

/// NeonLiveIndicator — dot pulsating untuk status "live / real-time"
class NeonLiveIndicator extends StatefulWidget {
  const NeonLiveIndicator({
    super.key,
    this.label = 'LIVE',
    this.color,
    this.size = 8.0,
  });

  final String label;
  final Color? color;
  final double size;

  @override
  State<NeonLiveIndicator> createState() => _NeonLiveIndicatorState();
}

class _NeonLiveIndicatorState extends State<NeonLiveIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _anim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(milliseconds: 900))
      ..repeat(reverse: true);
    _anim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppTokens.success;

    return AnimatedBuilder(
      animation: _anim,
      builder: (context, child) => Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              // Outer pulse ring
              Container(
                width: widget.size * 2.5,
                height: widget.size * 2.5,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: color.withValues(alpha: _anim.value * 0.2),
                ),
              ),
              // Core dot
              Container(
                width: widget.size,
                height: widget.size,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: _anim.value),
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: color.withValues(alpha: _anim.value * 0.6),
                      blurRadius: 6,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(width: 5),
          Text(
            widget.label,
            style: TextStyle(
              color: color,
              fontSize: AppTokens.textXS,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.8,
            ),
          ),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────

/// ActiveSessionBanner — banner "Sesi Aktif Sekarang" untuk screen roster
class ActiveSessionBanner extends StatelessWidget {
  const ActiveSessionBanner({
    super.key,
    required this.sessionNumber,
    required this.startTime,
    required this.endTime,
    required this.activeCount,
    this.onTap,
  });

  final int sessionNumber;
  final String startTime;
  final String endTime;
  final int activeCount;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spaceMD,
          vertical: AppTokens.spaceSM,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppTokens.success.withValues(alpha: 0.20),
              AppTokens.primaryPurple.withValues(alpha: 0.15),
            ],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          border: Border(
            left: BorderSide(color: AppTokens.success, width: 3),
            top: BorderSide(color: AppTokens.success.withValues(alpha: 0.25)),
            bottom: BorderSide(color: AppTokens.success.withValues(alpha: 0.25)),
            right: BorderSide(color: AppTokens.success.withValues(alpha: 0.25)),
          ),
        ),
        child: Row(
          children: [
            const NeonLiveIndicator(label: 'SESI AKTIF', color: AppTokens.success),
            const SizedBox(width: AppTokens.spaceMD),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sesi $sessionNumber — $startTime s/d $endTime WIB',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppTokens.textSM,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  Text(
                    '$activeCount sesi kuliah berlangsung saat ini',
                    style: TextStyle(
                      color: AppTokens.textMutedDark,
                      fontSize: AppTokens.textXS,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppTokens.success.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(AppTokens.radiusCircle),
                border: Border.all(
                  color: AppTokens.success.withValues(alpha: 0.4),
                ),
              ),
              child: Text(
                'Hari Ini',
                style: TextStyle(
                  color: AppTokens.success,
                  fontSize: AppTokens.textXS,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    ).animate(onPlay: (c) => c.repeat(reverse: true))
        .shimmer(
          duration: const Duration(seconds: 3),
          color: AppTokens.success.withValues(alpha: 0.06),
        );
  }
}

// ─────────────────────────────────────────────────────────────────

/// NeonDivider — divider dengan glow effect
class NeonDivider extends StatelessWidget {
  const NeonDivider({super.key, this.color});
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final c = color ?? AppTokens.primaryPurpleLight;
    return Container(
      height: 1,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.transparent,
            c.withValues(alpha: 0.5),
            c.withValues(alpha: 0.5),
            Colors.transparent,
          ],
        ),
        boxShadow: [
          BoxShadow(color: c.withValues(alpha: 0.3), blurRadius: 4),
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────

/// DigitalClockWidget — Jam digital dengan font monospace dan glow effect
class DigitalClockWidget extends StatelessWidget {
  const DigitalClockWidget({
    super.key,
    required this.time,
    required this.dateStr,
    this.compact = false,
  });

  final String time;
  final String dateStr;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? 10 : 14,
        vertical: compact ? 5 : 7,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFF050312),
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        border: Border.all(
          color: AppTokens.primaryPurpleLight.withValues(alpha: 0.35),
        ),
        boxShadow: [
          BoxShadow(
            color: AppTokens.primaryPurple.withValues(alpha: 0.25),
            blurRadius: 16,
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.access_time_filled_rounded,
                color: AppTokens.accentGold,
                size: compact ? 12 : 14,
              ),
              const SizedBox(width: 6),
              Text(
                '$time WIB',
                style: TextStyle(
                  color: AppTokens.primaryPurpleGlow,
                  fontFamily: 'monospace',
                  fontWeight: FontWeight.w900,
                  fontSize: compact ? 13 : 15,
                  letterSpacing: 2.0,
                  shadows: [
                    Shadow(
                      color: AppTokens.primaryPurpleLight.withValues(alpha: 0.8),
                      blurRadius: 8,
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (!compact) ...[
            const SizedBox(height: 2),
            Text(
              dateStr,
              style: TextStyle(
                color: AppTokens.textMutedDark,
                fontSize: AppTokens.textXS,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────

/// _SpinnerWidget — indikator loading spinning dengan warna brand
class CyberLoadingIndicator extends StatefulWidget {
  const CyberLoadingIndicator({super.key, this.size = 48.0});
  final double size;

  @override
  State<CyberLoadingIndicator> createState() => _CyberLoadingIndicatorState();
}

class _CyberLoadingIndicatorState extends State<CyberLoadingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, child) => Transform.rotate(
        angle: _ctrl.value * 2 * math.pi,
        child: SizedBox(
          width: widget.size,
          height: widget.size,
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTokens.primaryPurpleLight),
            backgroundColor: AppTokens.primaryPurple.withValues(alpha: 0.2),
            strokeWidth: 3,
          ),
        ),
      ),
    );
  }
}
