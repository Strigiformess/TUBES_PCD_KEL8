import '../models/scan_result.dart';

class ScanRepository {
  // Menyimpan riwayat scan sementara dalam list
  final List<ScanResult> _history = [];

  Future<List<ScanResult>> getHistory() async {
    // Simulasi memuat data
    await Future.delayed(const Duration(milliseconds: 500));
    return _history;
  }

  Future<void> saveScan(ScanResult result) async {
    _history.insert(0, result); // Data terbaru selalu di atas
  }
}