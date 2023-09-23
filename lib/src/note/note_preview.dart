import 'package:flutter/material.dart';
import 'package:notes/src/note/note.dart';
import 'package:notes/src/note/note_details_view.dart';

class NotePreview extends StatelessWidget {
  const NotePreview({
    super.key,
    required this.note,
    this.maxContentLength = 200,
    this.maxTitleLength = 50,
    required this.onNoteUpdated,
    required this.onNoteDeleted,
    required this.onNoteFavorited,
  });

  final Note note;
  final int maxTitleLength;
  final int maxContentLength;
  final void Function(Note note) onNoteUpdated;
  final void Function(int id) onNoteDeleted;
  final void Function(int id) onNoteFavorited;

  @override
  Widget build(BuildContext context) {
    final String titlePreview = note.title.length < maxTitleLength
        ? note.title
        : "${note.title.substring(0, maxTitleLength)}...";

    // slice the content to a maximum length
    // or to the first double line break, whichever comes first
    final String contentPreview = (note.content.length < maxContentLength
        ? note.content.split("\n\n")[0]
        : "${note.content.substring(0, maxContentLength).split(RegExp(r'\n\s*\n'))[0].trimRight()}...");

    return InkWell(
        onTap: () => _navigate(context),
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(4),
            side: BorderSide(
              color: note.favorite
                  ? Theme.of(context).colorScheme.tertiaryContainer
                  : Colors.transparent,
              width: 2,
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(titlePreview,
                    style: Theme.of(context).textTheme.titleLarge),
                const SizedBox(height: 8),
                Text(contentPreview)
              ],
            ),
          ),
        ));
  }

  void _navigate(BuildContext context) =>
      Navigator.pushNamed(context, NoteDetailsView.routeName,
          arguments: NoteDetailsViewArgument(
              note: note,
              onNoteUpdated: onNoteUpdated,
              onNoteDeleted: onNoteDeleted,
              onNoteFavorited: onNoteFavorited));
}
