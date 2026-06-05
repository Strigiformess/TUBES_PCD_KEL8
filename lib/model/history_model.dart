import 'package:hive/hive.dart';

part 'history_model.g.dart';

@HiveType(typeId: 0)
class HistoryItem extends HiveObject {
  @HiveField(0) String id;
  @HiveField(1) String foodName;      // nama file / label
  @HiveField(2) String imagePath;     // path gambar lokal
  @HiveField(3) double skor;
  @HiveField(4) String kategori;
  @HiveField(5) DateTime createdAt;
  @HiveField(6) double skorWarna;
  @HiveField(7) double skorKecerahan;
  @HiveField(8) double skorTekstur;
  @HiveField(9) double skorKerusakan;

  HistoryItem({
    required this.id,
    required this.foodName,
    required this.imagePath,
    required this.skor,
    required this.kategori,
    required this.createdAt,
    required this.skorWarna,
    required this.skorKecerahan,
    required this.skorTekstur,
    required this.skorKerusakan,
  });
}
