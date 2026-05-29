import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FreshnessBadge extends StatelessWidget {
  final String status;

  const FreshnessBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    // Menggunakan variabel statusFresh, statusMedium, dan statusPoor dari AppTheme
    if (status.contains('Sangat') || status.contains('Segar')) {
      bgColor = AppTheme.statusFresh.withValues(alpha: 0.2);
      textColor = const Color(0xFF2E7D32); // Dark Green
    } else if (status.contains('Cukup') || status.contains('Sedang')) {
      bgColor = AppTheme.statusMedium.withValues(alpha: 0.3);
      textColor = const Color(0xFFE65100); // Dark Orange
    } else {
      bgColor = AppTheme.statusPoor.withValues(alpha: 0.2);
      textColor = const Color(0xFFC62828); // Dark Red
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: textColor, 
          fontWeight: FontWeight.bold, 
          fontSize: 12,
        ),
      ),
    );
  }
}