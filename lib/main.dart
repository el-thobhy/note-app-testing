import 'package:flutter/material.dart';
import 'package:note_app/providers/auth_providers.dart';
import 'package:note_app/providers/note_providers.dart';
import 'package:note_app/screen/splash_screen.dart';
import 'package:note_app/services/dio_client.dart';
import 'package:note_app/services/note_repository.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  // Initialize repository
  await NoteRepository().init();
  await AuthProvider().init();
  
  final noteProvider = NoteProvider();
  await noteProvider.loadNotes();
  
  // Init Dio
  DioClient().init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()..init()),  
        ChangeNotifierProvider(
          create: (_) => NoteProvider()..loadNotes(), // Load di sini
          lazy: false, // Pastikan langsung diinisialisasi
        ),
      ],
      child: MaterialApp(
        title: 'Note App',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF667EEA)),
        ),
        home: const SplashScreen(),
      ),
    );
  }
}
