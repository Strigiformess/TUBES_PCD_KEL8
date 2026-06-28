import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../controller/app_controller.dart';
import '../model/history_model.dart';
import '../service/auth_service.dart';
import '../widgets/common_widgets.dart';

// ─────────────────────────────────────────────
// TIPS — berganti tiap hari berdasarkan dayOfYear
// ─────────────────────────────────────────────
const _tips = [
  ('Simpan buah tropis', 'Pisang, mangga, dan pepaya sebaiknya disimpan di suhu ruang. Kulkas justru mempercepat kerusakan kulit.', Icons.wb_sunny_outlined),
  ('Pisahkan buah penghasil etilen', 'Apel dan pisang mengeluarkan gas etilen yang mempercepat pematangan buah di sekitarnya. Simpan terpisah.', Icons.air_outlined),
  ('Sayuran hijau tetap segar', 'Bungkus sayuran hijau dengan tisu lembab lalu masukkan kantong plastik longgar sebelum masuk kulkas.', Icons.eco_outlined),
  ('Jangan cuci sebelum simpan', 'Kelembaban dari cucian mempercepat jamur. Cuci buah & sayur hanya sesaat sebelum dikonsumsi.', Icons.water_drop_outlined),
  ('Cek bagian bawah tumpukan', 'Buah/sayur di bawah tumpukan sering rusak duluan karena tekanan. Scan secara berkala.', Icons.layers_outlined),
  ('Tomat di luar kulkas', 'Kulkas merusak tekstur dan rasa tomat. Simpan di suhu ruang dengan posisi tangkai di atas.', Icons.kitchen_outlined),
  ('Jeruk tahan lebih lama', 'Jeruk bisa tahan 2–4 minggu di kulkas. Pastikan tidak ada yang busuk agar tidak menular ke yang lain.', Icons.circle_outlined),
];

// ─────────────────────────────────────────────
// HOME TAB
// ─────────────────────────────────────────────
class HomeTab extends StatelessWidget {
  final VoidCallback? onGoToScanner;
  const HomeTab({super.key, this.onGoToScanner});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AppController>();
    final auth = context.watch<AuthService>();
    final tip = _tips[DateTime.now().dayOfYear % _tips.length];
    final userName = auth.currentUser?.name.split(' ').first ?? 'Chef';

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 24),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

        // ── Greeting ──
        const SizedBox(height: 8),
        Text('Halo, $userName.', style: const TextStyle(
          fontSize: 26, fontWeight: FontWeight.w800, color: AppTheme.textPrimary,
        )),
        const Text('Ready for a freshness scan?', style: TextStyle(
          color: AppTheme.textSecondary, fontSize: 14,
        )),

        const SizedBox(height: 20),

        // ── Stats Row ──
        _StatsRow(ctrl: ctrl),

        const SizedBox(height: 16),

        // ── Quick Actions ──
        Row(children: [
          Expanded(child: _QuickAction(
            icon: Icons.document_scanner_rounded,
            label: 'Scan Sekarang',
            color: AppTheme.green,
            onTap: onGoToScanner ?? () {},
          )),
        ]),

        const SizedBox(height: 20),

        // ── 7-day chart (hanya jika ada data) ──
        if (ctrl.history.isNotEmpty) ...[
          const SectionHeader('Tren 7 Hari Terakhir'),
          const SizedBox(height: 12),
          _WeeklyChart(history: ctrl.history),
          const SizedBox(height: 20),
        ],

        // ── Distribusi kategori (jika ada ≥ 3 scan) ──
        if (ctrl.history.length >= 3) ...[
          const SectionHeader('Distribusi Hasil'),
          const SizedBox(height: 12),
          _CategoryDistribution(history: ctrl.history),
          const SizedBox(height: 20),
        ],

        // ── Tip of the day ──
        const SectionHeader('Tips Hari Ini'),
        const SizedBox(height: 12),
        _TipCard(icon: tip.$3, title: tip.$1, body: tip.$2),

        const SizedBox(height: 20),

        // ── Recent Activity ──
        if (ctrl.history.isNotEmpty) ...[
          SectionHeader('Recent Activity', trailing: GestureDetector(
            onTap: () {},
            child: const Text('Lihat Semua', style: TextStyle(
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

// ─────────────────────────────────────────────
// STATS ROW  —  3 kartu kecil
// ─────────────────────────────────────────────
class _StatsRow extends StatelessWidget {
  final AppController ctrl;
  const _StatsRow({required this.ctrl});

  // Persentase fresh
  int get _freshPct {
    if (ctrl.history.isEmpty) return 0;
    final fresh = ctrl.history.where((h) => h.kategori == 'Fresh').length;
    return ((fresh / ctrl.history.length) * 100).round();
  }

  @override
  Widget build(BuildContext context) => Row(children: [
    _MiniStat(
      value: ctrl.totalScans.toString(),
      label: 'Total Scan',
      icon: Icons.bar_chart_rounded,
      color: const Color(0xFF6366F1),
      bgColor: const Color(0xFFEEF2FF),
    ),
    const SizedBox(width: 10),
    _MiniStat(
      value: ctrl.avgFreshness.toStringAsFixed(0),
      label: 'Rata-rata',
      icon: Icons.trending_up_rounded,
      color: AppTheme.green,
      bgColor: AppTheme.greenLight,
    ),
    const SizedBox(width: 10),
    _MiniStat(
      value: '$_freshPct%',
      label: 'Fresh rate',
      icon: Icons.eco_rounded,
      color: const Color(0xFF0EA5E9),
      bgColor: const Color(0xFFE0F2FE),
    ),
  ]);
}

class _MiniStat extends StatelessWidget {
  final String value, label;
  final IconData icon;
  final Color color, bgColor;
  const _MiniStat({required this.value, required this.label,
    required this.icon, required this.color, required this.bgColor});

  @override
  Widget build(BuildContext context) => Expanded(
    child: Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Container(
          width: 30, height: 30,
          decoration: BoxDecoration(color: bgColor, borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: color, size: 16),
        ),
        const SizedBox(height: 10),
        Text(value, style: TextStyle(
          fontSize: 20, fontWeight: FontWeight.w800, color: color,
        )),
        Text(label, style: const TextStyle(
          fontSize: 11, color: AppTheme.textSecondary,
        )),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────
// 7-DAY BAR CHART  —  pure CustomPaint, tanpa library
// ─────────────────────────────────────────────
class _WeeklyChart extends StatelessWidget {
  final List<HistoryItem> history;
  const _WeeklyChart({required this.history});

  // Rata-rata skor per hari untuk 7 hari terakhir
  List<({String label, double? avg})> get _days {
    final now = DateTime.now();
    final dayNames = ['Sen','Sel','Rab','Kam','Jum','Sab','Min'];
    return List.generate(7, (i) {
      final date = now.subtract(Duration(days: 6 - i));
      final items = history.where((h) =>
        h.createdAt.year == date.year &&
        h.createdAt.month == date.month &&
        h.createdAt.day == date.day
      ).toList();
      final avg = items.isEmpty
          ? null
          : items.map((h) => h.skor).reduce((a, b) => a + b) / items.length;
      return (label: dayNames[date.weekday - 1], avg: avg);
    });
  }

  @override
  Widget build(BuildContext context) {
    final days = _days;
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: [
        // Bars
        SizedBox(
          height: 100,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: days.map((d) => Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 3),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    // Nilai di atas bar
                    if (d.avg != null)
                      Text(d.avg!.toStringAsFixed(0),
                        style: const TextStyle(fontSize: 9, color: AppTheme.textSecondary)),
                    const SizedBox(height: 2),
                    // Bar
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 600),
                      curve: Curves.easeOut,
                      height: d.avg == null ? 4 : max(8, d.avg! * 0.9),
                      decoration: BoxDecoration(
                        color: d.avg == null
                            ? const Color(0xFFE2E8F0)
                            : d.avg! >= 70
                                ? AppTheme.green
                                : d.avg! >= 40
                                    ? AppTheme.yellow
                                    : AppTheme.red,
                        borderRadius: BorderRadius.circular(6),
                      ),
                    ),
                  ],
                ),
              ),
            )).toList(),
          ),
        ),
        const SizedBox(height: 8),
        // Labels
        Row(
          children: days.map((d) => Expanded(
            child: Text(d.label,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          )).toList(),
        ),
      ]),
    );
  }
}

// ─────────────────────────────────────────────
// DISTRIBUSI KATEGORI  —  horizontal bar
// ─────────────────────────────────────────────
class _CategoryDistribution extends StatelessWidget {
  final List<HistoryItem> history;
  const _CategoryDistribution({required this.history});

  @override
  Widget build(BuildContext context) {
    final total = history.length;
    final fresh  = history.where((h) => h.kategori == 'Fresh').length;
    final medium = history.where((h) => h.kategori == 'Medium').length;
    final rotten = history.where((h) => h.kategori == 'Rotten').length;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(children: [
        // Segmented bar
        ClipRRect(
          borderRadius: BorderRadius.circular(6),
          child: SizedBox(
            height: 10,
            child: Row(children: [
              if (fresh > 0) Flexible(flex: fresh,
                child: Container(color: AppTheme.green)),
              if (medium > 0) Flexible(flex: medium,
                child: Container(color: AppTheme.yellow)),
              if (rotten > 0) Flexible(flex: rotten,
                child: Container(color: AppTheme.red)),
            ]),
          ),
        ),
        const SizedBox(height: 14),
        Row(children: [
          _DistItem('Fresh',  fresh,  total, AppTheme.green),
          _DistItem('Medium', medium, total, AppTheme.yellow),
          _DistItem('Rotten', rotten, total, AppTheme.red),
        ]),
      ]),
    );
  }
}

class _DistItem extends StatelessWidget {
  final String label;
  final int count, total;
  final Color color;
  const _DistItem(this.label, this.count, this.total, this.color);

  @override
  Widget build(BuildContext context) => Expanded(
    child: Column(children: [
      Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Container(width: 8, height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 5),
        Text(label, style: const TextStyle(
          fontSize: 12, color: AppTheme.textSecondary)),
      ]),
      const SizedBox(height: 4),
      Text('${total == 0 ? 0 : ((count / total) * 100).round()}%',
        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color)),
      Text('$count scan', style: const TextStyle(
        fontSize: 11, color: AppTheme.textSecondary)),
    ]),
  );
}

// ─────────────────────────────────────────────
// TIP CARD
// ─────────────────────────────────────────────
class _TipCard extends StatelessWidget {
  final IconData icon;
  final String title, body;
  const _TipCard({required this.icon, required this.title, required this.body});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(16),
    decoration: BoxDecoration(
      gradient: const LinearGradient(
        colors: [Color(0xFF16A34A), Color(0xFF22C55E)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
    ),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(icon, color: Colors.white, size: 20),
      ),
      const SizedBox(width: 14),
      Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Text(title, style: const TextStyle(
          color: Colors.white, fontSize: 14, fontWeight: FontWeight.w700,
        )),
        const SizedBox(height: 4),
        Text(body, style: TextStyle(
          color: Colors.white.withValues(alpha: 0.85), fontSize: 12, height: 1.5,
        )),
      ])),
    ]),
  );
}

// ─────────────────────────────────────────────
// QUICK ACTION
// ─────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;
  const _QuickAction({required this.icon, required this.label,
    required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) => GestureDetector(
    onTap: onTap,
    child: Container(
      height: 52,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
        Icon(icon, color: Colors.white, size: 20),
        const SizedBox(width: 10),
        Text(label, style: const TextStyle(
          color: Colors.white, fontSize: 15, fontWeight: FontWeight.w700,
        )),
      ]),
    ),
  );
}

// ─────────────────────────────────────────────
// RECENT ITEM
// ─────────────────────────────────────────────
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
        Text(item.foodName, style: const TextStyle(
          color: AppTheme.textPrimary, fontSize: 14, fontWeight: FontWeight.w600,
        )),
        Text(_timeAgo(item.createdAt), style: const TextStyle(
          color: AppTheme.textSecondary, fontSize: 12,
        )),
      ])),
      ScoreText(item.skor, item.kategori, fontSize: 16),
    ]),
  );

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Baru saja';
    if (diff.inMinutes < 60) return '${diff.inMinutes} menit lalu';
    if (diff.inHours < 24) return '${diff.inHours} jam lalu';
    return '${diff.inDays} hari lalu';
  }
}

// ─────────────────────────────────────────────
// EXTENSION
// ─────────────────────────────────────────────
extension on DateTime {
  int get dayOfYear {
    return difference(DateTime(year, 1, 1)).inDays;
  }
}