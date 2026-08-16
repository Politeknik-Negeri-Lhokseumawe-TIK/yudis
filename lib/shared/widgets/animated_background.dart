import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Animated background mutakhir dengan prioritas:
/// 1. 💜 UNGU UTAMA — Melambangkan Jurusan Teknologi Informasi dan Komputer (TIK)
/// 2. 💛 KUNING CERAH / EMAS — Melambangkan Politeknik Negeri Lhokseumawe (PNL)
/// 3. 🤍 PUTIH BERSIH — Kontras tajam, starlight radiance & kejernihan data
/// 4. 🕸️ NEURAL NETWORK PARTICLES — Interkoneksi simpul cerdas bertema TRKJ/TIK
class AnimatedBackground extends StatefulWidget {
  const AnimatedBackground({
    super.key,
    required this.child,
    this.showBlobs = true,
    this.showNetwork = true,
    this.blobCount = 4,
  });

  final Widget child;
  final bool showBlobs;
  final bool showNetwork;
  final int blobCount;

  @override
  State<AnimatedBackground> createState() => _AnimatedBackgroundState();
}

class _AnimatedBackgroundState extends State<AnimatedBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 16),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // StackFit.passthrough: child menentukan bounded/unbounded size
    return Stack(
      fit: StackFit.passthrough,
      children: [
        // ── Layer 1: Ambient Gradient Background (TIK Deep Violet Base) ─
        Positioned.fill(
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final t = _controller.value;
              final sinT = math.sin(t * 2 * math.pi);
              final cosT = math.cos(t * 2 * math.pi);

              return Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment(-0.8 + 0.35 * sinT, -1.0 + 0.25 * cosT),
                    end: Alignment(0.8 - 0.35 * sinT, 1.0 - 0.25 * cosT),
                    colors: const [
                      Color(0xFF06030D), // Deep Obsidian Purple
                      Color(0xFF130826), // Royal TIK Violet Chamber
                      Color(0xFF1E0C38), // Electric Purple Twilight
                      Color(0xFF0A0414), // Base Midnight TIK Dark
                    ],
                    stops: const [0.0, 0.35, 0.70, 1.0],
                  ),
                ),
              );
            },
          ),
        ),

        // ── Layer 2: Luminous Color Orbs (Ungu TIK, Kuning PNL, Putih) ──
        if (widget.showBlobs)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _TikThemeOrbPainter(
                    progress: _controller.value,
                  ),
                );
              },
            ),
          ),

        // ── Layer 3: Network Particle Grid (TRKJ / TIK Cyber Mesh) ──────
        if (widget.showNetwork)
          Positioned.fill(
            child: AnimatedBuilder(
              animation: _controller,
              builder: (context, _) {
                return CustomPaint(
                  painter: _TikNetworkParticlePainter(
                    progress: _controller.value,
                  ),
                );
              },
            ),
          ),

        // ── Layer 4: Subtle Vignette & Depth Contrast ───────────────────
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              gradient: RadialGradient(
                center: Alignment.center,
                radius: 1.3,
                colors: [
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.40),
                ],
                stops: const [0.55, 1.0],
              ),
            ),
          ),
        ),

        // ── Layer 5: Child Content (Interactive UI) ─────────────────────
        widget.child,
      ],
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// LUMINOUS ORB PAINTER (Dominasi Ungu TIK + Kuning PNL + Putih Bersih)
// ─────────────────────────────────────────────────────────────────────────────
class _TikThemeOrbPainter extends CustomPainter {
  _TikThemeOrbPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0) return;

    final orbs = [
      // Orb 1 (Dominan 1): UNGU TIK PRIMER — Kiri Bawah & Tengah
      _OrbConfig(
        baseX: 0.20,
        baseY: 0.72,
        radiusFactor: 0.42,
        dxAmp: 0.10,
        dyAmp: 0.08,
        phase: 0.0,
        colors: [
          const Color(0xFFA855F7).withValues(alpha: 0.24), // Vibrant TIK Purple
          const Color(0xFF7C3AED).withValues(alpha: 0.14), // Royal Violet
          const Color(0xFF5B21B6).withValues(alpha: 0.04),
          Colors.transparent,
        ],
      ),
      // Orb 2 (Dominan 2): KUNING PNL CERAH — Kanan Atas
      _OrbConfig(
        baseX: 0.82,
        baseY: 0.22,
        radiusFactor: 0.35,
        dxAmp: 0.08,
        dyAmp: 0.09,
        phase: 0.30,
        colors: [
          const Color(0xFFFDE047).withValues(alpha: 0.22), // Radiant PNL Yellow
          const Color(0xFFF59E0B).withValues(alpha: 0.12), // Amber Gold PNL
          const Color(0xFFD97706).withValues(alpha: 0.03),
          Colors.transparent,
        ],
      ),
      // Orb 3: PUTIH BERSIH / ETHEREAL WHITE STARLIGHT — Tengah Atas
      _OrbConfig(
        baseX: 0.42,
        baseY: 0.28,
        radiusFactor: 0.28,
        dxAmp: 0.07,
        dyAmp: 0.06,
        phase: 0.60,
        colors: [
          Colors.white.withValues(alpha: 0.18),             // Pure White Glow
          const Color(0xFFF3E8FF).withValues(alpha: 0.09), // Soft Lilac
          const Color(0xFFE9D5FF).withValues(alpha: 0.03),
          Colors.transparent,
        ],
      ),
      // Orb 4: NEON MAGENTA / VIOLET GLOW — Pojok Kanan Bawah
      _OrbConfig(
        baseX: 0.75,
        baseY: 0.80,
        radiusFactor: 0.32,
        dxAmp: 0.09,
        dyAmp: 0.07,
        phase: 0.85,
        colors: [
          const Color(0xFFC084FC).withValues(alpha: 0.18), // Electric Lilac
          const Color(0xFF9333EA).withValues(alpha: 0.09), // Violet Deep
          const Color(0xFF7E22CE).withValues(alpha: 0.03),
          Colors.transparent,
        ],
      ),
    ];

    for (final orb in orbs) {
      final t = (progress + orb.phase) % 1.0;
      final cx = size.width *
          (orb.baseX + orb.dxAmp * math.sin(t * 2 * math.pi));
      final cy = size.height *
          (orb.baseY + orb.dyAmp * math.cos(t * 2 * math.pi));
      final radius = size.shortestSide * orb.radiusFactor;

      final paint = Paint()
        ..shader = RadialGradient(
          colors: orb.colors,
          stops: const [0.0, 0.35, 0.70, 1.0],
        ).createShader(Rect.fromCircle(center: Offset(cx, cy), radius: radius))
        ..blendMode = BlendMode.screen;

      canvas.drawCircle(Offset(cx, cy), radius, paint);
    }
  }

  @override
  bool shouldRepaint(_TikThemeOrbPainter old) => old.progress != progress;
}

class _OrbConfig {
  const _OrbConfig({
    required this.baseX,
    required this.baseY,
    required this.radiusFactor,
    required this.dxAmp,
    required this.dyAmp,
    required this.phase,
    required this.colors,
  });

  final double baseX;
  final double baseY;
  final double radiusFactor;
  final double dxAmp;
  final double dyAmp;
  final double phase;
  final List<Color> colors;
}

// ─────────────────────────────────────────────────────────────────────────────
// NETWORK PARTICLE PAINTER (Partikel Ungu TIK, Kuning PNL, & Putih Bersih)
// ─────────────────────────────────────────────────────────────────────────────
class _TikNetworkParticlePainter extends CustomPainter {
  _TikNetworkParticlePainter({required this.progress}) {
    _initParticlesOnce();
  }

  final double progress;
  static List<_NetworkNode>? _cachedNodes;

  void _initParticlesOnce() {
    if (_cachedNodes != null) return;
    final random = math.Random(1337);
    const count = 42;

    // Komposisi: Ungu TIK (50%), Kuning PNL (30%), Putih Bersih (20%)
    final palette = [
      const Color(0xFFC084FC), // Ungu TIK Neon
      const Color(0xFFA855F7), // Ungu TIK Cerah
      const Color(0xFFFDE047), // Kuning PNL Terang
      const Color(0xFFF59E0B), // Kuning Emas PNL
      Colors.white,            // Putih Bersih
      const Color(0xFFE879F9), // Orchid Violet TIK
      const Color(0xFFDDD6FE), // Lavender Putih
    ];

    _cachedNodes = List.generate(count, (i) {
      return _NetworkNode(
        initialX: random.nextDouble(),
        initialY: random.nextDouble(),
        speedX: (random.nextDouble() - 0.5) * 0.075,
        speedY: (random.nextDouble() - 0.5) * 0.075,
        radius: 2.0 + random.nextDouble() * 2.8,
        color: palette[i % palette.length],
        pulseOffset: random.nextDouble() * 2 * math.pi,
      );
    });
  }

  @override
  void paint(Canvas canvas, Size size) {
    if (size.width <= 0 || size.height <= 0 || _cachedNodes == null) return;

    final nodeOffsets = <Offset>[];
    final nodePaints = <Paint>[];
    final pulseFactors = <double>[];

    // 1. Posisi aktual setiap titik simpul partikel
    for (final node in _cachedNodes!) {
      final t = progress;
      final rawX = (node.initialX + node.speedX * t * 10) % 1.0;
      final rawY = (node.initialY + node.speedY * t * 10) % 1.0;

      final x = (rawX < 0 ? rawX + 1.0 : rawX) * size.width;
      final y = (rawY < 0 ? rawY + 1.0 : rawY) * size.height;
      nodeOffsets.add(Offset(x, y));

      final pulse = (math.sin(progress * 4 * math.pi + node.pulseOffset) + 1.0) / 2.0;
      pulseFactors.add(pulse);

      final paint = Paint()
        ..color = node.color.withValues(alpha: 0.40 + 0.55 * pulse)
        ..style = PaintingStyle.fill;
      nodePaints.add(paint);
    }

    // 2. Garis interkoneksi cerdas (Mesh Network) dengan gradasi warna Ungu & Kuning
    final connectionThreshold = size.shortestSide * 0.17;
    final linePaint = Paint()
      ..strokeWidth = 0.9
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < nodeOffsets.length; i++) {
      for (int j = i + 1; j < nodeOffsets.length; j++) {
        final p1 = nodeOffsets[i];
        final p2 = nodeOffsets[j];
        final distance = (p1 - p2).distance;

        if (distance < connectionThreshold) {
          final proximity = 1.0 - (distance / connectionThreshold);
          final alpha = (proximity * proximity * 0.32).clamp(0.0, 1.0);

          final c1 = _cachedNodes![i].color;
          final c2 = _cachedNodes![j].color;
          final midColor = Color.lerp(c1, c2, 0.5) ?? Colors.white;

          linePaint.color = midColor.withValues(alpha: alpha);
          canvas.drawLine(p1, p2, linePaint);
        }
      }
    }

    // 3. Simpul Nodes + Glowing Halo berdenyut
    for (int i = 0; i < nodeOffsets.length; i++) {
      final offset = nodeOffsets[i];
      final node = _cachedNodes![i];
      final pulse = pulseFactors[i];

      // Outer luminous halo
      final glowPaint = Paint()
        ..color = node.color.withValues(alpha: 0.20 * pulse)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(offset, node.radius * (2.0 + 0.8 * pulse), glowPaint);

      // Core particle dot
      canvas.drawCircle(offset, node.radius, nodePaints[i]);
    }
  }

  @override
  bool shouldRepaint(_TikNetworkParticlePainter old) => old.progress != progress;
}

class _NetworkNode {
  const _NetworkNode({
    required this.initialX,
    required this.initialY,
    required this.speedX,
    required this.speedY,
    required this.radius,
    required this.color,
    required this.pulseOffset,
  });

  final double initialX;
  final double initialY;
  final double speedX;
  final double speedY;
  final double radius;
  final Color color;
  final double pulseOffset;
}

// ─────────────────────────────────────────────────────────────────────────────
// LIGHT ANIMATED BACKGROUND (Fallback)
// ─────────────────────────────────────────────────────────────────────────────
class LightAnimatedBackground extends StatelessWidget {
  const LightAnimatedBackground({super.key, required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFFFAF5FF), // Lilac soft
            Color(0xFFFFFBEB), // Soft Amber PNL
            Color(0xFFFFFFFF),
          ],
        ),
      ),
      child: child,
    );
  }
}
