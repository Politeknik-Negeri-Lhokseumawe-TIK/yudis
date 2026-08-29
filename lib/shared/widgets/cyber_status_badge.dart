import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../core/theme/app_tokens.dart';

/// Status enum untuk ketersediaan ruangan
enum RoomTileStatus {
  available,   // 🟢 Tersedia — bisa dipinjam
  classPBM,    // 🔴 Jadwal Kuliah PBM — tidak bisa dipinjam
  borrowed,    // 🟡 Sedang Dipinjam — ada peminjaman aktif
  maintenance, // ⚫ Maintenance — dikunci/tidak tersedia
}

/// CyberStatusBadge — Chip indikator status peminjaman/ruangan
/// Digunakan di card, list tile, dan tabel.
class CyberStatusBadge extends StatelessWidget {
  const CyberStatusBadge({
    super.key,
    required this.label,
    this.color,
    this.icon,
    this.size = CyberBadgeSize.medium,
    this.pulse = false,
  });

  final String label;
  final Color? color;
  final IconData? icon;
  final CyberBadgeSize size;
  final bool pulse;

  // ── Convenience constructors ────────────────────────────────────
  factory CyberStatusBadge.available({CyberBadgeSize size = CyberBadgeSize.medium}) =>
      CyberStatusBadge(
        label: 'Tersedia',
        color: AppTokens.success,
        icon: Icons.check_circle_rounded,
        size: size,
        pulse: true,
      );

  factory CyberStatusBadge.borrowed({CyberBadgeSize size = CyberBadgeSize.medium}) =>
      CyberStatusBadge(
        label: 'Dipinjam',
        color: AppTokens.warning,
        icon: Icons.vpn_key_rounded,
        size: size,
        pulse: true,
      );

  factory CyberStatusBadge.classPBM({CyberBadgeSize size = CyberBadgeSize.medium}) =>
      CyberStatusBadge(
        label: 'Kuliah PBM',
        color: AppTokens.error,
        icon: Icons.school_rounded,
        size: size,
      );

  factory CyberStatusBadge.maintenance({CyberBadgeSize size = CyberBadgeSize.medium}) =>
      CyberStatusBadge(
        label: 'Maintenance',
        color: AppTokens.textMutedDark,
        icon: Icons.build_rounded,
        size: size,
      );

  factory CyberStatusBadge.fromBookingStatus(String status,
      {CyberBadgeSize size = CyberBadgeSize.medium}) {
    switch (status.toLowerCase()) {
      case 'approved':
        return CyberStatusBadge(
          label: 'Disetujui',
          color: AppTokens.success,
          icon: Icons.verified_rounded,
          size: size,
        );
      case 'active':
        return CyberStatusBadge(
          label: 'Aktif',
          color: AppTokens.info,
          icon: Icons.play_circle_rounded,
          size: size,
          pulse: true,
        );
      case 'pending':
        return CyberStatusBadge(
          label: 'Menunggu',
          color: AppTokens.warning,
          icon: Icons.hourglass_top_rounded,
          size: size,
          pulse: true,
        );
      case 'rejected':
        return CyberStatusBadge(
          label: 'Ditolak',
          color: AppTokens.error,
          icon: Icons.cancel_rounded,
          size: size,
        );
      case 'cancelled':
        return CyberStatusBadge(
          label: 'Dibatalkan',
          color: AppTokens.error,
          icon: Icons.remove_circle_rounded,
          size: size,
        );
      case 'completed':
        return CyberStatusBadge(
          label: 'Selesai',
          color: AppTokens.primaryPurpleLight,
          icon: Icons.task_alt_rounded,
          size: size,
        );
      default:
        return CyberStatusBadge(label: status, size: size);
    }
  }

  @override
  Widget build(BuildContext context) {
    final badgeColor = color ?? AppTokens.textMutedDark;
    final fontSize = switch (size) {
      CyberBadgeSize.small  => 9.0,
      CyberBadgeSize.medium => AppTokens.textXS,
      CyberBadgeSize.large  => AppTokens.textSM,
    };
    final iconSize = switch (size) {
      CyberBadgeSize.small  => 9.0,
      CyberBadgeSize.medium => 11.0,
      CyberBadgeSize.large  => 13.0,
    };
    final hPad = switch (size) {
      CyberBadgeSize.small  => 6.0,
      CyberBadgeSize.medium => AppTokens.spaceXS,
      CyberBadgeSize.large  => AppTokens.spaceSM,
    };
    final vPad = switch (size) {
      CyberBadgeSize.small  => 3.0,
      CyberBadgeSize.medium => AppTokens.spaceXXS,
      CyberBadgeSize.large  => 6.0,
    };

    Widget badge = Container(
      padding: EdgeInsets.symmetric(horizontal: hPad, vertical: vPad),
      decoration: BoxDecoration(
        color: badgeColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppTokens.radiusCircle),
        border: Border.all(
          color: badgeColor.withValues(alpha: 0.30),
          width: 1.0,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, color: badgeColor, size: iconSize),
            SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(
              color: badgeColor,
              fontSize: fontSize,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.3,
            ),
          ),
        ],
      ),
    );

    if (pulse) {
      badge = badge
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .custom(
            duration: const Duration(milliseconds: 1500),
            builder: (_, value, child) => Opacity(
              opacity: 0.7 + 0.3 * value,
              child: child,
            ),
          );
    }

    return badge;
  }
}

enum CyberBadgeSize { small, medium, large }

// ────────────────────────────────────────────────────────────────────────────

/// RoomStatusTile — Tile grid ruangan dengan animasi status real-time
/// Menampilkan kode/nama ruangan dan indikator ketersediaan berwarna.
class RoomStatusTile extends StatefulWidget {
  const RoomStatusTile({
    super.key,
    required this.roomCode,
    required this.status,
    this.roomName,
    this.sessionLabel,
    this.onTap,
    this.animateEntry = true,
    this.delay = Duration.zero,
    this.compact = false,
  });

  final String roomCode;
  final RoomTileStatus status;
  final String? roomName;
  final String? sessionLabel;
  final VoidCallback? onTap;
  final bool animateEntry;
  final Duration delay;

  /// Compact mode — lebih kecil, untuk grid dengan banyak ruangan
  final bool compact;

  @override
  State<RoomStatusTile> createState() => _RoomStatusTileState();
}

class _RoomStatusTileState extends State<RoomStatusTile>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  bool _isHovered = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    if (_shouldPulse) _pulseController.repeat(reverse: true);
  }

  bool get _shouldPulse =>
      widget.status == RoomTileStatus.borrowed ||
      widget.status == RoomTileStatus.classPBM;

  (Color, Color, IconData, String) get _statusProps {
    switch (widget.status) {
      case RoomTileStatus.available:
        return (AppTokens.success, AppTokens.success, Icons.check_circle_rounded, 'Tersedia');
      case RoomTileStatus.classPBM:
        return (AppTokens.error, AppTokens.error, Icons.school_rounded, 'Kuliah PBM');
      case RoomTileStatus.borrowed:
        return (AppTokens.warning, AppTokens.warning, Icons.vpn_key_rounded, 'Dipinjam');
      case RoomTileStatus.maintenance:
        return (AppTokens.textMutedDark, AppTokens.textDisabledDark, Icons.build_rounded, 'Maintenance');
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final (borderColor, iconColor, statusIcon, statusText) = _statusProps;
    final compact = widget.compact;

    Widget tile = MouseRegion(
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedBuilder(
          animation: _pulseController,
          builder: (_, child) {
            final pulseAlpha = _shouldPulse
                ? 0.15 + 0.12 * _pulseController.value
                : 0.10;
            return AnimatedContainer(
              duration: AppTokens.durationNormal,
              curve: Curves.easeOutCubic,
              padding: EdgeInsets.all(compact ? AppTokens.spaceXS : AppTokens.spaceSM),
              decoration: BoxDecoration(
                color: borderColor.withValues(alpha: pulseAlpha),
                borderRadius: BorderRadius.circular(
                  compact ? AppTokens.radiusSM : AppTokens.radiusMD,
                ),
                border: Border.all(
                  color: _isHovered
                      ? borderColor.withValues(alpha: 0.80)
                      : borderColor.withValues(alpha: 0.35),
                  width: 1.0,
                ),
                boxShadow: _isHovered
                    ? AppTokens.shadowNeon(borderColor)
                    : [
                        BoxShadow(
                          color: borderColor.withValues(alpha: 0.08),
                          blurRadius: 12,
                        ),
                      ],
              ),
              child: child,
            );
          },
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Row: Kode Ruangan + Status Icon ─────────────────
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Flexible(
                    child: Text(
                      widget.roomCode,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: compact ? 11 : AppTokens.textSM,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Icon(statusIcon, color: _statusProps.$2, size: compact ? 12 : 14),
                ],
              ),
              // ── Nama Ruangan (hanya non-compact) ─────────────────
              if (!compact && widget.roomName != null) ...[
                const SizedBox(height: 2),
                Text(
                  widget.roomName!,
                  style: TextStyle(
                    color: AppTokens.textMutedDark,
                    fontSize: 10,
                    height: 1.2,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
              const SizedBox(height: 4),
              // ── Status badge ─────────────────────────────────────
              CyberStatusBadge(
                label: widget.sessionLabel ?? _statusProps.$4,
                color: _statusProps.$1,
                size: compact ? CyberBadgeSize.small : CyberBadgeSize.small,
              ),
            ],
          ),
        ),
      ),
    );

    if (widget.animateEntry) {
      tile = tile
          .animate(delay: widget.delay)
          .fadeIn(duration: AppTokens.durationNormal)
          .scale(
            begin: const Offset(0.9, 0.9),
            end: const Offset(1.0, 1.0),
            duration: AppTokens.durationNormal,
            curve: Curves.easeOutBack,
          );
    }

    return tile;
  }
}

/// Grid builder — untuk menampilkan banyak RoomStatusTile secara grid
class RoomStatusGrid extends StatelessWidget {
  const RoomStatusGrid({
    super.key,
    required this.tiles,
    this.crossAxisCount = 4,
    this.spacing = 10,
    this.compact = false,
  });

  final List<RoomStatusTile> tiles;
  final int crossAxisCount;
  final double spacing;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: spacing,
        mainAxisSpacing: spacing,
        childAspectRatio: compact ? 1.3 : 1.1,
      ),
      itemCount: tiles.length,
      itemBuilder: (context, i) => tiles[i],
    );
  }
}
