import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Data/Models/notiModel.dart';
import 'package:todo_notes/Presentation/Providers/notiProvider.dart';

class NotificationNotifier extends AsyncNotifier<List<NotificationModel>> {
  @override
  FutureOr<List<NotificationModel>> build() {
    return [];
  }

  Future<void> refreshList() async {
    state = AsyncLoading();
    final service = ref.read(notificcationServiceProvider);
    final noti = await service.getTaskNotification();
    state = AsyncValue.data(noti);
  }

  void clear() {
    state = const AsyncValue.data([]);
  }

  Future<void> preFetchNotifications() async {
    final service = ref.read(notificcationServiceProvider);
    final noti = await service.getTaskNotification();
    state = AsyncValue.data(noti);
  }

  /// Optimistic add-or-update (backend is upsert, so local state must match)
  Future<void> upsertLocal(NotificationModel noti) async {
    final prev = state.value ?? [];

    final exists = prev.any((n) => n.taskId == noti.taskId);
    final temp = exists
        ? prev.map((n) => n.taskId == noti.taskId ? noti : n).toList()
        : [...prev, noti];

    state = AsyncValue.data(temp);

    try {
      final service = ref.read(notificcationServiceProvider);
      await service.sendTaskNotification(noti, noti.taskId!);
    } catch (err) {
      // rollback to the exact prior state — not a derived filter
      state = AsyncValue.data(prev);
    }
  }

  /// 🔥 THE IMPORTANT PART
  // void replaceTaskId(int tempId, int realId) {
  //   final prev = state.value ?? [];

  //   state = AsyncValue.data([
  //     for (final n in prev)
  //       if (n.taskId == tempId) n.copyWith(taskId: realId) else n,
  //   ]);
  // }
}
