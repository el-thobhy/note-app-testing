// screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:note_app/models/note_models.dart';
import 'package:note_app/providers/note_providers.dart';
import 'package:provider/provider.dart';
import '../constants/app_theme.dart';
import 'create_note_screen.dart';
import 'note_detail_screen.dart';
import 'archive_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isGridView = true;
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Consumer<NoteProvider>(
      builder: (context, provider, child) {
        return ResponsiveLayout(
          mobile: _buildMobileLayout(provider),
          tablet: _buildTabletLayout(provider),
          desktop: _buildDesktopLayout(provider),
        );
      },
    );
  }

  Widget _buildMobileLayout(NoteProvider provider) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: RefreshIndicator(
        onRefresh: () => provider.loadNotes(),
        child: CustomScrollView(
          slivers: [
            _buildModernAppBar(),
            SliverToBoxAdapter(
              child: _buildSearchBar(provider),
            ),
            if (provider.notes.isEmpty)
              const SliverFillRemaining(child: _EmptyState())
            else
              SliverPadding(
                padding: const EdgeInsets.all(16),
                sliver: isGridView 
                  ? _buildSliverGrid(provider.notes)
                  : _buildSliverList(provider.notes),
              ),
          ],
        ),
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildTabletLayout(NoteProvider provider) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          NavigationRail(
            extended: true,
            backgroundColor: Colors.white,
            selectedIndex: selectedIndex,
            onDestinationSelected: (index) {
              setState(() => selectedIndex = index);
              if (index == 1) {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ArchiveScreen()),
                );
              }
            },
            destinations: const [
              NavigationRailDestination(
                icon: Icon(Icons.note_outlined),
                selectedIcon: Icon(Icons.note),
                label: Text('Notes'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.archive_outlined),
                selectedIcon: Icon(Icons.archive),
                label: Text('Archive'),
              ),
              NavigationRailDestination(
                icon: Icon(Icons.settings_outlined),
                selectedIcon: Icon(Icons.settings),
                label: Text('Settings'),
              ),
            ],
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildModernAppBar(),
                SliverPadding(
                  padding: const EdgeInsets.all(24),
                  sliver: _buildSliverGrid(provider.notes, crossAxisCount: 3),
                ),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildDesktopLayout(NoteProvider provider) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: Row(
        children: [
          Container(
            width: 280,
            color: Colors.white,
            child: Column(
              children: [
                const SizedBox(height: 48),
                _buildSidebarHeader(),
                const SizedBox(height: 32),
                _buildSidebarItem(Icons.note, 'All Notes', true, () {}),
                _buildSidebarItem(Icons.archive, 'Archive', false, () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ArchiveScreen()),
                  );
                }),
                _buildSidebarItem(Icons.delete, 'Trash', false, () {}),
                const Spacer(),
                _buildSidebarItem(Icons.settings, 'Settings', false, () {}),
                const SizedBox(height: 24),
              ],
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDesktopHeader(provider),
                  const SizedBox(height: 24),
                  Expanded(
                    child: provider.notes.isEmpty
                        ? const _EmptyState()
                        : GridView.builder(
                            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: provider.notes.length,
                            itemBuilder: (context, index) {
                              final note = provider.notes[index];
                              return _NoteCard(
                                note: note,
                                onTap: () => _openNoteDetail(note),
                                onPin: () => provider.togglePin(note.id),
                                onArchive: () => provider.toggleArchive(note.id),
                                onDelete: () => _confirmDelete(note.id),
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: _buildFAB(),
    );
  }

  Widget _buildSliverGrid(List<Note> notes, {int crossAxisCount = 2}) {
    return SliverGrid(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: 0.8,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final note = notes[index];
          return _NoteCard(
            note: note,
            onTap: () => _openNoteDetail(note),
            onPin: () => context.read<NoteProvider>().togglePin(note.id),
            onArchive: () => context.read<NoteProvider>().toggleArchive(note.id),
            onDelete: () => _confirmDelete(note.id),
          );
        },
        childCount: notes.length,
      ),
    );
  }

  Widget _buildSliverList(List<Note> notes) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final note = notes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: _NoteListTile(
              note: note,
              onTap: () => _openNoteDetail(note),
              onPin: () => context.read<NoteProvider>().togglePin(note.id),
              onArchive: () => context.read<NoteProvider>().toggleArchive(note.id),
              onDelete: () => _confirmDelete(note.id),
            ),
          );
        },
        childCount: notes.length,
      ),
    );
  }

  Widget _buildModernAppBar() {
    return SliverAppBar(
      floating: true,
      backgroundColor: AppTheme.backgroundColor,
      elevation: 0,
      title: const Text(
        'My Notes',
        style: TextStyle(
          color: AppTheme.textDark,
          fontWeight: FontWeight.bold,
          fontSize: 32,
        ),
      ),
      actions: [
        IconButton(
          icon: Icon(
            isGridView ? Icons.view_list : Icons.grid_view,
            color: AppTheme.textDark,
          ),
          onPressed: () => setState(() => isGridView = !isGridView),
        ),
        const SizedBox(width: 8),
      ],
    );
  }

  Widget _buildSearchBar(NoteProvider provider) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [AppTheme.cardShadow],
        ),
        child: TextField(
          onChanged: provider.setSearchQuery,
          decoration: InputDecoration(
            hintText: 'Search notes...',
            hintStyle: TextStyle(color: Colors.grey[400]),
            prefixIcon: const Icon(Icons.search, color: AppTheme.primaryColor),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.all(16),
          ),
        ),
      ),
    );
  }

  Widget _buildFAB() {
    return FloatingActionButton.extended(
      onPressed: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateNoteScreen()),
        );
        if (result == true) {
          context.read<NoteProvider>().loadNotes();
        }
      },
      backgroundColor: AppTheme.primaryColor,
      icon: const Icon(Icons.add),
      label: const Text('New Note'),
      elevation: 4,
    );
  }

  Widget _buildSidebarHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.primaryColor, AppTheme.secondaryColor],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(Icons.notes, color: Colors.white),
          ),
          const SizedBox(width: 16),
          const Text(
            'NoteApp',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSidebarItem(IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected ? AppTheme.primaryColor.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isSelected ? AppTheme.primaryColor : AppTheme.textLight,
        ),
        title: Text(
          label,
          style: TextStyle(
            color: isSelected ? AppTheme.primaryColor : AppTheme.textDark,
            fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        onTap: onTap,
      ),
    );
  }

  Widget _buildDesktopHeader(NoteProvider provider) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'All Notes (${provider.notes.length})',
          style: const TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: AppTheme.textDark,
          ),
        ),
        Row(
          children: [
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {},
            ),
            const SizedBox(width: 8),
            IconButton(
              icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
              onPressed: () => setState(() => isGridView = !isGridView),
            ),
          ],
        ),
      ],
    );
  }

  void _openNoteDetail(Note note) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => NoteDetailScreen(note: note),
      ),
    );
  }

  void _confirmDelete(String id) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Note'),
        content: const Text('Are you sure you want to delete this note?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              context.read<NoteProvider>().deleteNote(id);
              Navigator.pop(context);
            },
            child: const Text('Delete', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }
}

// RESPONSIVE LAYOUT
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    super.key,
    required this.mobile,
    this.tablet,
    this.desktop,
  });

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 1100 && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= 650 && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}

// NOTE CARD dengan Action Menu
class _NoteCard extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const _NoteCard({
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
                    note.isPinned ?
                      const Icon(Icons.push_pin, size: 20, color: AppTheme.primaryColor)
                    :
                      const SizedBox.shrink(),
                    _buildPopupMenu(),
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
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                  maxLines: 4,
                  overflow: TextOverflow.ellipsis,
                ),
                const Spacer(),
                if (note.tags.isNotEmpty)
                  Wrap(
                    spacing: 6,
                    children: note.tags.map((tag) => _buildTag(tag)).toList(),
                  ),
                const SizedBox(height: 8),
                Text(
                  _formatDate(note.modifiedAt),
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPopupMenu() {
    return PopupMenuButton<String>(
      icon: const Icon(Icons.more_vert, size: 20, color: Colors.grey),
      onSelected: (value) {
        switch (value) {
          case 'pin':
            onPin();
            break;
          case 'archive':
            onArchive();
            break;
          case 'delete':
            onDelete();
            break;
        }
      },
      itemBuilder: (context) => [
        PopupMenuItem(
          value: 'pin',
          child: Row(
            children: [
              Icon(note.isPinned ? Icons.push_pin_outlined : Icons.push_pin),
              const SizedBox(width: 8),
              Text(note.isPinned ? 'Unpin' : 'Pin'),
            ],
          ),
        ),
        PopupMenuItem(
          value: 'archive',
          child: Row(
            children: [
              const Icon(Icons.archive),
              const SizedBox(width: 8),
              Text(note.isArchived ? 'Unarchive' : 'Archive'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(
            children: [
              Icon(Icons.delete, color: Colors.red),
              SizedBox(width: 8),
              Text('Delete', style: TextStyle(color: Colors.red)),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildTag(String tag) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        tag,
        style: const TextStyle(
          fontSize: 11,
          color: AppTheme.primaryColor,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }
}

// NOTE LIST TILE
class _NoteListTile extends StatelessWidget {
  final Note note;
  final VoidCallback onTap;
  final VoidCallback onPin;
  final VoidCallback onArchive;
  final VoidCallback onDelete;

  const _NoteListTile({
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
            title: Text(
              note.title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 8),
              child: Text(
                note.content,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(color: Colors.grey[600]),
              ),
            ),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (note.isPinned)
                  const Icon(Icons.push_pin, color: AppTheme.primaryColor, size: 20),
                PopupMenuButton<String>(
                  onSelected: (value) {
                    switch (value) {
                      case 'pin':
                        onPin();
                        break;
                      case 'archive':
                        onArchive();
                        break;
                      case 'delete':
                        onDelete();
                        break;
                    }
                  },
                  itemBuilder: (context) => [
                    PopupMenuItem(value: 'pin', child: Text(note.isPinned ? 'Unpin' : 'Pin')),
                    PopupMenuItem(value: 'archive', child: Text(note.isArchived ? 'Unarchive' : 'Archive')),
                    const PopupMenuItem(value: 'delete', child: Text('Delete', style: TextStyle(color: Colors.red))),
                  ],
                ),
              ],
            ),
            onTap: onTap,
          ),
        ),
      ),
    );
  }
}

// EMPTY STATE
class _EmptyState extends StatelessWidget {
  const _EmptyState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.notes_outlined, size: 80, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No notes yet',
            style: TextStyle(fontSize: 20, color: Colors.grey[400], fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 8),
          Text('Tap + to create a new note', style: TextStyle(color: Colors.grey[400])),
        ],
      ),
    );
  }
}