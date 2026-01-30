import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Data/Models/notiModel.dart';
import 'package:todo_notes/Presentation/Providers/notiProvider.dart';

class CacheNoti {
  static List<NotificationModel>? notiList;
}

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

  /// Optimistic add (KEEP temp taskId)
  Future<void> addLocal(NotificationModel noti) async {
    final prev = state.value ?? [];

    //into cache
    CacheNoti.notiList = prev;
    CacheNoti.notiList?.add(noti);

    // state = AsyncValue.data([...prev, noti]);

    debugPrint("Noti taskId: ${noti.taskId}");

    try {
      final service = ref.read(notificcationServiceProvider);
      await service.sendTaskNotification(noti, noti.taskId!);
    } catch (_) {
      // rollback
      state = AsyncValue.data(
        prev.where((n) => n.taskId != noti.taskId).toList(),
      );
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
