import '../../../../core/network/dio_client.dart';
import '../models/note_model.dart';

abstract class NoteRemoteDataSource {
  Future<List<NoteModel>> getNotes();
  Future<String> createNote(NoteModel note);
  Future<void> updateNote(NoteModel note);
  Future<void> deleteNote(String serverId);
}

class NoteRemoteDataSourceImpl implements NoteRemoteDataSource {
  final DioClient _client;

  NoteRemoteDataSourceImpl(this._client);

  @override
  Future<List<NoteModel>> getNotes() async {
    final response = await _client.getNotes();
    return (response.data as List).map((e) => NoteModel.fromJson(e)).toList();
  }

  @override
  Future<String> createNote(NoteModel note) async {
    final response = await _client.createNote(note.toJson());
    return response.data['id'].toString();
  }

  @override
  Future<void> updateNote(NoteModel note) =>
      _client.updateNote(note.serverId!, note.toJson());

  @override
  Future<void> deleteNote(String serverId) => _client.deleteNote(serverId);
}
