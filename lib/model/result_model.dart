class AnalysisResult {
  final double skor;
  final String kategori;
  final double skorWarna;
  final double skorKecerahan;
  final double skorTekstur;
  final double skorKerusakan;
  final String pesan;

  AnalysisResult({
    required this.skor,
    required this.kategori,
    required this.skorWarna,
    required this.skorKecerahan,
    required this.skorTekstur,
    required this.skorKerusakan,
    required this.pesan,
  });

  factory AnalysisResult.fromJson(Map<String, dynamic> j) => AnalysisResult(
    skor: (j['skor'] as num).toDouble(),
    kategori: j['kategori'] as String,
    skorWarna: (j['detail']['skor_warna'] as num).toDouble(),
    skorKecerahan: (j['detail']['skor_kecerahan'] as num).toDouble(),
    skorTekstur: (j['detail']['skor_tekstur'] as num).toDouble(),
    skorKerusakan: (j['detail']['skor_kerusakan'] as num).toDouble(),
    pesan: j['pesan'] as String,
  );
}
