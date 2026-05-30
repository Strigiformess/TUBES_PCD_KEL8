import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:google_mlkit_image_labeling/google_mlkit_image_labeling.dart';

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

  dynamic _interpreter;

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
      final options = ImageLabelerOptions(
        confidenceThreshold: AppConfig.mlKitConfidenceThreshold,
      );

      _mlKitLabeler = ImageLabeler(options: options);
    } catch (_) {
      _mlKitLabeler = null;
    }
  }

  Future<void> _initTFLite() async {
    if (kIsWeb) return;

    try {
      if (!Platform.isAndroid && !Platform.isIOS) return;

      _interpreter = null;
      _currentPipeline = 'mlkit_only';
    } catch (_) {
      _interpreter = null;
      _currentPipeline = 'mlkit_only';
    }
  }

  // ============================================================
  // TAMBAHAN: analyzePath untuk scan_provider
  // ============================================================

  @override
  Future<AnalysisResult?> analyzePath(String imagePath) async {
    if (kIsWeb) {
      return _generateMockResult('Web Image');
    }

    final file = File(imagePath);

    if (!await file.exists()) {
      return null;
    }

    return analyzeFile(file);
  }

  // ============================================================

  @override
  Future<AnalysisResult?> analyzeFile(File imageFile) async {
    if (!_isInitialized) {
      await init();
    }

    try {
      if (!await imageFile.exists()) {
        return null;
      }

      final String? mlKitLabel =
          await _runMLKit(imageFile);

      if (mlKitLabel == null) {
        return _generateMockResult('Unknown Food');
      }

      final freshnessData =
          await _runFreshnessAnalysis(
        imageFile,
        mlKitLabel,
      );

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

      final inputImage =
          InputImage.fromFile(imageFile);

      final labels =
          await _mlKitLabeler!.processImage(
        inputImage,
      );

      for (final label in labels) {
        final match =
            AppConfig.supportedFruits.firstWhere(
          (fruit) => label.label
              .toLowerCase()
              .contains(
                fruit.toLowerCase(),
              ),
          orElse: () => '',
        );

        if (match.isNotEmpty) {
          return match;
        }
      }

      if (labels.isNotEmpty) {
        return labels.first.label;
      }

      return null;
    } catch (_) {
      return null;
    }
  }

  Future<(String, double, int)>
      _runFreshnessAnalysis(
    File imageFile,
    String detectedLabel,
  ) async {
    if (_interpreter != null &&
        !kIsWeb) {
      return _runTFLiteModel(
        imageFile,
        detectedLabel,
      );
    }

    return _simulateFreshnessScore(
      detectedLabel,
    );
  }

  Future<(String, double, int)>
      _runTFLiteModel(
    File imageFile,
    String detectedLabel,
  ) async {
    try {
      if (_interpreter == null) {
        return _simulateFreshnessScore(
          detectedLabel,
        );
      }

      final bytes =
          await imageFile.readAsBytes();

      final inputTensor =
          await ImageProcessor
              .preprocessImageBytes(
        bytes,
      );

      final outputShape =
          _interpreter
              .getOutputTensor(0)
              .shape;

      final outputBuffer =
          List.generate(
        1,
        (_) => List<double>.filled(
          outputShape[1],
          0.0,
        ),
      );

      _interpreter.run(
        [inputTensor],
        outputBuffer,
      );

      final List<double> scores =
          outputBuffer[0];

      int bestIdx = 0;

      for (
        int i = 1;
        i < scores.length;
        i++
      ) {
        if (scores[i] >
            scores[bestIdx]) {
          bestIdx = i;
        }
      }

      final String label =
          bestIdx < _labels.length
              ? _labels[bestIdx]
              : detectedLabel;

      final double confidence =
          scores[bestIdx].clamp(
        0.0,
        1.0,
      );

      final int freshnessScore =
          _confidenceToFreshnessScore(
        scores,
        label,
      );

      return (
        label,
        confidence,
        freshnessScore,
      );
    } catch (_) {
      return _simulateFreshnessScore(
        detectedLabel,
      );
    }
  }

  int _confidenceToFreshnessScore(
    List<double> scores,
    String label,
  ) {
    try {
      if (scores.length >= 3) {
        final pFresh =
            scores[0].clamp(
          0.0,
          1.0,
        );

        final pMedium =
            scores[1].clamp(
          0.0,
          1.0,
        );

        final pPoor =
            scores[2].clamp(
          0.0,
          1.0,
        );

        final score =
            ((pFresh * 100) +
                    (pMedium *
                        60) +
                    (pPoor *
                        20)) /
                1.8;

        return score
            .round()
            .clamp(0, 100);
      }

      return (scores.first
                  .clamp(
                    0.0,
                    1.0,
                  ) *
              100)
          .round();
    } catch (_) {
      return 50;
    }
  }

  (String, double, int)
      _simulateFreshnessScore(
    String label,
  ) {
    const mockData = {
      'Apple': (0.92, 88),
      'Apel': (0.92, 88),
      'Banana': (0.78, 62),
      'Pisang': (0.78, 62),
      'Tomato': (0.88, 81),
      'Tomat': (0.88, 81),
      'Mangga': (0.89, 81),
    };

    final data =
        mockData[label] ??
            (0.75, 70);

    return (
      label,
      data.$1,
      data.$2,
    );
  }

  AnalysisResult _generateMockResult(
    String label,
  ) {
    final (
      finalLabel,
      confidence,
      score,
    ) =
        _simulateFreshnessScore(
      label,
    );

    return AnalysisResult(
      label: finalLabel,
      confidence: confidence,
      freshnessScore: score,
      pipeline:
          'mock_fallback',
    );
  }

  @override
  void dispose() {
    try {
      _mlKitLabeler?.close();

      _isInitialized = false;
    } catch (_) {}
  }
}