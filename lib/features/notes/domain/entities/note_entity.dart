import 'package:flutter/material.dart';

enum SyncStatus { synced, pending, modified, deleted }

class NoteEntity {
  final String id;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime modifiedAt;
  final List<String> tags;
  final Color color;
  final bool isPinned;
  final bool isArchived;
  final SyncStatus syncStatus;
  final String? serverId;

  const NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.createdAt,
    required this.modifiedAt,
    this.tags = const [],
    this.color = Colors.white,
    this.isPinned = false,
    this.isArchived = false,
    this.syncStatus = SyncStatus.pending,
    this.serverId,
  });

  NoteEntity copyWith({
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
    return NoteEntity(
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
}
