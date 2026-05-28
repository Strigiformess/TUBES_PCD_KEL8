import 'package:hive_flutter/hive_flutter.dart';
import '../models/scan_result.dart';

abstract interface class IScanRepository {
  Future<List<ScanResult>> getAll();
  Future<void> save(ScanResult result);
  Future<void> delete(String id);
  Future<void> clear();
}

class ScanRepository implements IScanRepository {
  static const _boxName = 'scan_results';

  Box<ScanResult> get _box => Hive.box<ScanResult>(_boxName);

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(ScanResultAdapter());
    await Hive.openBox<ScanResult>(_boxName);
  }

  @override
  Future<List<ScanResult>> getAll() async {
    final results = _box.values.toList()
      ..sort((a, b) => b.scannedAt.compareTo(a.scannedAt));
    return results;
  }

  @override
  Future<void> save(ScanResult result) => _box.put(result.id, result);

  @override
  Future<void> delete(String id) => _box.delete(id);

  @override
  Future<void> clear() => _box.clear();
}
