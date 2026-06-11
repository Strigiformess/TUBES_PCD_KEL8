import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'config/app_config.dart';
import 'controller/app_controller.dart';
import 'model/history_model.dart';
import 'model/sync_queue_model.dart';
import 'service/hive_service.dart';
import 'model/user_model.dart';          // ← baru
import 'service/auth_service.dart';      // ← baru
import 'service/tflite_service.dart';
import 'view/main_shell.dart';
import 'view/login_screen.dart';         // ← baru

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // ══════════════════════════════════════════════════════════════
  // LOAD ENVIRONMENT VARIABLES
  // ══════════════════════════════════════════════════════════════

  await AppConfig.load();
  AppConfig.printConfig(); // Print config jika debug mode

  // ══════════════════════════════════════════════════════════════
  // INITIALIZE HIVE - OFFLINE FIRST DATABASE
  // ══════════════════════════════════════════════════════════════

  // Init Hive Flutter
  await Hive.initFlutter();

  // Register Adapters
  Hive.registerAdapter(HistoryItemAdapter());
  Hive.registerAdapter(SyncQueueItemAdapter());

  // Initialize HiveService (akan membuka semua boxes)
  await HiveService.init();
  Hive.registerAdapter(UserModelAdapter());   // ← daftarkan adapter user

  // ══════════════════════════════════════════════════════════════
  // RUN APP
  // ══════════════════════════════════════════════════════════════

  // Init AuthService (buka box session)
  final authService = AuthService();
  await authService.init();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider.value(value: authService),
        ChangeNotifierProvider(create: (_) => AppController()..init()),
      ],
      child: const FreshCheckApp(),
    ),
  );
}

class FreshCheckApp extends StatelessWidget {
  const FreshCheckApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'FreshCheck',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      // Routing berdasarkan status login
      home: Consumer<AuthService>(
        builder: (_, auth, __) =>
          auth.isLoggedIn ? const MainShell() : const LoginScreen(),
      ),
    );
  }
}
