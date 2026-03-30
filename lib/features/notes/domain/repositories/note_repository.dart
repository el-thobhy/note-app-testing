import '../entities/note_entity.dart';

abstract class NoteRepository {
  List<NoteEntity> getActiveNotes();
  List<NoteEntity> getArchivedNotes();
  List<NoteEntity> searchNotes(String query);
  NoteEntity? getNoteById(String id);
  Future<void> createNote(NoteEntity note);
  Future<void> updateNote(NoteEntity note);
  Future<void> deleteNote(String id);
  Future<void> togglePin(String id);
  Future<void> toggleArchive(String id);
  Future<void> syncWithServer();
}
