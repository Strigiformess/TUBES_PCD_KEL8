import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../controller/app_controller.dart';
import '../model/history_model.dart';
import '../widgets/common_widgets.dart';

class HomeTab extends StatelessWidget {
  const HomeTab({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AppController>();

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        // ── Greeting ──
        const SizedBox(height: 8),
        const Text('Hello, Chef.', style: TextStyle(
          fontSize: 28, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
        )),
        const Text('Ready for a freshness scan?', style: TextStyle(
          color: AppTheme.textSecondary, fontSize: 14,
        )),

        const SizedBox(height: 20),

        // ── Last scan preview (if any) ──
        if (ctrl.history.isNotEmpty) ...[
          ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: Stack(children: [
              SizedBox(
                height: 180,
                width: double.infinity,
                child: File(ctrl.history.first.imagePath).existsSync()
                    ? Image.file(File(ctrl.history.first.imagePath), fit: BoxFit.cover)
                    : Container(color: const Color(0xFFE2E8F0),
                        child: const Icon(Icons.image_outlined, size: 48, color: Colors.grey)),
              ),
              Positioned(
                top: 12, left: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(children: [
                    Icon(Icons.circle, color: AppTheme.green, size: 8),
                    SizedBox(width: 6),
                    Text('READY TO SCAN', style: TextStyle(
                      color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700,
                    )),
                  ]),
                ),
              ),
            ]),
          ),
          const SizedBox(height: 16),
        ],

        // ── Quick actions ──
        _QuickAction(
          icon: Icons.camera_alt_rounded,
          title: 'Camera',
          subtitle: 'Live capture',
          color: AppTheme.green,
          onTap: () {}, // trigger dari parent via tab
        ),
        const SizedBox(height: 10),
        _QuickAction(
          icon: Icons.photo_library_outlined,
          title: 'Gallery',
          subtitle: 'Analyze existing media',
          color: const Color(0xFF3B82F6),
          onTap: () {},
        ),

        const SizedBox(height: 24),

        // ── Recent Activity ──
        if (ctrl.history.isNotEmpty) ...[
          SectionHeader('Recent Activity', trailing: GestureDetector(
            onTap: () {},
            child: const Text('View History', style: TextStyle(
              color: AppTheme.green, fontSize: 13, fontWeight: FontWeight.w600,
            )),
          )),
          const SizedBox(height: 12),
          ...ctrl.history.take(3).map((item) => _RecentItem(item)),
        ],
      ]),
    );
  }
}

class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String title, subtitle;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.title,
    required this.subtitle, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color == AppTheme.green ? AppTheme.green : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: color == AppTheme.green ? null : Border.all(color: AppTheme.border),
      ),
      child: Row(children: [
        Icon(icon,
          color: color == AppTheme.green ? Colors.white : color, size: 28),
        const SizedBox(width: 14),
        Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(title, style: TextStyle(
            color: color == AppTheme.green ? Colors.white : AppTheme.textPrimary,
            fontSize: 16, fontWeight: FontWeight.w700,
          )),
          Text(subtitle, style: TextStyle(
            color: color == AppTheme.green
                ? Colors.white70 : AppTheme.textSecondary,
            fontSize: 12,
          )),
        ]),
      ]),
    ),
  );
}

class _RecentItem extends StatelessWidget {
  final HistoryItem item;
  const _RecentItem(this.item);

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 10),
    padding: const EdgeInsets.all(12),
    decoration: BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      border: Border.all(color: AppTheme.border),
    ),
    child: Row(children: [
      ClipRRect(
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 44, height: 44,
          child: File(item.imagePath).existsSync()
              ? Image.file(File(item.imagePath), fit: BoxFit.cover)
              : Container(color: const Color(0xFFE2E8F0),
                  child: const Icon(Icons.image_outlined, size: 20)),
        ),
      ),
      const SizedBox(width: 12),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text('LAST SCAN', style: TextStyle(
          color: AppTheme.textSecondary, fontSize: 10,
          fontWeight: FontWeight.w600, letterSpacing: 0.5,
        )),
        Text(item.foodName, style: const TextStyle(
          color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600,
        )),
      ])),
      CategoryBadge(item.kategori),
    ]),
  );
}
