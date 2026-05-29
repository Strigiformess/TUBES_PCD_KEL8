import 'package:hive/hive.dart';
import '../../core/config/app_config.dart';

part 'scan_result.g.dart';

/// Model gabungan:
/// - Base dari model teman (foodType, recommendations, dominantColorHex, pcdMetrics)
/// - Ditambah field dari model saya (confidence, pipeline)
/// - freshnessScore: double (sesuai model teman)
/// - scanDate dipakai (menggantikan scannedAt)
/// - status disimpan sebagai String, bukan computed
@HiveType(typeId: 0)
class ScanResult extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String imagePath;

  @HiveField(2)
  final String foodType;

  @HiveField(3)
  final double freshnessScore;

  @HiveField(4)
  final String status; // 'Fresh' | 'Medium' | 'Poor'

  @HiveField(5)
  final DateTime scanDate;

  @HiveField(6)
  final List<String> recommendations;

  @HiveField(7)
  final String dominantColorHex;

  @HiveField(8)
  final Map<String, double> pcdMetrics;
  // Contoh isi:
  // { 'brightness': 142.5, 'contrast': 0.73,
  //   'saturation': 0.61, 'sharpness': 88.2 }

  @HiveField(9)
  final double confidence;

  @HiveField(10)
  final String pipeline;

  ScanResult({
    required this.id,
    required this.imagePath,
    required this.foodType,
    required this.freshnessScore,
    required this.status,
    required this.scanDate,
    required this.recommendations,
    required this.dominantColorHex,
    required this.pcdMetrics,
    this.confidence = 0.0,
    this.pipeline   = 'mlkit',
  });

  // ── Helpers ───────────────────────────────────────────────────────────────

  int    get scoreAsInt      => freshnessScore.round();
  double get scoreNormalized => (freshnessScore / 100.0).clamp(0.0, 1.0);

  // ── Factory: status dihitung otomatis dari skor ───────────────────────────

  factory ScanResult.withAutoStatus({
    required String id,
    required String imagePath,
    required String foodType,
    required double freshnessScore,
    required DateTime scanDate,
    required List<String> recommendations,
    required String dominantColorHex,
    required Map<String, double> pcdMetrics,
    double confidence = 0.0,
    String pipeline   = 'mlkit',
  }) {
    return ScanResult(
      id:               id,
      imagePath:        imagePath,
      foodType:         foodType,
      freshnessScore:   freshnessScore,
      status:           _computeStatus(freshnessScore),
      scanDate:         scanDate,
      recommendations:  recommendations,
      dominantColorHex: dominantColorHex,
      pcdMetrics:       pcdMetrics,
      confidence:       confidence,
      pipeline:         pipeline,
    );
  }

  static String _computeStatus(double score) {
    if (score >= AppConfig.freshThreshold)  return 'Fresh';
    if (score >= AppConfig.mediumThreshold) return 'Medium';
    return 'Poor';
  }

  ScanResult copyWith({
    String? id, String? imagePath, String? foodType,
    double? freshnessScore, String? status, DateTime? scanDate,
    List<String>? recommendations, String? dominantColorHex,
    Map<String, double>? pcdMetrics, double? confidence, String? pipeline,
  }) => ScanResult(
    id:               id               ?? this.id,
    imagePath:        imagePath         ?? this.imagePath,
    foodType:         foodType          ?? this.foodType,
    freshnessScore:   freshnessScore    ?? this.freshnessScore,
    status:           status            ?? this.status,
    scanDate:         scanDate          ?? this.scanDate,
    recommendations:  recommendations   ?? this.recommendations,
    dominantColorHex: dominantColorHex  ?? this.dominantColorHex,
    pcdMetrics:       pcdMetrics        ?? this.pcdMetrics,
    confidence:       confidence        ?? this.confidence,
    pipeline:         pipeline          ?? this.pipeline,
  );
}
