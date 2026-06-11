// service/hive_service.dart
// Hive Service dengan implementasi offline-first database

import 'package:hive/hive.dart';
import '../model/history_model.dart';
import '../model/sync_queue_model.dart';

class HiveService {
  // Box names
  static const String historyBox = 'history';
  static const String syncQueueBox = 'sync_queue';
  static const String settingsBox = 'settings';

  // Boxes
  static Box<HistoryItem>? _historyBox;
  static Box<SyncQueueItem>? _syncQueueBox;
  static Box? _settingsBox;

  /// Initialize semua boxes
  static Future<void> init() async {
    _historyBox = await Hive.openBox<HistoryItem>(historyBox);
    _syncQueueBox = await Hive.openBox<SyncQueueItem>(syncQueueBox);
    _settingsBox = await Hive.openBox(settingsBox);
  }

  /// Getters untuk boxes
  static Box<HistoryItem> get history => _historyBox!;
  static Box<SyncQueueItem> get syncQueue => _syncQueueBox!;
  static Box get settings => _settingsBox!;

  /// ══════════════════════════════════════════════════════════════
  /// HISTORY OPERATIONS
  /// ══════════════════════════════════════════════════════════════

  /// Simpan history item baru
  static Future<void> saveHistory(HistoryItem item) async {
    await history.put(item.id, item);
  }

  /// Get semua history, sorted by date
  static List<HistoryItem> getAllHistory() {
    final items = history.values.toList();
    items.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return items;
  }

  /// Get history by ID
  static HistoryItem? getHistoryById(String id) {
    return history.get(id);
  }

  /// Update history item
  static Future<void> updateHistory(HistoryItem item) async {
    await history.put(item.id, item);
  }

  /// Delete history item
  static Future<void> deleteHistory(String id) async {
    await history.delete(id);
  }

  /// Delete multiple history items
  static Future<void> deleteMultipleHistory(List<String> ids) async {
    await history.deleteAll(ids);
  }

  /// Clear semua history
  static Future<void> clearAllHistory() async {
    await history.clear();
  }

  /// Get history by date range
  static List<HistoryItem> getHistoryByDateRange(DateTime start, DateTime end) {
    return history.values.where((item) {
      return item.createdAt.isAfter(start) && item.createdAt.isBefore(end);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Get history by kategori
  static List<HistoryItem> getHistoryByKategori(String kategori) {
    return history.values.where((item) => item.kategori == kategori).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// Search history by food name
  static List<HistoryItem> searchHistory(String query) {
    final lowerQuery = query.toLowerCase();
    return history.values.where((item) {
      return item.foodName.toLowerCase().contains(lowerQuery);
    }).toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
  }

  /// ══════════════════════════════════════════════════════════════
  /// SYNC QUEUE OPERATIONS
  /// ══════════════════════════════════════════════════════════════

  /// Tambah item ke sync queue
  static Future<void> addToSyncQueue(SyncQueueItem item) async {
    await syncQueue.put(item.id, item);
  }

  /// Get semua items yang perlu di-sync
  static List<SyncQueueItem> getPendingSyncItems() {
    return syncQueue.values.where((item) => !item.isSynced).toList()
      ..sort((a, b) => a.createdAt.compareTo(b.createdAt));
  }

  /// Mark item sebagai synced
  static Future<void> markAsSynced(String id) async {
    final item = syncQueue.get(id);
    if (item != null) {
      item.isSynced = true;
      item.syncedAt = DateTime.now();
      await syncQueue.put(id, item);
    }
  }

  /// Remove synced items older than X days
  static Future<void> cleanupSyncQueue({int daysOld = 7}) async {
    final cutoffDate = DateTime.now().subtract(Duration(days: daysOld));
    final toDelete = syncQueue.values
        .where((item) =>
            item.isSynced &&
            item.syncedAt != null &&
            item.syncedAt!.isBefore(cutoffDate))
        .map((item) => item.id)
        .toList();

    await syncQueue.deleteAll(toDelete);
  }

  /// Get sync queue count
  static int getPendingSyncCount() {
    return syncQueue.values.where((item) => !item.isSynced).length;
  }

  /// Clear sync queue
  static Future<void> clearSyncQueue() async {
    await syncQueue.clear();
  }

  /// Retry failed sync items
  static Future<void> retryFailedSyncs() async {
    final failedItems = syncQueue.values
        .where((item) => !item.isSynced && item.retryCount > 0)
        .toList();

    for (final item in failedItems) {
      item.retryCount = 0;
      await syncQueue.put(item.id, item);
    }
  }

  /// ══════════════════════════════════════════════════════════════
  /// SETTINGS OPERATIONS
  /// ══════════════════════════════════════════════════════════════

  /// Save setting
  static Future<void> saveSetting(String key, dynamic value) async {
    await settings.put(key, value);
  }

  /// Get setting
  static T? getSetting<T>(String key, {T? defaultValue}) {
    return settings.get(key, defaultValue: defaultValue) as T?;
  }

  /// Delete setting
  static Future<void> deleteSetting(String key) async {
    await settings.delete(key);
  }

  /// Clear all settings
  static Future<void> clearSettings() async {
    await settings.clear();
  }

  /// ══════════════════════════════════════════════════════════════
  /// STATISTICS
  /// ══════════════════════════════════════════════════════════════

  /// Get average freshness score
  static double getAverageFreshness() {
    final items = history.values.toList();
    if (items.isEmpty) return 0;
    final sum = items.fold(0.0, (sum, item) => sum + item.skor);
    return sum / items.length;
  }

  /// Get total scans
  static int getTotalScans() {
    return history.length;
  }

  /// Get statistics by kategori
  static Map<String, int> getStatsByKategori() {
    final stats = <String, int>{
      'Fresh': 0,
      'Medium': 0,
      'Rotten': 0,
    };

    for (final item in history.values) {
      stats[item.kategori] = (stats[item.kategori] ?? 0) + 1;
    }

    return stats;
  }

  /// Get statistics by date (last 7 days)
  static Map<String, int> getStatsByDate({int days = 7}) {
    final stats = <String, int>{};
    final now = DateTime.now();

    for (int i = 0; i < days; i++) {
      final date = now.subtract(Duration(days: i));
      final dateKey =
          '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')}';
      stats[dateKey] = 0;
    }

    for (final item in history.values) {
      final dateKey =
          '${item.createdAt.year}-${item.createdAt.month.toString().padLeft(2, '0')}-${item.createdAt.day.toString().padLeft(2, '0')}';
      if (stats.containsKey(dateKey)) {
        stats[dateKey] = stats[dateKey]! + 1;
      }
    }

    return stats;
  }

  /// ══════════════════════════════════════════════════════════════
  /// MAINTENANCE
  /// ══════════════════════════════════════════════════════════════

  /// Compact all boxes (optimize storage)
  static Future<void> compact() async {
    await history.compact();
    await syncQueue.compact();
    await settings.compact();
  }

  /// Close all boxes
  static Future<void> close() async {
    await history.close();
    await syncQueue.close();
    await settings.close();
  }

  /// Delete all data (factory reset)
  static Future<void> deleteAllData() async {
    await clearAllHistory();
    await clearSyncQueue();
    await clearSettings();
  }
}
