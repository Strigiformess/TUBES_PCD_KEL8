import 'package:flutter/material.dart';
import '../../core/theme/app_theme.dart';

class FreshnessBadge extends StatelessWidget {
  final String status;

  const FreshnessBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color bgColor;
    Color textColor;

    if (status.contains('Sangat')) {
      bgColor = AppTheme.excellent.withValues(alpha:0.2);
      textColor = const Color(0xFF2E7D32); // Dark Green
    } else if (status.contains('Cukup')) {
      bgColor = AppTheme.moderate.withValues(alpha:0.3);
      textColor = const Color(0xFFE65100); // Dark Orange
    } else {
      bgColor = AppTheme.poor.withValues(alpha:0.2);
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
        style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 12),
      ),
    );
  }
}