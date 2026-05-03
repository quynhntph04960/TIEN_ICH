// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'name_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GroupShareMoneyAdapter extends TypeAdapter<GroupShareMoney> {
  @override
  final typeId = 0;

  @override
  GroupShareMoney read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GroupShareMoney(
      name: fields[0] as String,
      users: (fields[1] as List).cast<NameModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, GroupShareMoney obj) {
    writer
      ..writeByte(2)
      ..writeByte(0)
      ..write(obj.name)
      ..writeByte(1)
      ..write(obj.users);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GroupShareMoneyAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NameModelAdapter extends TypeAdapter<NameModel> {
  @override
  final typeId = 1;

  @override
  NameModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NameModel(
      id: (fields[0] as num).toInt(),
      name: fields[1] as String,
      listMoney: (fields[2] as List?)?.cast<MoneyModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, NameModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.listMoney);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NameModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class MoneyModelAdapter extends TypeAdapter<MoneyModel> {
  @override
  final typeId = 2;

  @override
  MoneyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MoneyModel(
      money: (fields[0] as num?)?.toInt(),
      isCollected: fields[2] == null ? false : fields[2] as bool,
      title: fields[1] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MoneyModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.money)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.isCollected);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MoneyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
