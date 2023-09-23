import 'dart:async';

import 'package:flutter/material.dart';
import 'package:notes/src/note/note.dart';

class NoteDetailsViewArgument {
  final Note note;
  final void Function(Note note) onNoteUpdated;
  final void Function(int id) onNoteDeleted;
  final void Function(int id) onNoteFavorited;

  NoteDetailsViewArgument({
    required this.note,
    required this.onNoteUpdated,
    required this.onNoteDeleted,
    required this.onNoteFavorited,
  });
}

class NoteDetailsView extends StatefulWidget {
  const NoteDetailsView(
      {super.key,
      required this.note,
      required this.onNoteUpdated,
      required this.onNoteDeleted,
      required this.onNoteFavorited});

  static const routeName = '/note_details';

  final Note note;
  final void Function(Note note) onNoteUpdated;
  final void Function(int id) onNoteDeleted;
  final void Function(int id) onNoteFavorited;

  @override
  State<NoteDetailsView> createState() => _NoteDetailsViewState();
}

class _NoteDetailsViewState extends State<NoteDetailsView> {
  final _titleController = TextEditingController();
  final _contentController = TextEditingController();
  Timer? _debounce;
  bool? _isFavorite;

  void _updateNote() async {
    widget.onNoteUpdated(widget.note.copyWith(
      title: _titleController.text,
      content: _contentController.text,
    ));
  }

  void _onTitleChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _updateNote();
    });
  }

  void _onContentChanged() {
    if (_debounce?.isActive ?? false) _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _updateNote();
    });
  }

  void _onFavorite() {
    widget.onNoteFavorited(widget.note.id);
    setState(() {
      _isFavorite = !_isFavorite!;
    });
  }

  void _onNoteDeleted() {
    widget.onNoteDeleted(widget.note.id);
    Navigator.pop(context);
  }

  @override
  void initState() {
    super.initState();
    _titleController.text = widget.note.title;
    _contentController.text = widget.note.content;
    _isFavorite = widget.note.favorite;
  }

  @override
  void dispose() {
    _titleController.dispose();
    _contentController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        actions: [
          IconButton(
              onPressed: () => _onFavorite(),
              icon: Icon((_isFavorite ?? false)
                  ? Icons.favorite
                  : Icons.favorite_border)),
          IconButton(
              onPressed: () => _onNoteDeleted(),
              icon: const Icon(Icons.delete)),
        ],
      ),
      body: Container(
        margin: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
                controller: _titleController,
                onChanged: (_) => _onTitleChanged(),
                textAlign: TextAlign.center,
                keyboardType: TextInputType.text,
                minLines: 1,
                maxLines: 2,
                style: Theme.of(context).textTheme.titleLarge,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                )),
            const Divider(
              height: 32,
              thickness: 1,
            ),
            Expanded(
              child: TextField(
                  controller: _contentController,
                  onChanged: (_) => _onContentChanged(),
                  textAlign: TextAlign.justify,
                  keyboardType: TextInputType.multiline,
                  maxLines: null,
                  decoration: const InputDecoration(
                    border: InputBorder.none,
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
