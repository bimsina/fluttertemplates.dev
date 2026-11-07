import 'package:flutter/material.dart';

class NotesApp extends StatefulWidget {
  const NotesApp({super.key});

  @override
  State<NotesApp> createState() => _NotesAppState();
}

class _NotesAppState extends State<NotesApp> {
  final List<Map<String, dynamic>> _notes = [
    {
      'title': 'Shopping List',
      'content': 'Milk, Eggs, Bread, Butter, Cheese',
      'color': Colors.blue,
      'date': 'Today',
    },
    {
      'title': 'Meeting Notes',
      'content': 'Discuss Q1 goals and timeline...',
      'color': Colors.purple,
      'date': 'Yesterday',
    },
    {
      'title': 'Project Ideas',
      'content': 'Build a Flutter app for task management...',
      'color': Colors.orange,
      'date': 'Mar 1',
    },
    {
      'title': 'Book Recommendations',
      'content': 'Clean Code, Design Patterns, Refactoring...',
      'color': Colors.green,
      'date': 'Feb 28',
    },
    {
      'title': 'Travel Plans',
      'content': 'Visit Japan, See cherry blossoms...',
      'color': Colors.red,
      'date': 'Feb 25',
    },
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Notes'),
        backgroundColor: isDark ? Colors.grey[900] : Colors.blue[700],
        foregroundColor: Colors.white,
        actions: [
          IconButton(tooltip: 'Search', icon: const Icon(Icons.search), onPressed: () => _showDemo(context, 'Search (demo)')),
          IconButton(tooltip: 'Change layout', icon: const Icon(Icons.grid_view), onPressed: () => _showDemo(context, 'Change layout (demo)')),
        ],
      ),
      body: _notes.isEmpty
          ? const Center(child: Text('No notes yet'))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: _notes.length,
              itemBuilder: (context, index) {
                final note = _notes[index];
                return _buildNoteCard(context, note, isDark);
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openNoteSheet(context, isDark),
        backgroundColor: Colors.blue,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }

  Widget _buildNoteCard(
    BuildContext context,
    Map<String, dynamic> note,
    bool isDark,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? Colors.grey[800] : Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 6,
            decoration: BoxDecoration(
              color: note['color'],
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(16),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Text(
                        note['title'],
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    PopupMenuButton<String>(
                      icon: Icon(
                        Icons.more_vert,
                        color: isDark ? Colors.white54 : Colors.grey[400],
                      ),
                      onSelected: (action) {
                        if (action == 'edit') {
                          _openNoteSheet(context, isDark, note: note);
                        } else {
                          setState(() => _notes.remove(note));
                        }
                      },
                      itemBuilder: (context) => [
                        const PopupMenuItem(value: 'edit', child: Text('Edit')),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Text('Delete'),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  note['content'],
                  style: TextStyle(
                    color: isDark ? Colors.white54 : Colors.grey[600],
                    fontSize: 14,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                Text(
                  note['date'],
                  style: TextStyle(
                    color: isDark ? Colors.white38 : Colors.grey[400],
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openNoteSheet(
    BuildContext context,
    bool isDark, {
    Map<String, dynamic>? note,
  }) async {
    final result = await showModalBottomSheet<({String title, String content})>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _NoteSheet(isDark: isDark, note: note),
    );
    if (result == null || !mounted) return;

    setState(() {
      if (note != null) {
        note['title'] = result.title;
        note['content'] = result.content;
      } else {
        _notes.insert(0, {
          'title': result.title,
          'content': result.content,
          'color': Colors.primaries[_notes.length % Colors.primaries.length],
          'date': 'Today',
        });
      }
    });
  }
}

/// Owns the text controllers so they are disposed with the sheet.
class _NoteSheet extends StatefulWidget {
  final bool isDark;
  final Map<String, dynamic>? note;

  const _NoteSheet({required this.isDark, this.note});

  @override
  State<_NoteSheet> createState() => _NoteSheetState();
}

class _NoteSheetState extends State<_NoteSheet> {
  late final _titleController = TextEditingController(
    text: widget.note?['title'] as String?,
  );
  late final _contentController = TextEditingController(
    text: widget.note?['content'] as String?,
  );

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  void _save() {
    final title = _titleController.text.trim();
    final content = _contentController.text.trim();
    if (title.isEmpty && content.isEmpty) {
      Navigator.pop(context);
      return;
    }
    Navigator.pop(context, (
      title: title.isEmpty ? 'Untitled' : title,
      content: content,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: widget.isDark ? Colors.grey[900] : Colors.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: EdgeInsets.only(
        left: 20,
        right: 20,
        top: 20,
        bottom: MediaQuery.of(context).viewInsets.bottom + 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[400],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Text(
            widget.note == null ? 'New Note' : 'Edit Note',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          TextField(
            controller: _titleController,
            decoration: InputDecoration(
              hintText: 'Title',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: TextField(
              controller: _contentController,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              decoration: InputDecoration(
                hintText: 'Start writing...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _save,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Save Note',
                style: TextStyle(color: Colors.white, fontSize: 16),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void _showDemo(BuildContext context, String message) {
  ScaffoldMessenger.of(context)
    ..hideCurrentSnackBar()
    ..showSnackBar(SnackBar(content: Text(message)));
}
