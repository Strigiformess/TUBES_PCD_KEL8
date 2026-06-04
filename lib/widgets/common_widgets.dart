import 'package:flutter/material.dart';
import '../app_theme.dart';

// ── Category Badge ──
class CategoryBadge extends StatelessWidget {
  final String kategori;
  const CategoryBadge(this.kategori, {super.key});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
    decoration: BoxDecoration(
      color: AppTheme.categoryBg(kategori),
      borderRadius: BorderRadius.circular(20),
    ),
    child: Text(
      '● $kategori',
      style: TextStyle(
        color: AppTheme.categoryColor(kategori),
        fontSize: 11,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

// ── Score Text ──
class ScoreText extends StatelessWidget {
  final double skor;
  final String kategori;
  final double fontSize;
  const ScoreText(this.skor, this.kategori, {this.fontSize = 16, super.key});

  @override
  Widget build(BuildContext context) => RichText(
    text: TextSpan(
      children: [
        TextSpan(
          text: skor.toStringAsFixed(0),
          style: TextStyle(
            color: AppTheme.categoryColor(kategori),
            fontSize: fontSize,
            fontWeight: FontWeight.w800,
          ),
        ),
        TextSpan(
          text: '/100',
          style: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: fontSize * 0.65,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    ),
  );
}

// ── Section Header ──
class SectionHeader extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const SectionHeader(this.title, {this.trailing, super.key});

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Text(title, style: const TextStyle(
        color: AppTheme.textPrimary,
        fontSize: 17,
        fontWeight: FontWeight.w700,
      )),
      const Spacer(),
      if (trailing != null) trailing!,
    ],
  );
}

// ── Stat Card ──
class StatCard extends StatelessWidget {
  final String value;
  final String label;
  final IconData icon;
  const StatCard({required this.value, required this.label, required this.icon, super.key});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Row(
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppTheme.greenLight,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: AppTheme.green, size: 18),
          ),
          const SizedBox(width: 10),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: const TextStyle(
                color: AppTheme.green,
                fontSize: 20,
                fontWeight: FontWeight.w800,
              )),
              Text(label, style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 11,
              )),
            ],
          ),
        ],
      ),
    ),
  );
}
