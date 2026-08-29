import 'package:flutter/material.dart';

/// Design tokens terpusat — semua warna, spacing, radius, animasi
/// Design System: "Cyber-Academic Glassmorphism v2.0"
/// Jurusan Teknologi Informasi & Komputer — Politeknik Negeri Lhokseumawe
abstract class AppTokens {
  // ── Brand Colors (Deep Obsidian Purple — TIK Cyber Night) ──────
  static const Color primaryPurple      = Color(0xFF7C3AED);
  static const Color primaryPurpleLight = Color(0xFFA855F7);
  static const Color primaryPurpleDark  = Color(0xFF5B21B6);
  static const Color primaryPurpleGlow  = Color(0xFFC084FC);

  /// Canonical brand aliases (v2.0) — use these in new code
  static const Color brand      = primaryPurple;
  static const Color brandLight = primaryPurpleLight;
  static const Color brandDark  = primaryPurpleDark;
  static const Color brandGlow  = primaryPurpleGlow;

  /// Legacy aliases — kept for backward compatibility, prefer `brand*`
  @Deprecated('Use brand instead')
  static const Color primaryGreen      = primaryPurple;
  @Deprecated('Use brandLight instead')
  static const Color primaryGreenLight = primaryPurpleLight;
  @Deprecated('Use brandDark instead')
  static const Color primaryGreenDark  = primaryPurpleDark;

  // ── Accent — Kuning / Emas PNL ─────────────────────────────────
  static const Color accentGold      = Color(0xFFF59E0B);
  static const Color accentGoldLight = Color(0xFFFDE047);
  static const Color accentGoldDark  = Color(0xFFD97706);

  // ── Background — Deep Space ─────────────────────────────────────
  static const Color bgDark           = Color(0xFF070410);
  static const Color bgDarkSurface    = Color(0xFF100A24);
  static const Color bgDarkCard       = Color(0xFF181033);
  static const Color bgDarkCardHover  = Color(0xFF1E1440);

  /// Background light (Soft Lilac Mist — untuk light theme kelak)
  static const Color bgLight        = Color(0xFFF7F5FC);
  static const Color bgLightSurface = Color(0xFFFFFFFF);

  // ── Semantic Status Colors ─────────────────────────────────────
  static const Color success  = Color(0xFF10B981); // Tersedia, Selesai
  static const Color warning  = Color(0xFFF59E0B); // Pending, Menunggu
  static const Color error    = Color(0xFFEF4444); // Ditolak, Bentrok
  static const Color info     = Color(0xFF38BDF8); // Informasi, Aktif

  // ── Text Colors ───────────────────────────────────────────────
  static const Color textOnDark       = Color(0xFFF3E8FF); // Teks utama di dark bg
  static const Color textMutedDark    = Color(0xFF8B7EAB); // Teks sekunder di dark bg
  static const Color textDisabledDark = Color(0xFF4A3F6B); // Teks disabled/placeholder

  // ── Prodi Identity Colors ──────────────────────────────────────
  static const Color prodiTRKJ = Color(0xFFA855F7); // Ungu — Teknologi Rekayasa Komputer Jaringan
  static const Color prodiTRMM = Color(0xFFEC4899); // Pink Magenta — Teknologi Rekayasa Multimedia
  static const Color prodiTI   = Color(0xFF38BDF8); // Cyan Sky — Teknik Informatika
  static const Color prodiTRPL = Color(0xFF10B981); // Emerald — Teknologi Rekayasa Perangkat Lunak

  // ── Glassmorphism System ───────────────────────────────────────
  static const double glassBlur        = 20.0;
  static const double glassBorderWidth = 1.0;
  static const Color glassBorderColor  = Color(0x33C084FC); // Purple Luminous Border
  static const Color glassFillLight    = Color(0x1AFFFFFF);
  static const Color glassFillDark     = Color(0x12A855F7); // Purple Tinted Glass Fill
  static const Color glassFillElevated = Color(0x20A855F7); // Elevated glass fill

  // ── Gradient System ────────────────────────────────────────────
  static const LinearGradient gradientPrimary = LinearGradient(
    colors: [Color(0xFF7C3AED), Color(0xFF5B21B6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientNeon = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFF38BDF8)],
    begin: Alignment.centerLeft,
    end: Alignment.centerRight,
  );

  static const LinearGradient gradientGold = LinearGradient(
    colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient gradientBg = LinearGradient(
    colors: [Color(0xFF070410), Color(0xFF100A24), Color(0xFF181033)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  // Prodi Gradients
  static const LinearGradient gradientProdiTRKJ = LinearGradient(
    colors: [Color(0xFFA855F7), Color(0xFF7C3AED)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient gradientProdiTRMM = LinearGradient(
    colors: [Color(0xFFEC4899), Color(0xFFBE185D)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient gradientProdiTI = LinearGradient(
    colors: [Color(0xFF38BDF8), Color(0xFF0284C7)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );
  static const LinearGradient gradientProdiTRPL = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft, end: Alignment.bottomRight,
  );

  // ── Spacing System (8px base grid) ────────────────────────────
  static const double spaceXXS  =  4.0;
  static const double spaceXS   =  8.0;
  static const double spaceSM   = 12.0;
  static const double spaceMD   = 16.0;
  static const double spaceLG   = 24.0;
  static const double spaceXL   = 32.0;
  static const double spaceXXL  = 48.0;
  static const double spaceXXXL = 64.0;

  // ── Border Radius ──────────────────────────────────────────────
  static const double radiusSM     =  8.0;
  static const double radiusMD     = 12.0;
  static const double radiusLG     = 16.0;
  static const double radiusXL     = 24.0;
  static const double radiusXXL    = 32.0;
  static const double radiusCircle = 100.0;

  // ── Animation Durations ───────────────────────────────────────
  static const Duration durationFast  = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 300);
  static const Duration durationSlow  = Duration(milliseconds: 500);
  static const Duration durationXSlow = Duration(milliseconds: 800);
  static const Duration durationBgAnim = Duration(seconds: 8);

  // ── Elevation / Shadow System ─────────────────────────────────
  static List<BoxShadow> shadowCard = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.35),
      blurRadius: 20,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: primaryPurple.withValues(alpha: 0.15),
      blurRadius: 40,
      offset: const Offset(0, 4),
    ),
  ];

  /// Neon glow shadow — digunakan pada komponen aktif/highlight
  static List<BoxShadow> shadowNeon([Color? color]) {
    final c = color ?? primaryPurpleLight;
    return [
      BoxShadow(color: c.withValues(alpha: 0.50), blurRadius: 20, spreadRadius: -2),
      BoxShadow(color: c.withValues(alpha: 0.25), blurRadius: 60, spreadRadius: -10),
    ];
  }

  /// Intense neon glow — untuk CTA button dan status kritis
  static List<BoxShadow> shadowNeonIntense([Color? color]) {
    final c = color ?? primaryPurpleLight;
    return [
      BoxShadow(color: c.withValues(alpha: 0.70), blurRadius: 25, spreadRadius: -2),
      BoxShadow(color: c.withValues(alpha: 0.35), blurRadius: 80, spreadRadius: -10),
    ];
  }

  /// Standard card glow
  static List<BoxShadow> get shadowGlow => [
        BoxShadow(
          color: primaryPurpleLight.withValues(alpha: 0.35),
          blurRadius: 30,
          spreadRadius: -5,
        ),
      ];

  // ── Typography Scale ──────────────────────────────────────────
  static const double textXS      = 11.0;
  static const double textSM      = 13.0;
  static const double textMD      = 15.0;
  static const double textLG      = 17.0;
  static const double textXL      = 20.0;
  static const double textXXL     = 24.0;
  static const double textXXXL    = 32.0;
  static const double textDisplay = 40.0;

  // ── Status Color Helpers ──────────────────────────────────────
  /// Kembalikan warna sesuai nama status peminjaman
  static Color statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'approved':
        return success;
      case 'active':
        return info;
      case 'pending':
        return warning;
      case 'rejected':
      case 'cancelled':
        return error;
      case 'completed':
        return const Color(0xFF8B5CF6); // Purple soft untuk completed
      default:
        return textMutedDark;
    }
  }

  /// Kembalikan warna prodi berdasarkan nama singkatan
  static Color prodiColor(String prodi) {
    switch (prodi.toUpperCase()) {
      case 'TRKJ': return prodiTRKJ;
      case 'TRMM': return prodiTRMM;
      case 'TI':   return prodiTI;
      case 'TRPL': return prodiTRPL;
      default:     return primaryPurpleLight;
    }
  }

  /// Kembalikan gradient prodi berdasarkan nama singkatan
  static LinearGradient prodiGradient(String prodi) {
    switch (prodi.toUpperCase()) {
      case 'TRKJ': return gradientProdiTRKJ;
      case 'TRMM': return gradientProdiTRMM;
      case 'TI':   return gradientProdiTI;
      case 'TRPL': return gradientProdiTRPL;
      default:     return gradientPrimary;
    }
  }
}
