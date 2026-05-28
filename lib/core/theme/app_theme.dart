import 'package:flutter/material.dart';

class AppTheme {
  // Palet Warna Aesthetic & Lucu
  static const Color primary = Color(0xFFFFB6C1);       // Soft Pink
  static const Color primaryLight = Color(0xFFFFE4E1);  // Baby Pink
  static const Color accentBlue = Color(0xFFAEC6CF);    // Soft Blue
  static const Color accentYellow = Color(0xFFFDFD96);  // Soft Yellow
  static const Color background = Color(0xFFFFFDD0);    // Cream
  static const Color surface = Color(0xFFFFFFFF);       // White
  
  // Status Kesegaran (Pastel Tone)
  static const Color excellent = Color(0xFFA8E6CF);     // Soft Pastel Green
  static const Color moderate = Color(0xFFFFDAB9);      // Peach / Soft Orange
  static const Color poor = Color(0xFFFFAAA5);          // Soft Pastel Red

  static const Color textPrimary = Color(0xFF5D5D5D);
  static const Color textSecondary = Color(0xFF9E9E9E);

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: primaryLight,
        surface: surface,
      ),
      fontFamily: 'Nunito', // Anda bisa ganti dengan font pilihan kelompok
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
    );
  }
}