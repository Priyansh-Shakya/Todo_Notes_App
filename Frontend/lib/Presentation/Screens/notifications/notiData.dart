import 'package:flutter/material.dart';
import 'package:todo_notes/Data/Models/notiModel.dart';

enum NotificationType { dateBased, weekly }

class NotificationData {
  DateTime? pickedDate;
  final Set<int> selectedDays;
  final List<TimeOfDay> pickedTimes;

  NotificationData({
    this.pickedDate,
    Set<int>? selectedDays,
    List<TimeOfDay>? pickedTimes,
  }) : selectedDays = selectedDays ?? {},
       pickedTimes = pickedTimes ?? [];

  NotificationModel toNotificationModel(NotificationType type) {
    if (type == NotificationType.dateBased && pickedDate == null) {
      throw StateError('pickedDate is required for dateBased notification');
    }

    return NotificationModel(
      scheduleType: type == NotificationType.dateBased ? 'date' : 'weekly',
      scheduledDate: type == NotificationType.dateBased
          ? pickedDate!.toIso8601String()
          : null,
      weekdays: type == NotificationType.weekly ? selectedDays.toList() : null,
      times: pickedTimes.map(_formatTime).toList(),
      timezone: DateTime.now().timeZoneName,
      isActive: true,
    );
  }

  bool isReady(NotificationType type) {
    if (type == NotificationType.weekly) {
      return selectedDays.isNotEmpty && pickedTimes.isNotEmpty;
    }
    if (type == NotificationType.dateBased) {
      return pickedDate != null && pickedTimes.isNotEmpty;
    }
    return false;
  }

  static String _formatTime(TimeOfDay time) {
    final hour = time.hour.toString().padLeft(2, '0');
    final minute = time.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}
