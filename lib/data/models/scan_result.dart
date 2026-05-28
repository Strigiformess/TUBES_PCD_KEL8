import 'dart:io';

class ScanResult {
  final String id;
  final String imagePath; // Diubah menjadi String agar aman di Web
  final String foodType;
  final double freshnessScore;
  final String status;
  final DateTime scanDate;
  final List<String> recommendations;
  final String dominantColorHex;
  final Map<String, double> pcdMetrics;

  ScanResult({
    required this.id,
    required this.imagePath, // Sesuaikan di sini
    required this.foodType,
    required this.freshnessScore,
    required this.status,
    required this.scanDate,
    required this.recommendations,
    required this.dominantColorHex,
    required this.pcdMetrics,
  });
}