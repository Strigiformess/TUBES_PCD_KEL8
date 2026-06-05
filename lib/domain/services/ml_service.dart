import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:tflite_flutter/tflite_flutter.dart'; // ✅ WAJIB IMPORT INI

import '../../core/config/app_config.dart';
import 'image_processor.dart';

/// Hasil analisis dari ML Service
class AnalysisResult {
  final String label;
  final double confidence;
  final int freshnessScore;
  final String pipeline;

  const AnalysisResult({
    required this.label,
    required this.confidence,
    required this.freshnessScore,
    required this.pipeline,
  });
}

/// Interface untuk ML Service
abstract interface class IMLService {
  Future<void> init();
  Future<AnalysisResult?> analyzeFile(File imageFile);
  Future<AnalysisResult?> analyzePath(String imagePath);
  void dispose();
}

/// MLService - Smart ML Pipeline
class MLService implements IMLService {
  ImageLabeler? _mlKitLabeler;
  Interpreter? _interpreter; // ✅ Ganti tipe dynamic menjadi Interpreter

  final List<String> _labels = [];
  bool _isInitialized = false;
  String _currentPipeline = 'not_initialized';

  @override
  Future<void> init() async {
    try {
      await _initMLKit();
      if (!kIsWeb && (Platform.isAndroid || Platform.isIOS)) {
        await _initTFLite();
      }
      _isInitialized = true;
    } catch (_) {
      _currentPipeline = 'mock_fallback';
      _isInitialized = true;
    }
  }

  Future<void> _initMLKit() async {
    try {
      final options = ImageLabelerOptions(confidenceThreshold: AppConfig.mlKitConfidenceThreshold);
      _mlKitLabeler = ImageLabeler(options: options);
    } catch (_) {
      _mlKitLabeler = null;
    }
  }

  // ✅ UPDATE: Inisialisasi TFLite
  Future<void> _initTFLite() async {
    if (kIsWeb) return;
    try {
      if (!Platform.isAndroid && !Platform.isIOS) return;
      
      // Load model dari assets
      _interpreter = await Interpreter.fromAsset('assets/models/freshness_model.tflite');
      _currentPipeline = 'mlkit_tflite'; // Status pipeline menjadi sukses ganda
    } catch (e) {
      print("Error loading TFLite: $e");
      _interpreter = null;
      _currentPipeline = 'mlkit_only';
    }
  }

  @override
  Future<AnalysisResult?> analyzePath(String imagePath) async {
    if (kIsWeb) return _generateMockResult('Web Image');
    final file = File(imagePath);
    if (!await file.exists()) return null;
    return analyzeFile(file);
  }

  @override
  Future<AnalysisResult?> analyzeFile(File imageFile) async {
    if (!_isInitialized) await init();
    try {
      if (!await imageFile.exists()) return null;

      // 1. Dapatkan Label Buah dari ML Kit
      final String? mlKitLabel = await _runMLKit(imageFile);
      if (mlKitLabel == null) return _generateMockResult('Unknown Food');

      // 2. Dapatkan Skor Kesegaran dari TFLite
      final freshnessData = await _runFreshnessAnalysis(imageFile, mlKitLabel);

      return AnalysisResult(
        label: freshnessData.$1,
        confidence: freshnessData.$2,
        freshnessScore: freshnessData.$3,
        pipeline: _currentPipeline,
      );
    } catch (_) {
      return _generateMockResult('Analysis Error');
    }
  }

  Future<String?> _runMLKit(File imageFile) async {
    try {
      if (_mlKitLabeler == null) return null;
      final inputImage = InputImage.fromFile(imageFile);
      final labels = await _mlKitLabeler!.processImage(inputImage);

      for (final label in labels) {
        final match = AppConfig.supportedFruits.firstWhere(
          (fruit) => label.label.toLowerCase().contains(fruit.toLowerCase()),
          orElse: () => '',
        );
        if (match.isNotEmpty) return match;
      }
      if (labels.isNotEmpty) return labels.first.label;
      return null;
    } catch (_) {
      return null;
    }
  }

  Future<(String, double, int)> _runFreshnessAnalysis(File imageFile, String detectedLabel) async {
    if (_interpreter != null && !kIsWeb) {
      return _runTFLiteModel(imageFile, detectedLabel);
    }
    return _simulateFreshnessScore(detectedLabel);
  }

  // ✅ UPDATE: Menjalankan Inferensi TFLite Asli
  Future<(String, double, int)> _runTFLiteModel(File imageFile, String detectedLabel) async {
    try {
      if (_interpreter == null) return _simulateFreshnessScore(detectedLabel);

      final bytes = await imageFile.readAsBytes();
      
      // Asumsi preprocessImageBytes mereturn Float32List ukuran [1, 224, 224, 3]
      final inputTensor = await ImageProcessor.preprocessImageBytes(bytes);

      // Siapkan buffer output (Asumsi model Kaggle memprediksi 2 kelas: Fresh dan Rotten)
      var outputBuffer = List.generate(1, (_) => List<double>.filled(2, 0.0));

      // Jalankan model!
      _interpreter!.run(inputTensor, outputBuffer);

      // Ekstrak probabilitas. Asumsi: Index 0 = Fresh, Index 1 = Rotten
      double probFresh = outputBuffer[0][0];
      double probRotten = outputBuffer[0][1];

      // Normalisasi nilai jika outputnya bukan persentase
      double total = probFresh + probRotten;
      if (total > 0) {
        probFresh /= total;
        probRotten /= total;
      }

      // Hitung Confidence & Score 0-100
      double confidence = probFresh > probRotten ? probFresh : probRotten;
      int freshnessScore = (probFresh * 100).round().clamp(0, 100);

      return (detectedLabel, confidence, freshnessScore);
      
    } catch (e) {
      print("TFLite inference failed: $e");
      return _simulateFreshnessScore(detectedLabel);
    }
  }

  (String, double, int) _simulateFreshnessScore(String label) {
    const mockData = {
      'Apple': (0.92, 88), 'Apel': (0.92, 88),
      'Banana': (0.78, 62), 'Pisang': (0.78, 62),
      'Tomato': (0.88, 81), 'Tomat': (0.88, 81),
      'Mangga': (0.89, 81),
    };
    final data = mockData[label] ?? (0.75, 70);
    return (label, data.$1, data.$2);
  }

  AnalysisResult _generateMockResult(String label) {
    final (finalLabel, confidence, score) = _simulateFreshnessScore(label);
    return AnalysisResult(
      label: finalLabel,
      confidence: confidence,
      freshnessScore: score,
      pipeline: 'mock_fallback',
    );
  }

  @override
  void dispose() {
    try {
      _mlKitLabeler?.close();
      _interpreter?.close(); // ✅ Tutup interpreter untuk cegah memory leak
      _isInitialized = false;
    } catch (_) {}
  }
}