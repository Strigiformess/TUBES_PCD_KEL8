import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../data/models/scan_result.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/camera/camera_screen.dart';
import '../presentation/screens/detail/detail_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      builder: (ctx, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/camera',
      builder: (ctx, state) => const CameraScreen(),
    ),
    GoRoute(
      path: '/detail',
      builder: (ctx, state) {
        final scan = state.extra as ScanResult;
        return DetailScreen(scan: scan);
      },
    ),
  ],
);
