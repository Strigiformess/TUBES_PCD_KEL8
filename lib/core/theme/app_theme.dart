import 'package:flutter/material.dart';

/// Design System utama untuk FreshCheck
/// Mengikuti prinsip SOLID: Single Source of Truth untuk semua styling
class AppTheme {
  AppTheme._();

  // ──────────────────────────────────────────────────────────────────────
  // BRAND COLORS - Core palette
  // ──────────────────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF2ECC71);  // Hijau brand
  static const Color primaryDark  = Color(0xFF27AE60);  // Hijau gelap
  static const Color primaryLight = Color(0xFFD5F4E6);  // Hijau muda
  static const Color surface      = Color(0xFFF8FAF8);  // Background utama
  static const Color cardBg       = Color(0xFFFFFFFF);  // Card background
  
  // ──────────────────────────────────────────────────────────────────────
  // TEXT COLORS
  // ──────────────────────────────────────────────────────────────────────
  static const Color textPrimary  = Color(0xFF1A1A2E);  // Text utama
  static const Color textSecondary= Color(0xFF8A9BB0);  // Text secondary
  static const Color textDisabled = Color(0xFFBEC3C9);  // Text disabled

  // ──────────────────────────────────────────────────────────────────────
  // FRESHNESS STATUS COLORS - Semantic
  // ──────────────────────────────────────────────────────────────────────
  static const Color statusFresh  = Color(0xFF2ECC71);  // Hijau - Segar
  static const Color statusMedium = Color(0xFFF39C12);  // Oranye - Sedang
  static const Color statusPoor   = Color(0xFFE74C3C);  // Merah - Busuk

  // ──────────────────────────────────────────────────────────────────────
  // BORDER & DIVIDER
  // ──────────────────────────────────────────────────────────────────────
  static const Color border       = Color(0xFFE8EDF2);
  static const Color divider      = Color(0xFFF0F2F5);

  // ──────────────────────────────────────────────────────────────────────
  // SPACING (Design tokens)
  // ──────────────────────────────────────────────────────────────────────
  static const double spacing4  = 4;
  static const double spacing8  = 8;
  static const double spacing12 = 12;
  static const double spacing14 = 14;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing48 = 48;

  // ──────────────────────────────────────────────────────────────────────
  // BORDER RADIUS (Design tokens)
  // ──────────────────────────────────────────────────────────────────────
  static const double radiusSmall  = 8;
  static const double radiusMedium = 12;
  static const double radiusLarge  = 16;
  static const double radiusXL     = 24;
  static const double radiusCircle = 32;

  // ──────────────────────────────────────────────────────────────────────
  // TYPOGRAPHY
  // ──────────────────────────────────────────────────────────────────────
  static const String fontFamily = 'Poppins';

  // Headline
  static const TextStyle headlineL = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle headlineM = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle headlineS = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    fontFamily: fontFamily,
  );

  // Body
  static const TextStyle bodyL = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyM = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w500,
    color: textPrimary,
    fontFamily: fontFamily,
  );

  static const TextStyle bodyS = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    fontFamily: fontFamily,
  );

  // ──────────────────────────────────────────────────────────────────────
  // HELPER: Mapping status ke warna
  // ──────────────────────────────────────────────────────────────────────
  static Color statusColor(FreshnessStatus status) => switch (status) {
    FreshnessStatus.fresh  => statusFresh,
    FreshnessStatus.medium => statusMedium,
    FreshnessStatus.poor   => statusPoor,
  };

  // ──────────────────────────────────────────────────────────────────────
  // ThemeData - Material 3
  // ──────────────────────────────────────────────────────────────────────
  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      surface: surface,
      brightness: Brightness.light,
    ),
    scaffoldBackgroundColor: surface,
    fontFamily: fontFamily,
    
    // AppBar
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: headlineM,
      iconTheme: IconThemeData(color: textPrimary),
    ),
    
    // Card
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusLarge),
      ),
    ),
    
    // Button
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMedium),
        ),
        padding: const EdgeInsets.symmetric(
          vertical: spacing14,
          horizontal: spacing24,
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          fontFamily: fontFamily,
        ),
        elevation: 2,
      ),
    ),

    // Input Decoration
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(
        horizontal: spacing16,
        vertical: spacing12,
      ),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(radiusMedium),
        borderSide: const BorderSide(color: primary, width: 2),
      ),
    ),
  );
}

// ──────────────────────────────────────────────────────────────────────
// ENUM & EXTENSIONS
// ──────────────────────────────────────────────────────────────────────

/// Enum untuk status kesegaran makanan
enum FreshnessStatus { fresh, medium, poor }

extension FreshnessStatusX on FreshnessStatus {
  /// Label dalam Bahasa Indonesia
  String get label => switch (this) {
    FreshnessStatus.fresh  => 'Segar',
    FreshnessStatus.medium => 'Sedang',
    FreshnessStatus.poor   => 'Busuk',
  };

  /// Warna untuk status
  Color get color => AppTheme.statusColor(this);

  /// Icon untuk status
  IconData get icon => switch (this) {
    FreshnessStatus.fresh  => Icons.check_circle,
    FreshnessStatus.medium => Icons.warning,
    FreshnessStatus.poor   => Icons.cancel,
  };
}