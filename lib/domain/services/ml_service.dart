import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/services.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';
import 'package:tflite_flutter/tflite_flutter.dart';
import '../../core/config/app_config.dart';
import '../../data/models/scan_result.dart';
import 'image_processor.dart';

/// Hasil analisis gabungan ML Kit + TFLite
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

/// MLService — mengorkestrasi dua pipeline:
///   1. Google ML Kit Image Labeling  → identifikasi jenis buah/sayur
///   2. TFLite Custom Model           → skor kesegaran 0–100
///
/// Mengikuti prinsip Dependency Inversion: UI bergantung pada abstraksi,
/// bukan implementasi konkret.
abstract interface class IMLService {
  Future<void> init();
  Future<AnalysisResult?> analyzeFile(File imageFile);
  void dispose();
}

class MLService implements IMLService {
  // ── Google ML Kit ────────────────────────────────────────────────────────
  late ImageLabeler _mlKitLabeler;

  // ── TFLite ───────────────────────────────────────────────────────────────
  Interpreter? _interpreter;
  List<String> _labels = [];

  bool _isInitialized = false;

  @override
  Future<void> init() async {
    await _initMLKit();
    await _initTFLite();
    _isInitialized = true;
  }

  // ── ML Kit init ──────────────────────────────────────────────────────────
  Future<void> _initMLKit() async {
    final options = ImageLabelerOptions(
      confidenceThreshold: AppConfig.mlKitConfidenceThreshold,
    );
    _mlKitLabeler = ImageLabeler(options: options);
  }

  // ── TFLite init ──────────────────────────────────────────────────────────
  Future<void> _initTFLite() async {
    try {
      _interpreter = await Interpreter.fromAsset(AppConfig.modelPath);

      final labelsData = await rootBundle.loadString(AppConfig.labelsPath);
      _labels = labelsData
          .split('\n')
          .map((l) => l.trim())
          .where((l) => l.isNotEmpty)
          .toList();
    } catch (e) {
      // Model belum ada (development) — gunakan fallback
      _interpreter = null;
    }
  }

  // ── Analisis utama ───────────────────────────────────────────────────────

  @override
  Future<AnalysisResult?> analyzeFile(File imageFile) async {
    if (!_isInitialized) await init();

    // Step 1: ML Kit → deteksi label / jenis buah
    final String? mlKitLabel = await _runMLKit(imageFile);

    if (mlKitLabel == null) return null;

    // Step 2: TFLite → skor kesegaran 0–100
    final Uint8List bytes = await imageFile.readAsBytes();
    final freshnessData   = await _runTFLite(bytes, mlKitLabel);

    return AnalysisResult(
      label:          freshnessData.$1,
      confidence:     freshnessData.$2,
      freshnessScore: freshnessData.$3,
      pipeline:       _interpreter != null ? 'mlkit+tflite' : 'mlkit',
    );
  }

  // ── ML Kit: identifikasi buah ────────────────────────────────────────────

  Future<String?> _runMLKit(File imageFile) async {
    final inputImage = InputImage.fromFile(imageFile);
    final labels     = await _mlKitLabeler.processImage(inputImage);

    // Pilih label pertama yang termasuk buah/sayur yang didukung
    for (final label in labels) {
      final match = AppConfig.supportedFruits.firstWhere(
        (f) => label.label.toLowerCase().contains(f.toLowerCase()),
        orElse: () => '',
      );
      if (match.isNotEmpty) return match;
    }

    // Fallback: label confidence tertinggi
    if (labels.isNotEmpty) return labels.first.label;
    return null;
  }

  // ── TFLite: skor kesegaran ───────────────────────────────────────────────

  Future<(String, double, int)> _runTFLite(
    Uint8List bytes,
    String detectedLabel,
  ) async {
    if (_interpreter == null) {
      // Fallback simulasi skor saat model belum ada
      return _simulateFreshnessScore(detectedLabel);
    }

    // Preprocessing: decode → resize 224×224 → normalize → tensor
    final Float32List inputTensor = await ImageProcessor.preprocessImageBytes(bytes);

    // Output tensor: [1, num_classes] — nilai float per kelas
    final outputShape  = _interpreter!.getOutputTensor(0).shape;
    final outputBuffer = List.filled(outputShape[1], 0.0).reshape([1, outputShape[1]]);

    // Jalankan inferensi
    _interpreter!.run(
      inputTensor.reshape([1, AppConfig.inputSize, AppConfig.inputSize, 3]),
      outputBuffer,
    );

    final List<double> scores = List<double>.from(outputBuffer[0]);

    // Cari index dengan confidence tertinggi
    int bestIdx = 0;
    for (int i = 1; i < scores.length; i++) {
      if (scores[i] > scores[bestIdx]) bestIdx = i;
    }

    final String  label      = bestIdx < _labels.length ? _labels[bestIdx] : detectedLabel;
    final double  confidence = scores[bestIdx];

    // Konversi confidence → skor kesegaran 0–100
    // (confidence tinggi = lebih segar untuk kelas "fresh")
    final int freshnessScore = _confidenceToFreshnessScore(scores, label);

    return (label, confidence, freshnessScore);
  }

  /// Mapping confidence output model → skor kesegaran 0–100.
  /// Asumsi model output: [p_fresh, p_medium, p_poor] per kelas buah.
  int _confidenceToFreshnessScore(List<double> scores, String label) {
    // Jika model output 3 kelas kesegaran: fresh(0), medium(1), poor(2)
    if (scores.length >= 3) {
      final pFresh  = scores[0];
      final pMedium = scores[1];
      final pPoor   = scores[2];
      // Weighted score
      return ((pFresh * 100) + (pMedium * 60) + (pPoor * 20))
          .round()
          .clamp(0, 100);
    }
    // Fallback: gunakan confidence tunggal
    return (scores.first * 100).round().clamp(0, 100);
  }

  /// Simulasi skor untuk development (tanpa model TFLite)
  (String, double, int) _simulateFreshnessScore(String label) {
    final mockScores = {
      'Apple':       (0.92, 88),
      'Avocado':     (0.87, 94),
      'Banana':      (0.78, 62),
      'Baby Spinach':(0.91, 76),
      'Broccoli':    (0.85, 82),
    };
    final data = mockScores[label] ?? (0.75, 70);
    return (label, data.$1, data.$2);
  }

  @override
  void dispose() {
    _mlKitLabeler.close();
    _interpreter?.close();
    _isInitialized = false;
  }
}
