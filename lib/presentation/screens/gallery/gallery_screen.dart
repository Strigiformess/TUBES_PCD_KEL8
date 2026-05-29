import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
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
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() => _isProcessing = true);

      if (!mounted) return;
      
      // Langsung oper path-nya (Aman untuk Chrome/Web)
      await ref.read(scanStateProvider.notifier).analyze(pickedFile.path);

      if (!mounted) return;
      final state = ref.read(scanStateProvider);
      
      if (state is ScanSuccess) {
        context.pushReplacement('/detail', extra: state.result);
      }
      
      setState(() => _isProcessing = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pilih dari Galeri'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: AppTheme.textPrimary),
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
                  color: AppTheme.surface.withValues(alpha:0.3),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.photo_library_rounded, size: 80, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 32),
              const Text(
                "Pilih Foto Makanan",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
              ),
              const SizedBox(height: 12),
              Text(
                "Pilih gambar buah atau sayur dari galeri HP untuk mulai mengekstrak warna dan menganalisis kesegarannya.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 14, color: AppTheme.textPrimary.withValues(alpha:0.7), height: 1.5),
              ),
              const SizedBox(height: 40),
              
              _isProcessing 
                ? const CircularProgressIndicator(color: AppTheme.primary)
                : SizedBox(
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
            ],
          ),
        ),
      ),
    );
  }
}