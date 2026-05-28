import 'dart:io';
import 'package:flutter/foundation.dart'; // Wajib ditambahkan untuk kIsWeb
import 'package:flutter/material.dart';
import '../../../../data/models/scan_result.dart';
import '../../../../core/theme/app_theme.dart';

class DetailScreen extends StatelessWidget {
  final ScanResult scan;

  const DetailScreen({super.key, required this.scan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Hasil Analisis PCD')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(32),
                boxShadow: [BoxShadow(color: AppTheme.primaryLight.withOpacity(0.5), blurRadius: 20, offset: const Offset(0, 10))],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(32),
                // Logika pembacaan gambar Web vs Mobile
                child: kIsWeb
                    ? Image.network(scan.imagePath, width: double.infinity, height: 260, fit: BoxFit.cover)
                    : Image.file(File(scan.imagePath), width: double.infinity, height: 260, fit: BoxFit.cover),
              ),
            ),
            const SizedBox(height: 32),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(scan.foodType, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(color: AppTheme.excellent, borderRadius: BorderRadius.circular(20)),
                  child: Text(scan.status, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(24)),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text("Tingkat Kesegaran", style: TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  Text("${scan.freshnessScore}%", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: AppTheme.primary)),
                ],
              ),
            ),
            const SizedBox(height: 24),

            const Text("Detail Metrik Citra", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.primaryLight.withOpacity(0.3), borderRadius: BorderRadius.circular(24)),
              child: Column(
                children: scan.pcdMetrics.entries.map((e) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(e.key, style: const TextStyle(color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
                      Text(e.value.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}