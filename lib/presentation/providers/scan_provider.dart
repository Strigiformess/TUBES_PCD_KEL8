import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/scan_result.dart';

abstract class ScanState {}
class ScanInitial extends ScanState {}
class ScanLoading extends ScanState {}
class ScanSuccess extends ScanState {
  final ScanResult result;
  ScanSuccess(this.result);
}
class ScanError extends ScanState {
  final String message;
  ScanError(this.message);
}

class ScanNotifier extends Notifier<ScanState> {
  @override
  ScanState build() {
    return ScanInitial();
  }

  // Parameter diubah menerima path berbentuk String
  Future<void> analyze(String imagePath) async {
    state = ScanLoading();
    try {
      await Future.delayed(const Duration(seconds: 2));

      final mockResult = ScanResult(
        id: DateTime.now().toString(),
        imagePath: imagePath, // Menyimpan URL/Path
        foodType: "Tomat Segar",
        freshnessScore: 92.5,
        status: "Sangat Segar",
        scanDate: DateTime.now(),
        dominantColorHex: "#FFAAA5",
        pcdMetrics: {"Mean R": 220.1, "Mean G": 60.3, "Mean B": 55.4},
        recommendations: [
          "Simpan di suhu ruang, hindari sinar matahari langsung.",
          "Kondisi warna merah ideal, siap untuk dikonsumsi."
        ],
      );
      state = ScanSuccess(mockResult);
    } catch (e) {
      state = ScanError("Gagal memproses gambar: $e");
    }
  }
}

final scanStateProvider = NotifierProvider<ScanNotifier, ScanState>(() {
  return ScanNotifier();
});