import 'package:flutter/material.dart';

class AppTheme {
  AppTheme._();

  // ── Brand Colors ────────────────────────────────────────────────────────
  static const Color primary      = Color(0xFF2ECC71);
  static const Color primaryDark  = Color(0xFF27AE60);
  static const Color surface      = Color(0xFFF8FAF8);
  static const Color cardBg       = Color(0xFFFFFFFF);
  static const Color textPrimary  = Color(0xFF1A1A2E);
  static const Color textSecondary= Color(0xFF8A9BB0);

  // ── Freshness Status Colors ──────────────────────────────────────────────
  static const Color fresh        = Color(0xFF2ECC71);  // hijau
  static const Color medium       = Color(0xFFF39C12);  // oranye
  static const Color poor         = Color(0xFFE74C3C);  // merah

  // ── Semantic ─────────────────────────────────────────────────────────────
  static Color statusColor(FreshnessStatus status) => switch (status) {
    FreshnessStatus.fresh  => fresh,
    FreshnessStatus.medium => medium,
    FreshnessStatus.poor   => poor,
  };

  static ThemeData get light => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: primary,
      surface: surface,
    ),
    scaffoldBackgroundColor: surface,
    fontFamily: 'Poppins',
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w600,
        fontFamily: 'Poppins',
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
    cardTheme: CardThemeData(
      color: cardBg,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
          fontFamily: 'Poppins',
        ),
      ),
    ),
  );
}

enum FreshnessStatus { fresh, medium, poor }

extension FreshnessStatusX on FreshnessStatus {
  String get label => switch (this) {
    FreshnessStatus.fresh  => 'Fresh',
    FreshnessStatus.medium => 'Medium',
    FreshnessStatus.poor   => 'Poor',
  };

  Color get color => AppTheme.statusColor(this);
}
