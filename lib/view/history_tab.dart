import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../controller/app_controller.dart';
import '../model/history_model.dart';
import '../widgets/common_widgets.dart';
import 'result_screen.dart';

class HistoryTab extends StatelessWidget {
  const HistoryTab({super.key});

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 60) return 'Today, ${_fmt(dt)}';
    if (diff.inDays == 0) return 'Today, ${_fmt(dt)}';
    if (diff.inDays == 1) return 'Yesterday, ${_fmt(dt)}';
    final months = ['Jan','Feb','Mar','Apr','May','Jun',
                    'Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month-1]} ${dt.day}, ${_fmt(dt)}';
  }

  String _fmt(DateTime dt) =>
      '${dt.hour % 12 == 0 ? 12 : dt.hour % 12}:${dt.minute.toString().padLeft(2,'0')} '
      '${dt.hour < 12 ? 'AM' : 'PM'}';

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AppController>();

    return Column(children: [
      // ── Stats ──
      Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
        child: Row(children: [
          StatCard(
            icon: Icons.auto_awesome_outlined,
            value: '${ctrl.avgFreshness.toStringAsFixed(0)}%',
            label: 'AVG FRESHNESS',
          ),
          const SizedBox(width: 12),
          StatCard(
            icon: Icons.bar_chart_rounded,
            value: ctrl.totalScans.toString(),
            label: 'TOTAL SCANS',
          ),
        ]),
      ),

      // ── List header ──
      const Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 12),
        child: SectionHeader('Recent Scans'),
      ),

      // ── List ──
      Expanded(
        child: ctrl.history.isEmpty
            ? const Center(child: Text('Belum ada riwayat scan.',
                style: TextStyle(color: AppTheme.textSecondary)))
            : ListView.separated(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                itemCount: ctrl.history.length,
                separatorBuilder: (_, __) => const SizedBox(height: 10),
                itemBuilder: (_, i) => _HistoryCard(
                  item: ctrl.history[i],
                  timeLabel: _timeAgo(ctrl.history[i].createdAt),
                  onDelete: () => ctrl.deleteHistory(ctrl.history[i].id),
                ),
              ),
      ),
    ]);
  }
}

class _HistoryCard extends StatelessWidget {
  final HistoryItem item;
  final String timeLabel;
  final VoidCallback onDelete;
  const _HistoryCard({required this.item, required this.timeLabel, required this.onDelete});

  @override
  Widget build(BuildContext context) => Dismissible(
    key: Key(item.id),
    direction: DismissDirection.endToStart,
    onDismissed: (_) => onDelete(),
    background: Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: 20),
      decoration: BoxDecoration(
        color: AppTheme.redLight,
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Icon(Icons.delete_outline, color: AppTheme.red),
    ),
    child: GestureDetector(
      onTap: () => Navigator.push(context, MaterialPageRoute(
        builder: (_) => ResultScreen(
          result: _itemToResult(item),
          imagePath: item.imagePath,
          foodName: item.foodName,
        ),
      )),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppTheme.border),
        ),
        child: Row(children: [
          // Thumbnail
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: SizedBox(
              width: 52, height: 52,
              child: File(item.imagePath).existsSync()
                  ? Image.file(File(item.imagePath), fit: BoxFit.cover)
                  : Container(color: const Color(0xFFE2E8F0),
                      child: const Icon(Icons.image_outlined, size: 24)),
            ),
          ),
          const SizedBox(width: 14),

          // Info
          Expanded(child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(item.foodName, style: const TextStyle(
                color: AppTheme.textPrimary, fontSize: 15, fontWeight: FontWeight.w700,
              )),
              const SizedBox(height: 3),
              Text(timeLabel, style: const TextStyle(
                color: AppTheme.textSecondary, fontSize: 12,
              )),
              const SizedBox(height: 6),
              CategoryBadge(item.kategori),
            ],
          )),

          // Score
          ScoreText(item.skor, item.kategori, fontSize: 18),
        ]),
      ),
    ),
  );

  // Convert HistoryItem → AnalysisResult for ResultScreen
  dynamic _itemToResult(HistoryItem item) {
    // Import result_model inline to avoid circular dep
    return _FakeResult(item);
  }
}

// Wrapper agar HistoryItem bisa dipakai di ResultScreen
class _FakeResult {
  final HistoryItem _i;
  _FakeResult(this._i);
  double get skor => _i.skor;
  String get kategori => _i.kategori;
  double get skorWarna => _i.skorWarna;
  double get skorKecerahan => _i.skorKecerahan;
  double get skorTekstur => _i.skorTekstur;
  double get skorKerusakan => _i.skorKerusakan;
  String get pesan => _buildPesan();
  String _buildPesan() {
    if (_i.kategori == 'Fresh') return 'Makanan dalam kondisi sangat segar. Aman dikonsumsi.';
    if (_i.kategori == 'Medium') return 'Makanan dalam kondisi cukup baik. Segera dikonsumsi.';
    return 'Makanan menunjukkan tanda kerusakan. Tidak disarankan dikonsumsi.';
  }
}
