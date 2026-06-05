// view/result_screen.dart
// Menampilkan hasil TFLite + PCD (jika tersedia)

import 'dart:io';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../controller/app_controller.dart';
import '../widgets/common_widgets.dart';

class ResultScreen extends StatelessWidget {
  final ScanResult result;
  final String imagePath;
  final String foodName;

  const ResultScreen({
    super.key,
    required this.result,
    required this.imagePath,
    required this.foodName,
  });

  Color get _color => AppTheme.categoryColor(result.kategori);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Hasil Analisis'),
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

          // ── Score Card ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 88, height: 88,
                  child: File(imagePath).existsSync()
                      ? Image.file(File(imagePath), fit: BoxFit.cover)
                      : Container(color: const Color(0xFFE2E8F0)),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(foodName, style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: AppTheme.textPrimary,
                  )),
                  const SizedBox(height: 6),
                  CategoryBadge(result.kategori),
                  const SizedBox(height: 10),
                  ScoreText(result.skor, result.kategori, fontSize: 30),
                ],
              )),
            ]),
          ),

          const SizedBox(height: 12),

          // ── Pesan ──
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppTheme.categoryBg(result.kategori),
              borderRadius: BorderRadius.circular(14),
            ),
            child: Text(result.pesan, style: TextStyle(
              color: _color, fontSize: 13, height: 1.5,
            )),
          ),

          const SizedBox(height: 20),

          // ── Probabilitas Model ──
          const SectionHeader('Hasil Model CNN'),
          const SizedBox(height: 10),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.border),
            ),
            child: Column(children: [
              _ProbBar(
                label: 'Fresh',
                value: result.probFresh,
                color: AppTheme.green,
              ),
              const SizedBox(height: 10),
              _ProbBar(
                label: 'Rotten',
                value: result.probRotten,
                color: AppTheme.red,
              ),
              const SizedBox(height: 12),
              Row(children: [
                const Icon(Icons.memory_outlined, size: 13, color: AppTheme.textSecondary),
                const SizedBox(width: 5),
                Text('On-device inference via TFLite',
                  style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
              ]),
            ]),
          ),

          // ── Detail PCD (jika backend aktif) ──
          if (result.usedPcd) ...[
            const SizedBox(height: 20),
            const SectionHeader('Detail Fitur PCD'),
            const SizedBox(height: 10),
            _FeatureBar('Warna', Icons.palette_outlined, result.skorWarna!),
            const SizedBox(height: 8),
            _FeatureBar('Kecerahan', Icons.wb_sunny_outlined, result.skorKecerahan!),
            const SizedBox(height: 8),
            _FeatureBar('Tekstur', Icons.texture_outlined, result.skorTekstur!),
            const SizedBox(height: 8),
            _FeatureBar('Kerusakan', Icons.warning_amber_outlined, result.skorKerusakan!),
          ] else ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFF1F5F9),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(children: [
                Icon(Icons.info_outline, size: 14, color: AppTheme.textSecondary),
                SizedBox(width: 8),
                Expanded(child: Text(
                  'Jalankan backend Python untuk melihat detail fitur PCD (warna, tekstur, dll).',
                  style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                )),
              ]),
            ),
          ],

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity, height: 52,
            child: OutlinedButton.icon(
              onPressed: () => Navigator.pop(context),
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Scan Lagi'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.green,
                side: const BorderSide(color: AppTheme.green),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
            ),
          ),
        ]),
      ),
    );
  }
}

class _ProbBar extends StatelessWidget {
  final String label;
  final double value;
  final Color color;
  const _ProbBar({required this.label, required this.value, required this.color});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(children: [
        Text(label, style: const TextStyle(
          fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary,
        )),
        const Spacer(),
        Text('${(value * 100).toStringAsFixed(1)}%',
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: color)),
      ]),
      const SizedBox(height: 6),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value,
          backgroundColor: const Color(0xFFE2E8F0),
          valueColor: AlwaysStoppedAnimation(color),
          minHeight: 6,
        ),
      ),
    ],
  );
}

class _FeatureBar extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  const _FeatureBar(this.label, this.icon, this.value);

  Color get _color {
    if (value >= 70) return AppTheme.green;
    if (value >= 45) return AppTheme.yellow;
    return AppTheme.red;
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border),
    ),
    child: Column(children: [
      Row(children: [
        Icon(icon, size: 16, color: _color),
        const SizedBox(width: 8),
        Text(label, style: const TextStyle(
          color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600,
        )),
        const Spacer(),
        Text(value.toStringAsFixed(1), style: TextStyle(
          color: _color, fontSize: 14, fontWeight: FontWeight.w700,
        )),
      ]),
      const SizedBox(height: 8),
      ClipRRect(
        borderRadius: BorderRadius.circular(4),
        child: LinearProgressIndicator(
          value: value / 100,
          backgroundColor: const Color(0xFFE2E8F0),
          valueColor: AlwaysStoppedAnimation(_color),
          minHeight: 5,
        ),
      ),
    ]),
  );
}
