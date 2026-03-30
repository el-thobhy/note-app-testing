import 'package:flutter/material.dart';
import '../../domain/entities/note_entity.dart';
import '../../../../core/theme/app_theme.dart';

class NoteCard extends StatelessWidget {
  final NoteEntity note;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const NoteCard({
    super.key,
    required this.note,
    required this.onTap,
    required this.onPin,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'note_${note.id}',
      child: Material(
        color: Colors.transparent,
        child: GestureDetector(
          onTap: onTap,
          child: Container(
            decoration: BoxDecoration(
              color: note.color,
              borderRadius: BorderRadius.circular(20),
              boxShadow: [AppTheme.cardShadow],
            ),
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    note.isPinned
                        ? const Icon(Icons.push_pin,
                            size: 20, color: AppTheme.primaryColor)
                        : const SizedBox.shrink(),
                    _PopupMenu(
                        note: note,
                        onPin: onPin,
                        onArchive: onArchive,
                        onDelete: onDelete),
                  ],
                ),
                Text(
                  note.title,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Text(
                  note.content,
                  style: TextStyle(
                      fontSize: 14, color: Colors.grey[700], height: 1.5),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                if (note.tags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    children: note.tags.map((tag) => _Tag(tag: tag)).toList(),
                  ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(note.modifiedAt),
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) =>
      '${date.day}/${date.month}/${date.year}';
}

class NoteListTile extends StatelessWidget {
  final NoteEntity note;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const NoteListTile({
    super.key,
    required this.note,
    required this.onTap,
    required this.onPin,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: 'note_${note.id}',
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [AppTheme.cardShadow],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.all(16),
            leading: Container(
              width: 4,
              height: 50,
              decoration: BoxDecoration(
                color: note.color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            title: Text(note.title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, fontSize: 16)),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(note.content,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(color: Colors.grey[600])),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (note.isPinned)
                  const Icon(Icons.push_pin,
                      color: AppTheme.primaryColor, size: 20),
                _PopupMenu(
                    note: note,
                    onPin: onPin,
                    onArchive: onArchive,
                    onDelete: onDelete),
              ],
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

class NoteEmptyState extends StatelessWidget {
  const NoteEmptyState({super.key});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notes_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text('No notes yet',
              style: TextStyle(
                  fontSize: 20,
                  color: Colors.grey[400],
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Text('Tap + to create a new note',
              style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }
}

class _Tag extends StatelessWidget {
  final String tag;
  const _Tag({required this.tag});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(tag,
          style: const TextStyle(
              fontSize: 11,
              color: AppTheme.primaryColor,
              fontWeight: FontWeight.w500)),
    );
  }
}

class _PopupMenu extends StatelessWidget {
  final NoteEntity note;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const _PopupMenu({
    required this.note,
    required this.onPin,
    required this.onArchive,
    required this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
      onSelected: (value) {
        switch (value) {
          case 'pin':
            onPin();
          case 'archive':
            onArchive();
          case 'delete':
            onDelete();
        }
      },
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'pin',
          child: Row(children: [
            Icon(note.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
            const SizedBox(width: 8),
            Text(note.isPinned ? 'Unpin' : 'Pin'),
          ]),
        ),
        PopupMenuItem(
          value: 'archive',
          child: Row(children: [
            const Icon(Icons.archive),
            const SizedBox(width: 8),
            Text(note.isArchived ? 'Unarchive' : 'Archive'),
          ]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete, color: Colors.red),
            SizedBox(width: 8),
            Text('Delete', style: TextStyle(color: Colors.red)),
          ]),
        ),
      ],
    );
  }
}
