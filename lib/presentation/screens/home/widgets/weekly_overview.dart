import 'package:flutter/material.dart';
import '../../../../core/theme/app_theme.dart';

class WeeklyOverview extends StatelessWidget {
  const WeeklyOverview({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppTheme.primaryLight, width: 2),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildStat("12", "Total Scan", AppTheme.accentBlue),
          _buildStat("85%", "Rerata Segar", AppTheme.primary),
          _buildStat("2", "Busuk", AppTheme.poor),
        ],
      ),
    );
  }

  Widget _buildStat(String value, String label, Color color) {
    return Column(
      children: [
        Text(value, style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900, color: color)),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w600)),
      ],
    );
  }
}