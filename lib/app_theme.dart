import 'package:flutter/material.dart';

class AppTheme {
  static const green = Color(0xFF22C55E);
  static const greenLight = Color(0xFFDCFCE7);
  static const yellow = Color(0xFFF59E0B);
  static const yellowLight = Color(0xFFFEF3C7);
  static const red = Color(0xFFEF4444);
  static const redLight = Color(0xFFFEE2E2);
  static const bg = Color(0xFFF8FAFC);
  static const card = Colors.white;
  static const textPrimary = Color(0xFF0F172A);
  static const textSecondary = Color(0xFF64748B);
  static const border = Color(0xFFE2E8F0);

  static Color categoryColor(String kategori) {
    switch (kategori) {
      case 'Fresh': return green;
      case 'Medium': return yellow;
      default: return red;
    }
  }

  static Color categoryBg(String kategori) {
    switch (kategori) {
      case 'Fresh': return greenLight;
      case 'Medium': return yellowLight;
      default: return redLight;
    }
  }

  static ThemeData get theme => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(seedColor: green),
    scaffoldBackgroundColor: bg,
    fontFamily: 'Roboto',
    appBarTheme: const AppBarTheme(
      backgroundColor: card,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      titleTextStyle: TextStyle(
        color: textPrimary, fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
      iconTheme: IconThemeData(color: textPrimary),
    ),
  );
}
