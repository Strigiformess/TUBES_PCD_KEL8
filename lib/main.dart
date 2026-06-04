import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

import 'app_theme.dart';
import 'controller/app_controller.dart';
import 'model/history_model.dart';
import 'service/tflite_service.dart';
import 'view/main_shell.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive
  await Hive.initFlutter();
  Hive.registerAdapter(HistoryItemAdapter());

  // Load TFLite model
  await TfliteService().loadModel();

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