// widgets/sync_status_widget.dart
// Widget untuk menampilkan status sinkronisasi

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_theme.dart';
import '../controller/app_controller.dart';

class SyncStatusWidget extends StatelessWidget {
  final bool showDetails;

  const SyncStatusWidget({
    super.key,
    this.showDetails = false,
  });

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<AppController>();

    if (!showDetails) {
      return _buildCompactStatus(context, ctrl);
    }

    return _buildDetailedStatus(context, ctrl);
  }

  /// Compact status - untuk ditampilkan di app bar atau floating button
  Widget _buildCompactStatus(BuildContext context, AppController ctrl) {
    final iconData = ctrl.isOnline
        ? (ctrl.isSyncing ? Icons.sync : Icons.cloud_done)
        : Icons.cloud_off;

    final color = ctrl.isOnline
        ? (ctrl.isSyncing ? Colors.orange : AppTheme.green)
        : Colors.grey;

    return GestureDetector(
      onTap: () => _showSyncDialog(context, ctrl),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(iconData, size: 16, color: color),
            if (ctrl.pendingSyncCount > 0) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  '${ctrl.pendingSyncCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Detailed status - untuk ditampilkan di halaman settings
  Widget _buildDetailedStatus(BuildContext context, AppController ctrl) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                ctrl.isOnline ? Icons.cloud_done : Icons.cloud_off,
                color: ctrl.isOnline ? AppTheme.green : Colors.grey,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      ctrl.isOnline ? 'Online' : 'Offline',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    if (ctrl.lastSyncTime != null)
                      Text(
                        'Last synced: ${_formatDateTime(ctrl.lastSyncTime!)}',
                        style: const TextStyle(
                          fontSize: 12,
                          color: AppTheme.textSecondary,
                        ),
                      ),
                  ],
                ),
              ),
              if (ctrl.isSyncing)
                const SizedBox(
                  width: 20,
                  height: 20,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
            ],
          ),
          if (ctrl.pendingSyncCount > 0) ...[
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  const Icon(Icons.info_outline,
                      color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      '${ctrl.pendingSyncCount} items waiting to sync',
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.orange,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
          if (ctrl.isOnline &&
              ctrl.pendingSyncCount > 0 &&
              !ctrl.isSyncing) ...[
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () async {
                  final result = await ctrl.syncNow();
                  if (context.mounted) {
                    _showSyncResult(context, result);
                  }
                },
                icon: const Icon(Icons.sync, size: 18),
                label: const Text('Sync Now'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Show sync dialog
  void _showSyncDialog(BuildContext context, AppController ctrl) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Sync Status'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildStatusRow(
              'Connection',
              ctrl.isOnline ? 'Online' : 'Offline',
              ctrl.isOnline ? AppTheme.green : Colors.grey,
            ),
            const SizedBox(height: 8),
            _buildStatusRow(
              'Pending',
              '${ctrl.pendingSyncCount} items',
              ctrl.pendingSyncCount > 0 ? Colors.orange : AppTheme.green,
            ),
            if (ctrl.lastSyncTime != null) ...[
              const SizedBox(height: 8),
              _buildStatusRow(
                'Last Sync',
                _formatDateTime(ctrl.lastSyncTime!),
                AppTheme.textSecondary,
              ),
            ],
            if (ctrl.isSyncing) ...[
              const SizedBox(height: 16),
              const Center(
                child: CircularProgressIndicator(),
              ),
              const SizedBox(height: 8),
              const Center(
                child: Text(
                  'Syncing...',
                  style: TextStyle(fontSize: 12),
                ),
              ),
            ],
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
          if (ctrl.isOnline && ctrl.pendingSyncCount > 0 && !ctrl.isSyncing)
            ElevatedButton.icon(
              onPressed: () async {
                Navigator.pop(context);
                final result = await ctrl.syncNow();
                if (context.mounted) {
                  _showSyncResult(context, result);
                }
              },
              icon: const Icon(Icons.sync, size: 18),
              label: const Text('Sync Now'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.green,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildStatusRow(String label, String value, Color valueColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 14,
            color: AppTheme.textSecondary,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
            color: valueColor,
          ),
        ),
      ],
    );
  }

  void _showSyncResult(BuildContext context, dynamic result) {
    final message = result.message;
    final isSuccess = result.success;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.error,
              color: Colors.white,
            ),
            const SizedBox(width: 8),
            Expanded(child: Text(message)),
          ],
        ),
        backgroundColor: isSuccess ? AppTheme.green : AppTheme.red,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  String _formatDateTime(DateTime dt) {
    final now = DateTime.now();
    final diff = now.difference(dt);

    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';

    return '${dt.day}/${dt.month}/${dt.year}';
  }
}
