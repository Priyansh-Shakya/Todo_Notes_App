import 'package:todo_notes/Data/Models/notiModel.dart';


enum NotificationType { dateBased, weekly }

class NotificationData {
  String? pickedDate;
  final Set<int> selectedDays;
  final List<String> pickedTimes;
  final List<String> displayTimes;
  
  NotificationData({
    this.pickedDate,
    Set<int>? selectedDays,
    List<String>? pickedTimes,
    List<String>? displayTimes,
  }) : selectedDays = selectedDays ?? {},
       pickedTimes = pickedTimes ?? [],
       displayTimes = displayTimes ?? [];

  NotificationModel toNotificationModel(NotificationType type) {
    if (type == NotificationType.dateBased && pickedDate == null) {
      throw StateError('pickedDate is required for dateBased notification');
    }

    return NotificationModel(
      scheduleType: type == NotificationType.dateBased ? 'date' : 'weekly',
      scheduledDate: type == NotificationType.dateBased ? pickedDate! : null,
      weekdays: type == NotificationType.weekly ? selectedDays.toList() : null,
      times: pickedTimes,
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
}
