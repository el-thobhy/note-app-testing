// models/note_model.dart
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

part 'note_models.g.dart';

@HiveType(typeId: 0)
class Note extends HiveObject {
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
  SyncStatus? syncStatus; // NEW: Track sync status

  @HiveField(10)
  String? serverId; // NEW: ID dari backend (jika sudah sync)

  Note({
    String? id,
    required this.title,
    required this.content,
    DateTime? createdAt,
    DateTime? modifiedAt,
    this.tags = const [],
    Color? color,
    this.isPinned = false,
    this.isArchived = false,
    this.syncStatus = SyncStatus.pending, // Default: belum sync
    this.serverId,
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now(),
        colorValue = color?.value ?? Colors.white.value;

  Color get color => Color(colorValue);
  set color(Color value) => colorValue = value.value;

  // Convert ke JSON untuk kirim ke backend
  Map<String, dynamic> toJson() => {
        'id': serverId, // Backend pakai serverId
        'localId': id,  // Referensi local ID
        'title': title,
        'content': content,
        'color': '#${colorValue.toRadixString(16).padLeft(8, '0').substring(2)}',
        'tags': tags,
        'isPinned': isPinned,
        'isArchived': isArchived,
        'createdAt': createdAt.toIso8601String(),
        'modifiedAt': modifiedAt.toIso8601String(),
      };

  // Parse dari JSON backend
  factory Note.fromJson(Map<String, dynamic> json) {
    return Note(
      id: json['localId'] as String?, // Keep local ID
      serverId: json['id'] as String?, // Server ID
      title: json['title'] ?? '',
      content: json['content'] ?? '',
      color: _parseColor(json['color']),
      tags: List<String>.from(json['tags'] ?? []),
      isPinned: json['isPinned'] ?? false,
      isArchived: json['isArchived'] ?? false,
      createdAt: DateTime.parse(json['createdAt']),
      modifiedAt: DateTime.parse(json['modifiedAt']),
      syncStatus: SyncStatus.synced, // Sudah sync dari server
    );
  }

  Note copyWith({
    String? title,
    String? content,
    DateTime? modifiedAt,
    List<String>? tags,
    Color? color,
    bool? isPinned,
    bool? isArchived,
    SyncStatus? syncStatus,
    String? serverId,
  }) {
    return Note(
      id: id,
      title: title ?? this.title,
      content: content ?? this.content,
      createdAt: createdAt,
      modifiedAt: modifiedAt ?? DateTime.now(),
      tags: tags ?? this.tags,
      color: color ?? this.color,
      isPinned: isPinned ?? this.isPinned,
      isArchived: isArchived ?? this.isArchived,
      syncStatus: syncStatus ?? this.syncStatus,
      serverId: serverId ?? this.serverId,
    );
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
enum SyncStatus {
  @HiveField(0)
  synced,    // Sudah sync dengan backend
  
  @HiveField(1)
  pending,   // Belum pernah sync (baru dibuat offline)
  
  @HiveField(2)
  modified,  // Sudah sync tapi ada perubahan lokal
  
  @HiveField(3)
  deleted,   // Dihapus offline, perlu sync deletion
}

// Hive Model untuk User Cache
@HiveType(typeId: 2)
class UserCache extends HiveObject {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String email;
  
  @HiveField(2)
  final String name;

  UserCache({
    required this.id,
    required this.email,
    required this.name,
  });
}