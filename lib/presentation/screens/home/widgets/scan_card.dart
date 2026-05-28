import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../data/models/scan_result.dart';
import '../../../../presentation/widgets/freshness_badge.dart';

class ScanCard extends StatelessWidget {
  final ScanResult scan;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const ScanCard({
    super.key,
    required this.scan,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(14),
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
        child: Row(
          children: [
            // Thumbnail gambar
            ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: 64,
                height: 64,
                child: scan.imagePath.isNotEmpty
                    ? Image.file(File(scan.imagePath), fit: BoxFit.cover)
                    : _PlaceholderIcon(label: scan.label),
              ),
            ),
            const SizedBox(width: 14),

            // Label & info
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    scan.label,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DateFormat('MMM d, hh:mm a').format(scan.scannedAt),
                    style: const TextStyle(
                      fontSize: 12,
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 8),
                  FreshnessBadge(status: scan.status, small: true),
                ],
              ),
            ),

            // Skor
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: '${scan.freshnessScore}',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                          color: scan.status.color,
                        ),
                      ),
                      const TextSpan(
                        text: '/100',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                if (onDelete != null)
                  GestureDetector(
                    onTap: onDelete,
                    child: const Icon(
                      Icons.delete_outline,
                      size: 18,
                      color: AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _PlaceholderIcon extends StatelessWidget {
  final String label;
  const _PlaceholderIcon({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.surface,
      child: Center(
        child: Text(
          label.isNotEmpty ? label[0] : '?',
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: AppTheme.primary,
          ),
        ),
      ),
    );
  }
}
