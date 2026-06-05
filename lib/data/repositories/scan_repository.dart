// lib/data/repositories/scan_repository.dart
import 'package:hive_flutter/hive_flutter.dart';
import '../models/scan_result.dart';

class ScanRepository {
  static const _boxName = 'scan_history';
  
  Box<ScanResult> get _box => Hive.box<ScanResult>(_boxName);

  // Simpan hasil scan baru
  Future<void> save(ScanResult result) async {
    await _box.put(result.id, result);
  }

  // Ambil semua riwayat (terbaru dulu)
  List<ScanResult> getAll() {
    return _box.values.toList()
      ..sort((a, b) => b.scanDate.compareTo(a.scanDate));
  }

  // Hapus satu hasil
  Future<void> delete(String id) async {
    await _box.delete(id);
  }
}