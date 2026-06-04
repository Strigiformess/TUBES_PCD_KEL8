import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';

import '../../../core/theme/app_theme.dart';
import '../../providers/scan_provider.dart';

class GalleryScreen extends ConsumerStatefulWidget {
  const GalleryScreen({super.key});

  @override
  ConsumerState<GalleryScreen> createState() => _GalleryScreenState();
}

class _GalleryScreenState extends ConsumerState<GalleryScreen> {
  bool _isProcessing = false;

  Future<void> _pickImage() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.image,
        allowMultiple: false,
        withData: kIsWeb,
      );

      if (result == null || result.files.isEmpty) {
        return;
      }

      String imagePath = '';

      if (kIsWeb) {
        final bytes = result.files.first.bytes;

        if (bytes == null) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: File bytes tidak ditemukan'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }

        imagePath = 'web_file_${DateTime.now().millisecondsSinceEpoch}';
      } else {
        imagePath = result.files.first.path ?? '';

        if (imagePath.isEmpty) {
          if (!mounted) return;

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error: Path file tidak valid'),
              backgroundColor: Colors.red,
            ),
          );
          return;
        }
      }

      setState(() {
        _isProcessing = true;
      });

      if (!mounted) return;

      await ref.read(scanStateProvider.notifier).analyze(imagePath);

      if (!mounted) return;

      final scanState = ref.read(scanStateProvider);

      if (scanState is ScanSuccess) {
        context.pushReplacementNamed(
          'detail',
          extra: scanState.result,
        );
      } else if (scanState is ScanError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(scanState.message),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 5),
          ),
        );

        setState(() {
          _isProcessing = false;
        });
      }
    } catch (e) {
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error membuka galeri: $e'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        _isProcessing = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih dari Galeri'),
        leading: IconButton(
          icon: const Icon(
            Icons.arrow_back_ios_new,
            color: AppTheme.textPrimary,
          ),
          onPressed: () => context.pop(),
        ),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(32),
                decoration: BoxDecoration(
                  color: AppTheme.surface.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.photo_library_rounded,
                  size: 80,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 32),

              const Text(
                "Pilih Foto Makanan",
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),

              const SizedBox(height: 12),

              Text(
                "Pilih gambar buah atau sayur dari galeri untuk mulai mengekstrak warna dan menganalisis kesegarannya.",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14,
                  color: AppTheme.textPrimary.withValues(alpha: 0.7),
                  height: 1.5,
                ),
              ),

              const SizedBox(height: 40),

              if (_isProcessing)
                const Column(
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.primary,
                      strokeWidth: 3,
                    ),
                    SizedBox(height: 16),
                    Text(
                      'Menganalisis gambar...',
                      style: TextStyle(
                        color: AppTheme.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                )
              else
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _pickImage,
                    icon: const Icon(Icons.upload_file_rounded),
                    label: const Text("Buka Galeri Sekarang"),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                    ),
                  ),
                ),

              const SizedBox(height: 24),

              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppTheme.primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info,
                      color: AppTheme.primary,
                      size: 20,
                    ),
                    SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Analisis otomatis membutuhkan waktu 2–5 detik tergantung ukuran gambar',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}