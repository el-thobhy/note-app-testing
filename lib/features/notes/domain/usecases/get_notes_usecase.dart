import '../entities/note_entity.dart';
import '../repositories/note_repository.dart';

class GetActiveNotesUseCase {
  final NoteRepository repository;
  GetActiveNotesUseCase(this.repository);
  List<NoteEntity> call() => repository.getActiveNotes();
}

class GetArchivedNotesUseCase {
  final NoteRepository repository;
  GetArchivedNotesUseCase(this.repository);
  List<NoteEntity> call() => repository.getArchivedNotes();
}

class SearchNotesUseCase {
  final NoteRepository repository;
  SearchNotesUseCase(this.repository);
  List<NoteEntity> call(String query) => repository.searchNotes(query);
}
