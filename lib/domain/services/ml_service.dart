import 'dart:io';

class MLService {
  Future<String> classifyFood(File imageFile) async {
    // Simulasi deteksi jenis buah/sayur
    await Future.delayed(const Duration(milliseconds: 500));
    return "Tomat Segar"; 
  }
}