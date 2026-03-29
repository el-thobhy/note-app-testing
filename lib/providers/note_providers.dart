// providers/note_provider.dart
import 'package:flutter/material.dart';
import '../models/note_models.dart';
import '../services/note_repository.dart';

class NoteProvider extends ChangeNotifier {
  final NoteRepository _repository = NoteRepository();
  
  List<Note> _notes = [];
  List<Note> _archivedNotes = [];
  String _searchQuery = '';
  bool _isLoading = false;

  // Getters
  List<Note> get notes => _searchQuery.isEmpty 
      ? _notes 
      : _repository.searchNotes(_searchQuery);
  
  List<Note> get archivedNotes => _archivedNotes;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;

  Future<void> loadNotes() async {
    _isLoading = true;
    notifyListeners();
    
    _notes = _repository.getActiveNotes();
    _archivedNotes = _repository.getArchivedNotes();
    
    _isLoading = false;
    notifyListeners();
  }

  Future<void> addNote(Note note) async {
    await _repository.addNote(note);
    await loadNotes();
  }

  Future<void> updateNote(Note note) async {
    await _repository.updateNote(note);
    await loadNotes();
  }

  Future<void> deleteNote(String id) async {
    await _repository.deleteNote(id);
    await loadNotes();
  }

  Future<void> togglePin(String id) async {
    await _repository.togglePin(id);
    await loadNotes();
  }

  Future<void> toggleArchive(String id) async {
    await _repository.toggleArchive(id);
    await loadNotes();
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  Note? getNoteById(String id) {
    return _repository.getNoteById(id);
  }
}