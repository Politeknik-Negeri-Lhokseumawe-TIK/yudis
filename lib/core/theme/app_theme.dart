import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_tokens.dart';

abstract class AppTheme {
  // ── Dark Theme ────────────────────────────────────────────────
  static ThemeData get dark {
    final base = ThemeData.dark(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.dark(
        primary: AppTokens.primaryPurpleLight,
        onPrimary: Colors.white,
        primaryContainer: AppTokens.primaryPurpleDark,
        onPrimaryContainer: AppTokens.primaryPurpleGlow,
        secondary: AppTokens.accentGold,
        onSecondary: AppTokens.bgDark,
        secondaryContainer: Color(0xFF3A2800),
        onSecondaryContainer: AppTokens.accentGoldLight,
        surface: AppTokens.bgDarkSurface,
        onSurface: AppTokens.textOnDark,
        surfaceContainerHighest: AppTokens.bgDarkCard,
        error: AppTokens.error,
        onError: Colors.white,
        outline: Color(0xFF4C1D95),
        outlineVariant: Color(0xFF2E1065),
        surfaceTint: AppTokens.primaryPurple,
      ),
      scaffoldBackgroundColor: AppTokens.bgDark,
      textTheme: _buildTextTheme(base.textTheme, const Color(0xFFECF5EF)),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: AppTokens.textLG,
          fontWeight: FontWeight.w700,
          color: Colors.white,
        ),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      inputDecorationTheme: _buildInputTheme(isDark: true),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: true),
      cardTheme: CardThemeData(
        color: AppTokens.bgDarkCard,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          side: const BorderSide(color: AppTokens.glassBorderColor),
        ),
      ),
      chipTheme: _buildChipTheme(isDark: true),
      dividerTheme: const DividerThemeData(
        color: Color(0x22A855F7), // Purple-tinted divider
        thickness: 1,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.transparent,
        selectedItemColor: AppTokens.primaryPurpleLight,
        unselectedItemColor: Color(0xFF5A4A7A), // Purple-muted
        elevation: 0,
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: AppTokens.primaryPurpleLight,
        foregroundColor: Colors.white,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusXL),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        backgroundColor: AppTokens.bgDarkCard,
        contentTextStyle: GoogleFonts.plusJakartaSans(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMD),
          side: const BorderSide(color: AppTokens.glassBorderColor),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  // ── Light Theme (Purple-Academic) ────────────────────────────
  static ThemeData get light {
    final base = ThemeData.light(useMaterial3: true);
    return base.copyWith(
      colorScheme: const ColorScheme.light(
        primary: AppTokens.primaryPurple,
        onPrimary: Colors.white,
        primaryContainer: Color(0xFFEDE9FE),
        onPrimaryContainer: AppTokens.primaryPurpleDark,
        secondary: AppTokens.accentGoldDark,
        onSecondary: Colors.white,
        secondaryContainer: Color(0xFFFFF3D0),
        onSecondaryContainer: AppTokens.accentGoldDark,
        surface: AppTokens.bgLightSurface,
        onSurface: Color(0xFF1A0B36),
        surfaceContainerHighest: AppTokens.bgLight,
        error: AppTokens.error,
        outline: Color(0xFFDDD6FE),
        outlineVariant: Color(0xFFEDE9FE),
        surfaceTint: AppTokens.primaryPurple,
      ),
      scaffoldBackgroundColor: AppTokens.bgLight,
      textTheme: _buildTextTheme(base.textTheme, const Color(0xFF1A0B36)),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        titleTextStyle: GoogleFonts.plusJakartaSans(
          fontSize: AppTokens.textLG,
          fontWeight: FontWeight.w700,
          color: AppTokens.primaryPurpleDark,
        ),
        iconTheme: const IconThemeData(color: AppTokens.primaryPurpleDark),
      ),
      inputDecorationTheme: _buildInputTheme(isDark: false),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      outlinedButtonTheme: _buildOutlinedButtonTheme(isDark: false),
      cardTheme: CardThemeData(
        color: Colors.white,
        elevation: 0,
        shadowColor: AppTokens.primaryPurple.withValues(alpha: 0.12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusLG),
          side: const BorderSide(color: Color(0xFFEDE9FE)),
        ),
      ),
      chipTheme: _buildChipTheme(isDark: false),
    );
  }

  // ── Helper Builders ───────────────────────────────────────────
  static TextTheme _buildTextTheme(TextTheme base, Color textColor) {
    return base
        .copyWith(
          displayLarge: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w800,
            fontSize: AppTokens.textDisplay,
            color: textColor,
          ),
          displayMedium: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: AppTokens.textXXXL,
            color: textColor,
          ),
          headlineLarge: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w700,
            fontSize: AppTokens.textXXL,
            color: textColor,
          ),
          headlineMedium: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: AppTokens.textXL,
            color: textColor,
          ),
          titleLarge: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            fontSize: AppTokens.textLG,
            color: textColor,
          ),
          titleMedium: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w500,
            fontSize: AppTokens.textMD,
            color: textColor,
          ),
          bodyLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: AppTokens.textMD,
            color: textColor,
          ),
          bodyMedium: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: AppTokens.textSM,
            color: textColor,
          ),
          bodySmall: GoogleFonts.poppins(
            fontWeight: FontWeight.w400,
            fontSize: AppTokens.textXS,
            color: textColor.withValues(alpha: 0.7),
          ),
          labelLarge: GoogleFonts.poppins(
            fontWeight: FontWeight.w600,
            fontSize: AppTokens.textSM,
            color: textColor,
          ),
          labelSmall: GoogleFonts.poppins(
            fontWeight: FontWeight.w500,
            fontSize: AppTokens.textXS,
            color: textColor.withValues(alpha: 0.7),
            letterSpacing: 0.5,
          ),
        );
  }

  static InputDecorationTheme _buildInputTheme({required bool isDark}) {
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? const Color(0x1AFFFFFF) : const Color(0x0F000000),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        borderSide: const BorderSide(color: AppTokens.glassBorderColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        borderSide: BorderSide(
          color: isDark ? const Color(0x30FFFFFF) : const Color(0x30000000),
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        borderSide: const BorderSide(
          color: AppTokens.primaryGreenLight,
          width: 2,
        ),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        borderSide: const BorderSide(color: AppTokens.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        borderSide: const BorderSide(color: AppTokens.error, width: 2),
      ),
      labelStyle: GoogleFonts.poppins(
        fontSize: AppTokens.textSM,
        color: isDark ? const Color(0xAAFFFFFF) : const Color(0xAA000000),
      ),
      hintStyle: GoogleFonts.poppins(
        fontSize: AppTokens.textSM,
        color: isDark ? const Color(0x66FFFFFF) : const Color(0x66000000),
      ),
      contentPadding: const EdgeInsets.symmetric(
        horizontal: AppTokens.spaceMD,
        vertical: AppTokens.spaceSM,
      ),
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTokens.primaryGreenLight,
        foregroundColor: Colors.white,
        elevation: 0,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spaceLG,
          vertical: AppTokens.spaceMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: AppTokens.textMD,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static OutlinedButtonThemeData _buildOutlinedButtonTheme({required bool isDark}) {
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? AppTokens.primaryPurpleLight : AppTokens.primaryPurple,
        side: BorderSide(
          color: isDark ? AppTokens.primaryPurpleLight : AppTokens.primaryPurple,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTokens.spaceLG,
          vertical: AppTokens.spaceMD,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTokens.radiusMD),
        ),
        textStyle: GoogleFonts.plusJakartaSans(
          fontSize: AppTokens.textMD,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  static ChipThemeData _buildChipTheme({required bool isDark}) {
    return ChipThemeData(
      backgroundColor: isDark
          ? const Color(0x18A855F7)  // Purple tinted
          : const Color(0x0F7C3AED), // Purple light
      labelStyle: GoogleFonts.poppins(
        fontSize: AppTokens.textXS,
        fontWeight: FontWeight.w500,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTokens.radiusCircle),
      ),
      side: BorderSide(
        color: isDark
            ? const Color(0x40A855F7) // Purple border dark
            : const Color(0x307C3AED), // Purple border light
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppTokens.spaceSM),
    );
  }
}
