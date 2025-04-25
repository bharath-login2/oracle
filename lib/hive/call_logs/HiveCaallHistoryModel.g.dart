// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'HiveCaallHistoryModel.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class HiveCaallHistoryModelAdapter extends TypeAdapter<HiveCaallHistoryModel> {
  @override
  final int typeId = 1;

  @override
  HiveCaallHistoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return HiveCaallHistoryModel(
      id: fields[0] as String,
      name: fields[1] as String,
      phoneNumber: fields[2] as String,
      callType: fields[3] as String,
      duration: fields[4] as String,
      timeStamp: fields[5] as String,
      simSlot: fields[6] as String,
      callRecordFilePath: fields[7] as String,
      isUploaded: fields[8] as bool,
      isDeleted: fields[9] as bool,
      isEnabled: fields[10] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, HiveCaallHistoryModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.phoneNumber)
      ..writeByte(3)
      ..write(obj.callType)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.timeStamp)
      ..writeByte(6)
      ..write(obj.simSlot)
      ..writeByte(7)
      ..write(obj.callRecordFilePath)
      ..writeByte(8)
      ..write(obj.isUploaded)
      ..writeByte(9)
      ..write(obj.isDeleted)
      ..writeByte(10)
      ..write(obj.isEnabled);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is HiveCaallHistoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
