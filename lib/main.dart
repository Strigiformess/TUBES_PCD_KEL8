import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'config/app_config.dart';
import 'controller/app_controller.dart';
import 'model/history_model.dart';
import 'model/sync_queue_model.dart';
import 'service/hive_service.dart';
import 'view/main_shell.dart';

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

  // ══════════════════════════════════════════════════════════════
  // RUN APP
  // ══════════════════════════════════════════════════════════════

  runApp(
    ChangeNotifierProvider(
      create: (_) => AppController()..init(),
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
      home: const MainShell(),
    );
  }
}
