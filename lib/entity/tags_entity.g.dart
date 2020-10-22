// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'tags_entity.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TagsEntityAdapter extends TypeAdapter<TagsEntity> {
  @override
  final int typeId = 1;

  @override
  TagsEntity read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TagsEntity(
      id: fields[0] as String,
      date: fields[1] as String,
      temperature: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TagsEntity obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.date)
      ..writeByte(2)
      ..write(obj.temperature);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TagsEntityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
