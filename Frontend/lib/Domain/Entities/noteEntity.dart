import 'package:todo_notes/Data/Models/notesModel.dart';

class NoteEntity {
  final int id;
  final String title;
  final String content;
  final bool pinned;
  final String createdAt;

  NoteEntity({
    required this.id,
    required this.title,
    required this.content,
    required this.pinned,
    required this.createdAt,
  });

  NoteModel toNoteModel() {
    return NoteModel(
      title: title,
      content: content,
      pinned: pinned,
      createdAt: createdAt,
    );
  }

  NoteEntity copyWith({
    int? id,
    String? title,
    String? content,
    bool? pinned,
    String? createdAt,
  }) {
    return NoteEntity(
      id: id ?? this.id,
      title: title ?? this.title,
      content: content ?? this.content,
      pinned: pinned ?? this.pinned,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
