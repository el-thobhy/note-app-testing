// screens/note_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note_models.dart';
import '../providers/note_providers.dart';
import '../constants/app_theme.dart';
import 'create_note_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final Note note;

  const NoteDetailScreen({super.key, required this.note});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: note.color,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit, color: AppTheme.primaryColor),
            onPressed: () async {
              final result = await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CreateNoteScreen(note: note),
                ),
              );
              if (result == true) {
                context.read<NoteProvider>().loadNotes();
                Navigator.pop(context); // Return to home to refresh
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              final provider = context.read<NoteProvider>();
              switch (value) {
                case 'pin':
                  await provider.togglePin(note.id);
                  Navigator.pop(context);
                  break;
                case 'archive':
                  await provider.toggleArchive(note.id);
                  Navigator.pop(context);
                  break;
                case 'delete':
                  await provider.deleteNote(note.id);
                  Navigator.pop(context);
                  break;
              }
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'pin',
                child: Text(note.isPinned ? 'Unpin' : 'Pin'),
              ),
              PopupMenuItem(
                value: 'archive',
                child: Text(note.isArchived ? 'Unarchive' : 'Archive'),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Text('Delete', style: TextStyle(color: Colors.red)),
              ),
            ],
          ),
        ],
      ),
      body: Hero(
        tag: 'note_${note.id}',
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                note.title,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Created: ${_formatDate(note.createdAt)}',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                note.content,
                style: const TextStyle(
                  fontSize: 18,
                  color: AppTheme.textDark,
                  height: 1.8,
                ),
              ),
              const SizedBox(height: 24),
              if (note.tags.isNotEmpty)
                Wrap(
                  spacing: 8,
                  children: note.tags.map((tag) => Chip(
                    label: Text(tag),
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                  )).toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
  }
}