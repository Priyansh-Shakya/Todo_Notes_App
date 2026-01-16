import 'package:todo_notes/Data/DataSources/RemoteSources/noteApiService.dart';
import 'package:todo_notes/Data/Models/notesModel.dart';
import 'package:todo_notes/Domain/Entities/noteEntity.dart';

class NoteRepo {
  final NoteService api;
  NoteRepo({required this.api});

  Future<List<NoteEntity>> getAll() async {
    final model = await api.readAllNotes();
    return model.map((e) => e.toNoteEntity()).toList();
  }

  Future<NoteEntity> writeN({required NoteModel note}) async {
    final model = await api.writeNote(note: note);
    return model.toNoteEntity();
  }

  Future<NoteEntity> updateN({required NoteModel note, required int id}) async {
    final model = await api.updateNote(note: note, id: id);
    return model.toNoteEntity();
  }

  Future<void> deleteN({required List<int> ids}) async {
    return await api.deleteNote(ids: ids);
  }
}
