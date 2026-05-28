import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'app.dart';
import 'core/theme/app_theme.dart';
import 'data/repositories/scan_repository.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inisialisasi Hive untuk penyimpanan riwayat scan
  await ScanRepository.init();

  runApp(
    const ProviderScope(
      child: FreshCheckApp(),
    ),
  );
}

class FreshCheckApp extends StatelessWidget {
  const FreshCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'FreshCheck',
      theme: AppTheme.light,
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
    );
  }
}
