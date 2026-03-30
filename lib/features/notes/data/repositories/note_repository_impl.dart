import 'package:connectivity_plus/connectivity_plus.dart';
import '../../domain/entities/note_entity.dart';
import '../../domain/repositories/note_repository.dart';
import '../datasources/note_local_datasource.dart';
import '../datasources/note_remote_datasource.dart';
import '../models/note_model.dart';

class NoteRepositoryImpl implements NoteRepository {
  final NoteLocalDataSource _local;
  final NoteRemoteDataSource _remote;
  final Connectivity _connectivity;

  NoteRepositoryImpl({
    required NoteLocalDataSource local,
    required NoteRemoteDataSource remote,
    required Connectivity connectivity,
  })  : _local = local,
        _remote = remote,
        _connectivity = connectivity;

  Future<bool> _hasInternet() async {
    final result = await _connectivity.checkConnectivity();
    return result != ConnectivityResult.none;
  }

  @override
  List<NoteEntity> getActiveNotes() =>
      _local.getActiveNotes().map((m) => m.toEntity()).toList();

  @override
  List<NoteEntity> getArchivedNotes() =>
      _local.getArchivedNotes().map((m) => m.toEntity()).toList();

  @override
  List<NoteEntity> searchNotes(String query) =>
      _local.searchNotes(query).map((m) => m.toEntity()).toList();

  @override
  NoteEntity? getNoteById(String id) => _local.getNoteById(id)?.toEntity();

  @override
  Future<void> createNote(NoteEntity entity) async {
    final model = NoteModel.fromEntity(entity);
    model.syncStatus = NoteModelSyncStatus.pending;
    await _local.saveNote(model);

    if (await _hasInternet()) {
      try {
        final serverId = await _remote.createNote(model);
        model.serverId = serverId;
        model.syncStatus = NoteModelSyncStatus.synced;
        await _local.saveNote(model);
      } catch (_) {}
    }
  }

  @override
  Future<void> updateNote(NoteEntity entity) async {
    final model = NoteModel.fromEntity(entity);
    model.modifiedAt = DateTime.now();
    model.syncStatus = model.serverId == null
        ? NoteModelSyncStatus.pending
        : NoteModelSyncStatus.modified;
    await _local.saveNote(model);

    if (await _hasInternet() && model.serverId != null) {
      try {
        await _remote.updateNote(model);
        model.syncStatus = NoteModelSyncStatus.synced;
        await _local.saveNote(model);
      } catch (_) {}
    }
  }

  @override
  Future<void> deleteNote(String id) async {
    final model = _local.getNoteById(id);
    if (model == null) return;

    if (model.serverId != null && await _hasInternet()) {
      try {
        await _remote.deleteNote(model.serverId!);
        await _local.hardDelete(id);
        return;
      } catch (_) {}
    }

    if (model.serverId != null) {
      await _local.markDeleted(id);
    } else {
      await _local.hardDelete(id);
    }
  }

  @override
  Future<void> togglePin(String id) async {
    final model = _local.getNoteById(id);
    if (model == null) return;
    final updated = model.toEntity().copyWith(isPinned: !model.isPinned);
    await updateNote(updated);
  }

  @override
  Future<void> toggleArchive(String id) async {
    final model = _local.getNoteById(id);
    if (model == null) return;
    final updated = model.toEntity().copyWith(isArchived: !model.isArchived);
    await updateNote(updated);
  }

  @override
  Future<void> syncWithServer() async {
    if (!await _hasInternet()) return;
    await _pushLocalChanges();
    await _pullFromServer();
  }

  Future<void> _pushLocalChanges() async {
    for (final model in _local.getUnsyncedNotes()) {
      try {
        if (model.syncStatus == NoteModelSyncStatus.deleted && model.serverId != null) {
          await _remote.deleteNote(model.serverId!);
          await _local.hardDelete(model.id);
        } else if (model.serverId == null) {
          final serverId = await _remote.createNote(model);
          model.serverId = serverId;
          model.syncStatus = NoteModelSyncStatus.synced;
          await _local.saveNote(model);
        } else {
          await _remote.updateNote(model);
          model.syncStatus = NoteModelSyncStatus.synced;
          await _local.saveNote(model);
        }
      } catch (_) {}
    }
  }

  Future<void> _pullFromServer() async {
    try {
      final serverNotes = await _remote.getNotes();
      for (final serverNote in serverNotes) {
        final localNote = _local.getActiveNotes().cast<NoteModel?>().firstWhere(
              (n) => n?.serverId == serverNote.serverId,
              orElse: () => null,
            );

        if (localNote == null) {
          await _local.saveNote(serverNote);
        } else if (localNote.syncStatus == NoteModelSyncStatus.synced &&
            serverNote.modifiedAt.isAfter(localNote.modifiedAt)) {
          serverNote.id = localNote.id;
          await _local.saveNote(serverNote);
        }
      }
    } catch (_) {}
  }
}
