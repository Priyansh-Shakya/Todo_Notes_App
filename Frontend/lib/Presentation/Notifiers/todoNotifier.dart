import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Data/Repositories/todoRepo.dart';
import 'package:todo_notes/Domain/Entities/todoEntity.dart';
import 'package:todo_notes/Presentation/Providers/todoProvider.dart';

class TodoNotifier extends AsyncNotifier<List<TodoEntity>> {
  late final TodoRepo repo;

  @override
  FutureOr<List<TodoEntity>> build() async {
    repo = ref.watch(todoRepoProvider);

    final todo = await repo.getAll();
    return todo;
  }

  Future<void> refreshList() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async => await repo.getAll());
  }

  Future<void> createTodo({required TodoEntity payload}) async {
    final current = state.value ?? [];
    final temp = payload.copyWith(id: -DateTime.now().microsecondsSinceEpoch);
    final updated = [temp, ...current];
    state = AsyncValue.data(updated);

    try {
      final created = await repo.writeT(todo: payload.toTodoModel());
      final replaced = [
        for (final n in state.value!)
          if (n.id == temp.id) created else n,
      ];
      state = AsyncValue.data(replaced);
    } catch (err, st) {
      state = AsyncError(err, st);
    }
  }

  Future<void> updateTodo({required TodoEntity todo, required int id}) async {
    final prev = state.value;
    if (prev == null) return;
    final temp = prev.map((e) => e.id == id ? todo : e).toList();
    state = AsyncValue.data(temp);

    try {
      await repo.updateT(todo: todo.toTodoModel(), id: id);
    } catch (err, st) {
      state = AsyncError(err, st);
    }
  }

  Future<void> deleteTodo({required int id}) async {
    final prev = state.value;
    if (prev == null) return;
    final temp = prev.where((e) => e.id != id).toList();
    state = AsyncValue.data(temp);

    try {
      await repo.deleteT(id: id);
    } catch (err, st) {
      state = AsyncError(err, st);
    }
  }
}
