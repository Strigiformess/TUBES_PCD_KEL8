// model/sync_queue_model.dart
// Model untuk Sync Queue - menyimpan data yang perlu di-sync ke backend

import 'package:hive/hive.dart';

part 'sync_queue_model.g.dart';

/// Tipe operasi yang perlu di-sync
enum SyncOperation {
  create,
  update,
  delete,
}

@HiveType(typeId: 1)
class SyncQueueItem extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String historyId; // ID dari HistoryItem yang terkait

  @HiveField(2)
  String operation; // 'create', 'update', 'delete'

  @HiveField(3)
  Map<String, dynamic> data; // Data yang perlu di-sync

  @HiveField(4)
  bool isSynced;

  @HiveField(5)
  DateTime createdAt;

  @HiveField(6)
  DateTime? syncedAt;

  @HiveField(7)
  int retryCount; // Jumlah percobaan sync

  @HiveField(8)
  String? errorMessage; // Pesan error jika sync gagal

  SyncQueueItem({
    required this.id,
    required this.historyId,
    required this.operation,
    required this.data,
    this.isSynced = false,
    required this.createdAt,
    this.syncedAt,
    this.retryCount = 0,
    this.errorMessage,
  });

  /// Convert ke JSON untuk kirim ke backend
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'historyId': historyId,
      'operation': operation,
      'data': data,
      'isSynced': isSynced,
      'createdAt': createdAt.toIso8601String(),
      'syncedAt': syncedAt?.toIso8601String(),
      'retryCount': retryCount,
      'errorMessage': errorMessage,
    };
  }

  /// Create dari JSON
  factory SyncQueueItem.fromJson(Map<String, dynamic> json) {
    return SyncQueueItem(
      id: json['id'],
      historyId: json['historyId'],
      operation: json['operation'],
      data: Map<String, dynamic>.from(json['data']),
      isSynced: json['isSynced'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      syncedAt:
          json['syncedAt'] != null ? DateTime.parse(json['syncedAt']) : null,
      retryCount: json['retryCount'] ?? 0,
      errorMessage: json['errorMessage'],
    );
  }

  /// Helper untuk membuat SyncQueueItem dari HistoryItem
  static SyncQueueItem fromHistoryItem({
    required String historyId,
    required SyncOperation operation,
    required Map<String, dynamic> data,
  }) {
    return SyncQueueItem(
      id: '${DateTime.now().millisecondsSinceEpoch}_$historyId',
      historyId: historyId,
      operation: operation.name,
      data: data,
      createdAt: DateTime.now(),
    );
  }

  /// Check apakah perlu retry
  bool shouldRetry({int maxRetries = 3}) {
    return !isSynced && retryCount < maxRetries;
  }

  /// Increment retry count
  void incrementRetry([String? error]) {
    retryCount++;
    errorMessage = error;
  }
}
