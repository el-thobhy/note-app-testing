import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/note_entity.dart';
import '../providers/note_provider.dart';
import '../../../../core/theme/app_theme.dart';
import 'create_note_screen.dart';

class NoteDetailScreen extends StatelessWidget {
  final NoteEntity note;
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
              final result = await Navigator.push<bool>(
                context,
                MaterialPageRoute(
                  builder: (_) => CreateNoteScreen(note: note),
                ),
              );
              if (result == true && context.mounted) {
                context.read<NoteProvider>().loadNotes();
                Navigator.pop(context);
              }
            },
          ),
          PopupMenuButton<String>(
            onSelected: (value) async {
              final provider = context.read<NoteProvider>();
              switch (value) {
                case 'pin':
                  await provider.togglePin(note.id);
                case 'archive':
                  await provider.toggleArchive(note.id);
                case 'delete':
                  await provider.deleteNote(note.id);
              }
              if (context.mounted) Navigator.pop(context);
            },
            itemBuilder: (_) => [
              PopupMenuItem(value: 'pin', child: Text(note.isPinned ? 'Unpin' : 'Pin')),
              PopupMenuItem(value: 'archive', child: Text(note.isArchived ? 'Unarchive' : 'Archive')),
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
                style: TextStyle(fontSize: 12, color: Colors.grey[600]),
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
                  children: note.tags
                      .map((tag) => Chip(
                            label: Text(tag),
                            backgroundColor:
                                AppTheme.primaryColor.withValues(alpha: 0.1),
                          ))
                      .toList(),
                ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year} ${date.hour}:${date.minute}';
}
