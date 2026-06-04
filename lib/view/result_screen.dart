import 'dart:io';
import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../model/result_model.dart';
import '../widgets/common_widgets.dart';

class ResultScreen extends StatelessWidget {
  final dynamic result; // AnalysisResult or _FakeResult
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
        title: const Text('Analysis Result'),
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
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppTheme.border),
            ),
            child: Row(children: [
              // Image
              ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: SizedBox(
                  width: 90, height: 90,
                  child: File(imagePath).existsSync()
                      ? Image.file(File(imagePath), fit: BoxFit.cover)
                      : Container(color: const Color(0xFFE2E8F0)),
                ),
              ),
              const SizedBox(width: 18),

              Expanded(child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(foodName, style: const TextStyle(
                    fontSize: 20, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
                  )),
                  const SizedBox(height: 6),
                  CategoryBadge(result.kategori),
                  const SizedBox(height: 10),
                  ScoreText(result.skor, result.kategori, fontSize: 32),
                ],
              )),
            ]),
          ),

          const SizedBox(height: 16),

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

          // ── Feature Detail ──
          const SectionHeader('Detail per Fitur'),
          const SizedBox(height: 12),

          _FeatureRow('Warna', Icons.palette_outlined, result.skorWarna),
          _FeatureRow('Kecerahan', Icons.wb_sunny_outlined, result.skorKecerahan),
          _FeatureRow('Tekstur', Icons.texture_outlined, result.skorTekstur),
          _FeatureRow('Kerusakan', Icons.warning_amber_outlined, result.skorKerusakan),

          const SizedBox(height: 20),

          // ── Back button ──
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

class _FeatureRow extends StatelessWidget {
  final String label;
  final IconData icon;
  final double value;
  const _FeatureRow(this.label, this.icon, this.value);

  Color get _color {
    if (value >= 70) return AppTheme.green;
    if (value >= 45) return AppTheme.yellow;
    return AppTheme.red;
  }

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
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
      const SizedBox(height: 10),
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
