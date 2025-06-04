// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'gadget.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GadgetAdapter extends TypeAdapter<Gadget> {
  @override
  final int typeId = 0;

  @override
  Gadget read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Gadget(
      id: fields[0] as String,
      name: fields[1] as String,
      data: (fields[2] as Map).cast<String, dynamic>(),
      imagePath: fields[3] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Gadget obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.data)
      ..writeByte(3)
      ..write(obj.imagePath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GadgetAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
