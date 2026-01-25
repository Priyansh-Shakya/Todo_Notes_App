class NotificationModel {
  int? taskId;
  final String scheduleType; // "date" or "weekly"
  final List<String> times;
  final String timezone;
  final bool isActive;

  // optional fields
  final String? scheduledDate; // only for "date"
  final List<int>? weekdays; // only for "weekly"

  NotificationModel({
    this.taskId,
    required this.scheduleType,
    required this.times,
    required this.timezone,
    required this.isActive,
    this.scheduledDate,
    this.weekdays,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      taskId: json['task_id'],
      scheduleType: json['schedule_type'],
      times: List<String>.from(json['times']),
      timezone: json['timezone'],
      isActive: json['is_active'],
      scheduledDate: json['scheduled_date'],
      weekdays: json['weekdays'] != null
          ? List<int>.from(json['weekdays'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = {
      'task_id': taskId,
      'schedule_type': scheduleType,
      'times': times,
      'timezone': timezone,
      'is_active': isActive,
    };

    if (scheduleType == 'date') {
      data['scheduled_date'] = scheduledDate;
    }

    if (scheduleType == 'weekly') {
      data['weekdays'] = weekdays;
    }

    return data;
  }

  NotificationModel copyWith({
    int? taskId,
    String? scheduleType,
    List<String>? times,
    String? timezone,
    bool? isActive,
    String? scheduledDate,
    List<int>? weekdays,
  }) {
    return NotificationModel(
      taskId: taskId ?? this.taskId,
      scheduleType: scheduleType ?? this.scheduleType,
      times: times ?? this.times,
      timezone: timezone ?? this.timezone,
      isActive: isActive ?? this.isActive,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      weekdays: weekdays ?? this.weekdays,
    );
  }
}
