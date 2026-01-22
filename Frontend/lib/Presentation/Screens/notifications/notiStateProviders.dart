import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:todo_notes/Presentation/Screens/notifications/notiData.dart';

final weeklyNoti = StateProvider<NotificationType>(
  (ref) => NotificationType.weekly,
);
