// service/tflite_service.dart
// Inferensi model TFLite on-device.
// Model: binary classifier fresh(0) vs rotten(1), input 128x128 RGB.

import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class TfliteResult {
  final double probFresh;   // 0.0 – 1.0
  final double probRotten;  // 0.0 – 1.0
  final double skor;        // 0 – 100 (makin tinggi = makin segar)
  final String kategori;    // Fresh / Medium / Rotten

  TfliteResult({
    required this.probFresh,
    required this.probRotten,
    required this.skor,
    required this.kategori,
  });

  String get pesan {
    if (kategori == 'Fresh') return 'Buah dalam kondisi segar. Aman dikonsumsi.';
    if (kategori == 'Medium') return 'Buah mulai kurang segar. Segera dikonsumsi.';
    return 'Buah menunjukkan tanda kerusakan. Tidak disarankan dikonsumsi.';
  }
}

class TfliteService {
  static const int _imgSize = 128;   // harus sama dengan waktu training
  static const String _modelPath = 'assets/models/fruit_model.tflite';

  Interpreter? _interpreter;
  bool _isLoaded = false;

  bool get isLoaded => _isLoaded;

  /// Muat model dari assets. Panggil sekali saat init.
  Future<void> loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset(_modelPath);
      _isLoaded = true;
    } catch (e) {
      _isLoaded = false;
      throw Exception('Gagal memuat model TFLite: $e');
    }
  }

  /// Jalankan inferensi pada file gambar.
  Future<TfliteResult> predict(File imageFile) async {
    if (!_isLoaded || _interpreter == null) {
      throw Exception('Model belum dimuat. Panggil loadModel() terlebih dahulu.');
    }

    // 1. Baca dan decode gambar
    final bytes = await imageFile.readAsBytes();
    img.Image? raw = img.decodeImage(bytes);
    if (raw == null) throw Exception('Gambar tidak dapat didecode.');

    // 2. Resize ke 128x128
    final resized = img.copyResize(raw, width: _imgSize, height: _imgSize);

    // 3. Konversi ke Float32 [1, 128, 128, 3], normalize /255
    final input = _imageToFloat32(resized);

    // 4. Siapkan output buffer: [1, 2] → [prob_fresh, prob_rotten]
    final output = List.filled(1 * 2, 0.0).reshape([1, 2]);

    // 5. Inferensi
    _interpreter!.run(input, output);

    final probFresh  = (output[0][0] as double);
    final probRotten = (output[0][1] as double);

    // 6. Hitung skor & kategori
    // Skor = prob_fresh * 100 → makin tinggi = makin segar
    final skor = (probFresh * 100).clamp(0.0, 100.0);

    final String kategori;
    if (skor >= 70) {
      kategori = 'Fresh';
    } else if (skor >= 40) {
      kategori = 'Medium';
    } else {
      kategori = 'Rotten';
    }

    return TfliteResult(
      probFresh: probFresh,
      probRotten: probRotten,
      skor: skor,
      kategori: kategori,
    );
  }

  /// Konversi img.Image → Float32List [1, H, W, 3]
  List<List<List<List<double>>>> _imageToFloat32(img.Image image) {
    // Shape: [batch=1][height][width][channel=3]
    return List.generate(1, (_) =>
      List.generate(_imgSize, (y) =>
        List.generate(_imgSize, (x) {
          final pixel = image.getPixel(x, y);
          return [
            pixel.r / 255.0,
            pixel.g / 255.0,
            pixel.b / 255.0,
          ];
        })
      )
    );
  }

  void dispose() {
    _interpreter?.close();
  }

  Future<void> inspectModel() async {}
}
