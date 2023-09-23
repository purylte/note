import 'package:flutter/material.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';
import 'package:notes/src/db.dart';

import '../settings/settings_view.dart';
import 'note.dart';
import 'note_preview.dart';

class NoteListView extends StatefulWidget {
  const NoteListView({
    super.key,
  });

  static const routeName = '/';

  @override
  State<NoteListView> createState() => _NoteListViewState();
}

class _NoteListViewState extends State<NoteListView> {
  List<Note> _notes = [];

  final Db db = Db();

  @override
  void initState() {
    super.initState();
    _refreshNotes();
  }

  void _refreshNotes() {
    db.getNotes().then((value) => setState(() {
          _notes = value;
        }));
  }

  void _addNote() {
    db
        .insertNote(
          title: 'New Note',
          content: 'This is a new note.',
        )
        .then((value) => _refreshNotes());
  }

  void _updateNote(Note note) {
    db
        .updateNoteById(
          id: note.id,
          title: note.title,
          content: note.content,
        )
        .then((value) => _refreshNotes());
  }

  void _deleteNoteById(int id) {
    db.deleteNoteById(id).then((value) => _refreshNotes());
  }

  void _favoriteNoteById(int id) {
    db.favoriteNoteById(id).then((value) => _refreshNotes());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Notes'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => _addNote(),
          ),
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.restorablePushNamed(context, SettingsView.routeName);
            },
          ),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(8),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) =>
              MasonryGridView.count(
            restorationId: 'noteListView',
            crossAxisCount: (constraints.maxWidth ~/ 250) + 1,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            itemCount: _notes.length,
            itemBuilder: (BuildContext context, int index) {
              final note = _notes[index];

              return NotePreview(
                  note: note,
                  onNoteUpdated: _updateNote,
                  onNoteDeleted: _deleteNoteById,
                  onNoteFavorited: _favoriteNoteById);
            },
          ),
        ),
      ),
    );
  }
}
