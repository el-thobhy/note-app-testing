// repositories/note_repository.dart
import 'package:hive/hive.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/note_models.dart';
import '../services/dio_client.dart';

class NoteRepository {
  static final NoteRepository _instance = NoteRepository._internal();
  factory NoteRepository() => _instance;
  NoteRepository._internal();

  late Box<Note> _box;
  late Box<SyncStatus> _boxStatus;
  final _dio = DioClient();
  final _connectivity = Connectivity();

  Future<void> init() async {
    await Hive.initFlutter();
    // Register adapters
    Hive.registerAdapter(NoteAdapter());
    Hive.registerAdapter(SyncStatusAdapter());
    Hive.registerAdapter(UserCacheAdapter());

    _boxStatus = await Hive.openBox<SyncStatus>('sync_status');
    _box = await Hive.openBox<Note>('notes');
  }

  // ==================== LOCAL OPERATIONS ====================

  List<Note> getLocalNotes() {
    return _box.values
        .where((n) => n.syncStatus != SyncStatus.deleted)
        .toList()
      ..sort((a, b) {
        if (a.isPinned == b.isPinned) {
          return b.modifiedAt.compareTo(a.modifiedAt);
        }
        return a.isPinned ? -1 : 1;
      });
  }

  List<Note> getArchivedLocalNotes() {
    return _box.values
        .where((n) => n.isArchived && n.syncStatus != SyncStatus.deleted)
        .toList();
  }

  Future<void> saveLocal(Note note) async {
    await _box.put(note.id, note);
  }

  Future<void> deleteLocal(String id) async {
    final note = _box.get(id);
    if (note != null) {
      if (note.serverId != null) {
        note.syncStatus = SyncStatus.deleted;
        await note.save();
      } else {
        await _box.delete(id);
      }
    }
  }

  // ==================== SYNC OPERATIONS ====================

  Future<bool> hasInternet() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  Future<void> syncWithServer() async {
    if (!await hasInternet()) return;

    // 1. Push local changes
    await _pushLocalChanges();

    // 2. Pull from server
    await _pullFromServer();
  }

  Future<void> _pushLocalChanges() async {
    final unsynced = _box.values.where((n) =>
        n.syncStatus == SyncStatus.pending ||
        n.syncStatus == SyncStatus.modified ||
        n.syncStatus == SyncStatus.deleted).toList();

    for (final note in unsynced) {
      try {
        if (note.syncStatus == SyncStatus.deleted && note.serverId != null) {
          await _dio.deleteNote(note.serverId!);
          await _box.delete(note.id);
        } else if (note.serverId == null) {
          final response = await _dio.createNote(note.toJson());
          note.serverId = response.data['id'].toString();
          note.syncStatus = SyncStatus.synced;
          await note.save();
        } else {
          await _dio.updateNote(note.serverId!, note.toJson());
          note.syncStatus = SyncStatus.synced;
          await note.save();
        }
      } catch (e) {
        print('Sync failed for ${note.id}: $e');
      }
    }
  }

  Future<void> _pullFromServer() async {
    try {
      final response = await _dio.getNotes();
      final serverNotes = response.data as List;

      for (final serverNote in serverNotes) {
        final serverId = serverNote['id'].toString();
        final localNote = _box.values.firstWhere(
          (n) => n.serverId == serverId,
          orElse: () => null as Note,
        );

        if (localNote.syncStatus == SyncStatus.synced) {
          // Only update if local hasn't been modified
          final serverModified = DateTime.parse(serverNote['modifiedAt']);
          if (serverModified.isAfter(localNote.modifiedAt)) {
            final updated = Note.fromJson(serverNote)..id = localNote.id;
            await _box.put(localNote.id, updated);
          }
        }
      }
    } catch (e) {
      print('Pull failed: $e');
    }
  }

  // ==================== CRUD WITH AUTO-SYNC ====================

  Future<void> createNote(Note note) async {
    // Save local first (instant)
    note.syncStatus = SyncStatus.pending;
    await _box.put(note.id, note);

    // Try sync if online
    if (await hasInternet()) {
      try {
        final response = await _dio.createNote(note.toJson());
        note.serverId = response.data['id'].toString();
        note.syncStatus = SyncStatus.synced;
        await note.save();
      } catch (e) {
        // Keep as pending, will sync later
      }
    }
  }

  Future<void> updateNote(Note note) async {
    note.modifiedAt = DateTime.now();
    note.syncStatus = note.serverId == null ? SyncStatus.pending : SyncStatus.modified;
    await _box.put(note.id, note);

    if (await hasInternet() && note.serverId != null) {
      try {
        await _dio.updateNote(note.serverId!, note.toJson());
        note.syncStatus = SyncStatus.synced;
        await note.save();
      } catch (e) {
        // Keep as modified
      }
    }
  }

  Future<void> togglePin(String id) async {
    final note = _box.get(id);
    if (note != null) {
      note.isPinned = !note.isPinned;
      await updateNote(note);
    }
  }

  Future<void> toggleArchive(String id) async {
    final note = _box.get(id);
    if (note != null) {
      note.isArchived = !note.isArchived;
      await updateNote(note);
    }
  }

  Future<void> deleteNote(String id) async {
    final note = _box.get(id);
    if (note?.serverId != null && await hasInternet()) {
      try {
        await _dio.deleteNote(note!.serverId!);
        await _box.delete(id);
      } catch (e) {
        await deleteLocal(id);
      }
    } else {
      await deleteLocal(id);
    }
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

  List<Note> getArchivedNotes() {
    return _box.values.where((note) => note.isArchived).toList()
      ..sort((a, b) => b.modifiedAt.compareTo(a.modifiedAt));
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
   // CREATE
  Future<void> addNote(Note note) async {
    await _box.put(note.id, note);
  }
  Note? getNoteById(String id) => _box.get(id);
}