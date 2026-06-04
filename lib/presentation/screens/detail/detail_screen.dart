import 'dart:io';
import 'package:flutter/foundation.dart'; 
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../data/models/scan_result.dart';
import '../../../core/theme/app_theme.dart';

class DetailScreen extends StatelessWidget {
  final ScanResult? scan;

  const DetailScreen({super.key, this.scan});

  @override
  Widget build(BuildContext context) {
    // ❌ Handle jika scan null atau invalid
    if (scan == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 16),
              const Text(
                'Data hasil analisis tidak ditemukan',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () => context.go('/'),
                child: const Text('Kembali ke Home'),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Hasil Analisis'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ✅ GAMBAR HASIL SCAN
            _buildImageSection(scan!),
            const SizedBox(height: 32),

            // ✅ NAMA MAKANAN + STATUS
            _buildHeaderSection(scan!),
            const SizedBox(height: 24),

            // ✅ SKOR KESEGARAN
            _buildFreshnessScoreSection(scan!),
            const SizedBox(height: 24),

            // ✅ METRIK PCD
            _buildPCDMetricsSection(scan!),
            const SizedBox(height: 24),

            // ✅ REKOMENDASI
            _buildRecommendationsSection(scan!),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Widget builders
  // ─────────────────────────────────────────────────────────────────────────

  Widget _buildImageSection(ScanResult scan) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(32),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primary.withValues(alpha: 0.5),
            blurRadius: 20,
            offset: const Offset(0, 10),
          )
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: _buildImageWidget(scan.imagePath),
      ),
    );
  }

  /// Handle image rendering untuk berbagai platform
  Widget _buildImageWidget(String imagePath) {
    try {
      // Web platform
      if (kIsWeb) {
        return Image.network(
          imagePath,
          width: double.infinity,
          height: 260,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 260,
              color: Colors.grey[300],
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Gambar tidak dapat ditampilkan'),
                ],
              ),
            );
          },
        );
      }

      // Native platform (Android/iOS)
      final file = File(imagePath);
      if (file.existsSync()) {
        return Image.file(
          file,
          width: double.infinity,
          height: 260,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            return Container(
              width: double.infinity,
              height: 260,
              color: Colors.grey[300],
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
                  SizedBox(height: 8),
                  Text('Gambar tidak dapat ditampilkan'),
                ],
              ),
            );
          },
        );
      }

      // File tidak ada
      return Container(
        width: double.infinity,
        height: 260,
        color: Colors.grey[300],
        child: const Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.image_not_supported, size: 48, color: Colors.grey),
            SizedBox(height: 8),
            Text('File gambar tidak ditemukan'),
          ],
        ),
      );
    } catch (e) {
      return Container(
        width: double.infinity,
        height: 260,
        color: Colors.grey[300],
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 8),
            Text('Error: $e', textAlign: TextAlign.center),
          ],
        ),
      );
    }
  }

  Widget _buildHeaderSection(ScanResult scan) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                scan.foodType,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _getStatusColor(scan.status),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            scan.status,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 12,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFreshnessScoreSection(ScanResult scan) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Tingkat Kesegaran",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              Text(
                "${scan.freshnessScore.toStringAsFixed(1)}%",
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w900,
                  color: AppTheme.primary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress bar
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: scan.scoreNormalized,
              minHeight: 8,
              backgroundColor: AppTheme.border,
              valueColor: AlwaysStoppedAnimation<Color>(
                _getScoreColor(scan.freshnessScore.toInt()),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPCDMetricsSection(ScanResult scan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Metrik Analisis Citra",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: AppTheme.primary.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppTheme.primary.withValues(alpha: 0.3)),
          ),
          child: Column(
            // ✅ FIX: Hapus .toList() karena sudah menggunakan spread operator
            children: [
              ...scan.pcdMetrics.entries.map((e) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        e.key,
                        style: const TextStyle(
                          color: AppTheme.textSecondary,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Text(
                        e.value.toStringAsFixed(2),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ],
                  ),
                );
              }),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildRecommendationsSection(ScanResult scan) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Rekomendasi Penyimpanan",
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        // ✅ FIX: Hapus .toList() karena sudah menggunakan spread operator
        ...scan.recommendations.map((rec) {
          return Padding(
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '•',
                  style: TextStyle(fontSize: 20, color: AppTheme.primary),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    rec,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 14,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          );
        }),
      ],
    );
  }

  // ─────────────────────────────────────────────────────────────────────────
  // Helper functions
  // ─────────────────────────────────────────────────────────────────────────

  Color _getStatusColor(String status) {
    if (status.contains('Segar') || status.contains('Fresh')) {
      return AppTheme.statusFresh;
    } else if (status.contains('Sedang') || status.contains('Medium')) {
      return AppTheme.statusMedium;
    } else {
      return AppTheme.statusPoor;
    }
  }

  Color _getScoreColor(int score) {
    if (score >= 70) {
      return AppTheme.statusFresh;
    } else if (score >= 40) {
      return AppTheme.statusMedium;
    } else {
      return AppTheme.statusPoor;
    }
  }
}