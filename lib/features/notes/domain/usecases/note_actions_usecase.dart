import '../entities/note_entity.dart';
import '../repositories/note_repository.dart';

class CreateNoteUseCase {
  final NoteRepository repository;
  CreateNoteUseCase(this.repository);
  Future<void> call(NoteEntity note) => repository.createNote(note);
}

class UpdateNoteUseCase {
  final NoteRepository repository;
  UpdateNoteUseCase(this.repository);
  Future<void> call(NoteEntity note) => repository.updateNote(note);
}

class DeleteNoteUseCase {
  final NoteRepository repository;
  DeleteNoteUseCase(this.repository);
  Future<void> call(String id) => repository.deleteNote(id);
}

class TogglePinUseCase {
  final NoteRepository repository;
  TogglePinUseCase(this.repository);
  Future<void> call(String id) => repository.togglePin(id);
}

class ToggleArchiveUseCase {
  final NoteRepository repository;
  ToggleArchiveUseCase(this.repository);
  Future<void> call(String id) => repository.toggleArchive(id);
}
