import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'controller/app_controller.dart';
import 'model/history_model.dart';
import 'view/main_shell.dart';
import 'service/tflite_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Init Hive
  await Hive.initFlutter();
  Hive.registerAdapter(HistoryItemAdapter());


  // Inspect TFLite model
  // WidgetsFlutterBinding.ensureInitialized();
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
  Widget build(BuildContext context) => MaterialApp(
    title: 'FreshCheck',
    debugShowCheckedModeBanner: false,
    theme: AppTheme.theme,
    home: const MainShell(),
  );
}
