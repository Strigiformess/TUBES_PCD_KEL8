// view/settings_screen.dart
// Settings screen dengan sync management dan offline data controls

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../controller/app_controller.dart';
import '../service/hive_service.dart';
import '../widgets/sync_status_widget.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AppController>();

    return Scaffold(
      backgroundColor: AppTheme.bg,
      appBar: AppBar(
        title: const Text('Settings'),
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Sync Status ──
          const Text(
            'Sync Status',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const SyncStatusWidget(showDetails: true),

          const SizedBox(height: 24),

          // ── Storage Info ──
          const Text(
            'Storage',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStorageInfo(ctrl),

          const SizedBox(height: 24),

          // ── Statistics ──
          const Text(
            'Statistics',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatistics(ctrl),

          const SizedBox(height: 24),

          // ── Actions ──
          const Text(
            'Actions',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildActions(context, ctrl),
        ],
      ),
    );
  }

  Widget _buildStorageInfo(AppController ctrl) {
    final totalScans = ctrl.totalScans;
    final pendingSync = ctrl.pendingSyncCount;
    final synced = totalScans - pendingSync;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.storage,
            label: 'Total Records',
            value: '$totalScans',
            color: AppTheme.green,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.cloud_done,
            label: 'Synced',
            value: '$synced',
            color: AppTheme.green,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.pending_actions,
            label: 'Pending Sync',
            value: '$pendingSync',
            color: pendingSync > 0 ? Colors.orange : AppTheme.green,
          ),
        ],
      ),
    );
  }

  Widget _buildStatistics(AppController ctrl) {
    final stats = ctrl.getStatsByKategori();
    final avgFreshness = ctrl.avgFreshness;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _buildInfoRow(
            icon: Icons.analytics,
            label: 'Average Freshness',
            value: '${avgFreshness.toStringAsFixed(1)}%',
            color: _getFreshnessColor(avgFreshness),
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.check_circle,
            label: 'Fresh Items',
            value: '${stats['Fresh'] ?? 0}',
            color: AppTheme.green,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.warning,
            label: 'Medium Items',
            value: '${stats['Medium'] ?? 0}',
            color: Colors.orange,
          ),
          const Divider(height: 24),
          _buildInfoRow(
            icon: Icons.dangerous,
            label: 'Rotten Items',
            value: '${stats['Rotten'] ?? 0}',
            color: AppTheme.red,
          ),
        ],
      ),
    );
  }

  Widget _buildActions(BuildContext context, AppController ctrl) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        children: [
          _buildActionTile(
            context: context,
            icon: Icons.sync,
            title: 'Force Sync',
            subtitle: 'Manually sync all pending data',
            onTap: () async {
              _showLoadingDialog(context, 'Syncing...');
              final result = await ctrl.syncNow();
              if (context.mounted) {
                Navigator.pop(context);
                _showResultDialog(context, result);
              }
            },
          ),
          const Divider(height: 1),
          _buildActionTile(
            context: context,
            icon: Icons.refresh,
            title: 'Retry Failed Syncs',
            subtitle: 'Retry items that failed to sync',
            onTap: () async {
              _showLoadingDialog(context, 'Retrying...');
              final result = await ctrl.retryFailedSyncs();
              if (context.mounted) {
                Navigator.pop(context);
                _showResultDialog(context, result);
              }
            },
          ),
          const Divider(height: 1),
          _buildActionTile(
            context: context,
            icon: Icons.storage,
            title: 'Optimize Storage',
            subtitle: 'Compact database to free up space',
            onTap: () async {
              _showLoadingDialog(context, 'Optimizing...');
              await HiveService.compact();
              if (context.mounted) {
                Navigator.pop(context);
                _showSuccessSnackBar(context, 'Storage optimized successfully');
              }
            },
          ),
          const Divider(height: 1),
          _buildActionTile(
            context: context,
            icon: Icons.delete_forever,
            title: 'Clear All Data',
            subtitle: 'Delete all local data (cannot be undone)',
            textColor: AppTheme.red,
            onTap: () => _showClearDataDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: color, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppTheme.textSecondary,
            ),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }

  Widget _buildActionTile({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppTheme.textSecondary),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: textColor,
        ),
      ),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Color _getFreshnessColor(double score) {
    if (score >= 70) return AppTheme.green;
    if (score >= 40) return Colors.orange;
    return AppTheme.red;
  }

  void _showLoadingDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 16),
            Text(message),
          ],
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context, dynamic result) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Icon(
              result.success ? Icons.check_circle : Icons.error,
              color: result.success ? AppTheme.green : AppTheme.red,
            ),
            const SizedBox(width: 8),
            Text(result.success ? 'Success' : 'Failed'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(result.message),
            if (result.synced > 0 || result.failed > 0) ...[
              const SizedBox(height: 12),
              Text('Synced: ${result.synced}'),
              Text('Failed: ${result.failed}'),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showSuccessSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: AppTheme.green,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showClearDataDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.warning, color: AppTheme.red),
            SizedBox(width: 8),
            Text('Clear All Data'),
          ],
        ),
        content: const Text(
          'This will permanently delete all local data including scan history. '
          'This action cannot be undone.\n\n'
          'Are you sure you want to continue?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              _showLoadingDialog(context, 'Clearing data...');

              await HiveService.deleteAllData();

              if (context.mounted) {
                Navigator.pop(context);
                final ctrl = context.read<AppController>();
                ctrl.resetScan();
                _showSuccessSnackBar(context, 'All data cleared successfully');
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.red,
              foregroundColor: Colors.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
