// service/sync_service.dart
// Service untuk sinkronisasi data offline-online

import 'dart:async';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/foundation.dart';
import '../model/sync_queue_model.dart';
import 'hive_service.dart';

class SyncService {
  static final SyncService _instance = SyncService._internal();
  factory SyncService() => _instance;
  SyncService._internal();

  final Connectivity _connectivity = Connectivity();
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  bool _isSyncing = false;
  bool _isOnline = false;
  DateTime? _lastSyncTime;

  final StreamController<SyncStatus> _syncStatusController =
      StreamController<SyncStatus>.broadcast();

  /// Stream untuk mendengarkan status sync
  Stream<SyncStatus> get syncStatusStream => _syncStatusController.stream;

  /// Getter status
  bool get isSyncing => _isSyncing;
  bool get isOnline => _isOnline;
  DateTime? get lastSyncTime => _lastSyncTime;
  int get pendingSyncCount => HiveService.getPendingSyncCount();

  /// Initialize sync service
  Future<void> init() async {
    // Check koneksi awal
    await _checkConnectivity();

    // Listen to connectivity changes
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen(
      (List<ConnectivityResult> results) async {
        await _checkConnectivity();

        // Auto sync ketika online
        if (_isOnline && pendingSyncCount > 0) {
          await syncAll();
        }
      },
    );
  }

  /// Check koneksi internet
  Future<void> _checkConnectivity() async {
    final results = await _connectivity.checkConnectivity();
    final wasOffline = !_isOnline;

    _isOnline = results.any((result) =>
        result == ConnectivityResult.mobile ||
        result == ConnectivityResult.wifi ||
        result == ConnectivityResult.ethernet);

    // Emit status change
    if (wasOffline && _isOnline) {
      _syncStatusController.add(SyncStatus(
        state: SyncState.connected,
        message: 'Connected to internet',
      ));
    } else if (!wasOffline && !_isOnline) {
      _syncStatusController.add(SyncStatus(
        state: SyncState.offline,
        message: 'No internet connection',
      ));
    }
  }

  /// Sync semua pending items
  Future<SyncResult> syncAll() async {
    if (_isSyncing) {
      return SyncResult(
        success: false,
        message: 'Sync already in progress',
        synced: 0,
        failed: 0,
      );
    }

    if (!_isOnline) {
      return SyncResult(
        success: false,
        message: 'No internet connection',
        synced: 0,
        failed: 0,
      );
    }

    _isSyncing = true;
    _syncStatusController.add(SyncStatus(
      state: SyncState.syncing,
      message: 'Syncing data...',
    ));

    int synced = 0;
    int failed = 0;

    try {
      final pendingItems = HiveService.getPendingSyncItems();

      for (final item in pendingItems) {
        // Skip jika sudah terlalu banyak retry
        if (!item.shouldRetry(maxRetries: 3)) {
          failed++;
          continue;
        }

        try {
          // Sync berdasarkan operation type
          await _syncItem(item);

          // Mark as synced
          await HiveService.markAsSynced(item.id);
          synced++;

          // Emit progress
          _syncStatusController.add(SyncStatus(
            state: SyncState.syncing,
            message: 'Synced $synced of ${pendingItems.length}',
            progress: synced / pendingItems.length,
          ));
        } catch (e) {
          failed++;
          item.incrementRetry(e.toString());
          await HiveService.addToSyncQueue(item);

          debugPrint('Sync failed for item ${item.id}: $e');
        }
      }

      _lastSyncTime = DateTime.now();
      await HiveService.saveSetting(
          'last_sync_time', _lastSyncTime!.toIso8601String());

      // Cleanup old synced items
      await HiveService.cleanupSyncQueue(daysOld: 7);

      final success = failed == 0;
      final message = success
          ? 'All data synced successfully'
          : 'Synced $synced items, $failed failed';

      _syncStatusController.add(SyncStatus(
        state: success ? SyncState.completed : SyncState.error,
        message: message,
        progress: 1.0,
      ));

      return SyncResult(
        success: success,
        message: message,
        synced: synced,
        failed: failed,
      );
    } catch (e) {
      _syncStatusController.add(SyncStatus(
        state: SyncState.error,
        message: 'Sync error: ${e.toString()}',
      ));

      return SyncResult(
        success: false,
        message: e.toString(),
        synced: synced,
        failed: failed,
      );
    } finally {
      _isSyncing = false;
    }
  }

  /// Sync single item
  Future<void> _syncItem(SyncQueueItem item) async {
    switch (item.operation) {
      case 'create':
        await _syncCreate(item);
        break;
      case 'update':
        await _syncUpdate(item);
        break;
      case 'delete':
        await _syncDelete(item);
        break;
      default:
        throw Exception('Unknown operation: ${item.operation}');
    }
  }

  /// Sync create operation
  Future<void> _syncCreate(SyncQueueItem item) async {
    // Implementasi sesuai dengan API backend Anda
    // Contoh:
    // await ApiService.createHistory(item.data);

    // Untuk sementara, simulasi delay
    await Future.delayed(const Duration(milliseconds: 500));

    // Jika API berhasil, fungsi ini akan selesai tanpa throw error
    // Jika gagal, throw error yang akan di-catch oleh caller
  }

  /// Sync update operation
  Future<void> _syncUpdate(SyncQueueItem item) async {
    // Implementasi sesuai dengan API backend Anda
    // Contoh:
    // await ApiService.updateHistory(item.historyId, item.data);

    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Sync delete operation
  Future<void> _syncDelete(SyncQueueItem item) async {
    // Implementasi sesuai dengan API backend Anda
    // Contoh:
    // await ApiService.deleteHistory(item.historyId);

    await Future.delayed(const Duration(milliseconds: 500));
  }

  /// Manual retry untuk failed syncs
  Future<SyncResult> retryFailedSyncs() async {
    await HiveService.retryFailedSyncs();
    return await syncAll();
  }

  /// Force sync (ignore online status for testing)
  Future<SyncResult> forceSyncAll() async {
    _isOnline = true;
    return await syncAll();
  }

  /// Dispose
  void dispose() {
    _connectivitySubscription?.cancel();
    _syncStatusController.close();
  }
}

/// Sync status untuk UI
class SyncStatus {
  final SyncState state;
  final String message;
  final double? progress;

  SyncStatus({
    required this.state,
    required this.message,
    this.progress,
  });
}

/// Sync state enum
enum SyncState {
  idle,
  connected,
  offline,
  syncing,
  completed,
  error,
}

/// Sync result
class SyncResult {
  final bool success;
  final String message;
  final int synced;
  final int failed;

  SyncResult({
    required this.success,
    required this.message,
    required this.synced,
    required this.failed,
  });
}
