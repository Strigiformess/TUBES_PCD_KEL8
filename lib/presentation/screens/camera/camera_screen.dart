import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../providers/scan_provider.dart';
import 'widgets/corner_painter.dart';

class CameraScreen extends ConsumerStatefulWidget {
  const CameraScreen({super.key});

  @override
  ConsumerState<CameraScreen> createState() => _CameraScreenState();
}

class _CameraScreenState extends ConsumerState<CameraScreen> {
  bool _isProcessing = false;

  Future<void> _takePhoto() async {
    setState(() => _isProcessing = true);
    await Future.delayed(const Duration(seconds: 1)); // Simulasi jepret
    
    // PERBAIKAN: Kita ganti File menjadi String (path palsu/dummy)
    const String dummyPath = 'dummy_image_path.jpg';
    
    if (!mounted) return;
    
    // Sekarang provider akan menerima String dengan aman
    await ref.read(scanStateProvider.notifier).analyze(dummyPath);
    
    if (!mounted) return;
    final state = ref.read(scanStateProvider);
    if (state is ScanSuccess) {
      context.pushReplacement('/detail', extra: state.result);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFFDD0), // Background Cream
      body: Stack(
        children: [
          Center(
            child: Container(
              width: 300,
              height: 400,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: AppTheme.primary.withValues(alpha:0.5), blurRadius: 20)],
              ),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  const Text("Kamera Aktif", style: TextStyle(color: AppTheme.textSecondary)),
                  SizedBox(
                    width: 220,
                    height: 220,
                    child: CustomPaint(painter: CornerPainter(color: AppTheme.primary)),
                  )
                ],
              ),
            ),
          ),
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                GestureDetector(
                  onTap: _isProcessing ? null : _takePhoto,
                  child: Container(
                    padding: const EdgeInsets.all(6),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(color: AppTheme.primary, width: 3),
                    ),
                    child: CircleAvatar(
                      radius: 36,
                      backgroundColor: _isProcessing ? Colors.grey : AppTheme.primary,
                      child: _isProcessing 
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Icon(Icons.camera_alt, color: Colors.white, size: 32),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 50,
            left: 20,
            child: IconButton(
              icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
              onPressed: () => context.pop(),
            ),
          )
        ],
      ),
    );
  }
}