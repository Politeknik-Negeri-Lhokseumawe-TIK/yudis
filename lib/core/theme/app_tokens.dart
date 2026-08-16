import 'package:flutter/material.dart';

/// Design tokens terpusat — semua warna, spacing, radius, animasi
abstract class AppTokens {
  // ── Brand Colors ──────────────────────────────────────────────
  /// Ungu Utama TIK (Jurusan Teknologi Informasi dan Komputer)
  static const Color primaryPurple = Color(0xFF7C3AED);
  static const Color primaryPurpleLight = Color(0xFFA855F7);
  static const Color primaryPurpleDark = Color(0xFF5B21B6);
  static const Color primaryPurpleGlow = Color(0xFFC084FC);

  /// Aliases for primary color
  static const Color primaryGreen = primaryPurple;
  static const Color primaryGreenLight = primaryPurpleLight;
  static const Color primaryGreenDark = primaryPurpleDark;

  /// Kuning / Emas Aksen PNL (Politeknik Negeri Lhokseumawe)
  static const Color accentGold = Color(0xFFF59E0B);
  static const Color accentGoldLight = Color(0xFFFDE047);
  static const Color accentGoldDark = Color(0xFFD97706);

  /// Background dark (Deep Obsidian Purple / TIK Cyber Night)
  static const Color bgDark = Color(0xFF070410);
  static const Color bgDarkSurface = Color(0xFF100A24);
  static const Color bgDarkCard = Color(0xFF181033);

  /// Background light (Soft Lilac Mist)
  static const Color bgLight = Color(0xFFF7F5FC);
  static const Color bgLightSurface = Color(0xFFFFFFFF);

  // ── Semantic Colors ───────────────────────────────────────────
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFEF4444);
  static const Color info = Color(0xFF38BDF8);

  // ── Prodi Colors ──────────────────────────────────────────────
  static const Color prodiTRKJ = Color(0xFFA855F7);   // Ungu — Teknologi Rekayasa Komputer Jaringan
  static const Color prodiTRMM = Color(0xFFEC4899);   // Pink Magenta — Teknologi Rekayasa Multimedia
  static const Color prodiTI = Color(0xFF38BDF8);     // Cyan Sky — Teknik Informatika

  // ── Glass / Blur ──────────────────────────────────────────────
  static const double glassBlur = 20.0;
  static const double glassBorderWidth = 1.0;
  static const Color glassBorderColor = Color(0x33C084FC); // Purple Luminous Border
  static const Color glassFillLight = Color(0x1AFFFFFF);
  static const Color glassFillDark = Color(0x18A855F7);   // Purple Tinted Glass Fill

  // ── Spacing ───────────────────────────────────────────────────
  static const double spaceXXS = 4.0;
  static const double spaceXS = 8.0;
  static const double spaceSM = 12.0;
  static const double spaceMD = 16.0;
  static const double spaceLG = 24.0;
  static const double spaceXL = 32.0;
  static const double spaceXXL = 48.0;
  static const double spaceXXXL = 64.0;

  // ── Border Radius ─────────────────────────────────────────────
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;
  static const double radiusXXL = 32.0;
  static const double radiusCircle = 100.0;

  // ── Animation Durations ───────────────────────────────────────
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow = Duration(milliseconds: 500);
  static const Duration durationXSlow = Duration(milliseconds: 800);
  static const Duration durationBgAnim = Duration(seconds: 8);

  // ── Elevation / Shadow ────────────────────────────────────────
  static List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.3),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: AppTokens.primaryGreen.withValues(alpha: 0.15),
      blurRadius: 40,
      offset: const Offset(0, 4),
    ),
  ];

  static List<BoxShadow> shadowGlow = [
    BoxShadow(
      color: AppTokens.primaryGreenLight.withValues(alpha: 0.4),
      blurRadius: 30,
      spreadRadius: -5,
    ),
  ];

  // ── Typography Scale ──────────────────────────────────────────
  static const double textXS = 11.0;
  static const double textSM = 13.0;
  static const double textMD = 15.0;
  static const double textLG = 17.0;
  static const double textXL = 20.0;
  static const double textXXL = 24.0;
  static const double textXXXL = 32.0;
  static const double textDisplay = 40.0;
}
