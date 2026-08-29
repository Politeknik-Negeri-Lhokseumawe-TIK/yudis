import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_tokens.dart';

/// NeonStatCard — Metric card berteknologi tinggi dengan animasi counter
/// Menampilkan satu metrik utama dengan icon, trend indicator, dan breakdown opsional.
class NeonStatCard extends StatelessWidget {
  const NeonStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
    this.color,
    this.trend,
    this.trendLabel,
    this.breakdownItems,
    this.onTap,
    this.animateEntry = true,
    this.delay = Duration.zero,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color? color;

  /// Nilai persentase trend: positif = hijau naik, negatif = merah turun
  final double? trend;
  final String? trendLabel;

  /// Pasangan label-value untuk baris breakdown opsional
  final List<MapEntry<String, String>>? breakdownItems;

  final VoidCallback? onTap;
  final bool animateEntry;
  final Duration delay;

  @override
  Widget build(BuildContext context) {
    final accentColor = color ?? AppTokens.brand;

    Widget card = _NeonStatCardBody(
      title: title,
      value: value,
      icon: icon,
      accentColor: accentColor,
      trend: trend,
      trendLabel: trendLabel,
      breakdownItems: breakdownItems,
      onTap: onTap,
    );

    if (animateEntry) {
      card = card
          .animate(delay: delay)
          .fadeIn(duration: AppTokens.durationNormal)
          .slideY(begin: 0.15, end: 0, duration: AppTokens.durationSlow, curve: Curves.easeOutCubic);
    }

    return card;
  }
}

class _NeonStatCardBody extends StatefulWidget {
  const _NeonStatCardBody({
    required this.title,
    required this.value,
    required this.icon,
    required this.accentColor,
    this.trend,
    this.trendLabel,
    this.breakdownItems,
    this.onTap,
  });

  final String title;
  final String value;
  final IconData icon;
  final Color accentColor;
  final double? trend;
  final String? trendLabel;
  final List<MapEntry<String, String>>? breakdownItems;
  final VoidCallback? onTap;

  @override
  State<_NeonStatCardBody> createState() => _NeonStatCardBodyState();
}

class _NeonStatCardBodyState extends State<_NeonStatCardBody>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _pulseAnim = Tween<double>(begin: 0.6, end: 1.0).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasTrend = widget.trend != null;
    final trendPositive = (widget.trend ?? 0) >= 0;
    final trendColor = trendPositive ? AppTokens.success : AppTokens.error;

    return MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: AppTokens.durationNormal,
          curve: Curves.easeOutCubic,
          padding: const EdgeInsets.all(AppTokens.spaceMD),
          decoration: BoxDecoration(
            color: _isHovered
                ? AppTokens.bgDarkCardHover
                : AppTokens.bgDarkCard,
            borderRadius: BorderRadius.circular(AppTokens.radiusLG),
            border: Border.all(
              color: _isHovered
                  ? widget.accentColor.withValues(alpha: 0.50)
                  : widget.accentColor.withValues(alpha: 0.22),
              width: 1.0,
            ),
            boxShadow: _isHovered
                ? AppTokens.shadowNeon(widget.accentColor)
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.30),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                    BoxShadow(
                      color: widget.accentColor.withValues(alpha: 0.08),
                      blurRadius: 32,
                    ),
                  ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // ── Row: Icon + Trend Badge ──────────────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Icon container with glow
                  AnimatedBuilder(
                    animation: _pulseAnim,
                    builder: (context, child) => Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: widget.accentColor.withValues(alpha: 0.15),
                        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
                        boxShadow: [
                          BoxShadow(
                            color: widget.accentColor.withValues(
                              alpha: 0.25 * _pulseAnim.value,
                            ),
                            blurRadius: 12,
                            spreadRadius: -2,
                          ),
                        ],
                      ),
                      child: Icon(widget.icon, color: widget.accentColor, size: 20),
                    ),
                  ),
                  // Trend badge
                  if (hasTrend)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTokens.spaceXS,
                        vertical: AppTokens.spaceXXS,
                      ),
                      decoration: BoxDecoration(
                        color: trendColor.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(AppTokens.radiusCircle),
                        border: Border.all(
                          color: trendColor.withValues(alpha: 0.30),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            trendPositive
                                ? Icons.trending_up_rounded
                                : Icons.trending_down_rounded,
                            color: trendColor,
                            size: 12,
                          ),
                          const SizedBox(width: 2),
                          Text(
                            '${trendPositive ? '+' : ''}${widget.trend!.toStringAsFixed(1)}%',
                            style: TextStyle(
                              color: trendColor,
                              fontSize: AppTokens.textXS,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
              const SizedBox(height: AppTokens.spaceMD),

              // ── Value ─────────────────────────────────────────────
              Text(
                widget.value,
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                      color: widget.accentColor,
                      fontWeight: FontWeight.w800,
                      fontSize: AppTokens.textXXXL,
                      height: 1.1,
                    ),
              ),
              const SizedBox(height: AppTokens.spaceXXS),

              // ── Title ─────────────────────────────────────────────
              Text(
                widget.title,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: AppTokens.textMutedDark,
                      letterSpacing: 0.3,
                    ),
              ),

              // ── Trend Label ───────────────────────────────────────
              if (widget.trendLabel != null) ...[
                const SizedBox(height: AppTokens.spaceXXS),
                Text(
                  widget.trendLabel!,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTokens.textDisabledDark,
                        fontSize: 10,
                      ),
                ),
              ],

              // ── Breakdown Items ───────────────────────────────────
              if (widget.breakdownItems != null &&
                  widget.breakdownItems!.isNotEmpty) ...[
                const SizedBox(height: AppTokens.spaceSM),
                const Divider(height: 1),
                const SizedBox(height: AppTokens.spaceSM),
                ...widget.breakdownItems!.map(
                  (entry) => Padding(
                    padding: const EdgeInsets.only(bottom: 4),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          entry.key,
                          style: TextStyle(
                            color: AppTokens.textDisabledDark,
                            fontSize: AppTokens.textXS,
                          ),
                        ),
                        Text(
                          entry.value,
                          style: TextStyle(
                            color: AppTokens.textMutedDark,
                            fontSize: AppTokens.textXS,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

/// Row builder — untuk menampilkan 2–4 NeonStatCard secara horizontal
class NeonStatRow extends StatelessWidget {
  const NeonStatRow({super.key, required this.cards, this.spacing});

  final List<NeonStatCard> cards;
  final double? spacing;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (int i = 0; i < cards.length; i++) ...[
          Expanded(child: cards[i]),
          if (i < cards.length - 1)
            SizedBox(width: spacing ?? AppTokens.spaceMD),
        ],
      ],
    );
  }
}
