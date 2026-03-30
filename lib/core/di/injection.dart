import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../features/auth/data/datasources/auth_remote_datasource.dart';
import '../../features/auth/data/repositories/auth_repository_impl.dart';
import '../../features/auth/domain/repositories/auth_repository.dart';
import '../../features/auth/domain/usecases/login_usecase.dart';
import '../../features/auth/domain/usecases/logout_usecase.dart';
import '../../features/auth/domain/usecases/register_usecase.dart';
import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/notes/data/datasources/note_local_datasource.dart';
import '../../features/notes/data/datasources/note_remote_datasource.dart';
import '../../features/notes/data/models/note_model.dart';
import '../../features/notes/data/repositories/note_repository_impl.dart';
import '../../features/notes/domain/repositories/note_repository.dart';
import '../../features/notes/domain/usecases/get_notes_usecase.dart';
import '../../features/notes/domain/usecases/note_actions_usecase.dart';
import '../../features/notes/presentation/providers/note_provider.dart';
import '../network/dio_client.dart';

class AppInjection {
  static late AuthProvider authProvider;
  static late NoteProvider noteProvider;

  static Future<void> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(NoteModelAdapter());
    Hive.registerAdapter(NoteModelSyncStatusAdapter());
    Hive.registerAdapter(UserCacheModelAdapter());

    // Open box — jika ada data lama yang incompatible, clear dulu
    Box<NoteModel> notesBox;
    try {
      notesBox = await Hive.openBox<NoteModel>('notes');
      // Validasi data dengan mencoba baca semua — deteksi incompatible cast
      final _ = notesBox.values.map((n) => n.syncStatus).toList();
    } catch (_) {
      await Hive.deleteBoxFromDisk('notes');
      notesBox = await Hive.openBox<NoteModel>('notes');
    }

    final dioClient = DioClient()..init();
    const storage = FlutterSecureStorage();
    final connectivity = Connectivity();

    // Auth
    final authDataSource = AuthRemoteDataSourceImpl(
      client: dioClient,
      storage: storage,
    );
    final AuthRepository authRepo = AuthRepositoryImpl(authDataSource);

    authProvider = AuthProvider(
      loginUseCase: LoginUseCase(authRepo),
      registerUseCase: RegisterUseCase(authRepo),
      logoutUseCase: LogoutUseCase(authRepo),
      authRepository: authRepo,
    );

    // Notes
    final noteLocalDs = NoteLocalDataSourceImpl(notesBox);
    final noteRemoteDs = NoteRemoteDataSourceImpl(dioClient);
    final NoteRepository noteRepo = NoteRepositoryImpl(
      local: noteLocalDs,
      remote: noteRemoteDs,
      connectivity: connectivity,
    );

    noteProvider = NoteProvider(
      getActiveNotes: GetActiveNotesUseCase(noteRepo),
      getArchivedNotes: GetArchivedNotesUseCase(noteRepo),
      searchNotes: SearchNotesUseCase(noteRepo),
      createNote: CreateNoteUseCase(noteRepo),
      updateNote: UpdateNoteUseCase(noteRepo),
      deleteNote: DeleteNoteUseCase(noteRepo),
      togglePin: TogglePinUseCase(noteRepo),
      toggleArchive: ToggleArchiveUseCase(noteRepo),
    );

    await noteProvider.loadNotes();
  }
}
