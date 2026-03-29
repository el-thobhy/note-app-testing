// services/note_repository.dart
import 'package:hive/hive.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_models.dart';

class NoteRepository {
  static const String _boxName = 'notes';
  late Box<Note> _box;

  // Singleton pattern
  static final NoteRepository _instance = NoteRepository._internal();
  factory NoteRepository() => _instance;
  NoteRepository._internal();

  Box<Note> get notesBox => _box;

  Future<void> init() async {
    await Hive.initFlutter();
    // Register adapters
    Hive.registerAdapter(NoteAdapter());
    _box = await Hive.openBox<Note>(_boxName);
  }

  // CREATE
  Future<void> addNote(Note note) async {
    await _box.put(note.id, note);
  }

  // READ
  List<Note> getAllNotes() {
    return _box.values.toList();
  }

  List<Note> getActiveNotes() {
    return _box.values.where((note) => !note.isArchived).toList()
      ..sort((a, b) {
        if (a.isPinned == b.isPinned) {
          return b.modifiedAt.compareTo(a.modifiedAt);
        }
        return a.isPinned ? -1 : 1;
      });
  }

  List<Note> getArchivedNotes() {
    return _box.values.where((note) => note.isArchived).toList()
      ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
  }

  List<Note> searchNotes(String query) {
    final lowerQuery = query.toLowerCase();
    return _box.values.where((note) {
      final matchesSearch = note.title.toLowerCase().contains(lowerQuery) ||
          note.content.toLowerCase().contains(lowerQuery) ||
          note.tags.any((tag) => tag.toLowerCase().contains(lowerQuery));
      return matchesSearch && !note.isArchived;
    }).toList();
  }

  Note? getNoteById(String id) {
    return _box.get(id);
  }

  // UPDATE
  Future<void> updateNote(Note note) async {
    note.modifiedAt = DateTime.now();
    await _box.put(note.id, note);
  }

  // DELETE
  Future<void> deleteNote(String id) async {
    await _box.delete(id);
  }

  // Archive/Unarchive
  Future<void> toggleArchive(String id) async {
    final note = _box.get(id);
    if (note != null) {
      note.isArchived = !note.isArchived;
      await note.save();
    }
  }

  // Pin/Unpin
  Future<void> togglePin(String id) async {
    final note = _box.get(id);
    if (note != null) {
      note.isPinned = !note.isPinned;
      await note.save();
    }
  }

  // Close box
  Future<void> close() async {
    await _box.close();
  }
}