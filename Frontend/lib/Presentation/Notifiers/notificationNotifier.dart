import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Data/Models/notiModel.dart';
import 'package:todo_notes/Presentation/Providers/notiProvider.dart';
import 'package:todo_notes/Presentation/Screens/notifications/notiData.dart';

class NotificationNotifier extends AsyncNotifier<List<NotificationData>> {
  @override
  FutureOr<List<NotificationData>> build() {
    return [];
  }

  Future<List<NotificationModel>> preFetchNotifications() async {
    final service = ref.watch(notificcationServiceProvider);
    final noti = await service.getTaskNotification();
    return noti;
  }
}
