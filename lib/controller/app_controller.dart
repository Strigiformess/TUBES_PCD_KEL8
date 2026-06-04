// controller/app_controller.dart
// Hybrid: TFLite untuk klasifikasi + PCD via backend untuk detail fitur.
// Jika backend tidak tersedia, hanya TFLite yang dipakai.

import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import '../model/history_model.dart';
import '../service/tflite_service.dart';
import '../service/api_service.dart';        // tetap ada untuk detail PCD

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

  ScanState scanState = ScanState.idle;
  File? selectedImage;
  ScanResult? result;
  String errorMsg = '';

  List<HistoryItem> history = [];
  late Box<HistoryItem> _box;

  Future<void> init() async {
    // Load TFLite model
    await _tflite.loadModel();

    // Load Hive history
    _box = await Hive.openBox<HistoryItem>('history');
    _loadHistory();
  }

  void setImage(File f) {
    selectedImage = f;
    result = null;
    scanState = ScanState.idle;
    errorMsg = '';
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
        skorWarna     = pcdResult.skorWarna;
        skorKecerahan = pcdResult.skorKecerahan;
        skorTekstur   = pcdResult.skorTekstur;
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
    await _box.put(item.id, item);
    _loadHistory();
  }

  void _loadHistory() {
    history = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
  }

  Future<void> deleteHistory(String id) async {
    await _box.delete(id);
    _loadHistory();
  }

  void resetScan() {
    selectedImage = null;
    result = null;
    scanState = ScanState.idle;
    errorMsg = '';
    notifyListeners();
  }

  double get avgFreshness {
    if (history.isEmpty) return 0;
    return history.map((e) => e.skor).reduce((a, b) => a + b) / history.length;
  }

  int get totalScans => history.length;

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();

  @override
  void dispose() {
    _tflite.dispose();
    super.dispose();
  }
}
