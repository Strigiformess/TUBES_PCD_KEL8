import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';
import 'package:path/path.dart' as p;
import '../model/result_model.dart';
import '../model/history_model.dart';
import '../service/api_service.dart';

enum ScanState { idle, loading, success, error }

class AppController extends ChangeNotifier {
  // ── Scan state ──
  ScanState scanState = ScanState.idle;
  File? selectedImage;
  AnalysisResult? result;
  String errorMsg = '';

  // ── History ──
  List<HistoryItem> history = [];
  late Box<HistoryItem> _box;

  Future<void> init() async {
    _box = await Hive.openBox<HistoryItem>('history');
    _loadHistory();
  }

  void _loadHistory() {
    history = _box.values.toList()
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    notifyListeners();
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
      result = await ApiService.analyze(selectedImage!);
      scanState = ScanState.success;
      await _saveHistory(result!);
    } catch (e) {
      errorMsg = e.toString().replaceFirst('Exception: ', '');
      scanState = ScanState.error;
    }
    notifyListeners();
  }

  Future<void> _saveHistory(AnalysisResult r) async {
    final fileName = p.basenameWithoutExtension(selectedImage!.path);
    final item = HistoryItem(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      foodName: _capitalize(fileName.split('_').first),
      imagePath: selectedImage!.path,
      skor: r.skor,
      kategori: r.kategori,
      createdAt: DateTime.now(),
      skorWarna: r.skorWarna,
      skorKecerahan: r.skorKecerahan,
      skorTekstur: r.skorTekstur,
      skorKerusakan: r.skorKerusakan,
    );
    await _box.put(item.id, item);
    _loadHistory();
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

  // Stats for home dashboard
  double get avgFreshness {
    if (history.isEmpty) return 0;
    return history.map((e) => e.skor).reduce((a, b) => a + b) / history.length;
  }

  int get totalScans => history.length;

  String _capitalize(String s) =>
      s.isEmpty ? s : s[0].toUpperCase() + s.substring(1).toLowerCase();
}
