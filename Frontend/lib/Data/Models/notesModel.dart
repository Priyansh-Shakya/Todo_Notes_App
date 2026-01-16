import 'package:todo_notes/Domain/Entities/noteEntity.dart';

class NoteModel {
  int? id;
  String? title;
  String? content;
  bool? pinned;
  String? createdAt;

  NoteModel({this.id, this.title, this.content, this.pinned, this.createdAt});

  NoteModel.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    title = json['title'];
    content = json['content'];
    pinned = json['isPinned'];
    createdAt = json['createdAt'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};

    data['title'] = title ?? "";
    data['content'] = content ?? "";
    data['isPinned'] = pinned ?? false;

    return data;
  }

  NoteEntity toNoteEntity() => NoteEntity(
    id: id ?? -1,
    title: title ?? "",
    content: content ?? "",
    pinned: pinned ?? false,
    createdAt: createdAt ?? " ",
  );

  NoteModel toNoteModel() {
    return NoteModel(
      id: id,
      title: title,
      content: content,
      pinned: pinned,
      createdAt: createdAt,
    );
  }
}
