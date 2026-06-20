// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'history_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HistoryItemAdapter extends TypeAdapter<HistoryItem> {
  @override
  final int typeId = 0;

  @override
  HistoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HistoryItem(
      id: fields[0] as String,
      foodName: fields[1] as String,
      imagePath: fields[2] as String,
      skor: fields[3] as double,
      kategori: fields[4] as String,
      createdAt: fields[5] as DateTime,
      skorWarna: fields[6] as double,
      skorKecerahan: fields[7] as double,
      skorTekstur: fields[8] as double,
      skorKerusakan: fields[9] as double,
    );
  }

  @override
  void write(BinaryWriter writer, HistoryItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.foodName)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.skor)
      ..writeByte(4)
      ..write(obj.kategori)
      ..writeByte(5)
      ..write(obj.createdAt)
      ..writeByte(6)
      ..write(obj.skorWarna)
      ..writeByte(7)
      ..write(obj.skorKecerahan)
      ..writeByte(8)
      ..write(obj.skorTekstur)
      ..writeByte(9)
      ..write(obj.skorKerusakan);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HistoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
