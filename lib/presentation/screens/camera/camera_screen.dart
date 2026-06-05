// lib/presentation/screens/camera/camera_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../domain/services/camera_service.dart';
import '../../providers/scan_provider.dart';
import 'widgets/corner_painter.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});
  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  final CameraService _cameraService = CameraService();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _cameraService.init(); // Inisialisasi kamera saat screen dibuka
    _cameraService.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _cameraService.dispose(); // Hentikan kamera saat meninggalkan screen
    super.dispose();
  }

  Future<void> _takePhoto() async {
    if (_isProcessing) return;
    setState(() => _isProcessing = true);

    // Ambil foto asli dari kamera
    final photo = await _cameraService.takePicture();
    if (photo == null) {
      setState(() => _isProcessing = false);
      return;
    }

    if (!mounted) return;
    // Kirim path foto asli ke ML service
    await ref.read(scanStateProvider.notifier).analyze(photo.path);

    if (!mounted) return;
    final state = ref.read(scanStateProvider);
    if (state is ScanSuccess) {
      context.pushReplacementNamed('detail', extra: state.result);
    }
    setState(() => _isProcessing = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          // Preview kamera asli
          if (_cameraService.isInitialized)
            SizedBox.expand(
              child: CameraPreview(_cameraService.controller!),
            )
          else
            const Center(child: CircularProgressIndicator()),

          // Overlay kotak deteksi
          Center(
            child: SizedBox(
              width: 240, height: 240,
              child: CustomPaint(
                painter: CornerPainter(color: AppTheme.primary),
              ),
            ),
          ),

          // Tombol kembali
          Positioned(
            top: 50, left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white),
              onPressed: () => context.pop(),
            ),
          ),

          // Tombol capture
          Positioned(
            bottom: 50, left: 0, right: 0,
            child: Center(
              child: GestureDetector(
                onTap: _isProcessing ? null : _takePhoto,
                child: Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 3),
                  ),
                  child: CircleAvatar(
                    radius: 36,
                    backgroundColor: _isProcessing
                        ? Colors.grey : AppTheme.primary,
                    child: _isProcessing
                        ? const CircularProgressIndicator(color: Colors.white)
                        : const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}