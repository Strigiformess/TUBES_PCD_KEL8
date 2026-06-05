import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_theme.dart';
import '../../../data/models/scan_result.dart';
import '../../../data/repositories/scan_repository.dart';

class HistoryScreen extends StatelessWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final history = ScanRepository().getAll();

    return Scaffold(
      appBar: AppBar(title: const Text('Riwayat Scan')),
      body: history.isEmpty
        ? const Center(
            child: Text('Belum ada scan. Yuk mulai scan pertamamu!'),
          )
        : ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: history.length,
            itemBuilder: (ctx, i) {
              final scan = history[i];
              return _ScanCard(scan: scan);
            },
          ),
    );
  }
}

class _ScanCard extends StatelessWidget {
  final ScanResult scan;
  const _ScanCard({required this.scan});

  @override
  Widget build(BuildContext context) {
    final color = scan.status == 'Fresh'
      ? AppTheme.statusFresh
      : scan.status == 'Medium'
        ? AppTheme.statusMedium : AppTheme.statusPoor;

    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: color.withOpacity(0.15),
          child: Text(
            '${scan.scoreAsInt}',
            style: TextStyle(color: color, fontWeight: FontWeight.bold),
          ),
        ),
        title: Text(scan.foodType, style: const TextStyle(fontWeight: FontWeight.w600)),
        subtitle: Text('${scan.scanDate.day}/${scan.scanDate.month}/${scan.scanDate.year}'),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(scan.status, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12)),
        ),
        onTap: () => context.pushNamed('detail', extra: scan),
      ),
    );
  }
}