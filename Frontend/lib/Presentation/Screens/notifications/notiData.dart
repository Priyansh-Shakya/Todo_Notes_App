import 'package:flutter/material.dart';

enum NotificationType { dateBased, weekly }

class NotificationData {
  DateTime? pickedDate; // optional
  final Set<int> selectedDays; // always exists
  final List<TimeOfDay> pickedTimes;

  NotificationData({
    this.pickedDate,
    Set<int>? selectedDays,
    List<TimeOfDay>? pickedTimes,
  }) : selectedDays = selectedDays ?? {},
       pickedTimes = pickedTimes ?? [];

  bool isReady(NotificationType type) {
    if (type == NotificationType.weekly) {
      return selectedDays.isNotEmpty && pickedTimes.isNotEmpty;
    }

    if (type == NotificationType.dateBased) {
      return pickedDate != null && pickedTimes.isNotEmpty;
    }

    return false;
  }
}
