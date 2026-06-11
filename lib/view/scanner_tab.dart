import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../controller/app_controller.dart';
import 'result_screen.dart';

class ScannerTab extends StatelessWidget {
  const ScannerTab({super.key});

  Future<void> _pick(BuildContext context, ImageSource src) async {
    final picked = await ImagePicker().pickImage(
      source: src,
      imageQuality: 85,
      maxWidth: 1200,
    );
    if (picked == null || !context.mounted) return;
    context.read<AppController>().setImage(File(picked.path));
  }

  Future<void> _analyze(BuildContext context) async {
    await context.read<AppController>().analyze();
    if (!context.mounted) return;
    final ctrl = context.read<AppController>();
    if (ctrl.scanState == ScanState.success && ctrl.result != null) {
      Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => ResultScreen(
              result: ctrl.result!,
              imagePath: ctrl.selectedImage!.path,
              foodName: ctrl.history.first.foodName,
            ),
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AppController>();

    return Column(children: [
      // ── Image area ──
      Expanded(
        child: Stack(children: [
          // Preview
          Container(
            width: double.infinity,
            margin: const EdgeInsets.fromLTRB(20, 0, 20, 0),
            decoration: BoxDecoration(
              color: const Color(0xFFF1F5F9),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: ctrl.selectedImage != null
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(19),
                    child: Image.file(ctrl.selectedImage!, fit: BoxFit.cover),
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                        Icon(Icons.add_photo_alternate_outlined,
                            size: 64, color: Colors.grey.shade400),
                        const SizedBox(height: 12),
                        const Text(
                          'Position the sample clearly\nwithin the focus frame',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                              color: AppTheme.textSecondary, fontSize: 14),
                        ),
                      ]),
          ),

          // PCD Active badge
          if (ctrl.selectedImage != null)
            Positioned(
              top: 12,
              left: 32,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 5),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.55),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(children: [
                  Icon(Icons.circle, color: AppTheme.green, size: 7),
                  SizedBox(width: 6),
                  Text('PCD ACTIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 0.5,
                      )),
                ]),
              ),
            ),
        ]),
      ),

      // ── Controls ──
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
        child: Column(children: [
          // Camera / Gallery
          Row(children: [
            _PickBtn(
                icon: Icons.camera_alt_outlined,
                label: 'CAMERA',
                onTap: () => _pick(context, ImageSource.camera)),
            const SizedBox(width: 12),
            _PickBtn(
                icon: Icons.photo_library_outlined,
                label: 'GALLERY',
                onTap: () => _pick(context, ImageSource.gallery)),
          ]),

          const SizedBox(height: 12),

          // Analyze button
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: ctrl.selectedImage == null ||
                      ctrl.scanState == ScanState.loading
                  ? null
                  : () => _analyze(context),
              icon: ctrl.scanState == ScanState.loading
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.white))
                  : const Icon(Icons.analytics_outlined, size: 20),
              label: Text(
                ctrl.scanState == ScanState.loading
                    ? 'Analyzing...'
                    : 'Analyze Now',
                style:
                    const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.green,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppTheme.green.withOpacity(0.35),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16)),
                elevation: 0,
              ),
            ),
          ),

          // Error
          if (ctrl.scanState == ScanState.error) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: AppTheme.redLight,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Text(ctrl.errorMsg,
                  style: const TextStyle(
                    color: AppTheme.red,
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center),
            ),
          ],
        ]),
      ),
    ]);
  }
}

class _PickBtn extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  const _PickBtn(
      {required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) => Expanded(
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              Icon(icon, size: 18, color: AppTheme.textSecondary),
              const SizedBox(width: 8),
              Text(label,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  )),
            ]),
          ),
        ),
      );
}
