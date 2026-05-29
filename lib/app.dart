import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import './data/models/scan_result.dart';
import './presentation/screens/home/home_screen.dart';
import './presentation/screens/camera/camera_screen.dart';
import './presentation/screens/detail/detail_screen.dart';
import './presentation/screens/gallery/gallery_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/',
  routes: [
    GoRoute(
      path: '/',
      name: 'home',
      builder: (ctx, state) => const HomeScreen(),
    ),
    GoRoute(
      path: '/camera',
      name: 'camera',
      builder: (ctx, state) => const CameraScreen(),
    ),
    GoRoute(
      path: '/gallery',
      name: 'gallery',
      builder: (ctx, state) => const GalleryScreen(),
    ),
    GoRoute(
      path: '/detail',
      name: 'detail',
      builder: (ctx, state) {
        final scan = state.extra as ScanResult;
        return DetailScreen(scan: scan);
      },
    ),
  ],
);