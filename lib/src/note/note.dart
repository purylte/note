class Note {
  const Note(
      {required this.id,
      required this.title,
      required this.content,
      required this.favorite});

  final int id;
  final String title;
  final String content;
  final bool favorite;

  copyWith({String? title, String? content, bool? favorite}) => Note(
        id: id,
        title: title ?? this.title,
        content: content ?? this.content,
        favorite: favorite ?? this.favorite,
      );
}
