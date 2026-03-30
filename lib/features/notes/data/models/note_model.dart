import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:uuid/uuid.dart';
import '../../domain/entities/note_entity.dart';

part 'note_model.g.dart';

@HiveType(typeId: 0)
class NoteModel extends HiveObject {
  @HiveField(0)
  String id;

  @HiveField(1)
  String title;

  @HiveField(2)
  String content;

  @HiveField(3)
  final DateTime createdAt;

  @HiveField(4)
  DateTime modifiedAt;

  @HiveField(5)
  List<String> tags;

  @HiveField(6)
  int colorValue;

  @HiveField(7)
  bool isPinned;

  @HiveField(8)
  bool isArchived;

  @HiveField(9)
  NoteModelSyncStatus syncStatus;

  @HiveField(10)
  String? serverId;

  NoteModel({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? modifiedAt,
    this.tags = const [],
    Color? color,
    this.isPinned = false,
    this.isArchived = false,
    this.syncStatus = NoteModelSyncStatus.pending,
    this.serverId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now(),
        colorValue = color?.toARGB32() ?? Colors.white.toARGB32();

  Color get color => Color(colorValue);

  NoteEntity toEntity() => NoteEntity(
        id: id,
        title: title,
        content: content,
        createdAt: createdAt,
        modifiedAt: modifiedAt,
        tags: List.from(tags),
        color: color,
        isPinned: isPinned,
        isArchived: isArchived,
        syncStatus: _mapSyncStatus(syncStatus),
        serverId: serverId,
      );

  static NoteModel fromEntity(NoteEntity entity) => NoteModel(
        id: entity.id,
        title: entity.title,
        content: entity.content,
        createdAt: entity.createdAt,
        modifiedAt: entity.modifiedAt,
        tags: List.from(entity.tags),
        color: entity.color,
        isPinned: entity.isPinned,
        isArchived: entity.isArchived,
        syncStatus: _mapSyncStatusReverse(entity.syncStatus),
        serverId: entity.serverId,
      );

  static NoteModel fromJson(Map<String, dynamic> json) => NoteModel(
        serverId: json['id']?.toString(),
        title: json['title'] ?? '',
        content: json['content'] ?? '',
        color: _parseColor(json['color']),
        tags: List<String>.from(json['tags'] ?? []),
        isPinned: json['isPinned'] ?? false,
        isArchived: json['isArchived'] ?? false,
        createdAt: DateTime.parse(json['createdAt']),
        modifiedAt: DateTime.parse(json['modifiedAt']),
        syncStatus: NoteModelSyncStatus.synced,
      );

  Map<String, dynamic> toJson() => {
        'id': serverId,
        'localId': id,
        'title': title,
        'content': content,
        'color': '#${colorValue.toRadixString(16).padLeft(8, '0').substring(2)}',
        'tags': tags,
        'isPinned': isPinned,
        'isArchived': isArchived,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
      };

  static SyncStatus _mapSyncStatus(NoteModelSyncStatus s) {
    switch (s) {
      case NoteModelSyncStatus.synced:
        return SyncStatus.synced;
      case NoteModelSyncStatus.pending:
        return SyncStatus.pending;
      case NoteModelSyncStatus.modified:
        return SyncStatus.modified;
      case NoteModelSyncStatus.deleted:
        return SyncStatus.deleted;
    }
  }

  static NoteModelSyncStatus _mapSyncStatusReverse(SyncStatus s) {
    switch (s) {
      case SyncStatus.synced:
        return NoteModelSyncStatus.synced;
      case SyncStatus.pending:
        return NoteModelSyncStatus.pending;
      case SyncStatus.modified:
        return NoteModelSyncStatus.modified;
      case SyncStatus.deleted:
        return NoteModelSyncStatus.deleted;
    }
  }

  static Color? _parseColor(String? hex) {
    if (hex == null) return null;
    final buffer = StringBuffer();
    if (hex.length == 6 || hex.length == 7) buffer.write('ff');
    buffer.write(hex.replaceFirst('#', ''));
    return Color(int.parse(buffer.toString(), radix: 16));
  }
}

@HiveType(typeId: 1)
enum NoteModelSyncStatus {
  @HiveField(0)
  synced,
  @HiveField(1)
  pending,
  @HiveField(2)
  modified,
  @HiveField(3)
  deleted,
}

@HiveType(typeId: 2)
class UserCacheModel extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String email;
  @HiveField(2)
  final String name;

  UserCacheModel({required this.id, required this.email, required this.name});
}
