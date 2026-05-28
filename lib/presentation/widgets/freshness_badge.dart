import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FreshnessBadge extends StatelessWidget {
  final FreshnessStatus status;
  final bool small;

  const FreshnessBadge({super.key, required this.status, this.small = false});

  @override
  Widget build(BuildContext context) {
    final color   = status.color;
    final label   = status.label;
    final padding = small
        ? const EdgeInsets.symmetric(horizontal: 8, vertical: 3)
        : const EdgeInsets.symmetric(horizontal: 12, vertical: 6);

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: small ? 6 : 8,
            height: small ? 6 : 8,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.w600,
              fontSize: small ? 11 : 13,
            ),
          ),
        ],
      ),
    );
  }
}

/// Progress bar skor kesegaran (0–100)
class FreshnessScoreBar extends StatelessWidget {
  final int score;
  final double height;

  const FreshnessScoreBar({
    super.key,
    required this.score,
    this.height = 6,
  });

  Color get _barColor {
    if (score >= AppConfig.freshThreshold)  return AppTheme.fresh;
    if (score >= AppConfig.mediumThreshold) return AppTheme.medium;
    return AppTheme.poor;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(height),
      child: LinearProgressIndicator(
        value: score / 100.0,
        backgroundColor: Colors.grey.shade200,
        valueColor: AlwaysStoppedAnimation<Color>(_barColor),
        minHeight: height,
      ),
    );
  }
}

// ignore: avoid_classes_with_only_static_members
class AppConfig {
  static const int freshThreshold  = 70;
  static const int mediumThreshold = 40;
}
