import 'package:todo_notes/Data/Models/notiModel.dart';
import 'package:todo_notes/Domain/Entities/todoEntity.dart';

//-------------- WRITE , UPDATE , DELETE Model -----------------------------

class TodoModel {
  String? task;
  bool? isComplete;
  int? id;
  String? createdAt;

  TodoModel({this.task, this.isComplete, this.id, this.createdAt});

  TodoModel.fromJson(Map<String, dynamic> json) {
    task = json['task'];
    isComplete = json['is_complete'];
    id = json['id'];
    createdAt = json['created_at'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['task'] = task;
    data['is_complete'] = isComplete;
    data['id'] = id;
    data['created_at'] = createdAt;
    return data;
  }

  TodoEntity toTodoEntity() => TodoEntity(
    id: id ?? -1,
    task: task ?? " ",
    isComplete: isComplete ?? false,
    createdAt: " ",
  );
}

// ----------------------READ Model----------------
class TodoReadModel {
  String? task;
  bool? isComplete;
  int? id;
  String? createdAt;
  List<NotificationModel>? notifications;

  TodoReadModel({
    this.task,
    this.isComplete,
    this.id,
    this.createdAt,
    this.notifications,
  });

  TodoReadModel.fromJson(Map<String, dynamic> json) {
    task = json['task'];
    isComplete = json['is_complete'];
    id = json['id'];
    createdAt = json['created_at'];
    if (json['notifications'] != null) {
      notifications = <NotificationModel>[];
      json['notifications'].forEach((v) {
        notifications!.add(NotificationModel.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['task'] = task;
    data['is_complete'] = isComplete;
    data['id'] = id;
    data['created_at'] = createdAt;
    if (notifications != null) {
      data['notifications'] = notifications!.map((v) => v.toJson()).toList();
    }
    return data;
  }

  TodoReadEntity toTodoReadEntity() => TodoReadEntity(
    id: id ?? -1,
    task: task ?? " ",
    isComplete: isComplete ?? false,
    createdAt: " ",
    notification: notifications ?? [], //add noti to entity
  );

  TodoReadModel copyWith({
    String? task,
    bool? isComplete,
    int? id,
    String? createdAt,
    List<NotificationModel>? notifications,
  }) {
    return TodoReadModel(
      task: task ?? this.task,
      isComplete: isComplete ?? this.isComplete,
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      notifications: notifications ?? this.notifications,
    );
  }
}
