// screens/create_note_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/note_models.dart';
import '../providers/note_providers.dart';
import '../constants/app_theme.dart';

class CreateNoteScreen extends StatefulWidget {
  final Note? note;

  const CreateNoteScreen({super.key, this.note});

  @override
  State<CreateNoteScreen> createState() => _CreateNoteScreenState();
}

class _CreateNoteScreenState extends State<CreateNoteScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;
  late Color selectedColor;
  late List<String> tags;
  bool isPinned = false;

  final List<Color> availableColors = [
    Colors.white,
    const Color(0xFFFFE4E1), // Misty Rose
    const Color(0xFFE0F2F1), // Teal 50
    const Color(0xFFFFF9C4), // Yellow 100
    const Color(0xFFE1BEE7), // Purple 100
    const Color(0xFFBBDEFB), // Blue 100
    const Color(0xFFC8E6C9), // Green 100
    const Color(0xFFFFCCBC), // Deep Orange 100
  ];

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.note?.title);
    _contentController = TextEditingController(text: widget.note?.content);
    selectedColor = widget.note?.color ?? Colors.white;
    tags = List.from(widget.note?.tags ?? []);
    isPinned = widget.note?.isPinned ?? false;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: selectedColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppTheme.textDark),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(
              isPinned ? Icons.push_pin : Icons.push_pin_outlined,
              color: isPinned ? AppTheme.primaryColor : AppTheme.textDark,
            ),
            onPressed: () => setState(() => isPinned = !isPinned),
          ),
          TextButton(
            onPressed: _saveNote,
            child: const Text(
              'Save',
              style: TextStyle(
                color: AppTheme.primaryColor,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                children: [
                  TextField(
                    controller: _titleController,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Title',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                  const SizedBox(height: 16),
                  TextField(
                    controller: _contentController,
                    maxLines: null,
                    style: const TextStyle(
                      fontSize: 18,
                      color: AppTheme.textDark,
                      height: 1.6,
                    ),
                    decoration: const InputDecoration(
                      hintText: 'Start typing your note...',
                      border: InputBorder.none,
                      hintStyle: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ),
            ),
          ),
          _buildBottomToolbar(),
        ],
      ),
    );
  }

  Widget _buildBottomToolbar() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: [
                  ...availableColors.map((color) => GestureDetector(
                    onTap: () => setState(() => selectedColor = color),
                    child: Container(
                      width: 40,
                      height: 40,
                      margin: const EdgeInsets.only(right: 12),
                      decoration: BoxDecoration(
                        color: color,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: selectedColor == color 
                              ? AppTheme.primaryColor 
                              : Colors.grey[300]!,
                          width: 2,
                        ),
                        boxShadow: selectedColor == color 
                            ? [AppTheme.cardShadow] 
                            : null,
                      ),
                    ),
                  )),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.label_outlined),
                  onPressed: _showTagDialog,
                ),
                if (tags.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: Wrap(
                      spacing: 8,
                      children: tags.map((tag) => Chip(
                        label: Text(tag),
                        onDeleted: () => setState(() => tags.remove(tag)),
                        backgroundColor: AppTheme.primaryColor.withOpacity(0.1),
                        side: BorderSide.none,
                      )).toList(),
                    ),
                  ),
                ],
                const Spacer(),
                Text(
                  'Edited ${_formatDate(DateTime.now())}',
                  style: TextStyle(color: Colors.grey[500], fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showTagDialog() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Add Tag'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(
            hintText: 'Enter tag name',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                setState(() => tags.add(controller.text));
              }
              Navigator.pop(context);
            },
            child: const Text('Add'),
          ),
        ],
      ),
    );
  }

  Future<void> _saveNote() async {
    if (_titleController.text.isEmpty && _contentController.text.isEmpty) {
      Navigator.pop(context);
      return;
    }

    final provider = context.read<NoteProvider>();
    
    if (widget.note != null) {
      // Update existing
      final updatedNote = widget.note!.copyWith(
        title: _titleController.text,
        content: _contentController.text,
        color: selectedColor,
        tags: tags,
        isPinned: isPinned,
      );
      await provider.updateNote(updatedNote);
    } else {
      // Create new
      final newNote = Note(
        title: _titleController.text,
        content: _contentController.text,
        color: selectedColor,
        tags: tags,
        isPinned: isPinned,
      );
      await provider.addNote(newNote);
    }

    if (mounted) {
      Navigator.pop(context, true);
    }
  }

  String _formatDate(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }
}