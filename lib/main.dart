import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart'; // ✅ Import Riverpod ditambahkan
import 'package:go_router/go_router.dart';
import 'core/theme/app_theme.dart';
import 'presentation/screens/home/home_screen.dart';
import 'presentation/screens/camera/camera_screen.dart';
import 'presentation/screens/gallery/gallery_screen.dart';
import 'presentation/screens/detail/detail_screen.dart';
import 'data/models/scan_result.dart';

void main() {
  // ✅ Bungkus MyApp dengan ProviderScope agar state management Riverpod bisa berjalan
  runApp(
    const ProviderScope(
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FreshCheck - Analisis Kesegaran Makanan',
      theme: AppTheme.light,
      routerConfig: _router,
      debugShowCheckedModeBanner: false,
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// ROUTER CONFIGURATION - Semua routes terdaftar di sini
// ─────────────────────────────────────────────────────────────────────────────

final GoRouter _router = GoRouter(
  initialLocation: '/',
  errorBuilder: (context, state) => Scaffold(
    body: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            '404 - Halaman tidak ditemukan',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () => context.go('/'),
            child: const Text('Kembali ke Home'),
          ),
        ],
      ),
    ),
  ),
  routes: [
    // 🏠 HOME SCREEN
    GoRoute(
      path: '/',
      name: 'home',
      builder: (context, state) => const HomeScreen(),
    ),

    // 📷 CAMERA SCREEN
    GoRoute(
      path: '/camera',
      name: 'camera',
      builder: (context, state) => const CameraScreen(),
    ),

    // 🖼️ GALLERY SCREEN
    GoRoute(
      path: '/gallery',
      name: 'gallery',
      builder: (context, state) => const GalleryScreen(),
    ),

    // 📊 DETAIL SCREEN
    GoRoute(
      path: '/detail',
      name: 'detail',
      builder: (context, state) {
        final scan = state.extra as ScanResult;
        return DetailScreen(scan: scan);
      },
    ),
  ],
);