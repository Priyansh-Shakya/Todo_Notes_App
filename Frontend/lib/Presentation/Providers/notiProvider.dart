import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Data/DataSources/RemoteSources/notificationService.dart';
import 'package:todo_notes/Presentation/Providers/authProvider.dart';
import 'package:todo_notes/Presentation/Screens/notifications/notiData.dart';
import 'package:todo_notes/Presentation/Notifiers/notificationNotifier.dart';

final notificcationServiceProvider = Provider<Notificationservice>((ref) {
  final dio = ref.watch(dioProvider);
  return Notificationservice(dio: dio);
});

final notificationNotifierProvider =
    AsyncNotifierProvider<NotificationNotifier, List<NotificationData>>(
      NotificationNotifier.new,
    );
