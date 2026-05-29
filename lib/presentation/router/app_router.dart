import 'package:flutter/material.dart';
import '../screens/home/home_screen.dart';
import '../screens/detail/detail_screen.dart';
import '../../../data/models/scan_result.dart'; // Diperlukan untuk membaca data scan di detail screen

class AppRouter {
  Route? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case '/':
        // Sudah diperbaiki dari syntax error pencampuran Scaffold lama
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
      
      case '/detail':
        // Menangkap data ScanResult yang dikirim dari halaman sebelumya
        final args = settings.arguments as ScanResult;
        return MaterialPageRoute(
          builder: (_) => DetailScreen(scan: args),
        );
      
      default:
        // Halaman fallback jika nama rute tidak dikenali
        return MaterialPageRoute(
          builder: (_) => const Scaffold(
            body: Center(child: Text('Route tidak ditemukan')),
          ),
        );
    }
  }
}