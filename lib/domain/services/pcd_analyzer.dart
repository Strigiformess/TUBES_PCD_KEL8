// lib/domain/services/pcd_analyzer.dart
import 'dart:typed_data';
import 'package:image/image.dart' as img;

class PCDAnalyzer {
  /// Hitung semua metrik PCD dari gambar
  static Map<String, double> analyze(Uint8List imageBytes) {
    final image = img.decodeImage(imageBytes);
    if (image == null) return _emptyMetrics();

    // Resize kecil dulu buat efisiensi
    final small = img.copyResize(image, width: 64, height: 64);

    return {
      'Brightness': _calcBrightness(small),
      'Contrast': _calcContrast(small),
      'Saturation': _calcSaturation(small),
      'Sharpness': _calcSharpness(small),
    };
  }

  // Kecerahan = rata-rata nilai piksel (0–255)
  static double _calcBrightness(img.Image img) {
    double sum = 0;
    int count = img.width * img.height;
    for (int y = 0; y < img.height; y++) {
      for (int x = 0; x < img.width; x++) {
        final p = img.getPixel(x, y);
        sum += (p.r + p.g + p.b) / 3;
      }
    }
    return sum / count;
  }

  // Kontras = standar deviasi kecerahan
  static double _calcContrast(img.Image image) {
    final brightness = _calcBrightness(image);
    double variance = 0;
    int count = image.width * image.height;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        final lum = (p.r + p.g + p.b) / 3;
        variance += (lum - brightness) * (lum - brightness);
      }
    }
    return (variance / count).clamp(0, 65025) / 65025; // Normalisasi 0–1
  }

  // Saturasi = seberapa "cerah" warna (0=abu-abu, 1=sangat berwarna)
  static double _calcSaturation(img.Image image) {
    double totalSat = 0;
    int count = image.width * image.height;
    for (int y = 0; y < image.height; y++) {
      for (int x = 0; x < image.width; x++) {
        final p = image.getPixel(x, y);
        final r = p.r / 255, g = p.g / 255, b = p.b / 255;
        final max = [r, g, b].reduce((a, b) => a > b ? a : b);
        final min = [r, g, b].reduce((a, b) => a < b ? a : b);
        final delta = max - min;
        totalSat += (max == 0) ? 0 : delta / max;
      }
    }
    return totalSat / count;
  }

  // Ketajaman = variansi filter Laplacian (tepi/edge detection)
  static double _calcSharpness(img.Image image) {
    double variance = 0;
    int count = 0;
    for (int y = 1; y < image.height - 1; y++) {
      for (int x = 1; x < image.width - 1; x++) {
        // Laplacian kernel: tengah * 4 - 4 tetangga
        final center = _lum(image.getPixel(x, y));
        final n = _lum(image.getPixel(x, y - 1));
        final s = _lum(image.getPixel(x, y + 1));
        final e = _lum(image.getPixel(x + 1, y));
        final w = _lum(image.getPixel(x - 1, y));
        final laplacian = (4 * center - n - s - e - w).abs();
        variance += laplacian;
        count++;
      }
    }
    return (variance / count).clamp(0, 100);
  }

  static double _lum(img.Pixel p) => (p.r * 0.299 + p.g * 0.587 + p.b * 0.114);

  static Map<String, double> _emptyMetrics() => {
    'Brightness': 0, 'Contrast': 0, 'Saturation': 0, 'Sharpness': 0,
  };
}