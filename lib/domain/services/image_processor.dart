import 'dart:io';
import 'dart:math';

class ImageProcessor {
  Future<Map<String, double>> extractFeatures(File imageFile) async {
    // Simulasi proses ekstraksi nilai RGB/HSV dari citra
    await Future.delayed(const Duration(milliseconds: 800));
    final random = Random();
    
    return {
      "Rerata R": 200.0 + random.nextInt(50),
      "Rerata G": 80.0 + random.nextInt(40),
      "Rerata B": 90.0 + random.nextInt(30),
      "Rasio Kontras": 1.2 + (random.nextDouble() * 0.5),
    };
  }
}