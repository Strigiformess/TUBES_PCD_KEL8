import 'dart:io';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/scan_result.dart';
import '../../widgets/freshness_badge.dart';

class DetailScreen extends StatelessWidget {
  final ScanResult scan;
  const DetailScreen({super.key, required this.scan});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          // ── App Bar dengan gambar ─────────────────────────────────────
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: AppTheme.surface,
            leading: GestureDetector(
              onTap: () => context.pop(),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.9),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: AppTheme.textPrimary),
              ),
            ),
            flexibleSpace: FlexibleSpaceBar(
              background: scan.imagePath.isNotEmpty
                  ? Image.file(File(scan.imagePath), fit: BoxFit.cover)
                  : Container(
                      color: AppTheme.primary.withOpacity(0.1),
                      child: const Icon(Icons.eco,
                          size: 80, color: AppTheme.primary),
                    ),
            ),
          ),

          // ── Content ───────────────────────────────────────────────────
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label + Badge
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        scan.label,
                        style: const TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      FreshnessBadge(status: scan.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    DateFormat('MMM dd, yyyy — hh:mm a').format(scan.scannedAt),
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // ── Skor Kesegaran ──────────────────────────────────
                  _ScoreCard(scan: scan),

                  const SizedBox(height: 20),

                  // ── Detail Info ─────────────────────────────────────
                  _InfoCard(scan: scan),

                  const SizedBox(height: 20),

                  // ── Rekomendasi ─────────────────────────────────────
                  _RecommendationCard(status: scan.status),

                  const SizedBox(height: 32),

                  // ── Scan lagi button ────────────────────────────────
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: () => context.go('/camera'),
                      icon: const Icon(Icons.camera_alt_outlined),
                      label: const Text('Scan Lagi'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Score Card ────────────────────────────────────────────────────────────────

class _ScoreCard extends StatelessWidget {
  final ScanResult scan;
  const _ScoreCard({required this.scan});

  @override
  Widget build(BuildContext context) {
    final color = scan.status.color;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Freshness Score',
            style: TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '${scan.freshnessScore}',
                style: TextStyle(
                  fontSize: 56,
                  fontWeight: FontWeight.w700,
                  color: color,
                  height: 1,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 8),
                child: Text(
                  '/100',
                  style: TextStyle(
                    fontSize: 20,
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              const Spacer(),
              // Gauge circle
              SizedBox(
                width: 64,
                height: 64,
                child: CircularProgressIndicator(
                  value: scan.scoreNormalized,
                  strokeWidth: 7,
                  backgroundColor: color.withOpacity(0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FreshnessScoreBar(score: scan.freshnessScore, height: 8),
        ],
      ),
    );
  }
}

// ── Info Card ─────────────────────────────────────────────────────────────────

class _InfoCard extends StatelessWidget {
  final ScanResult scan;
  const _InfoCard({required this.scan});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          _InfoRow(
            icon: Icons.percent,
            label: 'Confidence',
            value: '${(scan.confidence * 100).toStringAsFixed(1)}%',
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.memory,
            label: 'Pipeline',
            value: scan.pipeline.toUpperCase(),
          ),
          const Divider(height: 20),
          _InfoRow(
            icon: Icons.access_time,
            label: 'Waktu Scan',
            value: DateFormat('HH:mm:ss').format(scan.scannedAt),
          ),
        ],
      ),
    );
  }
}

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({required this.icon, required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, size: 18, color: AppTheme.primary),
        const SizedBox(width: 10),
        Text(label,
            style: const TextStyle(color: AppTheme.textSecondary, fontSize: 14)),
        const Spacer(),
        Text(value,
            style: const TextStyle(
              fontWeight: FontWeight.w600,
              color: AppTheme.textPrimary,
              fontSize: 14,
            )),
      ],
    );
  }
}

// ── Recommendation Card ───────────────────────────────────────────────────────

class _RecommendationCard extends StatelessWidget {
  final FreshnessStatus status;
  const _RecommendationCard({required this.status});

  static const _recommendations = {
    FreshnessStatus.fresh: (
      icon: Icons.thumb_up_outlined,
      title: 'Sangat Segar!',
      message:
          'Produk ini dalam kondisi optimal. Segera konsumsi untuk mendapatkan nutrisi terbaik.',
    ),
    FreshnessStatus.medium: (
      icon: Icons.warning_amber_outlined,
      title: 'Cukup Segar',
      message:
          'Produk ini masih layak konsumsi namun sebaiknya digunakan dalam 1–2 hari ke depan.',
    ),
    FreshnessStatus.poor: (
      icon: Icons.dangerous_outlined,
      title: 'Tidak Segar',
      message:
          'Produk ini sudah melewati masa kesegaran optimal. Periksa kembali sebelum dikonsumsi.',
    ),
  };

  @override
  Widget build(BuildContext context) {
    final rec   = _recommendations[status]!;
    final color = status.color;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(rec.icon, color: color, size: 24),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  rec.title,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: color,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  rec.message,
                  style: const TextStyle(
                    color: AppTheme.textSecondary,
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
