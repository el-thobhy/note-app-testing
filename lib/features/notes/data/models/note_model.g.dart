// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'note_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class NoteModelAdapter extends TypeAdapter<NoteModel> {
  @override
  final int typeId = 0;

  @override
  NoteModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return NoteModel(
      id: fields[0] as String?,
      title: fields[1] as String,
      content: fields[2] as String,
      createdAt: fields[3] as DateTime?,
      modifiedAt: fields[4] as DateTime?,
      tags: (fields[5] as List).cast<String>(),
      isPinned: fields[7] as bool? ?? false,
      isArchived: fields[8] as bool? ?? false,
      syncStatus: fields[9] as NoteModelSyncStatus? ?? NoteModelSyncStatus.pending,
      serverId: fields[10] as String?,
    )..colorValue = fields[6] as int? ?? 0xFFFFFFFF;
  }

  @override
  void write(BinaryWriter writer, NoteModel obj) {
    writer
      ..writeByte(11)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.title)
      ..writeByte(2)
      ..write(obj.content)
      ..writeByte(3)
      ..write(obj.createdAt)
      ..writeByte(4)
      ..write(obj.modifiedAt)
      ..writeByte(5)
      ..write(obj.tags)
      ..writeByte(6)
      ..write(obj.colorValue)
      ..writeByte(7)
      ..write(obj.isPinned)
      ..writeByte(8)
      ..write(obj.isArchived)
      ..writeByte(9)
      ..write(obj.syncStatus)
      ..writeByte(10)
      ..write(obj.serverId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserCacheModelAdapter extends TypeAdapter<UserCacheModel> {
  @override
  final int typeId = 2;

  @override
  UserCacheModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserCacheModel(
      id: fields[0] as String,
      email: fields[1] as String,
      name: fields[2] as String,
    );
  }

  @override
  void write(BinaryWriter writer, UserCacheModel obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.email)
      ..writeByte(2)
      ..write(obj.name);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserCacheModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class NoteModelSyncStatusAdapter extends TypeAdapter<NoteModelSyncStatus> {
  @override
  final int typeId = 1;

  @override
  NoteModelSyncStatus read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return NoteModelSyncStatus.synced;
      case 1:
        return NoteModelSyncStatus.pending;
      case 2:
        return NoteModelSyncStatus.modified;
      case 3:
        return NoteModelSyncStatus.deleted;
      default:
        return NoteModelSyncStatus.synced;
    }
  }

  @override
  void write(BinaryWriter writer, NoteModelSyncStatus obj) {
    switch (obj) {
      case NoteModelSyncStatus.synced:
        writer.writeByte(0);
        break;
      case NoteModelSyncStatus.pending:
        writer.writeByte(1);
        break;
      case NoteModelSyncStatus.modified:
        writer.writeByte(2);
        break;
      case NoteModelSyncStatus.deleted:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is NoteModelSyncStatusAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
