// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'mentor_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MentorModelAdapter extends TypeAdapter<MentorModel> {
  @override
  final int typeId = 2;

  @override
  MentorModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MentorModel(
      id: fields[0] as String,
      name: fields[1] as String,
      institution: fields[2] as String,
      imageUrl: fields[3] as String,
      rating: fields[4] as double,
      reviewCount: fields[5] as int,
      description: fields[6] as String,
      categories: (fields[7] as List).cast<String>(),
      pricePerSession:  fields[8] as int,
    );
  }

  @override
  void write(BinaryWriter writer, MentorModel obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.institution)
      ..writeByte(3)
      ..write(obj.imageUrl)
      ..writeByte(4)
      ..write(obj.rating)
      ..writeByte(5)
      ..write(obj.reviewCount)
      ..writeByte(6)
      ..write(obj.description)
      ..writeByte(7)
      ..write(obj.categories);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MentorModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
