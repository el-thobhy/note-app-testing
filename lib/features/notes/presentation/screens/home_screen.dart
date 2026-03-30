import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../domain/entities/note_entity.dart';
import '../providers/note_provider.dart';
import '../widgets/note_card.dart';
import '../widgets/responsive_layout.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../features/auth/presentation/providers/auth_provider.dart';
import 'create_note_screen.dart';
import 'note_detail_screen.dart';
import 'archive_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';

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
      builder: (context, provider, _) => ResponsiveLayout(
        mobile: _buildMobileLayout(provider),
        tablet: _buildTabletLayout(provider),
        desktop: _buildDesktopLayout(provider),
      ),
    );
  }

  Widget _buildMobileLayout(NoteProvider provider) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      body: RefreshIndicator(
        onRefresh: provider.loadNotes,
        child: CustomScrollView(
          slivers: [
            _buildAppBar(),
            SliverToBoxAdapter(child: _buildSearchBar(provider)),
            if (provider.notes.isEmpty)
              const SliverFillRemaining(child: NoteEmptyState())
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
                Navigator.push(context,
                    MaterialPageRoute(builder: (_) => const ArchiveScreen()));
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
            ],
          ),
          Expanded(
            child: CustomScrollView(
              slivers: [
                _buildAppBar(),
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
                  Navigator.push(context,
                      MaterialPageRoute(builder: (_) => const ArchiveScreen()));
                }),
                const Spacer(),
                _buildSidebarItem(Icons.settings, 'Settings', false, () {}),
                _buildSidebarItem(Icons.logout, 'Logout', false, _logout),
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
                        ? const NoteEmptyState()
                        : GridView.builder(
                            gridDelegate:
                                const SliverGridDelegateWithFixedCrossAxisCount(
                              crossAxisCount: 4,
                              childAspectRatio: 0.8,
                              crossAxisSpacing: 16,
                              mainAxisSpacing: 16,
                            ),
                            itemCount: provider.notes.length,
                            itemBuilder: (_, index) {
                              final note = provider.notes[index];
                              return NoteCard(
                                note: note,
                                onTap: () => _openDetail(note),
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

  Widget _buildSliverGrid(List<NoteEntity> notes, {int crossAxisCount = 2}) {
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
          return NoteCard(
            note: note,
            onTap: () => _openDetail(note),
            onPin: () => context.read<NoteProvider>().togglePin(note.id),
            onArchive: () => context.read<NoteProvider>().toggleArchive(note.id),
            onDelete: () => _confirmDelete(note.id),
          );
        },
        childCount: notes.length,
      ),
    );
  }

  Widget _buildSliverList(List<NoteEntity> notes) {
    return SliverList(
      delegate: SliverChildBuilderDelegate(
        (context, index) {
          final note = notes[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: NoteListTile(
              note: note,
              onTap: () => _openDetail(note),
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

  Widget _buildAppBar() {
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
        IconButton(
          icon: const Icon(Icons.logout, color: AppTheme.textDark),
          tooltip: 'Logout',
          onPressed: _logout,
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
        final result = await Navigator.push<bool>(
          context,
          MaterialPageRoute(builder: (_) => const CreateNoteScreen()),
        );
        if (result == true && mounted) {
          context.read<NoteProvider>().loadNotes();
        }
      },
      backgroundColor: AppTheme.primaryColor,
      icon: const Icon(Icons.add),
      label: const Text('New Note'),
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

  Widget _buildSidebarItem(
      IconData icon, String label, bool isSelected, VoidCallback onTap) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isSelected
            ? AppTheme.primaryColor.withValues(alpha: 0.1)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(12),
      ),
      child: ListTile(
        leading: Icon(icon,
            color: isSelected ? AppTheme.primaryColor : AppTheme.textLight),
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
        IconButton(
          icon: Icon(isGridView ? Icons.view_list : Icons.grid_view),
          onPressed: () => setState(() => isGridView = !isGridView),
        ),
      ],
    );
  }

  Future<void> _logout() async {
    await context.read<AuthProvider>().logout();
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const LoginScreen()),
      (_) => false,
    );
  }

  void _openDetail(NoteEntity note) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => NoteDetailScreen(note: note)),
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
