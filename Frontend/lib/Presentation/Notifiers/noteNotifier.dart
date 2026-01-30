import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Data/Repositories/noteRepo.dart';
import 'package:todo_notes/Domain/Entities/noteEntity.dart';
import 'package:todo_notes/Presentation/Providers/todoProvider.dart';
import 'package:todo_notes/Supabase_Auth/Logic/authProvider.dart';

class NoteNotifier extends AsyncNotifier<List<NoteEntity>> {
  NoteRepo get repo => ref.watch(noteRepoProvider);

  @override
  FutureOr<List<NoteEntity>> build() async {
    final userId = ref.watch(userProvider.select((u) => u?.id));
    if (userId == null) {
      return const [];
    }
    final note = await repo.getAll();

    return sortNotes(note);
  }

  List<NoteEntity> sortNotes(List<NoteEntity> notes) {
    final pinned = notes.where((e) => e.pinned == true);
    final notPinned = notes.where((e) => e.pinned == false);

    return [...pinned, ...notPinned];
  }

  Future<void> refreshList() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await repo.getAll());
  }

  void clear() {
    state = const AsyncValue.data([]);
  }

  Future<void> writeNote({required NoteEntity note}) async {
    final current = state.value ?? [];
    final temp = note.copyWith(id: -DateTime.now().microsecondsSinceEpoch);
    final updated = sortNotes([temp, ...current]);
    state = AsyncValue.data(updated);

    try {
      final created = await repo.writeN(note: note.toNoteModel());
      final replaced = [
        for (final n in state.value!)
          if (n.id == temp.id) created else n,
      ];
      state = AsyncValue.data(sortNotes(replaced));
    } catch (err, st) {
      state = AsyncError(err, st);
      state = AsyncValue.data(current);
    }
  }

  Future<void> updateNote({required NoteEntity note, required int id}) async {
    final previous = state.value;
    if (previous == null) return;

    // 1️⃣ Optimistic update (keep sorting invariant)
    state = AsyncData(
      sortNotes(previous.map((e) => e.id == id ? note : e).toList()),
    );

    try {
      // 2️⃣ API call
      final server = await repo.updateN(note: note.toNoteModel(), id: id);

      // 3️⃣ MERGE server response with local note
      final merged = note.copyWith(
        title: server.title,
        content: server.content,
        pinned: server.pinned,
        // id & createdAt stay from `note`
      );

      // 4️⃣ Update CURRENT state (not prev!)
      state = AsyncData(
        sortNotes(state.value!.map((e) => e.id == id ? merged : e).toList()),
      );
    } catch (err, st) {
      // 5️⃣ Rollback
      state = AsyncError(err, st);
      state = AsyncData(previous);
    }
  }

  Future<void> deleteNote({required List<int> ids}) async {
    final prev = state.value;
    if (prev == null) return;
    final local = prev.where((element) => !ids.contains(element.id)).toList();
    state = AsyncValue.data(local);

    try {
      await repo.deleteN(ids: ids);
    } catch (err, st) {
      state = AsyncError(err, st);
      state = AsyncValue.data(prev);
    }
  }
}
