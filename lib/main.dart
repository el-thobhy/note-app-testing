import 'package:flutter/material.dart';
import 'package:note_app/providers/note_providers.dart';
import 'package:note_app/screen/home_screen.dart';
import 'package:note_app/services/note_repository.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  
  // Initialize repository
  await NoteRepository().init();
  
  final noteProvider = NoteProvider();
  await noteProvider.loadNotes();
  
  runApp(
    ChangeNotifierProvider.value(
      value: noteProvider,
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      home: const HomeScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}
