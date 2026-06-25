import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:todo_notes/Data/Models/notiModel.dart';
import 'package:todo_notes/Data/Repositories/todoRepo.dart';
import 'package:todo_notes/Domain/Entities/todoEntity.dart';
import 'package:todo_notes/Presentation/Providers/notiProvider.dart';
import 'package:todo_notes/Presentation/Providers/todoProvider.dart';
import 'package:todo_notes/Supabase_Auth/Logic/authProvider.dart';

//? For TimeZone
Future<String> getLocalTimeZone() async {
  final timezoneInfo = await FlutterTimezone.getLocalTimezone();
  String timezone = timezoneInfo.identifier;
  debugPrint('TIMEZONE: $timezone');
  return timezone;
}

class TodoNotifier extends AsyncNotifier<List<TodoEntity>> {
  TodoRepo get repo => ref.watch(todoRepoProvider);

  @override
  Future<List<TodoEntity>> build() async {
    final user = ref.watch(userProvider);

    // 👇 HARD EXIT, zero side effects
    if (user == null) {
      return const [];
    }

    final repo = ref.watch(todoRepoProvider);

    // optional: only for authenticated users
    await ref
        .read(notificationNotifierProvider.notifier)
        .preFetchNotifications();

    return repo.getAll();
  }

  Future<void> refreshList() async {
    state = AsyncLoading();
    state = await AsyncValue.guard(() => repo.getAll());
  }

  void clear() {
    state = const AsyncValue.data([]);
  }

  Future<void> createTodo({
    NotificationModel? noti,
    required TodoEntity payload,
  }) async {
    final prev = state.value ?? [];

    final tempId = -DateTime.now().microsecondsSinceEpoch;
    final tempTodo = payload.copyWith(id: tempId);

    // 1️⃣ optimistic todo
    state = AsyncValue.data([tempTodo, ...prev]);

    try {
      final created = await repo.writeT(todo: payload.toTodoModel());

      // 3️⃣ replace todo
      state = AsyncValue.data([
        for (final t in state.value!)
          if (t.id == tempId) created else t,
      ]);

      // 2️⃣ optimistic notification
      if (noti != null) {
        final tz = await getLocalTimeZone();
        noti = noti.copyWith(timezone: tz);
        ref
            .read(notificationNotifierProvider.notifier)
            .upsertLocal(noti.copyWith(taskId: created.id));
      }
    } catch (_) {
      // rollback everything
      state = AsyncValue.data(prev);
    }
  }

  Future<void> updateTodo({required TodoEntity todo, required int id}) async {
    final prev = state.value;
    if (prev == null) return;
    final temp = prev.map((e) => e.id == id ? todo : e).toList();
    debugPrint("Update Temp: $temp");
    debugPrint("Update Todo: $todo");
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
