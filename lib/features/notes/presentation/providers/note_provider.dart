import 'package:flutter/material.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/usecases/get_notes_usecase.dart';
import '../../domain/usecases/note_actions_usecase.dart';

class NoteProvider extends ChangeNotifier {
  final GetActiveNotesUseCase _getActiveNotes;
  final GetArchivedNotesUseCase _getArchivedNotes;
  final SearchNotesUseCase _searchNotes;
  final CreateNoteUseCase _createNote;
  final UpdateNoteUseCase _updateNote;
  final DeleteNoteUseCase _deleteNote;
  final TogglePinUseCase _togglePin;
  final ToggleArchiveUseCase _toggleArchive;

  List<NoteEntity> _notes = [];
  List<NoteEntity> _archivedNotes = [];
  String _searchQuery = '';
  bool _isLoading = false;

  List<NoteEntity> get notes =>
      _searchQuery.isEmpty ? _notes : _searchNotes(_searchQuery);
  List<NoteEntity> get archivedNotes => _archivedNotes;
  bool get isLoading => _isLoading;

  NoteProvider({
    required GetActiveNotesUseCase getActiveNotes,
    required GetArchivedNotesUseCase getArchivedNotes,
    required SearchNotesUseCase searchNotes,
    required CreateNoteUseCase createNote,
    required UpdateNoteUseCase updateNote,
    required DeleteNoteUseCase deleteNote,
    required TogglePinUseCase togglePin,
    required ToggleArchiveUseCase toggleArchive,
  })  : _getActiveNotes = getActiveNotes,
        _getArchivedNotes = getArchivedNotes,
        _searchNotes = searchNotes,
        _createNote = createNote,
        _updateNote = updateNote,
        _deleteNote = deleteNote,
        _togglePin = togglePin,
        _toggleArchive = toggleArchive;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    _notes = _getActiveNotes();
    _archivedNotes = _getArchivedNotes();
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNote(NoteEntity note) async {
    await _createNote(note);
    await loadNotes();
  }

  Future<void> updateNote(NoteEntity note) async {
    await _updateNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _deleteNote(id);
    await loadNotes();
  }

  Future<void> togglePin(String id) async {
    await _togglePin(id);
    await loadNotes();
  }

  Future<void> toggleArchive(String id) async {
    await _toggleArchive(id);
    await loadNotes();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }
}
