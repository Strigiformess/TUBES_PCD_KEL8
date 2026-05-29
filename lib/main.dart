import 'package:flutter/material.dart';
// Pastikan import ini ditambahkan:
import 'presentation/router/app_router.dart'; 
// Import file theme kamu di sini juga

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  // 1. Inisialisasi appRouter di sini
  final AppRouter appRouter = AppRouter();

  MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tubes PCD Kel 8',
      // Memanggil theme yang sudah kita tambahkan palet warnanya tadi
      // theme: AppTheme.lightTheme, 
      
      // 2. Sambungkan routing-nya di sini
      onGenerateRoute: appRouter.onGenerateRoute, 
    );
  }
}