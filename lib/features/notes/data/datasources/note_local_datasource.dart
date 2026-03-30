import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_model.dart';

abstract class NoteLocalDataSource {
  List<NoteModel> getActiveNotes();
  List<NoteModel> getArchivedNotes();
  List<NoteModel> searchNotes(String query);
  NoteModel? getNoteById(String id);
  Future<void> saveNote(NoteModel note);
  Future<void> markDeleted(String id);
  Future<void> hardDelete(String id);
  List<NoteModel> getUnsyncedNotes();
}

class NoteLocalDataSourceImpl implements NoteLocalDataSource {
  final Box<NoteModel> _box;

  NoteLocalDataSourceImpl(this._box);

  @override
  List<NoteModel> getActiveNotes() {
    return _box.values
        .where((n) => !n.isArchived && n.syncStatus != NoteModelSyncStatus.deleted)
        .toList()
      ..sort((a, b) {
        if (a.isPinned == b.isPinned) return b.modifiedAt.compareTo(a.modifiedAt);
        return a.isPinned ? -1 : 1;
      });
  }

  @override
  List<NoteModel> getArchivedNotes() {
    return _box.values
        .where((n) => n.isArchived && n.syncStatus != NoteModelSyncStatus.deleted)
        .toList()
      ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
  }

  @override
  List<NoteModel> searchNotes(String query) {
    final q = query.toLowerCase();
    return _box.values.where((n) {
      return !n.isArchived &&
          n.syncStatus != NoteModelSyncStatus.deleted &&
          (n.title.toLowerCase().contains(q) ||
              n.content.toLowerCase().contains(q) ||
              n.tags.any((t) => t.toLowerCase().contains(q)));
    }).toList();
  }

  @override
  NoteModel? getNoteById(String id) => _box.get(id);

  @override
  Future<void> saveNote(NoteModel note) => _box.put(note.id, note);

  @override
  Future<void> markDeleted(String id) async {
    final note = _box.get(id);
    if (note != null) {
      note.syncStatus = NoteModelSyncStatus.deleted;
      await note.save();
    }
  }

  @override
  Future<void> hardDelete(String id) => _box.delete(id);

  @override
  List<NoteModel> getUnsyncedNotes() {
    return _box.values
        .where((n) =>
            n.syncStatus == NoteModelSyncStatus.pending ||
            n.syncStatus == NoteModelSyncStatus.modified ||
            n.syncStatus == NoteModelSyncStatus.deleted)
        .toList();
  }
}
