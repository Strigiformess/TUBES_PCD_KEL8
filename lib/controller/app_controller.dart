// controller/app_controller.dart
// Hybrid: TFLite untuk klasifikasi + PCD via backend untuk detail fitur.
// Jika backend tidak tersedia, hanya TFLite yang dipakai.
// Dengan implementasi offline-first menggunakan Hive

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:path/path.dart' as p;
import '../model/history_model.dart';
import '../model/sync_queue_model.dart';
import '../service/tflite_service.dart';
import '../service/api_service.dart';
import '../service/hive_service.dart';
import '../service/sync_service.dart';
import '../service/image_filter_service.dart';

enum ScanState { idle, loading, success, error }

class ScanResult {
  // Dari TFLite
  final double skor;
  final String kategori;
  final double probFresh;
  final double probRotten;
  final String pesan;

  // Dari backend PCD (opsional, null jika backend tidak tersedia)
  final double? skorWarna;
  final double? skorKecerahan;
  final double? skorTekstur;
  final double? skorKerusakan;
  final bool usedPcd;

  ScanResult({
    required this.skor,
    required this.kategori,
    required this.probFresh,
    required this.probRotten,
    required this.pesan,
    this.skorWarna,
    this.skorKecerahan,
    this.skorTekstur,
    this.skorKerusakan,
    this.usedPcd = false,
  });
}

class AppController extends ChangeNotifier {
  final TfliteService _tflite = TfliteService();
  final SyncService _syncService = SyncService();

  ScanState scanState = ScanState.idle;
  File? selectedImage;
  ScanResult? result;
  String errorMsg = '';

  // PCD Filter state
  PCDFilter activeFilter = PCDFilter.none;
  Uint8List? filteredImage;
  bool isFiltering = false;

  List<HistoryItem> history = [];

  // Sync status
  bool get isSyncing => _syncService.isSyncing;
  bool get isOnline => _syncService.isOnline;
  int get pendingSyncCount => _syncService.pendingSyncCount;
  DateTime? get lastSyncTime => _syncService.lastSyncTime;

  Future<void> init() async {
    // Load TFLite model
    await _tflite.loadModel();

    // Initialize Hive service
    await HiveService.init();

    // Initialize Sync service
    await _syncService.init();

    // Listen to sync status changes
    _syncService.syncStatusStream.listen((status) {
      debugPrint('Sync status: ${status.state} - ${status.message}');
      notifyListeners();
    });

    // Load history
    _loadHistory();

    // Load last sync time
    final lastSyncStr = HiveService.getSetting<String>('last_sync_time');
    if (lastSyncStr != null) {
      try {
        // Last sync time is already stored in _syncService
      } catch (e) {
        debugPrint('Error parsing last sync time: $e');
      }
    }
  }

  void setImage(File f) {
    selectedImage = f;
    result = null;
    scanState = ScanState.idle;
    errorMsg = '';
    activeFilter = PCDFilter.none;
    filteredImage = null;
    isFiltering = false;
    notifyListeners();
  }

  /// Apply a PCD filter to the selected image (runs in isolate).
  /// Pass [PCDFilter.none] to clear the filter and show the original.
  Future<void> applyFilter(PCDFilter filter) async {
    activeFilter = filter;
    if (filter == PCDFilter.none || selectedImage == null) {
      filteredImage = null;
      isFiltering = false;
      notifyListeners();
      return;
    }
    isFiltering = true;
    notifyListeners();
    try {
      final bytes = await selectedImage!.readAsBytes();
      filteredImage = await compute(
        (List<Object> args) => ImageFilterService.applyFilter(
          args[0] as Uint8List,
          args[1] as PCDFilter,
        ),
        [bytes, filter],
      );
    } catch (e) {
      debugPrint('Filter error: $e');
      filteredImage = null;
    }
    isFiltering = false;
    notifyListeners();
  }

  Future<void> analyze() async {
    if (selectedImage == null) return;

    scanState = ScanState.loading;
    notifyListeners();

    try {
      // ── TAHAP 1: Inferensi TFLite (selalu jalan, on-device) ──
      final tfliteResult = await _tflite.predict(selectedImage!);

      // ── TAHAP 2: Coba ambil detail PCD dari backend (opsional) ──
      double? skorWarna, skorKecerahan, skorTekstur, skorKerusakan;
      bool usedPcd = false;

      try {
        final pcdResult = await ApiService.analyze(selectedImage!);
        skorWarna = pcdResult.skorWarna;
        skorKecerahan = pcdResult.skorKecerahan;
        skorTekstur = pcdResult.skorTekstur;
        skorKerusakan = pcdResult.skorKerusakan;
        usedPcd = true;
      } catch (_) {
        // Backend tidak aktif → lanjut hanya dengan TFLite
        usedPcd = false;
      }

      result = ScanResult(
        skor: tfliteResult.skor,
        kategori: tfliteResult.kategori,
        probFresh: tfliteResult.probFresh,
        probRotten: tfliteResult.probRotten,
        pesan: tfliteResult.pesan,
        skorWarna: skorWarna,
        skorKecerahan: skorKecerahan,
        skorTekstur: skorTekstur,
        skorKerusakan: skorKerusakan,
        usedPcd: usedPcd,
      );

      scanState = ScanState.success;
      await _saveHistory(result!);
    } catch (e) {
      errorMsg = e.toString().replaceFirst('Exception: ', '');
      scanState = ScanState.error;
    }

    notifyListeners();
  }

  Future<void> _saveHistory(ScanResult r) async {
    final fileName = p.basenameWithoutExtension(selectedImage!.path);
    final item = HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodName: _capitalize(fileName.split('_').first),
      imagePath: selectedImage!.path,
      skor: r.skor,
      kategori: r.kategori,
      createdAt: DateTime.now(),
      skorWarna: r.skorWarna ?? 0,
      skorKecerahan: r.skorKecerahan ?? 0,
      skorTekstur: r.skorTekstur ?? 0,
      skorKerusakan: r.skorKerusakan ?? 0,
    );

    // Save to Hive
    await HiveService.saveHistory(item);

    // Add to sync queue untuk di-sync ke backend nanti
    final syncItem = SyncQueueItem.fromHistoryItem(
      historyId: item.id,
      operation: SyncOperation.create,
      data: {
        'id': item.id,
        'foodName': item.foodName,
        'imagePath': item.imagePath,
        'skor': item.skor,
        'kategori': item.kategori,
        'createdAt': item.createdAt.toIso8601String(),
        'skorWarna': item.skorWarna,
        'skorKecerahan': item.skorKecerahan,
        'skorTekstur': item.skorTekstur,
        'skorKerusakan': item.skorKerusakan,
      },
    );
    await HiveService.addToSyncQueue(syncItem);

    // Reload history
    _loadHistory();

    // Try to sync if online
    if (_syncService.isOnline && !_syncService.isSyncing) {
      _syncService.syncAll();
    }
  }

  void _loadHistory() {
    history = HiveService.getAllHistory();
    notifyListeners();
  }

  Future<void> deleteHistory(String id) async {
    // Delete dari Hive
    await HiveService.deleteHistory(id);

    // Add to sync queue untuk delete di backend
    final syncItem = SyncQueueItem.fromHistoryItem(
      historyId: id,
      operation: SyncOperation.delete,
      data: {'id': id},
    );
    await HiveService.addToSyncQueue(syncItem);

    // Reload history
    _loadHistory();

    // Try to sync if online
    if (_syncService.isOnline && !_syncService.isSyncing) {
      _syncService.syncAll();
    }
  }

  void resetScan() {
    selectedImage = null;
    result = null;
    scanState = ScanState.idle;
    errorMsg = '';
    notifyListeners();
  }

  double get avgFreshness => HiveService.getAverageFreshness();
  int get totalScans => HiveService.getTotalScans();

  /// Manual sync
  Future<SyncResult> syncNow() async {
    return await _syncService.syncAll();
  }

  /// Retry failed syncs
  Future<SyncResult> retryFailedSyncs() async {
    return await _syncService.retryFailedSyncs();
  }

  /// Search history
  List<HistoryItem> searchHistory(String query) {
    return HiveService.searchHistory(query);
  }

  /// Get history by kategori
  List<HistoryItem> getHistoryByKategori(String kategori) {
    return HiveService.getHistoryByKategori(kategori);
  }

  /// Get statistics
  Map<String, int> getStatsByKategori() {
    return HiveService.getStatsByKategori();
  }

  Map<String, int> getStatsByDate({int days = 7}) {
    return HiveService.getStatsByDate(days: days);
  }

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  @override
  void dispose() {
    _tflite.dispose();
    _syncService.dispose();
    super.dispose();
  }
}
