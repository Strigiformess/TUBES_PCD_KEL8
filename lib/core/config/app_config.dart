/// AppConfig — Single Source of Truth untuk semua konfigurasi model & pipeline.
/// Mengikuti prinsip SOLID: Single Responsibility + Open/Closed.
class AppConfig {
  AppConfig._();

  // ── Model ───────────────────────────────────────────────────────────────
  static const String modelPath      = 'assets/models/freshness_model.tflite';
  static const String labelsPath     = 'assets/labels/labels.txt';

  // ── Input preprocessing ─────────────────────────────────────────────────
  static const int    inputSize      = 224;   // 224×224 px
  static const int    inputChannels  = 3;     // RGB
  static const double inputMean      = 0.0;
  static const double inputStd       = 255.0; // normalisasi [0,1]

  // ── Threshold ───────────────────────────────────────────────────────────
  static const double confidenceThreshold = 0.55;
  static const int    freshThreshold      = 70; // skor ≥70 → Fresh
  static const int    mediumThreshold     = 40; // skor ≥40 → Medium, <40 → Poor

  // ── ML Kit ──────────────────────────────────────────────────────────────
  static const double mlKitConfidenceThreshold = 0.60;

  // ── Pipeline labels ─────────────────────────────────────────────────────
  static const List<String> supportedFruits = [
    'Apple', 'Avocado', 'Banana', 'Baby Spinach',
    'Broccoli', 'Carrot', 'Grape', 'Mango',
    'Orange', 'Strawberry', 'Tomato',
  ];

  // ── Camera ──────────────────────────────────────────────────────────────
  static const double overlaySize    = 224.0;
  static const int    cameraWidth    = 1280;
  static const int    cameraHeight   = 720;
}
