import 'package:flutter/material.dart';

class AppTheme {
  // ===== Palet Warna Utama =====
  static const Color primary = Color(0xFFFFB6C1);       // Soft Pink
  static const Color primaryLight = Color(0xFFFFE4E1);  // Baby Pink
  static const Color primaryDark = Color(0xFF8B4A6D);   // Dark Pink/Purple
  
  // ===== Accent Colors =====
  static const Color accentBlue = Color(0xFFAEC6CF);    // Soft Blue
  static const Color accentYellow = Color(0xFFFDFD96);  // Soft Yellow
  static const Color accentOrange = Color(0xFFFFB366);  // Soft Orange
  static const Color accentRed = Color(0xFFFF6B6B);     // Soft Red
  static const Color accentGreen = Color(0xFF51CF66);   // Soft Green
  
  // ===== Background & Surface =====
  static const Color background = Color(0xFFFFFDD0);    // Cream
  static const Color surface = Color(0xFFFFFFFF);       // White
  static const Color divider = Color(0xFFE0E0E0);       // Light Gray
  
  // ===== Status Kesegaran (Pastel Tone) =====
  static const Color excellent = Color(0xFFA8E6CF);     // Soft Pastel Green
  static const Color moderate = Color(0xFFFFDAB9);      // Peach / Soft Orange
  static const Color poor = Color(0xFFFFAAA5);          // Soft Pastel Red

  // ===== Text Colors =====
  static const Color textPrimary = Color(0xFF5D5D5D);
  static const Color textSecondary = Color(0xFF9E9E9E);

  // ===== Status Color Mapping =====
  static Color statusColor(String status) {
    switch (status) {
      case 'DRAFT':
        return const Color(0xFFA0A0A0); // Gray
      case 'PENDING_REVIEW':
        return const Color(0xFFFFB74D); // Amber
      case 'APPROVED':
        return accentGreen;
      case 'NEEDS_REVISION':
        return accentOrange;
      case 'REJECTED':
        return accentRed;
      default:
        return textSecondary;
    }
  }

  // ===== Status Label Mapping (Bahasa Indonesia) =====
  static String statusLabel(String status) {
    switch (status) {
      case 'DRAFT':
        return 'Draft';
      case 'PENDING_REVIEW':
        return 'Menunggu Review';
      case 'APPROVED':
        return 'Disetujui';
      case 'NEEDS_REVISION':
        return 'Perlu Revisi';
      case 'REJECTED':
        return 'Ditolak';
      default:
        return status;
    }
  }

  // ===== Theme Data =====
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: primaryLight,
        surface: surface,
      ),
      fontFamily: 'Nunito',
      
      // ===== AppBar =====
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        elevation: 0,
        centerTitle: true,
        iconTheme: IconThemeData(color: textPrimary),
        titleTextStyle: TextStyle(
          color: textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w800,
        ),
      ),

      // ===== Elevated Button =====
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          padding: const EdgeInsets.symmetric(vertical: 16),
          textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
      ),

      // ===== Outlined Button =====
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: primaryDark,
          side: const BorderSide(color: primaryLight),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
        ),
      ),

      // ===== Input Decoration =====
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
      ),
    );
  }
}