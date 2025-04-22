// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'CloudConvertService.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CloudConvertServiceAdapter extends TypeAdapter<CloudConvertService> {
  @override
  final int typeId = 0;

  @override
  CloudConvertService read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CloudConvertService()
      ..estadoActual = fields[0] as estado
      .._outputformat = fields[1] as String?
      .._videoCodec = fields[2] as String?
      .._crf = fields[3] as int?
      .._width = fields[4] as int?
      .._height = fields[5] as int?
      .._audioCodec = fields[6] as String?;
  }

  @override
  void write(BinaryWriter writer, CloudConvertService obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.estadoActual)
      ..writeByte(1)
      ..write(obj._outputformat)
      ..writeByte(2)
      ..write(obj._videoCodec)
      ..writeByte(3)
      ..write(obj._crf)
      ..writeByte(4)
      ..write(obj._width)
      ..writeByte(5)
      ..write(obj._height)
      ..writeByte(6)
      ..write(obj._audioCodec);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CloudConvertServiceAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
