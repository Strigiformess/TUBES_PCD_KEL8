// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'scan_result.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ScanResultAdapter extends TypeAdapter<ScanResult> {
  @override
  final int typeId = 0;

  @override
  ScanResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ScanResult(
      id: fields[0] as String,
      imagePath: fields[1] as String,
      foodType: fields[2] as String,
      freshnessScore: fields[3] as double,
      status: fields[4] as String,
      scanDate: fields[5] as DateTime,
      recommendations: (fields[6] as List).cast<String>(),
      dominantColorHex: fields[7] as String,
      pcdMetrics: (fields[8] as Map).cast<String, double>(),
      confidence: fields[9] as double,
      pipeline: fields[10] as String,
    );
  }

  @override
  void write(BinaryWriter writer, ScanResult obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.imagePath)
      ..writeByte(2)
      ..write(obj.foodType)
      ..writeByte(3)
      ..write(obj.freshnessScore)
      ..writeByte(4)
      ..write(obj.status)
      ..writeByte(5)
      ..write(obj.scanDate)
      ..writeByte(6)
      ..write(obj.recommendations)
      ..writeByte(7)
      ..write(obj.dominantColorHex)
      ..writeByte(8)
      ..write(obj.pcdMetrics)
      ..writeByte(9)
      ..write(obj.confidence)
      ..writeByte(10)
      ..write(obj.pipeline);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ScanResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
