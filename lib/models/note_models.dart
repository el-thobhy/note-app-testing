// models/note_model.dart
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

part 'note_models.g.dart';  // 

@HiveType(typeId: 0)
class Note extends HiveObject {
  @HiveField(0)
  final String id;

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
  int colorValue; // Store color as int

  @HiveField(7)
  bool isPinned;

  @HiveField(8)
  bool isArchived;

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
  })  : id = id ?? const Uuid().v4(),
        createdAt = createdAt ?? DateTime.now(),
        modifiedAt = modifiedAt ?? DateTime.now(),
        colorValue = color?.value ?? Colors.white.value;

  // Getter untuk Color
  Color get color => Color(colorValue);
  set color(Color value) => colorValue = value.value;

  Note copyWith({
    String? title,
    String? content,
    DateTime? modifiedAt,
    List<String>? tags,
    Color? color,
    bool? isPinned,
    bool? isArchived,
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
    );
  }
}