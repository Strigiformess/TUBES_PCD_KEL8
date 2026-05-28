import 'package:hive/hive.dart';
import '../../core/theme/app_theme.dart';
import '../../core/config/app_config.dart';

part 'scan_result.g.dart';

@HiveType(typeId: 0)
class ScanResult extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String label;        // nama buah/sayuran

  @HiveField(2)
  final int freshnessScore;  // 0–100

  @HiveField(3)
  final double confidence;   // confidence dari model

  @HiveField(4)
  final DateTime scannedAt;

  @HiveField(5)
  final String imagePath;    // path lokal gambar

  @HiveField(6)
  final String pipeline;     // 'mlkit' | 'tflite'

  ScanResult({
    required this.id,
    required this.label,
    required this.freshnessScore,
    required this.confidence,
    required this.scannedAt,
    required this.imagePath,
    required this.pipeline,
  });

  /// Status kesegaran berdasarkan skor dan threshold dari AppConfig.
  FreshnessStatus get status {
    if (freshnessScore >= AppConfig.freshThreshold)  return FreshnessStatus.fresh;
    if (freshnessScore >= AppConfig.mediumThreshold) return FreshnessStatus.medium;
    return FreshnessStatus.poor;
  }

  /// Skor sebagai desimal [0,1] untuk progress bar.
  double get scoreNormalized => freshnessScore / 100.0;

  ScanResult copyWith({
    String? id, String? label, int? freshnessScore,
    double? confidence, DateTime? scannedAt,
    String? imagePath, String? pipeline,
  }) => ScanResult(
    id:             id             ?? this.id,
    label:          label          ?? this.label,
    freshnessScore: freshnessScore ?? this.freshnessScore,
    confidence:     confidence     ?? this.confidence,
    scannedAt:      scannedAt      ?? this.scannedAt,
    imagePath:      imagePath      ?? this.imagePath,
    pipeline:       pipeline       ?? this.pipeline,
  );
}
