import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/config/app_config.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/scan_provider.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen>
    with WidgetsBindingObserver {
  bool _isCapturing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    // Init camera saat screen pertama dibuka
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(cameraServiceProvider).init();
    });
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final cameraService = ref.read(cameraServiceProvider);
    switch (state) {
      case AppLifecycleState.inactive:
      case AppLifecycleState.paused:
        cameraService.pausePreview();
      case AppLifecycleState.resumed:
        cameraService.resumePreview();
      default:
        break;
    }
  }

  Future<void> _captureAndAnalyze() async {
    if (_isCapturing) return;
    setState(() => _isCapturing = true);

    try {
      final cameraService = ref.read(cameraServiceProvider);
      final photo = await cameraService.takePicture();
      if (photo == null) return;

      // Navigasi ke loading state — tetap di sini sampai selesai
      await ref.read(scanStateProvider.notifier).analyze(File(photo.path));

      if (!mounted) return;

      final scanState = ref.read(scanStateProvider);
      if (scanState is ScanSuccess) {
        context.pushReplacement('/detail', extra: scanState.result);
      } else if (scanState is ScanError) {
        _showError(scanState.message);
      }
    } finally {
      if (mounted) setState(() => _isCapturing = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.poor,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final cameraService = ref.watch(cameraServiceProvider);
    final scanState     = ref.watch(scanStateProvider);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // ── Camera Preview ─────────────────────────────────────────────
          if (cameraService.isInitialized)
            Positioned.fill(
              child: CameraPreview(cameraService.controller!),
            )
          else if (cameraService.hasError)
            Center(child: Text(
              cameraService.errorMessage!,
              style: const TextStyle(color: Colors.white),
            ))
          else
            const Center(child: CircularProgressIndicator(color: Colors.white)),

          // ── Overlay bounding box area ──────────────────────────────────
          Center(
            child: Container(
              width:  AppConfig.overlaySize,
              height: AppConfig.overlaySize,
              decoration: BoxDecoration(
                border: Border.all(
                  color: AppTheme.primary,
                  width: 2.5,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Stack(
                children: [
                  // Corner markers
                  ..._buildCorners(),
                ],
              ),
            ),
          ),

          // ── Top bar ────────────────────────────────────────────────────
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                children: [
                  GestureDetector(
                    onTap: () => context.pop(),
                    child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        color: Colors.black45,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Icon(Icons.arrow_back,
                          color: Colors.white, size: 20),
                    ),
                  ),
                  const Expanded(
                    child: Center(
                      child: Text(
                        'Posisikan objek di tengah',
                        style: TextStyle(color: Colors.white, fontSize: 14),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Bottom: Analyze button ─────────────────────────────────────
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              child: Container(
                padding: const EdgeInsets.fromLTRB(24, 20, 24, 24),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      Colors.black.withOpacity(0.9),
                      Colors.transparent,
                    ],
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    if (scanState is ScanLoading)
                      const Column(
                        children: [
                          CircularProgressIndicator(color: AppTheme.primary),
                          SizedBox(height: 12),
                          Text(
                            'Menganalisis...',
                            style: TextStyle(color: Colors.white),
                          ),
                        ],
                      )
                    else
                      SizedBox(
                        width: double.infinity,
                        height: 56,
                        child: ElevatedButton.icon(
                          onPressed: cameraService.isInitialized
                              ? _captureAndAnalyze
                              : null,
                          icon: _isCapturing
                              ? const SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2,
                                  ),
                                )
                              : const Icon(Icons.document_scanner_outlined),
                          label: const Text('Analyze It'),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  List<Widget> _buildCorners() {
    const size   = 20.0;
    const thick  = 3.0;
    const color  = AppTheme.primary;

    return [
      // Top-left
      Positioned(top: -1, left: -1,
          child: _Corner(size, thick, color, isTop: true, isLeft: true)),
      // Top-right
      Positioned(top: -1, right: -1,
          child: _Corner(size, thick, color, isTop: true, isLeft: false)),
      // Bottom-left
      Positioned(bottom: -1, left: -1,
          child: _Corner(size, thick, color, isTop: false, isLeft: true)),
      // Bottom-right
      Positioned(bottom: -1, right: -1,
          child: _Corner(size, thick, color, isTop: false, isLeft: false)),
    ];
  }
}

class _Corner extends StatelessWidget {
  final double size;
  final double thick;
  final Color color;
  final bool isTop, isLeft;

  const _Corner(this.size, this.thick, this.color,
      {required this.isTop, required this.isLeft});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(
          thick: thick,
          color: color,
          isTop: isTop,
          isLeft: isLeft,
        ),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final double thick;
  final Color color;
  final bool isTop, isLeft;

  _CornerPainter(
      {required this.thick, required this.color, required this.isTop, required this.isLeft});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = thick
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final x = isLeft ? 0.0 : size.width;
    final y = isTop  ? 0.0 : size.height;
    final dx = isLeft ? size.width  : -size.width;
    final dy = isTop  ? size.height : -size.height;

    canvas.drawLine(Offset(x, y), Offset(x + dx, y), paint);
    canvas.drawLine(Offset(x, y), Offset(x, y + dy), paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) => false;
}
